//
//  TNKCollectionViewController.h
//  TNKImagePickerController
//
//  Created by David Beck on 5/5/16.
//  Copyright © 2016 Think Ultimate LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@class PHFetchOptions;
@class PHCachingImageManager;


#define TNKObjectSpacing 1.0

#define TNKCollectionViewControllerCellIdentifier @"Cell"


NS_ASSUME_NONNULL_BEGIN

@interface TNKCollectionViewController : UICollectionViewController

/** The insets for the layout guides.
 
 Normally this would be automatically handled by top and bottomLayoutGuide, but because these view controllers are normally presented inside of a UIPageViewController, those properties do not propogate.
 */
@property (nonatomic) UIEdgeInsets layoutInsets;

- (nullable PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathForAsset:(PHAsset *)asset;

@property (nonatomic, copy, nullable) PHFetchOptions *assetFetchOptions;

@property (nonatomic, strong, readonly, nullable) PHCachingImageManager *imageManager;

/** Find the asset displayed at the given point.
 
 @param point A point in the collectionView's coordinate space.
 @return An asset at that point.
 */
- (nullable PHAsset *)assetAtPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
