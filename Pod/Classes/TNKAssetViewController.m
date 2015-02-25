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


@interface TNKAssetViewController ()
{
    TNKImageZoomView *_scrollView;
}

@end

@implementation TNKAssetViewController

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageForAsset:_asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        _scrollView.image = result;
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
