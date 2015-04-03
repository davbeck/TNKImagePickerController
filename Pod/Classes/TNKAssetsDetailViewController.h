//
//  TNKAssetsDetailViewController.h
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import <UIKit/UIKit.h>

@class TNKAssetsDetailViewController;
@class PHAssetCollection;
@class PHAsset;
@class PHFetchOptions;


extern NSString *TNKImagePickerControllerWillShowAssetNotification;
extern NSString *TNKImagePickerControllerAssetViewControllerNotificationKey;


@protocol TNKAssetsDetailViewControllerDelegate <NSObject>

- (BOOL)assetsDetailViewController:(TNKAssetsDetailViewController *)viewController isAssetSelectedAtIndexPath:(NSIndexPath *)indexPath;

- (void)assetsDetailViewController:(TNKAssetsDetailViewController *)viewController selectAssetAtIndexPath:(NSIndexPath *)indexPath;
- (void)assetsDetailViewController:(TNKAssetsDetailViewController *)viewController deselectAssetAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface TNKAssetsDetailViewController : UIPageViewController

@property (nonatomic, weak) id<TNKAssetsDetailViewControllerDelegate> assetDelegate;

/** The class used to create individual asset view controllers
 
 This class should be a subclass of `TNKAssetViewController`.
 */
@property (nonatomic, strong) Class assetViewControllerClass;

/** The asset collection the picker will display to the user.
 
 nil (the default) will cause the picker to display the user's moments.
 */
@property (nonatomic, strong) PHAssetCollection *assetCollection;

- (void)showAssetAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) PHFetchOptions *assetFetchOptions;

@end
