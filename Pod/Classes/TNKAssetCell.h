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


@interface TNKAssetCell : UICollectionViewCell

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImage *selectedBadgeImage;

@end
