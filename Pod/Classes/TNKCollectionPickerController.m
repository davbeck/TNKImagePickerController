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


@interface TNKCollectionPickerController () <PHPhotoLibraryChangeObserver>
{
    NSArray *_collectionsFetchResults;
    
    NSCache *_collectionHiddenCache;
    NSCache *_assetCountCache;
}

@end

@implementation TNKCollectionPickerController


#pragma mark - Initialization

- (void)_init
{
    _collectionHiddenCache = [NSCache new];
    _assetCountCache = [NSCache new];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
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
    
    
    [self.tableView registerClass:[TNKCollectionCell class] forCellReuseIdentifier:@"CollectionCell"];
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 95.0, 0.0, 0.0);
    self.tableView.estimatedRowHeight = 85.0 + 1.0 / self.traitCollection.displayScale;
    
    
    [self _reloadFetch];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)_reloadFetch
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *fetchResults = @[
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil],
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil],
                                  
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumGeneric options:nil],
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumPanoramas options:nil],
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:nil],
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil],
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumTimelapses options:nil],
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil],
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumBursts options:nil],
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSlomoVideos options:nil],
                                  
                                  [PHCollectionList fetchCollectionListsWithType:PHCollectionListTypeSmartFolder subtype:PHCollectionListSubtypeAny options:nil],
                                  
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil],
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil],
                                  [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumImported options:nil],
                                  ];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _collectionsFetchResults = fetchResults;
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _collectionsFetchResults.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return [_collectionsFetchResults[section - 1] count];
}

- (BOOL)_isCollectionHidden:(PHCollection *)collection
{
    NSNumber *hidden = [_collectionHiddenCache objectForKey:collection.localIdentifier];
    if (hidden == nil) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            if (assetCollection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                if (assetCollection.estimatedAssetCount == NSNotFound) {
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                    hidden = @(result.count <= 0);
                } else {
                    hidden = @(assetCollection.estimatedAssetCount <= 0);
                }
            }
        }
        
        [_collectionHiddenCache setObject:hidden ?: @NO forKey:collection.localIdentifier];
    }
    
    return hidden.boolValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
        
        cell.titleLabel.text = NSLocalizedString(@"Moments", nil);
        
        cell.thumbnailView.image = TNKImagePickerControllerImageNamed(@"default-collection");
        [PHCollection requestThumbnailForMoments:^(UIImage *result) {
            if (result != nil) {
                cell.thumbnailView.image = result;
            }
        }];
        
        return cell;
    } else {
        PHFetchResult *fetchResult = _collectionsFetchResults[indexPath.section - 1];
        PHCollection *collection = fetchResult[indexPath.row];
        
        
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            cell.titleLabel.text = collection.localizedTitle;
            
            NSInteger count = assetCollection.estimatedAssetCount;
            if (count == NSNotFound) {
                NSNumber *countNumber = [_assetCountCache objectForKey:assetCollection.localIdentifier];
                if (countNumber == nil) {
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
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
            [collection requestThumbnail:^(UIImage *result) {
                if (result != nil) {
                    cell.thumbnailView.image = result;
                }
            }];
            
            
            return cell;
        } else {
            TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
            
            cell.titleLabel.text = collection.localizedTitle;
            
            cell.thumbnailView.image = TNKImagePickerControllerImageNamed(@"default-collection-list");
            [collection requestThumbnail:^(UIImage *result) {
                if (result != nil) {
                    cell.thumbnailView.image = result;
                }
            }];
            
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL hidden = NO;
    
    if (indexPath.section > 0) {
        PHFetchResult *fetchResult = _collectionsFetchResults[indexPath.section - 1];
        PHCollection *collection = fetchResult[indexPath.row];
        
        hidden = [self _isCollectionHidden:collection];
    }
    
    
    if (hidden) {
        return 0.0;
    } else {
        // 85.0, plus the height of the separator
        return 85.0 + 1.0 / self.traitCollection.displayScale;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.delegate collectionPicker:self didSelectCollection:nil];
    } else {
        PHFetchResult *fetchResult = _collectionsFetchResults[indexPath.section - 1];
        PHCollection *collection = fetchResult[indexPath.row];
        
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            [self.delegate collectionPicker:self didSelectCollection:assetCollection];
        }
    }
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    [_assetCountCache removeAllObjects];
    [_collectionHiddenCache removeAllObjects];
    
    [self _reloadFetch];
}

@end
