//
//  TNKCollectionViewController.m
//  TNKImagePickerController
//
//  Created by David Beck on 5/5/16.
//  Copyright © 2016 Think Ultimate LLC. All rights reserved.
//

#import "TNKCollectionViewController.h"
#import "TNKCollectionViewController_Private.h"

@import Photos;

#import "TNKCollectionsTitleButton.h"
#import "TNKCollectionPickerController.h"
#import "TNKAssetCell.h"
#import "TNKAssetImageView.h"
#import "TNKMomentHeaderView.h"
#import "TNKAssetsDetailViewController.h"
#import "NSDate+TNKFormattedDay.h"
#import "UIImage+TNKIcons.h"
#import "TNKAssetSelection.h"


@interface TNKCollectionViewController ()

@end

@implementation TNKCollectionViewController

- (void)setAssetSelection:(TNKAssetSelection *)assetSelection {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TNKAssetSelectionDidChangeNotification object:_assetSelection];
	
	_assetSelection = assetSelection;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetSelectionDidChange:) name:TNKAssetSelectionDidChangeNotification object:_assetSelection];
}


#pragma mark - Initialization

- (void)_init
{
	_imageManager = [[PHCachingImageManager alloc] init];
	
	[[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
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


#pragma mark - Notifications

- (void)assetSelectionDidChange:(NSNotification *)notification
{
	[self _updateSelection];
}


#pragma mark - Asset Management

- (nullable PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (NSIndexPath *)indexPathForAsset:(PHAsset *)asset
{
	return nil;
}

- (void)_updateSelection {
	if (!self.isViewLoaded) {
		return;
	}

	for (TNKAssetCell *cell in self.collectionView.visibleCells) {
		cell.assetSelected = [self.assetSelection isAssetSelected:cell.asset];
	}
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.collectionView.backgroundColor = [UIColor whiteColor];
	self.collectionView.alwaysBounceVertical = YES;
	
	[self.collectionView registerClass:[TNKAssetCell class] forCellWithReuseIdentifier:TNKCollectionViewControllerCellIdentifier];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	[super traitCollectionDidChange:previousTraitCollection];
	
	UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
	if ([flowLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
		// we want our assets to be about 100pts wide, but have a constant margin of 1
		NSInteger columns = floor(self.collectionView.bounds.size.width / 100.0);
		CGFloat width = floor((self.collectionView.bounds.size.width + TNKObjectSpacing) / columns) - TNKObjectSpacing;
		
		flowLayout.itemSize = CGSizeMake(width, width);
	}
}

- (nullable PHAsset *)assetAtPoint:(CGPoint)point {
	NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
	
	if (indexPath != nil) {
		return [self assetAtIndexPath:indexPath];
	} else {
		return nil;
	}
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	TNKAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TNKCollectionViewControllerCellIdentifier forIndexPath:indexPath];
	PHAsset *asset = [self assetAtIndexPath:indexPath];
	
	cell.imageView.imageManager = self.imageManager;
	cell.asset = asset;
	cell.assetSelected = [self.assetSelection isAssetSelected:asset];
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	PHAsset *asset = [self assetAtIndexPath:indexPath];
	
	if (asset != nil) {
		if ([self.assetSelection isAssetSelected:asset]) {
			[self.assetSelection deselectAsset:asset];
		} else {
			[self.assetSelection selectAsset:asset];
		}
	}
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
	
}

@end
