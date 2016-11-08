//
//  TNKAssetImageView.m
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import "TNKAssetImageView.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNKAssetImageView ()
{
    BOOL _needsAssetReload;
}

@property (nonatomic, assign) PHImageRequestID imageRequestID;

@end

@implementation TNKAssetImageView

+ (PHImageRequestOptions *)imageRequestOptions {
	static PHImageRequestOptions *options;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		options = [[PHImageRequestOptions alloc] init];
		options.networkAccessAllowed = YES;
		options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
	});
	
	return options;
}

- (PHImageManager *)imageManager {
	if (_imageManager == nil) {
		return [PHImageManager defaultManager];
	}
	
	return _imageManager;
}

- (void)setAsset:(nullable PHAsset *)asset
{
    if (_asset != asset) {
        [self cancelAssetImageRequest];
        
        _asset = asset;
        self.image = self.defaultImage;
        
        [self loadAssetImage];
    }
}

- (void)setNeedsAssetReload
{
    if (!_needsAssetReload) {
        _needsAssetReload = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadAssetImage];
        });
    }
}

- (void)loadAssetImage
{
    [self cancelAssetImageRequest];
	
	PHAsset *asset = _asset;
    
    if (asset != nil && self.bounds.size.width > 0.0 && self.bounds.size.height > 0.0) {
		CGSize size = self.bounds.size;
        size.width *= self.traitCollection.displayScale;
        size.height *= self.traitCollection.displayScale;
		
		self.imageRequestID = [self.imageManager requestImageForAsset:_asset targetSize:size contentMode:PHImageContentModeAspectFill options:[self.class imageRequestOptions] resultHandler:^(UIImage *result, NSDictionary *info) {
			NSAssert([NSThread isMainThread], @"isMainThread");
			if (_asset == asset && result != nil) {
				self.image = result;
			}
		}];
	}
	
    _needsAssetReload = NO;
}

- (void)cancelAssetImageRequest
{
    if (self.imageRequestID != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        self.imageRequestID = 0;
    }
}

- (void)setFrame:(CGRect)frame
{
    BOOL changed = !CGSizeEqualToSize(self.frame.size, frame.size);
    
    [super setFrame:frame];
    
    if (changed) {
        [self setNeedsAssetReload];
    }
}

- (void)setBounds:(CGRect)bounds
{
    BOOL changed = !CGSizeEqualToSize(self.bounds.size, bounds.size);
    
    [super setBounds:bounds];
    
    if (changed) {
        [self setNeedsAssetReload];
    }
}

@end

NS_ASSUME_NONNULL_END
