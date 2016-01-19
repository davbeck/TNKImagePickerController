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
	_scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scrollView];
	
	[NSLayoutConstraint activateConstraints:@[
											  [_scrollView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
											  [_scrollView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
											  [_scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
											  [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
											  ]];
}

@end
