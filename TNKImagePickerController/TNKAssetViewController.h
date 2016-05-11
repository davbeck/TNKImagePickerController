//
//  TNKAssetViewController.h
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import <UIKit/UIKit.h>

@class PHAsset;

NS_ASSUME_NONNULL_BEGIN

@interface TNKAssetViewController : UIViewController

@property (nonatomic, strong, nullable) PHAsset *asset;

@end

NS_ASSUME_NONNULL_END
