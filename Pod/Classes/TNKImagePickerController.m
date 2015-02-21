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
#import "TNKImageCollectionCell.h"
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
    
    
    NSBundle *bundle = TNKImagePickerControllerBundle();
    [self.tableView registerNib:[UINib nibWithNibName:@"TNKImageCollectionCell" bundle:bundle] forCellReuseIdentifier:@"CollectionCell"];
    [self.tableView registerClass:[TNKCollectionCell class] forCellReuseIdentifier:@"CollectionListCell"];
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

- (void)_setupCell:(TNKImageCollectionCell *)cell withFetchResult:(PHFetchResult *)result
{
    [cell.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger index, BOOL *stop) {
        if (result.count > index) {
            imageView.asset = result[index];
        } else {
            imageView.asset = nil;
            
            if (index > 0) {
                imageView.image = nil;
            }
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TNKImageCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
        
//        cell.titleLabel.text = NSLocalizedString(@"Moments", nil);
//        cell.subtitleLabel.text = nil;
//        
//        PHFetchResult *moments = [PHAssetCollection fetchMomentsWithOptions:nil];
//        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:moments.lastObject options:nil];
        
//        PHFetchOptions *options = [[PHFetchOptions alloc] init];
//        options.sortDescriptors = @[
//                                    [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
//                                    ];
//        PHFetchResult *result = [PHAsset fetchAssetsWithOptions:options];
        
//        [self _setupCell:cell withFetchResult:result];
        
        return cell;
    } else {
        PHFetchResult *fetchResult = _collectionsFetchResults[indexPath.section - 1];
        PHCollection *collection = fetchResult[indexPath.row];
        
        
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            TNKImageCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
            
//            cell.titleLabel.text = collection.localizedTitle;
//            
//            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
//            
//            PHFetchOptions *options = [[PHFetchOptions alloc] init];
//            options.sortDescriptors = @[
//                                        [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
//                                        ];
//            PHFetchResult *keyResult = [PHAsset fetchKeyAssetsInAssetCollection:assetCollection options:nil];
//            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
//            if (keyResult.count <= 0) {
//                keyResult = result;
//            }
//            
//            
////            [self _setupCell:cell withFetchResult:keyResult];
//            
//            
//            static NSNumberFormatter *numberFormatter = nil;
//            static dispatch_once_t onceToken;
//            dispatch_once(&onceToken, ^{
//                numberFormatter = [[NSNumberFormatter alloc] init];
//                numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
//                numberFormatter.usesGroupingSeparator = YES;
//            });
//            cell.subtitleLabel.text = [numberFormatter stringFromNumber:@(result.count)];
            
            return cell;
        } else {
            TNKCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionListCell" forIndexPath:indexPath];
            
            cell.titleLabel.text = collection.localizedTitle;
            
            cell.thumbnailView.image = nil;
            [collection requestThumbnail:^(UIImage *result) {
                cell.thumbnailView.image = result;
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
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
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
