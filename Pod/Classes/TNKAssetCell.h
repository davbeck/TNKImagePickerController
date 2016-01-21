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

@property (nonatomic, strong, nullable) PHAsset *asset;
@property (nonatomic, strong, readonly) UIImageView *selectedBadgeImageView;

@end

NS_ASSUME_NONNULL_END
