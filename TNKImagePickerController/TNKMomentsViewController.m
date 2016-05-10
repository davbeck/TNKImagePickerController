//
//  TNKMomentsViewController.m
//  TNKImagePickerController
//
//  Created by David Beck on 5/5/16.
//  Copyright © 2016 Think Ultimate LLC. All rights reserved.
//

#import "TNKMomentsViewController.h"

@import Photos;

#import "TNKCollectionsTitleButton.h"
#import "TNKCollectionPickerController.h"
#import "TNKAssetImageView.h"
#import "TNKMomentHeaderView.h"
#import "TNKCollectionViewInvertedFlowLayout.h"
#import "TNKAssetsDetailViewController.h"
#import "NSDate+TNKFormattedDay.h"
#import "UIImage+TNKIcons.h"


#define TNKCollectionViewControllerHeaderIdentifier @"HeaderView"


@interface TNKMomentInfo : NSObject

@property (nonatomic, nonnull, readonly) PHAssetCollection *moment;
@property (nonatomic, readonly) NSUInteger count;

- (instancetype)initWithMoment:(PHAssetCollection *)moment count:(NSUInteger)count;

@end

@implementation TNKMomentInfo

- (instancetype)initWithMoment:(PHAssetCollection *)moment count:(NSUInteger)count {
	self = [super init];
	if (self != nil) {
		_moment = moment;
		_count = count;
	}
	
	return self;
}

@end


@interface TNKMomentsViewController () {
	PHFetchResult<PHAssetCollection *> *_moments;
	NSCache *_momentCache;
	
	NSArray<TNKMomentInfo *> *_sections;
	
	NSMutableArray<NSIndexSet *> *_sectionIndexQueue;
	// we don't want to update while scrolling
	NSArray<TNKMomentInfo *> *_sectionsWaitingToBeInserted;
}

@end

@implementation TNKMomentsViewController

- (void)setLayoutInsets:(UIEdgeInsets)layoutInsets {
	[super setLayoutInsets:layoutInsets];
	
	// because we invert scrolling our top is actually our bottom and vice versa
	self.collectionView.contentInset = UIEdgeInsetsMake(layoutInsets.bottom, 0, layoutInsets.top, 0);
	self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
}

- (TNKCollectionViewInvertedFlowLayout *)_layout {
	TNKCollectionViewInvertedFlowLayout *layout = (TNKCollectionViewInvertedFlowLayout *)self.collectionView.collectionViewLayout;
	
	if ([layout isKindOfClass:[TNKCollectionViewInvertedFlowLayout class]]) {
		return layout;
	}
	
	return nil;
}


#pragma mark - Initialization

- (instancetype)init
{
	UICollectionViewFlowLayout *layout = [[TNKCollectionViewInvertedFlowLayout alloc] init];
	layout.minimumLineSpacing = TNKObjectSpacing;
	layout.minimumInteritemSpacing = 0.0;
	
	self = [super initWithCollectionViewLayout:layout];
	if (self != nil) {
		_moments = [PHAssetCollection fetchMomentsWithOptions:nil];
		_momentCache = [[NSCache alloc] init];
		
		[self _loadMoments];
	}
	
	return self;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.collectionView.transform = TNKInvertedTransform;
	
	[self.collectionView registerClass:[TNKMomentHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:TNKCollectionViewControllerHeaderIdentifier];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	[super traitCollectionDidChange:previousTraitCollection];
	
	UICollectionViewFlowLayout *flowLayout = [self _layout];
	
	// because we are inverted we want "footers" instead of headers, even though fisually they look and act like headers.
	flowLayout.headerReferenceSize = CGSizeZero;
	flowLayout.footerReferenceSize = CGSizeMake(self.collectionView.bounds.size.width, 44.0);
	flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 0.0, 0.0, 0.0);
	if ([flowLayout respondsToSelector:@selector(sectionFootersPinToVisibleBounds)]) {
		flowLayout.sectionFootersPinToVisibleBounds = YES;
	}
}


#pragma mark - Asset Management

- (PHFetchResult *)_assetsForMoment:(PHAssetCollection *)collection {
	PHFetchResult *result = [_momentCache objectForKey:collection.localIdentifier];
	if (result == nil) {
		result = [PHAsset fetchAssetsInAssetCollection:collection options:[self assetFetchOptions]];
		[_momentCache setObject:result forKey:collection.localIdentifier];
	}
	
	return result;
}

- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath
{
	TNKMomentInfo *sectionInfo = _sections[indexPath.section];
	PHAssetCollection *collection = sectionInfo.moment;
	PHFetchResult *fetchResult = [self _assetsForMoment:collection];
	
	// we start by using the estimated count, which may be different from the actual count.
	if (indexPath.row < fetchResult.count) {
		return fetchResult[indexPath.row];
	} else {
		return nil;
	}
}

- (NSIndexPath *)indexPathForAsset:(PHAsset *)asset {
	PHAssetCollection *collection = [PHAssetCollection fetchAssetCollectionsContainingAsset:asset withType:PHAssetCollectionTypeMoment options:nil].firstObject;
	
	NSUInteger section = NSNotFound;
	for (TNKMomentInfo *sectionInfo in _sections) {
		if ([sectionInfo.moment isEqual:collection]) {
			section = [_sections indexOfObject:sectionInfo];
		}
	}
	
	PHFetchResult *fetchResult = [self _assetsForMoment:collection];
	NSUInteger item = [fetchResult indexOfObject:asset];
	
	if (item != NSNotFound && section != NSNotFound) {
		return [NSIndexPath indexPathForItem:item inSection:section];
	} else {
		return nil;
	}
}



- (void)_loadMoreSections {
	NSIndexSet *indexSet = [_sectionIndexQueue firstObject];
	if (indexSet != nil) {
		[_sectionIndexQueue removeObjectAtIndex:0];
		PHFetchResult<PHAssetCollection *> *moments = _moments;
		
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
			NSMutableArray<TNKMomentInfo *> *sections = [NSMutableArray new];
			
			[moments enumerateObjectsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:^(PHAssetCollection * _Nonnull moment, NSUInteger index, BOOL * _Nonnull stop) {
				NSUInteger count = [self _assetsForMoment:moment].count;
				
				// if a moment only has videos and we only display photos (or something similar) we will have empty moments
				if (count > 0) {
					TNKMomentInfo *info = [[TNKMomentInfo alloc] initWithMoment:moment count:count];
					[sections addObject:info];
					
					dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
						NSArray *assets = [fetchResult objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)]];
						CGSize size = [self _layout].itemSize;
						size.width *= self.traitCollection.displayScale;
						size.height *= self.traitCollection.displayScale;
						[self.imageManager startCachingImagesForAssets:assets targetSize:size contentMode:PHImageContentModeAspectFill options:[TNKAssetImageView imageRequestOptions]];
					});
				}
			}];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				if (_moments == moments) {
					_sectionsWaitingToBeInserted = sections;
					
					// we don't want to insert these while the user is interacting with the content because it will cause a freeze
					if (!self.collectionView.dragging && !self.collectionView.decelerating) {
						[self _applyChanges];
					}
				}
			});
		});
	}
}

- (void)_loadMoments {
	PHFetchResult<PHAssetCollection *> *moments = _moments;
	_sections = [NSArray new];
	[self.collectionView reloadData];
	
	
	
	// break up all the indexes in the moments array into groups of 50
	NSMutableArray<NSIndexSet *> *sectionIndexQueue = [NSMutableArray new];
	for (NSInteger i = moments.count; i > 0; i -= 50) {
		NSUInteger length = MIN(50, i);
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i - length, length)];
		
		[sectionIndexQueue addObject:indexSet];
	}
	_sectionIndexQueue = sectionIndexQueue;
	
	
	
	[self _loadMoreSections];
}


#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	TNKMomentInfo *sectionInfo = _sections[section];
	return sectionInfo.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	TNKMomentHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
	
	TNKMomentInfo *section = _sections[indexPath.section];
	
	
	NSString *dateString = [section.moment.startDate tnk_localizedDay];
	
	
	if (section.moment.localizedTitle != nil) {
		headerView.primaryLabel.text = section.moment.localizedTitle;
		headerView.secondaryLabel.text = [section.moment.localizedLocationNames componentsJoinedByString:@" & "];
		headerView.detailLabel.text = dateString;
	} else {
		headerView.primaryLabel.text = dateString;
		headerView.secondaryLabel.text = nil;
		headerView.detailLabel.text = nil;
	}
	
	return headerView;
}

// this should only be called if the collection view is not scrolling
- (void)_applyChanges {
	if (_sectionsWaitingToBeInserted.count > 0) {
		NSIndexSet *newIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_sections.count, _sectionsWaitingToBeInserted.count)];
		
		[UIView performWithoutAnimation:^{
			[self.collectionView performBatchUpdates:^{
				_sections = [_sections arrayByAddingObjectsFromArray:_sectionsWaitingToBeInserted];
				[self.collectionView insertSections:newIndexes];
				
				_sectionsWaitingToBeInserted = nil;
				
				// we don't want to load the next group of sections until we've merged in the last one to avoid having too many inserts at once
				[self _loadMoreSections];
			} completion:nil];
		}];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self _applyChanges];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate) {
		[self _applyChanges];
	}
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_momentCache removeAllObjects];

		PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:_moments];
		if (details != nil) {
			_moments = [details fetchResultAfterChanges];
			[self _loadMoments];
		}
    });
}

@end
