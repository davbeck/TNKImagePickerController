//
//  TNKAssetCell.h
//  Pods
//
//  Created by David Beck on 2/23/15.
//
//

#import <UIKit/UIKit.h>

@class TNKAssetImageView;
@class PHAsset;

NS_ASSUME_NONNULL_BEGIN

@interface TNKAssetCell : UICollectionViewCell

@property (nonatomic, strong) TNKAssetImageView *imageView;

@property (nonatomic, strong, nullable) PHAsset *asset;
@property (nonatomic) BOOL assetSelected;
@property (nonatomic, strong, readonly) UIImageView *selectedBadgeImageView;

@property (nonatomic, strong, null_resettable) UIImage *selectedAssetBadgeImage UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
