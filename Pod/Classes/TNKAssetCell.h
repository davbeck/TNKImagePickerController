//
//  TNKAssetCell.h
//  Pods
//
//  Created by David Beck on 2/23/15.
//
//

#import <UIKit/UIKit.h>

@class TNKAssetImageView;


@interface TNKAssetCell : UICollectionViewCell

@property (nonatomic, strong) TNKAssetImageView *imageView;
@property (nonatomic, strong) UIImageView *selectIcon;

@end
