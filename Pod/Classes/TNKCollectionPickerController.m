//
//  TNKImagePickerControllerTableViewController.m
//  Pods
//
//  Created by David Beck on 2/17/15.
//
//

#import "TNKCollectionPickerController.h"

@import Photos;

#import "TNKImagePickerControllerBundle.h"
#import "TNKAssetImageView.h"
#import "TNKCollectionCell.h"
#import "PHCollection+TNKThumbnail.h"


@interface TNKCollectionPickerController () <PHPhotoLibraryChangeObserver, UIViewControllerRestoration>
{
    NSArray *_collectionsFetchResults;
    
    NSCache *_collectionHiddenCache;
    NSCache *_assetCountCache;
    BOOL _needsRefetch;
}

@end

@implementation TNKCollectionPickerController

#pragma mark - Properties

- (void)setAdditionalAssetCollections:(NSArray<PHAssetCollection *> *)additionalAssetCollections
{
    _additionalAssetCollections = [additionalAssetCollections copy];
    
    [self _setNeedsReloadFetch];
}

- (void)setCollectionList:(PHCollectionList *)collectionList
{
    _collectionList = collectionList;
    
    self.title = _collectionList.localizedTitle;
    [self _setNeedsReloadFetch];
}


#pragma mark - Initialization

- (void)_init {
    _collectionHiddenCache = [NSCache new];
    _assetCountCache = [NSCache new];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.restorationIdentifier = @"TNKCollectionPickerController";
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
    
    
    [self _setNeedsReloadFetch];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = self.collectionList == nil;
}

- (void)_setNeedsReloadFetch {
    if (!_needsRefetch) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _reloadFetch];
        });
    }
}

- (void)_reloadFetch
{
    NSArray *additionalAssetCollections = [self.additionalAssetCollections copy];
    
    PHCollectionList *collectionList = self.collectionList;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *fetchResults;
        
        if (collectionList == nil) {
			fetchResults = @[
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil],
							 [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil],
							 
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
        
        if (additionalAssetCollections != nil) {
            fetchResults = [additionalAssetCollections arrayByAddingObjectsFromArray:fetchResults];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _collectionsFetchResults = fetchResults;
            [self.tableView reloadData];
        });
    });
    
    _needsRefetch = NO;
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)_momentsSections
{
    if (self.collectionList != nil) {
        return 0;
    }
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _collectionsFetchResults.count + [self _momentsSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < [self _momentsSections]) {
        return 1;
    }
    
    id collection = _collectionsFetchResults[section - [self _momentsSections]];
    if ([collection isKindOfClass:[PHFetchResult class]]) {
        return [_collectionsFetchResults[section - [self _momentsSections]] count];
	}
	
    return 1;
}

- (BOOL)_isCollectionHidden:(PHCollection *)collection
{
    NSNumber *hidden = [_collectionHiddenCache objectForKey:collection.localIdentifier];
    if (hidden == nil) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            if (assetCollection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                if (assetCollection.estimatedAssetCount == NSNotFound) {
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.assetFetchOptions];
                    hidden = @(result.count <= 0);
                } else {
                    hidden = @(assetCollection.estimatedAssetCount <= 0);
                }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < [self _momentsSections]) {
        TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
        
        cell.titleLabel.text = NSLocalizedString(@"Moments", nil);
        
        cell.thumbnailView.image = TNKImagePickerControllerImageNamed(@"default-collection");
        [PHCollection tnk_requestThumbnailForMomentsWithAssetsFetchOptions:self.assetFetchOptions completion:^(UIImage *result) {
            if (result != nil) {
                cell.thumbnailView.image = result;
            }
        }];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    } else {
        PHFetchResult *fetchResult = _collectionsFetchResults[indexPath.section - [self _momentsSections]];
        PHCollection *collection;
        if ([fetchResult isKindOfClass:[PHFetchResult class]]) {
            collection = fetchResult[indexPath.row];
        } else {
            collection = (PHCollection *)fetchResult;
        }
        
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            cell.titleLabel.text = collection.localizedTitle;
            
            NSInteger count = assetCollection.estimatedAssetCount;
            if (count == NSNotFound) {
                NSNumber *countNumber = [_assetCountCache objectForKey:assetCollection.localIdentifier];
                if (countNumber == nil) {
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.assetFetchOptions];
                    countNumber = @(result.count);
                    [_assetCountCache setObject:countNumber forKey:assetCollection.localIdentifier];
                }
                
                count = [countNumber integerValue];
            }
            
            static NSNumberFormatter *numberFormatter = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                numberFormatter = [[NSNumberFormatter alloc] init];
                numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                numberFormatter.usesGroupingSeparator = YES;
            });
            cell.subtitleLabel.text = [numberFormatter stringFromNumber:@(count)];
            
            cell.thumbnailView.image = TNKImagePickerControllerImageNamed(@"default-collection");
            [collection tnk_requestThumbnailWithAssetsFetchOptions:self.assetFetchOptions completion:^(UIImage *result) {
                if (result != nil) {
                    cell.thumbnailView.image = result;
                }
            }];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            return cell;
        } else {
            TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
            
            cell.titleLabel.text = collection.localizedTitle;
            
            cell.thumbnailView.image = TNKImagePickerControllerImageNamed(@"default-collection-list");
            [collection tnk_requestThumbnailWithAssetsFetchOptions:self.assetFetchOptions completion:^(UIImage *result) {
                if (result != nil) {
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
    
    if (indexPath.section >= [self _momentsSections]) {
        PHFetchResult *fetchResult = _collectionsFetchResults[indexPath.section - [self _momentsSections]];
        PHCollection *collection;
        if ([fetchResult isKindOfClass:[PHFetchResult class]]) {
            collection = fetchResult[indexPath.row];
        } else {
            collection = (PHCollection *)fetchResult;
        }
        
        hidden = [self _isCollectionHidden:collection];
    }
    
    
    if (hidden) {
        return 0.0;
    } else {
        return 85.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < [self _momentsSections]) {
        [self.delegate collectionPicker:self didSelectCollection:nil];
    } else {
        PHFetchResult *fetchResult = _collectionsFetchResults[indexPath.section - [self _momentsSections]];
        PHCollection *collection;
        if ([fetchResult isKindOfClass:[PHFetchResult class]]) {
            collection = fetchResult[indexPath.row];
        } else {
            collection = (PHCollection *)fetchResult;
        }
        
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            [self.delegate collectionPicker:self didSelectCollection:assetCollection];
        } else {
            TNKCollectionPickerController *picker = [[TNKCollectionPickerController alloc] init];
            picker.delegate = self.delegate;
            picker.collectionList = (PHCollectionList *)collection;
            picker.restorationClass = [self class];
            
            [self.navigationController pushViewController:picker animated:YES];
        }
    }
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    [_assetCountCache removeAllObjects];
    [_collectionHiddenCache removeAllObjects];
    
    [self _setNeedsReloadFetch];
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
        self.collectionList = [PHCollectionList fetchCollectionListsWithLocalIdentifiers:@[ collectionListIdentifier ] options:nil].firstObject;
    }
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray<NSString *> *)identifierComponents coder:(NSCoder *)coder {
    TNKCollectionPickerController *picker = [[TNKCollectionPickerController alloc] init];
    
    return picker;
}

@end
