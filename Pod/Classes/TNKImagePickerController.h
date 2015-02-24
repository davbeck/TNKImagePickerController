//
//  TNKImagePickerController.h
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import <UIKit/UIKit.h>

@class PHAssetCollection;


@interface TNKImagePickerController : UICollectionViewController

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;


/** The asset collection the picker will display to the user.
 
 The user can change this, but you can set this as a default. nil (the default) will cause the picker to display the user's moments.
 */
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@property (nonatomic, copy) NSSet *selectedAssets;

@end
