//
//  UIImageView+TNKAssets.m
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import "UIImageView+TNKAssets.h"

#import <objc/runtime.h>

#import "TNKImagePickerControllerBundle.h"


@implementation UIImageView (TNKAssets)

- (UIImage *)_defaultAssetImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = TNKImagePickerControllerBundle();
        image = [UIImage imageNamed:@"default-collection" inBundle:bundle compatibleWithTraitCollection:nil];
    });
    
    return image;
}

- (void)setImageRequestID:(PHImageRequestID)imageRequestID
{
    objc_setAssociatedObject(self, @selector(imageRequestID), @(imageRequestID), OBJC_ASSOCIATION_RETAIN);
}

- (PHImageRequestID)imageRequestID
{
    return [objc_getAssociatedObject(self, @selector(imageRequestID)) intValue];
}

- (void)setAsset:(PHAsset *)asset
{
    [self cancelAssetImageRequest];
    
    objc_setAssociatedObject(self, @selector(asset), asset, OBJC_ASSOCIATION_RETAIN);
    
    self.image = [self _defaultAssetImage];
    
    if (asset != nil) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        
        CGSize size = self.bounds.size;
        size.width *= self.traitCollection.displayScale;
        size.height *= self.traitCollection.displayScale;
        
        self.imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            self.image = result;
        }];
    }
}

- (PHAsset *)asset
{
    return objc_getAssociatedObject(self, @selector(asset));
}

- (void)cancelAssetImageRequest
{
    if (self.imageRequestID != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
}

@end
