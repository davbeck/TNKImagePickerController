//
//  UIImageView+TNKAssets.h
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import <UIKit/UIKit.h>

@import Photos;


@interface UIImageView (TNKAssets)

@property PHImageRequestID imageRequestID;
@property (strong) PHAsset *asset;
- (void)cancelAssetImageRequest;

@end
