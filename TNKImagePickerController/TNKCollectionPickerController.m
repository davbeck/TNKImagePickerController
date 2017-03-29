//
//  TNKImagePickerControllerTableViewController.m
//  Pods
//
//  Created by David Beck on 2/17/15.
//
//

#import "TNKCollectionPickerController.h"

@import Photos;

#import "TNKAssetImageView.h"
#import "TNKCollectionCell.h"
#import "PHCollection+TNKThumbnail.h"
#import "UIImage+TNKIcons.h"


NSString * const TNKMomentsSection = @"Moments";


@interface TNKCollectionPickerController () <PHPhotoLibraryChangeObserver, UIViewControllerRestoration>
{
	NSArray *_sections;
    NSArray *_collectionsFetchResults;
    
    NSCache<NSString *, NSNumber *> *_collectionHiddenCache;
    NSCache<NSString *, NSNumber *> *_assetCountCache;
    BOOL _needsRefetch;
}

@end

@implementation TNKCollectionPickerController

#pragma mark - Properties

- (void)setAdditionalAssetCollections:(NSArray<PHAssetCollection *> *)additionalAssetCollections
{
    _additionalAssetCollections = [additionalAssetCollections copy];
    
    [self _reloadSections];
}

- (void)setAssetFetchOptions:(PHFetchOptions *)assetFetchOptions {
	_assetFetchOptions = assetFetchOptions;
	
	[_collectionHiddenCache removeAllObjects];
	[_assetCountCache removeAllObjects];
	
	if (self.isViewLoaded && self.view.window != nil) {
		[self.tableView reloadData];
	} else {
		[self _preheatAssetCountCache];
	}
}


#pragma mark - Initialization

- (void)_init {
    _collectionHiddenCache = [NSCache new];
    _assetCountCache = [NSCache new];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
	self.restorationIdentifier = @"TNKCollectionPickerController";
	
	
	[self _reloadFetch:NO];
}

- (instancetype)initWithCollectionList:(PHCollectionList *)collectionList {
	_collectionList = collectionList;
	
	self = [self init];
	if (self != nil) {
		self.title = _collectionList.localizedTitle;
	}
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    
    
    self.tableView.restorationIdentifier = @"TableView";
    [self.tableView registerClass:[TNKCollectionCell class] forCellReuseIdentifier:@"CollectionCell"];
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 95.0, 0.0, 0.0);
    self.tableView.estimatedRowHeight = 85.0;
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = self.collectionList == nil;
}


#pragma mark - Photos Management

- (void)_reloadFetch:(BOOL)priority
{
    PHCollectionList *collectionList = self.collectionList;
    
	dispatch_async(dispatch_get_global_queue(priority ? QOS_CLASS_USER_INITIATED : QOS_CLASS_UTILITY, 0), ^{
        NSArray<PHFetchResult<PHCollection *> *> *fetchResults;
        
        if (collectionList == nil) {
			fetchResults = @[
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumGeneric options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumPanoramas options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumTimelapses options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumBursts options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSlomoVideos options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumAllHidden options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil],
							 
							 [PHCollectionList fetchCollectionListsWithType:PHCollectionListTypeSmartFolder subtype:PHCollectionListSubtypeAny options:nil],
							 
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil],
							 
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumImported options:nil],
							 ];
        } else {
            PHFetchOptions *options = [PHFetchOptions new];
            if (collectionList.collectionListSubtype == PHCollectionListSubtypeSmartFolderFaces) {
                options.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES] ];
            }
            
            fetchResults = @[ [PHAssetCollection fetchCollectionsInCollectionList:collectionList options:options] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _collectionsFetchResults = fetchResults;
			[self _reloadSections];
        });
		
		
		[self _preheatAssetCountCache];
    });
    
    _needsRefetch = NO;
}

- (void)_reloadSections {
	NSMutableArray *sections = [NSMutableArray new];
	
	if (self.collectionList == nil) {
		[sections addObject:TNKMomentsSection];
	}
	
	if (_additionalAssetCollections != nil) {
		[sections addObjectsFromArray:_additionalAssetCollections];
	}
	
	[sections addObjectsFromArray:_collectionsFetchResults];
	
	_sections = [sections copy];
	[self.tableView reloadData];
}

- (void)_preheatAssetCountCache {
	 NSArray<PHFetchResult<PHCollection *> *> *fetchResults = [_collectionsFetchResults copy];
	
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
		for (PHFetchResult *fetchResult in fetchResults) {
			[fetchResult enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
				[self _isCollectionHidden:collection];
				
				if ([collection isKindOfClass:[PHAssetCollection class]]) {
					[self _assetCountForAssetCollection:(PHAssetCollection *)collection];
				}
			}];
		}
	});
}

- (BOOL)_isCollectionHidden:(PHCollection *)collection {
	NSNumber *hidden = [_collectionHiddenCache objectForKey:collection.localIdentifier];
	if (hidden == nil) {
		if ([collection isKindOfClass:[PHAssetCollection class]]) {
			PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
			
			if (assetCollection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
				hidden = @([self _assetCountForAssetCollection:assetCollection] <= 0);
			}
		} else if ([collection isKindOfClass:[PHCollectionList class]]) {
			PHCollectionList *assetCollectionList = (PHCollectionList *)collection;
			
			PHFetchResult *result = [PHCollection fetchCollectionsInCollectionList:assetCollectionList options:nil];
			hidden = @(result.count <= 0);
		}
		
		[_collectionHiddenCache setObject:hidden ?: @NO forKey:collection.localIdentifier];
	}
	
	return hidden.boolValue;
}

- (NSInteger)_assetCountForAssetCollection:(PHAssetCollection *)assetCollection {
	NSNumber *countNumber = [_assetCountCache objectForKey:assetCollection.localIdentifier];
	if (countNumber == nil) {
		PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.assetFetchOptions];
		countNumber = @(result.count);
		[_assetCountCache setObject:countNumber forKey:assetCollection.localIdentifier];
	}
	
	return [countNumber integerValue];
}

- (PHCollection *)_collectionAtIndexPath:(NSIndexPath *)indexPath {
	id section = _sections[indexPath.section];
	
	PHCollection *collection = nil;
	
	if ([section isKindOfClass:[PHFetchResult class]]) {
		PHFetchResult *fetchResult = (PHFetchResult *)section;
		collection = fetchResult[indexPath.row];
	} else if ([section isKindOfClass:[PHCollection class]]) {
		collection = (PHCollection *)section;
	}
	
	return collection;
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
	id section = [_sections objectAtIndex:sectionIndex];
	
    if (section == TNKMomentsSection) {
        return 1;
    }
	
    if ([section isKindOfClass:[PHFetchResult class]]) {
        return [section count];
	}
	
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	id section = [_sections objectAtIndex:indexPath.section];
	
    if (section == TNKMomentsSection) {
        TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
		cell.collection = nil;
        
        cell.titleLabel.text = NSLocalizedString(@"Moments", nil);
        
        cell.thumbnailView.image = [UIImage tnk_defaultCollectionIcon];
        [PHCollection tnk_requestThumbnailForMomentsWithAssetsFetchOptions:self.assetFetchOptions completion:^(UIImage *result) {
            if (result != nil && cell.collection == nil) {
                cell.thumbnailView.image = result;
            }
        }];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
	} else {
		PHCollection *collection = [self _collectionAtIndexPath:indexPath];
		
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
			TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
			cell.collection = collection;
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            cell.titleLabel.text = collection.localizedTitle;
            
			NSInteger count = [self _assetCountForAssetCollection:assetCollection];
			
            static NSNumberFormatter *numberFormatter = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                numberFormatter = [[NSNumberFormatter alloc] init];
                numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                numberFormatter.usesGroupingSeparator = YES;
            });
            cell.subtitleLabel.text = [numberFormatter stringFromNumber:@(count)];
            
            cell.thumbnailView.image = [UIImage tnk_defaultCollectionIcon];
            [collection tnk_requestThumbnailWithAssetsFetchOptions:self.assetFetchOptions completion:^(UIImage *result) {
                if (result != nil && cell.collection == assetCollection) {
                    cell.thumbnailView.image = result;
                }
            }];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            return cell;
        } else {
			TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
			cell.collection = collection;
			
            cell.titleLabel.text = collection.localizedTitle;
            
            cell.thumbnailView.image = [UIImage tnk_defaultCollectionListIcon];
            [collection tnk_requestThumbnailWithAssetsFetchOptions:self.assetFetchOptions completion:^(UIImage *result) {
                if (result != nil && cell.collection == collection) {
                    cell.thumbnailView.image = result;
                }
            }];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL hidden = NO;
	
    PHCollection *collection = [self _collectionAtIndexPath:indexPath];
	if (collection != nil) {
		hidden = [self _isCollectionHidden:collection];
	}
	
	return hidden ? 0 : 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PHCollection *collection = [self _collectionAtIndexPath:indexPath];
	
	if ([collection isKindOfClass:[PHCollectionList class]]) {
		TNKCollectionPickerController *picker = [[TNKCollectionPickerController alloc] initWithCollectionList:(PHCollectionList *)collection];
		picker.delegate = self.delegate;
		picker.restorationClass = [self class];
		
		[self.navigationController pushViewController:picker animated:YES];
	} else {
		[self.delegate collectionPicker:self didSelectCollection:(PHAssetCollection *)collection];
	}
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    [_assetCountCache removeAllObjects];
    [_collectionHiddenCache removeAllObjects];
    
    [self _reloadFetch:NO];
}


#pragma mark - State Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.delegate forKey:@"delegate"];
    [coder encodeObject:self.collectionList.localIdentifier forKey:@"collectionList"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    id<TNKCollectionPickerControllerDelegate> delegate = [coder decodeObjectForKey:@"delegate"];
    if (delegate != nil) {
        self.delegate = delegate;
    }
    
    NSString *collectionListIdentifier = [coder decodeObjectForKey:@"collectionList"];
    if (collectionListIdentifier != nil) {
		_collectionList = [PHCollectionList fetchCollectionListsWithLocalIdentifiers:@[ collectionListIdentifier ] options:nil].firstObject;
		self.title = _collectionList.localizedTitle;
		[self _reloadFetch:YES];
    }
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray<NSString *> *)identifierComponents coder:(NSCoder *)coder {
    TNKCollectionPickerController *picker = [[TNKCollectionPickerController alloc] init];
    
    return picker;
}

@end
