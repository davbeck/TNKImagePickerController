//
//  TNKAssetImageView.m
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import "TNKAssetImageView.h"

#import "TNKImagePickerControllerBundle.h"


@interface TNKAssetImageView ()
{
    
}

@end

@implementation TNKAssetImageView

- (void)setAsset:(PHAsset *)asset
{
    [self cancelAssetImageRequest];
    
    _asset = asset;
    self.image = self.defaultImage;
    
    if (self.window != nil) {
        [self loadAssetImage];
    }
}

- (void)loadAssetImage
{
    [self cancelAssetImageRequest];
    
    if (_asset != nil) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        
        CGSize size = self.bounds.size;
        size.width *= self.traitCollection.displayScale;
        size.height *= self.traitCollection.displayScale;
        
        self.imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:_asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            self.image = result;
        }];
    }
}

- (void)cancelAssetImageRequest
{
    if (self.imageRequestID != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        self.imageRequestID = 0;
    }
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    [self loadAssetImage];
}

@end
