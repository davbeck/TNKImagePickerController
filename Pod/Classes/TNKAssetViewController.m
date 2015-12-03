//
//  TNKAssetViewController.m
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import "TNKAssetViewController.h"

@import Photos;
#import <TULayoutAdditions/TULayoutAdditions.h>

#import "TNKImageZoomView.h"
#import "TNKImagePickerControllerBundle.h"


@interface TNKAssetViewController ()
{
    TNKImageZoomView *_scrollView;
}

@end

@implementation TNKAssetViewController

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    
    [self.view layoutIfNeeded];
    
    CGSize assetSize = CGSizeMake(_asset.pixelWidth, _asset.pixelHeight);
    _scrollView.imageSize = assetSize;
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.networkAccessAllowed = NO;
    
    CGSize targetSize = _scrollView.bounds.size;
    targetSize.width *= [UIScreen mainScreen].scale;
    targetSize.height *= [UIScreen mainScreen].scale;
    
    [[PHImageManager defaultManager] requestImageForAsset:_asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        _scrollView.image = result;
        
        if (![info[PHImageResultIsDegradedKey] boolValue] && !CGSizeEqualToSize(assetSize, result.size)) {
            options.networkAccessAllowed = YES;
            
            [[PHImageManager defaultManager] requestImageForAsset:_asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                _scrollView.image = result;
            }];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [TNKImageZoomView new];
    [self.view addSubview:_scrollView];
    _scrollView.constrainedLeft = @0.0;
    _scrollView.constrainedRight = @0.0;
    _scrollView.constrainedTop = @0.0;
    _scrollView.constrainedBottom = @0.0;
}

@end
