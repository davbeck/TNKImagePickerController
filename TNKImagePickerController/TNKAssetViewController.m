//
//  TNKAssetViewController.m
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import "TNKAssetViewController.h"

@import Photos;

#import "TNKImageZoomView.h"


NS_ASSUME_NONNULL_BEGIN

@interface TNKAssetViewController ()
{
    TNKImageZoomView *_scrollView;
}

@end

@implementation TNKAssetViewController

- (void)setAsset:(nullable PHAsset *)asset {
    _asset = asset;
    
    [self.view layoutIfNeeded];
    
    CGSize assetSize = CGSizeMake(_asset.pixelWidth, _asset.pixelHeight);
    _scrollView.imageSize = assetSize;
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.networkAccessAllowed = YES;
    
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
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scrollView];

    [NSLayoutConstraint activateConstraints:@[
        [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
    ]];
}

@end

NS_ASSUME_NONNULL_END
