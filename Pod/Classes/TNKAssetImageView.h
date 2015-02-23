//
//  TNKAssetImageView.h
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import <UIKit/UIKit.h>

@import Photos;


@interface TNKAssetImageView : UIImageView

@property (nonatomic, strong) UIImage *defaultImage;

@property PHImageRequestID imageRequestID;
@property (nonatomic, strong) PHAsset *asset;
- (void)cancelAssetImageRequest;

@end
