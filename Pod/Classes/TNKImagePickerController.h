//
//  TNKImagePickerController.h
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import <UIKit/UIKit.h>

#import "PHImageManager+TNKRequestImages.h"

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

@end


@interface TNKImagePickerController : UICollectionViewController

@property (nonatomic, weak) id<TNKImagePickerControllerDelegate> delegate;

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;


/** The asset collection the picker will display to the user.
 
 The user can change this, but you can set this as a default. nil (the default) will cause the picker to display the user's moments.
 */
@property (nonatomic, strong) PHAssetCollection *assetCollection;

/** The currently selected assets.
 
 Instances are `PHAsset` objects. You can set this to provide default assets to be selected, or read them to see what the user has selected.
 */
@property (nonatomic, copy) NSSet *selectedAssets;

@end
