//
//  TNKImagePickerController.m
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import "TNKImagePickerController.h"

@import Photos;

#import "TNKCollectionsTitleButton.h"
#import "TNKCollectionPickerController.h"
#import "TNKAssetImageView.h"
#import "TNKMomentHeaderView.h"
#import "TNKAssetsDetailViewController.h"
#import "NSDate+TNKFormattedDay.h"
#import "UIImage+TNKIcons.h"
#import "TNKAssetSelection.h"
#import "TNKCollectionViewController.h"
#import "TNKCollectionViewController_Private.h"
#import "TNKUnauthorizedViewController.h"


#define TNKObjectSpacing 1.0


@interface TNKImagePickerController () <UIPopoverPresentationControllerDelegate, TNKCollectionPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerRestoration, TNKAssetSelectionDelegate>
{
	PHFetchOptions *_assetFetchOptions;
	TNKAssetSelection *_assetSelection;
    
    UIButton *_collectionButton;
    NSInteger _pasteChangeCount;
    
    TNKCollectionPickerController *_collectionPicker;
	
	NSMutableDictionary <NSString *, NSData *>*_originalGIFData;
}

@property (nonatomic, nullable) TNKCollectionPickerController *collectionPicker;

@property (nonatomic, nonnull) TNKCollectionViewController *collectionViewController;

@end

@implementation TNKImagePickerController

#pragma mark - Properties

- (TNKCollectionPickerController *)collectionPicker {
	if (_collectionPicker != nil) {
		return _collectionPicker;
	} else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
		_collectionPicker = [[TNKCollectionPickerController alloc] init];
		_collectionPicker.assetFetchOptions = _assetFetchOptions;
		_collectionPicker.delegate = self;
		return _collectionPicker;
	} else {
		return nil;
	}
}

- (void)setPickerDelegate:(id<TNKImagePickerControllerDelegate>)delegate {
	_pickerDelegate = delegate;
	
	[self _updateDoneButton];
}

- (void)setMediaTypes:(NSArray<NSString *> *)mediaTypes {
	_mediaTypes = mediaTypes;
	
	[self _reloadAssetFetchOptions];
}

- (void)_reloadAssetFetchOptions {
    NSMutableArray *assetMediaTypes = [NSMutableArray new];
    if ([self.mediaTypes containsObject:(id)kUTTypeImage]) {
        [assetMediaTypes addObject:@(PHAssetMediaTypeImage)];
    }
    if ([self.mediaTypes containsObject:(id)kUTTypeVideo]) {
        [assetMediaTypes addObject:@(PHAssetMediaTypeVideo)];
    }
    if ([self.mediaTypes containsObject:(id)kUTTypeAudio]) {
        [assetMediaTypes addObject:@(PHAssetMediaTypeAudio)];
    }
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType IN %@", assetMediaTypes];
	options.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES] ];
    options.includeAllBurstAssets = NO;
    
    _assetFetchOptions = options;
	
	_collectionViewController.assetFetchOptions = _assetFetchOptions;
	self.collectionPicker.assetFetchOptions = _assetFetchOptions;
}

- (void)setAssetCollection:(PHAssetCollection *)assetCollection {
    _assetCollection = assetCollection;
	
	if (_assetCollection == nil) {
		self.collectionViewController = self.momentsViewController;
	} else {
		
		TNKAssetCollectionViewFlowLayoutType assetCollectionFlowType;
		
		switch (assetCollection.assetCollectionType) {
			case PHAssetCollectionTypeSmartAlbum:
				assetCollectionFlowType = TNKAssetCollectionViewFlowLayoutTypeInverted;
				break;
			default:
				assetCollectionFlowType = TNKAssetCollectionViewFlowLayoutTypeDefault;
				break;
		}
		
		self.collectionViewController = [[TNKAssetCollectionViewController alloc] initWithAssetCollection:_assetCollection flowlayoutType:assetCollectionFlowType];
	}
    
    [self _updateForAssetCollection];
    [self _updateSelectAllButton];
}

- (void)setCollectionViewController:(TNKCollectionViewController *)collectionViewController {
	_collectionViewController = collectionViewController;
	_collectionViewController.assetFetchOptions = _assetFetchOptions;
	_collectionViewController.assetSelection = _assetSelection;
	
	[self setViewControllers:@[ collectionViewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
	
	[self _updateLayoutGuides];
}

- (TNKCollectionViewController *)momentsViewController {
	if (_momentsViewController == nil) {
		_momentsViewController = [[TNKMomentsViewController alloc] init];
	}
	
	return _momentsViewController;
}

- (void)_updateForAssetCollection
{
	if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
		if (_assetCollection == nil) {
			self.title = NSLocalizedString(@"Moments", nil);
		} else {
			self.title = _assetCollection.localizedTitle;
		}
		[_collectionButton setTitle:self.title forState:UIControlStateNormal];
		[_collectionButton sizeToFit];
		self.navigationItem.titleView = _collectionButton;
	} else {
		self.title = nil;
		self.navigationItem.titleView = nil;
	}
}

- (void)setHideSelectAll:(BOOL)hideSelectAll {
	_hideSelectAll = hideSelectAll;
	[self _updateToolbarItems:false];
}

- (void)_updateDoneButton {
    _doneButton.enabled = _assetSelection.count > 0;
	
	NSString *title = nil;
	
	if ([self.pickerDelegate respondsToSelector:@selector(imagePickerControllerTitleForDoneButton:)]) {
		title = [self.pickerDelegate imagePickerControllerTitleForDoneButton:self];
	} else if (_assetSelection.count > 0) {
		title = [NSString localizedStringWithFormat:NSLocalizedString(@"Done (%d)", @"Title for photo picker done button (short)."), _assetSelection.count];
	} else {
		title = NSLocalizedString(@"Done", nil);
	}
	
	_doneButton.title = title;
}

- (void)_updateSelectAllButton {
	if ([self.collectionViewController isKindOfClass:[TNKAssetCollectionViewController class]]) {
		_selectAllButton.enabled = YES;
		__block BOOL allSelected = YES;
		
		PHFetchResult *fetchResult = ((TNKAssetCollectionViewController *)self.collectionViewController).fetchResult;
		NSArray *selectedAssets = _assetSelection.assets;
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
				allSelected &= [selectedAssets containsObject:asset];
				*stop = !allSelected;
			}];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				if (allSelected) {
					_selectAllButton.title = NSLocalizedString(@"Deselect All", @"Photo picker button");
					_selectAllButton.action = @selector(deselectAll:);
				} else {
					_selectAllButton.title = NSLocalizedString(@"Select All", @"Photo picker button");
					_selectAllButton.action = @selector(selectAll:);
				}
			});
		});
	} else {
		_selectAllButton.enabled = NO;
		_selectAllButton.title = NSLocalizedString(@"Select All", @"Photo picker button");
		_selectAllButton.action = @selector(selectAll:);
	}
}

- (void)_updateToolbarItems:(BOOL)animated {
    NSMutableArray *items = [NSMutableArray new];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [items addObject:_cameraButton];
    }
    
    if ([[UIPasteboard generalPasteboard] containsPasteboardTypes:@[(NSString *)kUTTypeImage]] && [UIPasteboard generalPasteboard].changeCount != _pasteChangeCount) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            space.width = 20.0;
            [items addObject:space];
        }
        [items addObject:_pasteButton];
    }
    
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
	
	if (!self.hideSelectAll) {
		[items addObject:_selectAllButton];
	}
    
    [self setToolbarItems:items animated:animated];
}

- (void)_updateLayoutGuides {
	if (self.isViewLoaded) {
		self.collectionViewController.layoutInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
	}
}

- (nullable NSData *)originalGIFDataForAsset:(PHAsset *)asset {
	return _originalGIFData[asset.localIdentifier];
}

- (void)_setOriginalGIFData:(NSData *)data forAssetIdentifier:(NSString *)localIdentifier {
	_originalGIFData[localIdentifier] = data;
}


#pragma mark - Initialization

- (void)_init
{
	_originalGIFData = [NSMutableDictionary new];
	
	_assetSelection = [[TNKAssetSelection alloc] init];
	_assetSelection.delegate = self;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetSelectionDidChange:) name:TNKAssetSelectionDidChangeNotification object:_assetSelection];
	
	_mediaTypes = @[ (NSString *)kUTTypeImage ];
	[self _reloadAssetFetchOptions];
	
    _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = _cancelButton;
    
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = _doneButton;
    
    _cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    
    _pasteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Paste", @"Button to paste a photo") style:UIBarButtonItemStylePlain target:self action:@selector(paste:)];
    
    _selectAllButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)];
	
	[self collectionPicker]; // agressively load the picker if we can
	
    self.hidesBottomBarWhenPushed = NO;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _collectionButton = [TNKCollectionsTitleButton buttonWithType:UIButtonTypeSystem];
    [_collectionButton addTarget:self action:@selector(changeCollection:) forControlEvents:UIControlEventTouchUpInside];
    _collectionButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _collectionButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 3.0, 0.0, 0.0);
    [_collectionButton setImage:[[UIImage tnk_navDisclosureIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_collectionButton sizeToFit];
    self.navigationItem.titleView = _collectionButton;
    
    [self _updateForAssetCollection];
    [self _updateDoneButton];
    [self _updateSelectAllButton];
    [self _updateToolbarItems:NO];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteboardChanged:) name:UIPasteboardChangedNotification object:[UIPasteboard generalPasteboard]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
	
	
	self.automaticallyAdjustsScrollViewInsets = false;
}

- (instancetype)init
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
	if (self) {
		[self _init];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showAsset:)];
	recognizer.minimumPressDuration = 0.5;
	[self.view addGestureRecognizer:recognizer];
	
	
	if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
		UIViewController *viewController = [[UIViewController alloc] init];
		viewController.view.backgroundColor = [UIColor whiteColor];
		[self setViewControllers:@[ viewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
	}
	
	[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (status == PHAuthorizationStatusAuthorized) {
				self.assetCollection = nil;
			} else {
				TNKUnauthorizedViewController *viewController = [[TNKUnauthorizedViewController alloc] init];
				
				[self setViewControllers:@[ viewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
			}
		});
	}];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
    UIFont *font = self.navigationController.navigationBar.titleTextAttributes[NSFontAttributeName];
    if (font != nil) {
        _collectionButton.titleLabel.font = font;
        [_collectionButton sizeToFit];
    }
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	[self _updateLayoutGuides];
}


#pragma mark - Actions

- (IBAction)done:(id)sender {
    if ([self.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingAssets:)]) {
        [self.pickerDelegate imagePickerController:self didFinishPickingAssets:self.selectedAssets];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancel:(id)sender {
    if ([self.pickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.pickerDelegate imagePickerControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.mediaTypes = self.mediaTypes;
    
    UIViewController *viewController = imagePicker;
    if ([self.pickerDelegate respondsToSelector:@selector(imagePickerController:willDisplayCameraViewController:)]) {
        viewController = [self.pickerDelegate imagePickerController:self willDisplayCameraViewController:imagePicker];
    }
    
    if (viewController != nil) {
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (IBAction)paste:(id)sender {
    _pasteChangeCount = [UIPasteboard generalPasteboard].changeCount;
	
	for (NSInteger index = 0; index < [UIPasteboard generalPasteboard].numberOfItems; index++) {
		NSIndexSet *itemSet = [NSIndexSet indexSetWithIndex:index];
		
		BOOL validAsset = NO;
		
		NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"com.apple.mobileslideshow.asset.localidentifier" inItemSet:itemSet].firstObject;
		if ([data isKindOfClass:[NSData class]]) {
			NSString *localIdentifier = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			if (localIdentifier != nil) {
				PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[ localIdentifier ] options:nil];
				
				if (result.firstObject != nil) {
					[self selectAsset:result.firstObject];
					validAsset = YES;
				}
			}
		}
		
		
		if (!validAsset) {
			NSData *gifData = [[UIPasteboard generalPasteboard] dataForPasteboardType:(NSString *)kUTTypeGIF inItemSet:itemSet].firstObject;
			if ([gifData isKindOfClass:[NSData class]]) {
				UIImage *image = [[UIImage alloc] initWithData:gifData];
				__weak __typeof(self)self_weak = self;
				[self _addImages:@[ image ] completion:^(NSArray *localIdentifiers) {
					NSString *identifier = localIdentifiers.firstObject;
					if (identifier != nil) {
						[self_weak _setOriginalGIFData:gifData forAssetIdentifier:identifier];
					}
				}];
				
				validAsset = YES;
			}
		}
		
		
		if (!validAsset) {
			NSData *imageData = [[UIPasteboard generalPasteboard] dataForPasteboardType:(NSString *)kUTTypeImage inItemSet:itemSet].firstObject;
			if ([imageData isKindOfClass:[NSData class]]) {
				UIImage *image = [[UIImage alloc] initWithData:imageData];
				[self _addImages:@[ image ] completion:nil];
				
				validAsset = YES;
			}
		}
	}
    
    [self _updateToolbarItems:YES];
}

- (IBAction)selectAll:(id)sender {
	if ([self.collectionViewController isKindOfClass:[TNKAssetCollectionViewController class]]) {
		TNKAssetCollectionViewController *viewController = (TNKAssetCollectionViewController *)self.collectionViewController;
		PHFetchResult *fetchResult = viewController.fetchResult;
		
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
			
			[fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
				[assets addObject:asset];
			}];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[_assetSelection addAssets:assets];
			});
		});
	}
}

- (IBAction)deselectAll:(id)sender
{
	if ([self.collectionViewController isKindOfClass:[TNKAssetCollectionViewController class]]) {
		TNKAssetCollectionViewController *viewController = (TNKAssetCollectionViewController *)self.collectionViewController;
		PHFetchResult *fetchResult = viewController.fetchResult;
		
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
			
			[fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
				[assets addObject:asset];
			}];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[_assetSelection removeAssets:assets];
			});
		});
	}
}

- (void)showAsset:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state != UIGestureRecognizerStateBegan) {
		return;
	}
	
	CGPoint location = [recognizer locationInView:self.collectionViewController.collectionView];
	PHAsset *asset = [self.collectionViewController assetAtPoint:location];
	
	if (asset != nil){
		TNKAssetsDetailViewController *detailViewController = [[TNKAssetsDetailViewController alloc] init];
		detailViewController.assetSelection = _assetSelection;
		detailViewController.assetCollection = self.assetCollection;
		detailViewController.assetFetchOptions = _assetFetchOptions;
		[detailViewController showAsset:asset];
		
		if ([self.pickerDelegate respondsToSelector:@selector(imagePickerController:willDisplayDetailViewController:forAsset:)]) {
			UIViewController *viewController = [self.pickerDelegate imagePickerController:self willDisplayDetailViewController:detailViewController forAsset:asset];
			
			if (viewController != nil) {
				[self.navigationController pushViewController:viewController animated:YES];
			}
		} else {
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
	}
}

- (IBAction)changeCollection:(id)sender {
    if (_assetSelection.count > 0) {
        PHAssetCollection *collection = [PHAssetCollection transientAssetCollectionWithAssets:_assetSelection.assets title:NSLocalizedString(@"Selected", @"Collection name for selected photos")];
        self.collectionPicker.additionalAssetCollections = @[ collection ];
    } else {
        self.collectionPicker.additionalAssetCollections = @[];
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.collectionPicker];
    navigationController.restorationIdentifier = @"TNKCollectionPickerController.NavigationController";
    navigationController.restorationClass = [self class];
    navigationController.navigationBarHidden = YES;
    
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    navigationController.popoverPresentationController.sourceView = _collectionButton;
    navigationController.popoverPresentationController.sourceRect = _collectionButton.bounds;
    navigationController.popoverPresentationController.delegate = self;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_addImages:(NSArray<UIImage *> *)images completion:(nullable void(^)(NSArray *localIdentifiers))completion {
    NSMutableArray *localIdentifiers = [NSMutableArray new];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        for (UIImage *image in images) {
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            NSString *localIdentifier = createAssetRequest.placeholderForCreatedAsset.localIdentifier;
            [localIdentifiers addObject:localIdentifier];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (error != nil) {
            NSLog(@"Error creating asset from pasteboard: %@", error);
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(nil);
			});
        } else if (success) {
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:localIdentifiers options:nil];
            
            NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
            [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [assets addObject:obj];
            }];
            
			if (assets.count > 0) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[_assetSelection addAssets:assets];
					
					if (completion != nil) {
						completion(localIdentifiers);
					}
				});
			} else {
				if (completion != nil) {
					dispatch_async(dispatch_get_main_queue(), ^{
						completion(nil);
					});
				}
			}
        }
    }];
}

- (void)_addVideos:(NSArray<NSURL *> *)videos {
    NSMutableArray *localIdentifiers = [NSMutableArray new];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        for (NSURL *videoURL in videos) {
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
            NSString *localIdentifier = createAssetRequest.placeholderForCreatedAsset.localIdentifier;
            [localIdentifiers addObject:localIdentifier];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (error != nil) {
            NSLog(@"Error creating asset from pasteboard: %@", error);
        } else if (success) {
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:localIdentifiers options:nil];
            
            NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
            [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [assets addObject:obj];
            }];
            
            if (assets.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_assetSelection addAssets:assets];
                });
            }
        }
    }];
}


#pragma mark - Notifications

- (void)pasteboardChanged:(NSNotification *)notification {
    [self _updateToolbarItems:YES];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    // UIPasteboardChangedNotification is not called when we are in the background during the change
    [self _updateToolbarItems:NO];
}

- (void)assetSelectionDidChange:(NSNotification *)notification {
	[self _updateDoneButton];
	[self _updateSelectAllButton];
}


#pragma mark - TNKCollectionPickerControllerDelegate

- (void)collectionPicker:(TNKCollectionPickerController *)collectionPicker didSelectCollection:(PHAssetCollection *)collection {
    self.assetCollection = collection;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    
    if (image != nil) {
        [self _addImages:@[image] completion:nil];
    } else if (videoURL != nil) {
        [self _addVideos:@[videoURL]];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - State Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.mediaTypes forKey:@"mediaTypes"];
    [coder encodeObject:self.assetCollection.localIdentifier forKey:@"assetCollection"];
    [coder encodeObject:[_assetSelection.assets valueForKey:@"localIdentifier"] forKey:@"selectedAssets"];
    [coder encodeObject:self.collectionPicker forKey:@"collectionPicker"];
    [coder encodeObject:_collectionPicker.navigationController forKey:@"collectionPickerNavigationController"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    self.mediaTypes = [coder decodeObjectForKey:@"mediaTypes"];
    
    NSString *assetCollectionIdentifier = [coder decodeObjectForKey:@"assetCollection"];
    if (assetCollectionIdentifier != nil) {
        self.assetCollection = [[PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[ assetCollectionIdentifier ] options:nil] firstObject];
    }
    
    NSArray *selectedAssetsIdentifiers = [coder decodeObjectForKey:@"selectedAssets"];
    if ([selectedAssetsIdentifiers isKindOfClass:[NSArray class]]) {
        NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
        for (PHAsset *asset in [PHAsset fetchAssetsWithLocalIdentifiers:selectedAssetsIdentifiers options:nil]) {
            [assets addObject:asset];
        }
        [_assetSelection addAssets:assets];
    }
    
    TNKCollectionPickerController *collectionPicker = [coder decodeObjectForKey:@"collectionPicker"];
    if (collectionPicker != nil) {
        _collectionPicker = collectionPicker;
        self.collectionPicker.assetFetchOptions = _assetFetchOptions;
        if (_assetSelection.count > 0) {
            PHAssetCollection *collection = [PHAssetCollection transientAssetCollectionWithAssets:_assetSelection.assets title:NSLocalizedString(@"Selected", @"Collection name for selected photos")];
            self.collectionPicker.additionalAssetCollections = @[ collection ];
        }
        self.collectionPicker.delegate = self;
    }
    
    UINavigationController *navigationController = [coder decodeObjectForKey:@"collectionPickerNavigationController"];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    navigationController.popoverPresentationController.sourceView = _collectionButton;
    navigationController.popoverPresentationController.sourceRect = _collectionButton.bounds;
    navigationController.popoverPresentationController.delegate = self;
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    if ([identifierComponents.lastObject isEqual:@"TNKCollectionPickerController.NavigationController"]) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[TNKCollectionPickerController alloc] init]];
        navigationController.restorationIdentifier = @"TNKCollectionPickerController.NavigationController";
        navigationController.restorationClass = self;
        navigationController.navigationBarHidden = YES;
        
        return navigationController;
    }
    
    return nil;
}


#pragma mark - TNKAssetSelectionDelegate

- (void)setSelectedAssets:(NSArray *)selectedAssets {
	_assetSelection.assets = selectedAssets;
}

- (NSArray *)selectedAssets {
	return _assetSelection.assets;
}

- (void)selectAsset:(PHAsset *)asset {
	[_assetSelection selectAsset:asset];
}

- (void)deselectAsset:(PHAsset *)asset {
	[_assetSelection deselectAsset:asset];
}

// mostly we just forward these to our own delegate

- (NSArray<PHAsset *> *)assetSelection:(TNKAssetSelection *)assetSelection shouldSelectAssets:(NSArray<PHAsset *> *)assets {
	NSArray<PHAsset *> *objects = assets;
	
	if ([self.pickerDelegate respondsToSelector:@selector(imagePickerController:shouldSelectAssets:)]) {
		objects = [self.pickerDelegate imagePickerController:self shouldSelectAssets:objects];
	}
	
	return objects;
}

- (void)assetSelection:(TNKAssetSelection *)assetSelection didSelectAssets:(NSArray<PHAsset *> *)assets {
	if ([self.pickerDelegate respondsToSelector:@selector(imagePickerController:didSelectAssets:)]) {
		[self.pickerDelegate imagePickerController:self didSelectAssets:assets];
	}
}

@end
