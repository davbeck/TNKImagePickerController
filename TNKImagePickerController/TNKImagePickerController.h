//
//  TNKImagePickerController.h
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import <UIKit/UIKit.h>

//! Project version number for TNKImagePickerController.
FOUNDATION_EXPORT double TNKImagePickerControllerVersionNumber;

//! Project version string for TNKImagePickerController.
FOUNDATION_EXPORT const unsigned char TNKImagePickerControllerVersionString[];


@import MobileCoreServices;

#import <TNKImagePickerController/NSDate+TNKFormattedDay.h>
#import <TNKImagePickerController/PHCollection+TNKThumbnail.h>
#import <TNKImagePickerController/PHImageManager+TNKRequestImages.h>
#import <TNKImagePickerController/PHPhotoLibrary+TNKBlockObservers.h>
#import <TNKImagePickerController/TNKAssetCell.h>
#import <TNKImagePickerController/TNKAssetImageView.h>
#import <TNKImagePickerController/TNKAssetsDetailViewController.h>
#import <TNKImagePickerController/TNKAssetViewController.h>
#import <TNKImagePickerController/TNKCollectionCell.h>
#import <TNKImagePickerController/TNKCollectionPickerController.h>
#import <TNKImagePickerController/TNKCollectionsTitleButton.h>
#import <TNKImagePickerController/TNKCollectionViewFloatingHeaderFlowLayout.h>
#import <TNKImagePickerController/TNKImagePickerControllerBundle.h>
#import <TNKImagePickerController/TNKImageZoomView.h>
#import <TNKImagePickerController/TNKMomentHeaderView.h>
#import <TNKImagePickerController/UIImage+TNKAspectDraw.h>

@class PHAssetCollection;
@class TNKImagePickerController;


NS_ASSUME_NONNULL_BEGIN

@protocol TNKImagePickerControllerDelegate <NSObject>

@optional

/** Tells the delegate that the user finished picking images and movies.
 
 Your delegate object’s implementation of this method should pass the specified media on to any custom code that needs it, and should then dismiss the picker view.
 
 Instances of the assets set are `PHAsset` objects. You can request images for all the assets at once using the `TNKRequestImages` category on `PHImageManager` (`tnk_requestImagesForAssets:targetSize:contentMode:options:resultHandler:`).
 
 Implementation of this method is optional, but expected. If it is not implemented, the picker will be dismissed as a modal view controller.
 
 @param picker The controller object managing the image picker interface.
 @param assets The assets that were picked. These are the same as selectedAssets.
 */
- (void)imagePickerController:(TNKImagePickerController *)picker
       didFinishPickingAssets:(NSArray<PHAsset *> *)assets;

/** Tells the delegate that the user cancelled the pick operation.
 
 Your delegate’s implementation of this method should dismiss the picker view by calling the `-dismissModalViewControllerAnimated:` method of the parent view controller.
 
 Implementation of this method is optional. If it is not implemented, the picker will be dismissed as a modal view controller.
 
 @param picker The controller object managing the image picker interface.
 */
- (void)imagePickerControllerDidCancel:(TNKImagePickerController *)picker;

/** Tells the delegate that an image is being displayed fullscreen.
 
 Return the passed in viewController to use the default behavior. You can customize the view controller, for instance adding toolbar items and setting the `hidesBottomBarWhenPushed` to `NO`. Alternatively, you can return a different view controller to be pushed instead, or even return nil to cancel the push entirely.
 
 @param picker The controller object managing the image picker interface.
 @param viewController The proposed view controller to be pushed.
 @param asset The asset being displayed.
 @return Either a view controller to be pushed, or nil to cancel.
 */
- (nullable UIViewController *)imagePickerController:(TNKImagePickerController *)picker
                     willDisplayDetailViewController:(TNKAssetsDetailViewController *)viewController
                                            forAsset:(PHAsset *)asset;

/** Tells the delegate that the camera is about to be used.
 
 Return the passed in viewController to use the default behavior. You can customize the view controller, for instance by changing the settings of the camera. Alternatively, you can return a different view controller to be pushed instead, or even return nil to cancel the push entirely.
 
 @param picker The controller object managing the image picker interface.
 @param viewController The proposed view controller to be pushed.
 @return Either a view controller to be pushed, or nil to cancel.
 */
- (nullable UIViewController *)imagePickerController:(TNKImagePickerController *)picker
                     willDisplayCameraViewController:(UIImagePickerController *)viewController;

/** Asks the delegate for a title for the done button
 
 The delegate can use this to change the text used for the done button. The done button is updated whenever the selection changes.
 
 @param picker The controller object managing the image picker interface.
 */
- (NSString *)imagePickerControllerTitleForDoneButton:(TNKImagePickerController *)picker;

@end


@interface TNKImagePickerController : UICollectionViewController

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout NS_UNAVAILABLE;

@property (nonatomic, weak, nullable) id<TNKImagePickerControllerDelegate> delegate;

@property (nonatomic, readonly) UIBarButtonItem *cancelButton;
@property (nonatomic, readonly) UIBarButtonItem *doneButton;
@property (nonatomic, readonly) UIBarButtonItem *cameraButton;
@property (nonatomic, readonly) UIBarButtonItem *pasteButton;
@property (nonatomic, readonly) UIBarButtonItem *selectAllButton;
@property (nonatomic) BOOL hideSelectAll;

@property (nonatomic, strong, null_resettable) UIImage *selectedAssetBadgeImage;

@property (nonatomic, copy) NSArray<NSString *> *mediaTypes;

/** The asset collection the picker will display to the user.
 
 The user can change this, but you can set this as a default. nil (the default) will cause the picker to display the user's moments.
 */
@property (nonatomic, strong, nullable) PHAssetCollection *assetCollection;

/** The currently selected assets.
 
 Instances are `PHAsset` objects. You can set this to provide default assets to be selected, or read them to see what the user has selected. The order will be roughly the same as the order that the user selected them in.
 */
@property (nonatomic, copy) NSArray<PHAsset *> *selectedAssets;
- (void)selectAsset:(PHAsset *)asset;
- (void)deselectAsset:(PHAsset *)asset;

@end

NS_ASSUME_NONNULL_END
