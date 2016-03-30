//
//  TNKImagePickerController.m
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import "TNKImagePickerController.h"

@import Photos;

#import "TNKImagePickerControllerBundle.h"
#import "TNKCollectionsTitleButton.h"
#import "TNKCollectionPickerController.h"
#import "TNKAssetCell.h"
#import "TNKAssetImageView.h"
#import "TNKMomentHeaderView.h"
#import "TNKCollectionViewFloatingHeaderFlowLayout.h"
#import "TNKAssetsDetailViewController.h"
#import "NSDate+TNKFormattedDay.h"


#define TNKObjectSpacing 1.0


@interface TNKImagePickerController () <UIPopoverPresentationControllerDelegate, TNKCollectionPickerControllerDelegate, PHPhotoLibraryChangeObserver, TNKAssetsDetailViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerRestoration>
{
    NSMutableOrderedSet *_selectedAssets;
    
    UIButton *_collectionButton;
    PHFetchResult *_fetchResult;
    PHFetchResult *_moments;
    NSCache *_momentCache;
    BOOL _windowLoaded;
    NSInteger _pasteChangeCount;
    
    TNKCollectionPickerController *_collectionPicker;
}

@end

@implementation TNKImagePickerController

#pragma mark - Properties

- (void)setDelegate:(id<TNKImagePickerControllerDelegate>)delegate {
	_delegate = delegate;
	
	[self _updateDoneButton];
}

- (void)setSelectedAssets:(NSArray *)selectedAssets {
    _selectedAssets = [NSMutableOrderedSet orderedSetWithArray:selectedAssets];

    [self _updateDoneButton];
    [self _updateSelectAllButton];
    [self _updateSelection];
}

- (NSArray *)selectedAssets {
    // -[NSOrderedSet array] is an array proxy so copy the result
    return [_selectedAssets.array copy];
}

- (void)addSelectedAssets:(NSOrderedSet *)objects {
    [_selectedAssets unionOrderedSet:objects];

	[self _updateSelection];
    [self _updateDoneButton];
    [self _updateSelectAllButton];
}

- (void)selectAsset:(PHAsset *)asset {
    if (_selectedAssets.count >= self.maximumSelectionCount && self.maximumSelectionCount != 0) {
        if (self.maximumSelectionCountExceededHandler) {
            self.maximumSelectionCountExceededHandler();
        }
        return;
    }
    
    [self addSelectedAssets:[NSOrderedSet orderedSetWithObject:asset]];
}

- (void)removeSelectedAssets:(NSOrderedSet *)objects {
    [_selectedAssets minusOrderedSet:objects];
	
	[self _updateSelection];
    [self _updateDoneButton];
    [self _updateSelectAllButton];
}

- (void)deselectAsset:(PHAsset *)asset {
    [self removeSelectedAssets:[NSOrderedSet orderedSetWithObject:asset]];
}

- (PHFetchOptions *)_assetFetchOptions {
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
    options.includeAllBurstAssets = NO;
    
    return options;
}

- (void)setAssetCollection:(PHAssetCollection *)assetCollection {
    _assetCollection = assetCollection;
    
    [self _updateForAssetCollection];
    [self _updateSelectAllButton];
}

- (void)_updateForAssetCollection
{
    if (_assetCollection == nil) {
        self.title = NSLocalizedString(@"Moments", nil);
    } else {
        self.title = _assetCollection.localizedTitle;
    }
    [_collectionButton setTitle:self.title forState:UIControlStateNormal];
    [_collectionButton sizeToFit];
    
    
    if (_assetCollection != nil) {
        _fetchResult = [PHAsset fetchAssetsInAssetCollection:_assetCollection options:[self _assetFetchOptions]];
        _moments = nil;
    } else {
        _fetchResult = nil;
        _moments = [PHAssetCollection fetchMomentsWithOptions:nil];
    }
    
    if (self.isViewLoaded) {
        [self.collectionView reloadData];
        
        if (_moments != nil) {
            [self.collectionView layoutIfNeeded];
            [self _scrollToBottomAnimated:NO];
        } else {
            [self.collectionView setContentOffset:CGPointMake(0.0, -self.topLayoutGuide.length) animated:NO];
        }
    }
}

- (void)_updateDoneButton {
    _doneButton.enabled = _selectedAssets.count > 0;
	
	NSString *title = nil;
	
	if ([self.delegate respondsToSelector:@selector(imagePickerControllerTitleForDoneButton:)]) {
		title = [self.delegate imagePickerControllerTitleForDoneButton:self];
	} else if (_selectedAssets.count > 0) {
		title = [NSString localizedStringWithFormat:NSLocalizedString(@"Done (%d)", @"Title for photo picker done button (short)."), _selectedAssets.count];
	} else {
		title = NSLocalizedString(@"Done", nil);
	}
	
	_doneButton.title = title;
}

- (void)_updateSelectAllButton {
    _selectAllButton.enabled = _moments == nil;
    __block BOOL allSelected = _moments == nil;
    
    PHFetchResult *fetchResult = _fetchResult;
    NSSet *selectedAssets = [_selectedAssets copy];
    
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
    
    [items addObject:_selectAllButton];
    
    [self setToolbarItems:items animated:animated];
}

- (void)_updateSelection {
	if (!self.isViewLoaded) {
		return;
	}
	
	for (TNKAssetCell *cell in self.collectionView.visibleCells) {
		cell.assetSelected = [_selectedAssets containsObject:cell.asset];
	}
}

- (void)setSelectedAssetBadgeImage:(UIImage *)selectedAssetBadgeImage
{
    _selectedAssetBadgeImage = selectedAssetBadgeImage ?: TNKImagePickerControllerImageNamed(@"checkmark-selected");
}

#pragma mark - Initialization

- (void)_init
{
    _mediaTypes = @[ (NSString *)kUTTypeImage ];
    _selectedAssets = [NSMutableOrderedSet new];
    _selectedAssetBadgeImage = TNKImagePickerControllerImageNamed(@"checkmark-selected");
    
    _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = _cancelButton;
    
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = _doneButton;
    
    _cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    
    _pasteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Paste", @"Button to paste a photo") style:UIBarButtonItemStylePlain target:self action:@selector(paste:)];
    
    _selectAllButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)];
    
    self.hidesBottomBarWhenPushed = NO;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _collectionButton = [TNKCollectionsTitleButton buttonWithType:UIButtonTypeSystem];
    [_collectionButton addTarget:self action:@selector(changeCollection:) forControlEvents:UIControlEventTouchUpInside];
    _collectionButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _collectionButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 3.0, 0.0, 0.0);
    [_collectionButton setImage:[TNKImagePickerControllerImageNamed(@"nav-disclosure") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_collectionButton sizeToFit];
    self.navigationItem.titleView = _collectionButton;
    
    _momentCache = [[NSCache alloc] init];
    [self _updateForAssetCollection];
    [self _updateDoneButton];
    [self _updateSelectAllButton];
    [self _updateToolbarItems:NO];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteboardChanged:) name:UIPasteboardChangedNotification object:[UIPasteboard generalPasteboard]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[TNKCollectionViewFloatingHeaderFlowLayout alloc] init];
    layout.minimumLineSpacing = TNKObjectSpacing;
    layout.minimumInteritemSpacing = 0.0;
    self = [super initWithCollectionViewLayout:layout];
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

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[TNKAssetCell class] forCellWithReuseIdentifier:@"Cell"];
    self.collectionView.alwaysBounceVertical = YES;
    
    [self.collectionView registerClass:[TNKMomentHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
	
	UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showAsset:)];
	recognizer.minimumPressDuration = 0.5;
	[self.collectionView addGestureRecognizer:recognizer];
}

- (void)viewDidLayoutSubviews {
    if (self.view.window && !_windowLoaded) {
        _windowLoaded = YES;
        
        [self.collectionView reloadData];
        
        if (_moments != nil) {
            [self.collectionView layoutIfNeeded];
            [self _scrollToBottomAnimated:NO];
        }
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    
    UIFont *font = self.navigationController.navigationBar.titleTextAttributes[NSFontAttributeName];
    if (font != nil) {
        _collectionButton.titleLabel.font = font;
        [_collectionButton sizeToFit];
    }
}


#pragma mark - Actions

- (IBAction)done:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingAssets:)]) {
        [self.delegate imagePickerController:self didFinishPickingAssets:self.selectedAssets];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.delegate imagePickerControllerDidCancel:self];
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
    if ([self.delegate respondsToSelector:@selector(imagePickerController:willDisplayCameraViewController:)]) {
        viewController = [self.delegate imagePickerController:self willDisplayCameraViewController:imagePicker];
    }
    
    if (viewController != nil) {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (IBAction)paste:(id)sender {
    _pasteChangeCount = [UIPasteboard generalPasteboard].changeCount;
    
    BOOL validAsset = NO;
    
    // this is a private type, so we need to double and tripple check that everything is valid
    NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"com.apple.mobileslideshow.asset.localidentifier"];
    NSString *localIdentifier = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (localIdentifier != nil) {
        PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[ localIdentifier ] options:nil];
        
        if (result.firstObject != nil) {
            [self selectAsset:result.firstObject];
            [self _updateSelection];
            validAsset = YES;
        }
    }
    
    
    if (!validAsset) {
        // we can't reference the asset directly, either because of an internal change or because it was coppied from somewhere else
        // create an asset and add it to the library
        NSArray *images = [[UIPasteboard generalPasteboard] images];
        
        [self _addImages:images];
    }
    
    [self _updateToolbarItems:YES];
}

- (IBAction)selectAll:(id)sender {
    if (_moments != nil) {
        return;
    }
    
    PHFetchResult *fetchResult = _fetchResult;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
        
        [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            [assets addObject:asset];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSelectedAssets:assets];
            [self _updateSelection];
        });
    });
}

- (IBAction)deselectAll:(id)sender
{
    if (_moments != nil) {
        return;
    }
    
    PHFetchResult *fetchResult = _fetchResult;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
        
        [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            [assets addObject:asset];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeSelectedAssets:assets];
            [self _updateSelection];
        });
    });
}

- (void)showAsset:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state != UIGestureRecognizerStateBegan) {
		return;
	}
	
	CGPoint location = [recognizer locationInView:self.collectionView];
	
	NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
	if (indexPath != nil){
		TNKAssetsDetailViewController *detailViewController = [[TNKAssetsDetailViewController alloc] init];
		detailViewController.assetDelegate = self;
		detailViewController.assetCollection = self.assetCollection;
		detailViewController.assetFetchOptions = [self _assetFetchOptions];
		[detailViewController showAssetAtIndexPath:indexPath];
		
		if ([self.delegate respondsToSelector:@selector(imagePickerController:willDisplayDetailViewController:forAsset:)]) {
			PHAsset *asset = [self _assetAtIndexPath:indexPath];
			UIViewController *viewController = [self.delegate imagePickerController:self willDisplayDetailViewController:detailViewController forAsset:asset];
			
			if (viewController != nil) {
				[self.navigationController pushViewController:viewController animated:YES];
			}
		} else {
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
	}
}

- (IBAction)changeCollection:(id)sender {
    if (_collectionPicker == nil) {
        _collectionPicker = [[TNKCollectionPickerController alloc] init];
        _collectionPicker.delegate = self;
    }
    
    _collectionPicker.assetFetchOptions = [self _assetFetchOptions];
    if (_selectedAssets.count > 0) {
        PHAssetCollection *collection = [PHAssetCollection transientAssetCollectionWithAssets:_selectedAssets.array title:NSLocalizedString(@"Selected", @"Collection name for selected photos")];
        _collectionPicker.additionalAssetCollections = @[ collection ];
    } else {
        _collectionPicker.additionalAssetCollections = @[];
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_collectionPicker];
    navigationController.restorationIdentifier = @"TNKCollectionPickerController.NavigationController";
    navigationController.restorationClass = [self class];
    navigationController.navigationBarHidden = YES;
    
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    navigationController.popoverPresentationController.sourceView = _collectionButton;
    navigationController.popoverPresentationController.sourceRect = _collectionButton.bounds;
    navigationController.popoverPresentationController.delegate = self;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_addImages:(NSArray<UIImage *> *)images {
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
        } else if (success) {
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:localIdentifiers options:nil];
            
            NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
            [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [assets addObject:obj];
            }];
            
            if (assets.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addSelectedAssets:assets];
                    [self _updateSelection];
                });
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
                    [self addSelectedAssets:assets];
                    [self _updateSelection];
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


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_moments != nil) {
        return _moments.count;
    } else {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_moments != nil) {
        PHAssetCollection *collection = _moments[section];
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        return fetchResult.count;
    } else {
        return _fetchResult.count;
    }
}

- (PHFetchResult *)_assetsForMoment:(PHAssetCollection *)collection
{
    PHFetchResult *result = [_momentCache objectForKey:collection.localIdentifier];
    if (result == nil) {
        result = [PHAsset fetchAssetsInAssetCollection:collection options:[self _assetFetchOptions]];
        [_momentCache setObject:result forKey:collection.localIdentifier];
    }
    
    return result;
}

- (PHAsset *)_assetAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = nil;
    if (_moments != nil) {
        PHAssetCollection *collection = _moments[indexPath.section];
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        asset = fetchResult[indexPath.row];
    } else {
        asset = _fetchResult[indexPath.row];
    }
    
    return asset;
}

- (NSIndexPath *)_indexPathForAsset:(PHAsset *)asset {
	if (_moments != nil) {
		PHAssetCollection *collection = [PHAssetCollection fetchAssetCollectionsContainingAsset:asset withType:PHAssetCollectionTypeMoment options:nil].firstObject;
		NSUInteger section = [_moments indexOfObject:collection];
		
		PHFetchResult *fetchResult = [self _assetsForMoment:collection];
		NSUInteger item = [fetchResult indexOfObject:asset];
		
		if (item != NSNotFound && section != NSNotFound) {
			return [NSIndexPath indexPathForItem:item inSection:section];
		}
	} else {
		NSUInteger item = [_fetchResult indexOfObject:asset];
		
		if (item != NSNotFound) {
			return [NSIndexPath indexPathForItem:item inSection:0];
		}
	}
	
	return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TNKAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    PHAsset *asset = [self _assetAtIndexPath:indexPath];
    
    cell.asset = asset;
    cell.assetSelected = [_selectedAssets containsObject:asset];
    cell.selectedBadgeImageView.image = _selectedAssetBadgeImage;

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger columns = floor(collectionView.bounds.size.width / 100.0);
    CGFloat width = floor((collectionView.bounds.size.width + TNKObjectSpacing) / columns) - TNKObjectSpacing;
    
    return CGSizeMake(width, width);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    TNKMomentHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    
    if (_moments != nil) {
        PHAssetCollection *collection = _moments[indexPath.section];
        
        
        NSString *dateString = [collection.startDate tnk_localizedDay];
        
        
        if (collection.localizedTitle != nil) {
            headerView.primaryLabel.text = collection.localizedTitle;
            headerView.secondaryLabel.text = [collection.localizedLocationNames componentsJoinedByString:@" & "];
            headerView.detailLabel.text = dateString;
        } else {
            headerView.primaryLabel.text = dateString;
            headerView.secondaryLabel.text = nil;
            headerView.detailLabel.text = nil;
        }
    }
    
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (_moments != nil) {
        PHAssetCollection *collection = _moments[section];
        
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        if (fetchResult.count == 0) {
            return CGSizeZero;
        }
        
        return CGSizeMake(collectionView.bounds.size.width, 44.0);
    } else {
        return CGSizeZero;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (_moments != nil) {
        PHAssetCollection *collection = _moments[section];
        
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        if (fetchResult.count == 0) {
            return UIEdgeInsetsZero;
        }
        
        return UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0);
    } else {
        return UIEdgeInsetsZero;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	PHAsset *asset = [self _assetAtIndexPath:indexPath];

    if ([_selectedAssets containsObject:asset]) {
        [self deselectAsset:asset];
    } else {
        [self selectAsset:asset];
    }
}

- (void)_scrollToBottomAnimated:(BOOL)animated {
    CGPoint contentOffset = self.collectionView.contentOffset;
    contentOffset.y = self.collectionView.contentSize.height - self.collectionView.bounds.size.height + self.collectionView.contentInset.bottom;
    contentOffset.y = MAX(contentOffset.y, -self.collectionView.contentInset.top);
    contentOffset.y = MAX(self.collectionView.contentSize.height - self.collectionView.bounds.size.height + self.collectionView.contentInset.bottom, -self.collectionView.contentInset.top);
    [self.collectionView setContentOffset:contentOffset animated:animated];
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


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_momentCache removeAllObjects];
        
        if (_moments != nil) {
            PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:_moments];
            if (details != nil) {
                _moments = [details fetchResultAfterChanges];
                
                // incremental updates throw exceptions too often
                [self.collectionView reloadData];
                
//                if (details.hasIncrementalChanges) {
//                    [self.collectionView performBatchUpdates:^{
//                        if (details.removedIndexes != nil) {
//                            [self.collectionView deleteSections:details.removedIndexes];
//                        }
//                        
//                        if (details.insertedIndexes != nil) {
//                            [self.collectionView insertSections:details.insertedIndexes];
//                        }
//                        
//                        if (details.changedIndexes != nil) {
//                            [self.collectionView reloadSections:details.changedIndexes];
//                        }
//                        
//                        [details enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
//                            [self.collectionView moveSection:fromIndex toSection:toIndex];
//                        }];
//                    } completion:nil];
//                } else {
//                    [self.collectionView reloadData];
//                }
            }
        } else {
            PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:_fetchResult];
            if (details != nil) {
                _fetchResult = [details fetchResultAfterChanges];
                
                if (details.hasIncrementalChanges) {
                    [self.collectionView performBatchUpdates:^{
                        NSMutableArray *removedIndexPaths = [NSMutableArray new];
                        [details.removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                            [removedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                        }];
                        [self.collectionView deleteItemsAtIndexPaths:removedIndexPaths];
                        
                        
                        NSMutableArray *insertedIndexPaths = [NSMutableArray new];
                        [details.insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                            [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                        }];
                        [self.collectionView insertItemsAtIndexPaths:insertedIndexPaths];
                        
                        
                        NSMutableArray *changedIndexPaths = [NSMutableArray new];
                        [details.changedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                            [changedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                        }];
                        [self.collectionView reloadItemsAtIndexPaths:changedIndexPaths];
                        
                        
                        [details enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                            NSIndexPath *from = [NSIndexPath indexPathForRow:fromIndex inSection:0];
                            NSIndexPath *to = [NSIndexPath indexPathForRow:fromIndex inSection:0];
                            
                            [self.collectionView moveItemAtIndexPath:from toIndexPath:to];
                        }];
                    } completion:nil];
                } else {
                    [self.collectionView reloadData];
                }
            }
        }
    });
}


#pragma mark - TNKAssetsDetailViewControllerDelegate

- (BOOL)assetsDetailViewController:(TNKAssetsDetailViewController *)viewController isAssetSelectedAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [self _assetAtIndexPath:indexPath];
    return [_selectedAssets containsObject:asset];
}

- (void)assetsDetailViewController:(TNKAssetsDetailViewController *)viewController selectAssetAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [self _assetAtIndexPath:indexPath];
    [self selectAsset:asset];
}

- (void)assetsDetailViewController:(TNKAssetsDetailViewController *)viewController deselectAssetAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [self _assetAtIndexPath:indexPath];
    [self deselectAsset:asset];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    
    if (image != nil) {
        [self _addImages:@[image]];
    } else if (videoURL != nil) {
        [self _addVideos:@[videoURL]];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - State Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.mediaTypes forKey:@"mediaTypes"];
    [coder encodeObject:self.assetCollection.localIdentifier forKey:@"assetCollection"];
    [coder encodeObject:[_selectedAssets valueForKey:@"localIdentifier"] forKey:@"selectedAssets"];
    [coder encodeObject:_collectionPicker forKey:@"collectionPicker"];
    [coder encodeObject:_collectionPicker.navigationController forKey:@"collectionPickerNavigationController"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.mediaTypes = [coder decodeObjectForKey:@"mediaTypes"];
    
    NSString *assetCollectionIdentifier = [coder decodeObjectForKey:@"assetCollection"];
    if (assetCollectionIdentifier != nil) {
        self.assetCollection = [[PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[ assetCollectionIdentifier ] options:nil] firstObject];
    }
    
    NSOrderedSet *selectedAssetsIdentifiers = [coder decodeObjectForKey:@"selectedAssets"];
    if (selectedAssetsIdentifiers != nil) {
        NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
        for (PHAsset *asset in [PHAsset fetchAssetsWithLocalIdentifiers:selectedAssetsIdentifiers.array options:nil]) {
            [assets addObject:asset];
        }
        [self addSelectedAssets:assets];
    }
    
    TNKCollectionPickerController *collectionPicker = [coder decodeObjectForKey:@"collectionPicker"];
    if (collectionPicker != nil) {
        _collectionPicker = collectionPicker;
        _collectionPicker.assetFetchOptions = [self _assetFetchOptions];
        if (_selectedAssets.count > 0) {
            PHAssetCollection *collection = [PHAssetCollection transientAssetCollectionWithAssets:_selectedAssets.array title:NSLocalizedString(@"Selected", @"Collection name for selected photos")];
            _collectionPicker.additionalAssetCollections = @[ collection ];
        }
        _collectionPicker.delegate = self;
    }
    
    UINavigationController *navigationController = [coder decodeObjectForKey:@"collectionPickerNavigationController"];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    navigationController.popoverPresentationController.sourceView = _collectionButton;
    navigationController.popoverPresentationController.sourceRect = _collectionButton.bounds;
    navigationController.popoverPresentationController.delegate = self;
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    if ([identifierComponents.lastObject isEqual:@"TNKCollectionPickerController.NavigationController"]) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[TNKCollectionPickerController alloc] init]];
        navigationController.restorationIdentifier = @"TNKCollectionPickerController.NavigationController";
        navigationController.restorationClass = self;
        navigationController.navigationBarHidden = YES;
        
        return navigationController;
    }
    
    return nil;
}

@end
