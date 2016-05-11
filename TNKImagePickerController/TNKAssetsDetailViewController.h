//
//  TNKAssetsDetailViewController.h
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import <UIKit/UIKit.h>

@class TNKAssetsDetailViewController;
@class TNKAssetSelection;
@class PHAssetCollection;
@class PHAsset;
@class PHFetchOptions;


NS_ASSUME_NONNULL_BEGIN

extern NSString *const TNKImagePickerControllerWillShowAssetNotification;
extern NSString *const TNKImagePickerControllerAssetViewControllerNotificationKey;


@interface TNKAssetsDetailViewController : UIPageViewController

@property (nonatomic, nullable) TNKAssetSelection *assetSelection;

/** The class used to create individual asset view controllers
 
 This class should be a subclass of `TNKAssetViewController`.
 */
@property (nonatomic, assign) Class assetViewControllerClass;

/** The asset collection the picker will display to the user.
 
 nil (the default) will cause the picker to display the user's moments.
 */
@property (nonatomic, strong, nullable) PHAssetCollection *assetCollection;

- (void)showAsset:(PHAsset *)asset;

@property (nonatomic, copy, nullable) PHFetchOptions *assetFetchOptions;

@end

NS_ASSUME_NONNULL_END
