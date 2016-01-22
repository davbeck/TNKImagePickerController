//
//  TNKImagePickerControllerTableViewController.h
//  Pods
//
//  Created by David Beck on 2/17/15.
//
//

#import <UIKit/UIKit.h>

@class TNKCollectionPickerController;
@class PHAssetCollection;
@class PHCollectionList;
@class PHFetchOptions;

NS_ASSUME_NONNULL_BEGIN

@protocol TNKCollectionPickerControllerDelegate <NSObject>

- (void)collectionPicker:(TNKCollectionPickerController *)collectionPicker didSelectCollection:(nullable PHAssetCollection *)collection;

@end


@interface TNKCollectionPickerController : UITableViewController

@property (nonatomic, weak, nullable) id<TNKCollectionPickerControllerDelegate> delegate;

/** Additional asset collections that you want displayed.
 
 Instances are PHAssetCollection objects that will be displayed at the top of the list of collections.
 */
@property (nonatomic, copy, nullable) NSArray<PHAssetCollection *> *additionalAssetCollections;

/** A collection list to display.
 
 By default we display a list of all of the user's collections. Set this to only show a particular collection list of asset collections.
 */
@property (nonatomic, strong, nullable) PHCollectionList *collectionList;

@property (nonatomic, copy, nullable) PHFetchOptions *assetFetchOptions;

@end

NS_ASSUME_NONNULL_END
