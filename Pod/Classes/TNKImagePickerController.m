//
//  TNKImagePickerControllerTableViewController.m
//  Pods
//
//  Created by David Beck on 2/17/15.
//
//

#import "TNKImagePickerController.h"

@import Photos;

#import "TNKImagePickerControllerBundle.h"
#import "UIImageView+TNKAssets.h"
#import "TNKCollectionCell.h"
#import "PHCollection+TNKThumbnail.h"


@interface TNKImagePickerController () <PHPhotoLibraryChangeObserver>
{
    UIBarButtonItem *_cancelButton;
    
    NSArray *_collectionsFetchResults;
}

@end

@implementation TNKImagePickerController

#pragma mark - Properties

- (void)setShowsCancelButton:(BOOL)showsCancelButton {
    _showsCancelButton = showsCancelButton;
    
    if (_showsCancelButton) {
        self.navigationItem.rightBarButtonItem = _cancelButton;
    } else if (self.navigationItem.rightBarButtonItem == _cancelButton) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}


#pragma mark - Initialization

- (void)_init
{
    _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
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
    
    
    [self _reloadFetch];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)_reloadFetch
{
    _collectionsFetchResults = @[
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

- (NSCache *)_assetCountCache
{
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSCache new];
    });
    
    return cache;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
        
        cell.titleLabel.text = NSLocalizedString(@"Moments", nil);
        
        cell.thumbnailView.image = [UIImage imageNamed:@"default-collection" inBundle:TNKImagePickerControllerBundle() compatibleWithTraitCollection:self.traitCollection];
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
                NSNumber *countNumber = [[self _assetCountCache] objectForKey:assetCollection.localIdentifier];
                if (countNumber == nil) {
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                    countNumber = @(result.count);
                    [[self _assetCountCache] setObject:countNumber forKey:assetCollection.localIdentifier];
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
            
            cell.thumbnailView.image = [UIImage imageNamed:@"default-collection" inBundle:TNKImagePickerControllerBundle() compatibleWithTraitCollection:self.traitCollection];
            [collection requestThumbnail:^(UIImage *result) {
                if (result != nil) {
                    cell.thumbnailView.image = result;
                }
            }];
            
            
            return cell;
        } else {
            TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
            
            cell.titleLabel.text = collection.localizedTitle;
            
            cell.thumbnailView.image = [UIImage imageNamed:@"default-collection-list" inBundle:TNKImagePickerControllerBundle() compatibleWithTraitCollection:self.traitCollection];
            [collection requestThumbnail:^(UIImage *result) {
                if (result != nil) {
                    cell.thumbnailView.image = result;
                }
            }];
            
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0 + 1.0 / self.traitCollection.displayScale;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0 + 1.0 / self.traitCollection.displayScale;
    
    BOOL hidden = NO;
    
    if (indexPath.section > 0) {
        PHFetchResult *fetchResult = _collectionsFetchResults[indexPath.section - 1];
        PHCollection *collection = fetchResult[indexPath.row];
        
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            if (assetCollection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                if (assetCollection.estimatedAssetCount == NSNotFound) {
                    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                    hidden = result.count <= 0;
                } else {
                    hidden = assetCollection.estimatedAssetCount <= 0;
                }
            }
        }
    }
    
    
    if (hidden) {
        return 0.0;
    } else {
        // 85.0, plus the height of the separator
        return 85.0 + 1.0 / self.traitCollection.displayScale;
    }
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    [[self _assetCountCache] removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSMutableArray *updatedCollectionsFetchResults = nil;
//        
//        for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
//            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
//            if (changeDetails) {
//                if (!updatedCollectionsFetchResults) {
//                    updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
//                }
//                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
//            }
//        }
//        
//        if (updatedCollectionsFetchResults) {
//            self.collectionsFetchResults = updatedCollectionsFetchResults;
//            [self.tableView reloadData];
//        }
    });
}

@end
