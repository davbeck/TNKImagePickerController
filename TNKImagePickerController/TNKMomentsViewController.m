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

- (void)setAssetFetchOptions:(PHFetchOptions *)assetFetchOptions {
	[super setAssetFetchOptions:assetFetchOptions];
	
	if (![self.assetFetchOptions.predicate isEqual:assetFetchOptions.predicate]) {
		if (self.isViewLoaded) {
			[_momentCache removeAllObjects];
			[self _loadMoments];
		}
	}
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
	}
	
	return self;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.collectionView.transform = TNKInvertedTransform;
	
	[self.collectionView registerClass:[TNKMomentHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:TNKCollectionViewControllerHeaderIdentifier];
	
	
	[self _loadMoments];
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
		result = [PHAsset fetchAssetsInAssetCollection:collection options:self.assetFetchOptions];
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

- (void)_loadMoments {
	// first we load the first 20 sections to make sure that we initially show correct data
	// then we continue to load sections with estimated section counts
	// if the user scrolls to these sections, there may be mismatches and blank cells, but nothing will crash
	// then we asyncrounously load the rest of the sections to their final section counts
	
	PHFetchResult<PHAssetCollection *> *moments = _moments;
	
	__block NSInteger momentLoadingIndex = 0;
	NSMutableArray<TNKMomentInfo *> *sections = [NSMutableArray new];
	
	
	// the size we want to precache
	CGSize itemSize = [self _layout].itemSize;
	itemSize.width *= self.traitCollection.displayScale;
	itemSize.height *= self.traitCollection.displayScale;
	
	
	// because we invert the collection view we need to load moments in reverse order
	[moments enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAssetCollection * _Nonnull moment, NSUInteger index, BOOL * _Nonnull stop) {
		if (sections.count < 20) {
			PHFetchResult *fetchResult = [self _assetsForMoment:moment];
			NSUInteger count = fetchResult.count;
			
			if (count > 0) {
				momentLoadingIndex++;
				TNKMomentInfo *info = [[TNKMomentInfo alloc] initWithMoment:moment count:count];
				[sections addObject:info];
				
				// we only precache the first few sections because most user's won't need to scroll past those and we don't want to waste resources
				dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
					NSArray *assets = [fetchResult objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)]];
					[self.imageManager startCachingImagesForAssets:assets targetSize:itemSize contentMode:PHImageContentModeAspectFill options:[TNKAssetImageView imageRequestOptions]];
				});
			}
		} else {
			TNKMomentInfo *info = [[TNKMomentInfo alloc] initWithMoment:moment count:moment.estimatedAssetCount];
			[sections addObject:info];
		}
	}];
	
	
	_sections = [sections copy];
	[self.collectionView reloadData];
	
	
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
		// if _moments change, we might as well cancel because we will be out of date
		while (momentLoadingIndex < sections.count && _moments == moments) {
			TNKMomentInfo *oldInfo = [sections objectAtIndex:momentLoadingIndex];
			PHAssetCollection *moment = oldInfo.moment;
			
			PHFetchResult *fetchResult = [self _assetsForMoment:moment];
			NSUInteger count = fetchResult.count;
			
			// if a moment only has videos and we only display photos (or something similar) we will have empty moments
			if (count == 0) {
				[sections removeObjectAtIndex:momentLoadingIndex];
			} else {
				if (oldInfo.count != count) {
					TNKMomentInfo *info = [[TNKMomentInfo alloc] initWithMoment:moment count:count];
					[sections replaceObjectAtIndex:momentLoadingIndex withObject:info];
				}
				
				momentLoadingIndex++;
			}
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (_moments == moments) {
				_sections = sections;
				[self.collectionView reloadData];
			}
		});
	});
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


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
	dispatch_async(dispatch_get_main_queue(), ^{
		// at this time we can't update our fetch requests for each moment since NSCache doesn't give us access to all it's members
		[_momentCache removeAllObjects];
		
		PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:_moments];
		if (details != nil) {
			_moments = [details fetchResultAfterChanges];
		}
		
		[self _loadMoments];
	});
}

@end
