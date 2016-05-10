//
//  TNKAssetImageView.h
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import <UIKit/UIKit.h>

@import Photos;

NS_ASSUME_NONNULL_BEGIN

@interface TNKAssetImageView : UIImageView

@property (nonatomic, strong, nullable) UIImage *defaultImage;

@property (nonatomic, assign, readonly) PHImageRequestID imageRequestID;
@property (nonatomic, strong, nullable) PHAsset *asset;

@property (nonatomic, strong, null_resettable) PHImageManager *imageManager;

- (void)setNeedsAssetReload;
- (void)loadAssetImage;
- (void)cancelAssetImageRequest;

+ (PHImageRequestOptions *)imageRequestOptions;

@end

NS_ASSUME_NONNULL_END
