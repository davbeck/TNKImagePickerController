//
//  TNKImagePickerController.h
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import <UIKit/UIKit.h>

@import MobileCoreServices;
#import "PHImageManager+TNKRequestImages.h"
#import "TNKAssetsDetailViewController.h"

@class PHAssetCollection;
@class TNKImagePickerController;


@protocol TNKImagePickerControllerDelegate <NSObject>

@optional

/** Tells the delegate that the user finished picking images and movies.
 
 Your delegate object’s implementation of this method should pass the specified media on to any custom code that needs it, and should then dismiss the picker view.
 
 Instances of the assets set are `PHAsset` objects. You can request images for all the assets at once using the `TNKRequestImages` category on `PHImageManager` (`requestImagesForAssets:targetSize:contentMode:options:resultHandler:`).
 
 Implementation of this method is optional, but expected. If it is not implimented, the picker will be dismissed as a modal view controller.
 
 @param picker The controller object managing the image picker interface.
 @param assets The assets that were picked. These are the same as selectedAssets.
 */
- (void)imagePickerController:(TNKImagePickerController *)picker
       didFinishPickingAssets:(NSSet *)assets;

/** Tells the delegate that the user cancelled the pick operation.
 
 Your delegate’s implementation of this method should dismiss the picker view by calling the dismissModalViewControllerAnimated: method of the parent view controller.
 
 Implementation of this method is optional. If it is not implimented, the picker will be dismissed as a modal view controller.
 
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
- (UIViewController *)imagePickerController:(TNKImagePickerController *)picker
            willDisplayDetailViewController:(TNKAssetsDetailViewController *)viewController
                                   forAsset:(PHAsset *)asset;

/** Tells the delegate that the camera is about to be used.
 
 Return the passed in viewController to use the default behavior. You can customize the view controller, for instance by changing the settings of the camera. Alternatively, you can return a different view controller to be pushed instead, or even return nil to cancel the push entirely.
 
 @param picker The controller object managing the image picker interface.
 @param viewController The proposed view controller to be pushed.
 @return Either a view controller to be pushed, or nil to cancel.
 */
- (UIViewController *)imagePickerController:(TNKImagePickerController *)picker
            willDisplayCameraViewController:(UIImagePickerController *)viewController;

@end


@interface TNKImagePickerController : UICollectionViewController

@property (nonatomic, weak) id<TNKImagePickerControllerDelegate> delegate;

@property (nonatomic, readonly) UIBarButtonItem *cancelButton;
@property (nonatomic, readonly) UIBarButtonItem *doneButton;
@property (nonatomic, readonly) UIBarButtonItem *cameraButton;
@property (nonatomic, readonly) UIBarButtonItem *selectAllButton;


@property (nonatomic, copy) NSArray *mediaTypes;

/** The asset collection the picker will display to the user.
 
 The user can change this, but you can set this as a default. nil (the default) will cause the picker to display the user's moments.
 */
@property (nonatomic, strong) PHAssetCollection *assetCollection;

/** The currently selected assets.
 
 Instances are `PHAsset` objects. You can set this to provide default assets to be selected, or read them to see what the user has selected.
 */
@property (nonatomic, copy) NSSet *selectedAssets;
- (void)selectAsset:(PHAsset *)asset;
- (void)deselectAsset:(PHAsset *)asset;

@end
