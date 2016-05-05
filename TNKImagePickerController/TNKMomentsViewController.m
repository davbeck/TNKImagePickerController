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
#import "TNKCollectionViewFloatingHeaderFlowLayout.h"
#import "TNKAssetsDetailViewController.h"
#import "NSDate+TNKFormattedDay.h"
#import "UIImage+TNKIcons.h"


#define TNKCollectionViewControllerHeaderIdentifier @"HeaderView"


@interface TNKMomentsViewController () {
	PHFetchResult<PHAssetCollection *> *_moments;
	NSCache *_momentCache;
	BOOL _windowLoaded;
}

@end

@implementation TNKMomentsViewController

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		_moments = [PHAssetCollection fetchMomentsWithOptions:nil];
		_momentCache = [[NSCache alloc] init];
	}
	
	return self;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.collectionView registerClass:[TNKMomentHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TNKCollectionViewControllerHeaderIdentifier];
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

- (void)_scrollToBottomAnimated:(BOOL)animated {
	CGPoint contentOffset = self.collectionView.contentOffset;
	contentOffset.y = self.collectionView.contentSize.height - self.collectionView.bounds.size.height + self.collectionView.contentInset.bottom;
	contentOffset.y = MAX(contentOffset.y, -self.collectionView.contentInset.top);
	contentOffset.y = MAX(self.collectionView.contentSize.height - self.collectionView.bounds.size.height + self.collectionView.contentInset.bottom, -self.collectionView.contentInset.top);
	[self.collectionView setContentOffset:contentOffset animated:animated];
}


#pragma mark - Asset Management

- (PHFetchResult *)_assetsForMoment:(PHAssetCollection *)collection
{
	PHFetchResult *result = [_momentCache objectForKey:collection.localIdentifier];
	if (result == nil) {
		result = [PHAsset fetchAssetsInAssetCollection:collection options:[self assetFetchOptions]];
		[_momentCache setObject:result forKey:collection.localIdentifier];
	}
	
	return result;
}

- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath
{
	PHAssetCollection *collection = _moments[indexPath.section];
	PHFetchResult *fetchResult = [self _assetsForMoment:collection];
	return fetchResult[indexPath.row];
}

- (NSIndexPath *)indexPathForAsset:(PHAsset *)asset {
	PHAssetCollection *collection = [PHAssetCollection fetchAssetCollectionsContainingAsset:asset withType:PHAssetCollectionTypeMoment options:nil].firstObject;
	NSUInteger section = [_moments indexOfObject:collection];
	
	PHFetchResult *fetchResult = [self _assetsForMoment:collection];
	NSUInteger item = [fetchResult indexOfObject:asset];
	
	if (item != NSNotFound && section != NSNotFound) {
		return [NSIndexPath indexPathForItem:item inSection:section];
	} else {
		return nil;
	}
}


#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _moments.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	PHAssetCollection *collection = _moments[section];
	PHFetchResult *fetchResult = [self _assetsForMoment:collection];
	return fetchResult.count;
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


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_momentCache removeAllObjects];

		PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:_moments];
		if (details != nil) {
			_moments = [details fetchResultAfterChanges];
			
			// incremental updates throw exceptions too often
			[self.collectionView reloadData];
		}
    });
}

@end
