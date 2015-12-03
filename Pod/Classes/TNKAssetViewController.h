//
//  TNKAssetViewController.h
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import <UIKit/UIKit.h>

@class PHAsset;


@interface TNKAssetViewController : UIViewController

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) NSIndexPath *assetIndexPath;

@end
