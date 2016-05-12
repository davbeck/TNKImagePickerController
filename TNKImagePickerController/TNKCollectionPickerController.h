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

/** Notify the delegate that a collection has been picked.
 
 When the user taps on a collection, this method is called on the delegate. Make sure to dismiss the picker.
 
 @param collectionPicker The picker view controller.
 @param collection The collection that was picked, or nil if moments were selected.
 */
- (void)collectionPicker:(TNKCollectionPickerController *)collectionPicker didSelectCollection:(nullable PHAssetCollection *)collection;

@end


@interface TNKCollectionPickerController : UITableViewController

/** The picker's delegate
 
 Set this to get the result of the collection picked.
 */
@property (nonatomic, weak, nullable) id<TNKCollectionPickerControllerDelegate> delegate;

/** A collection list to display.
 
 By default we display a list of all of the user's collections. Set this to only show a particular collection list of asset collections.
 */
@property (nonatomic, strong, nullable, readonly) PHCollectionList *collectionList;

/** Initialize the view controller to show a particular collection list.
 
 When set, moments will not be shown.
 
 @param collectionList The collection list to display.
 @return A new view controller with collectionList set.
 */
- (instancetype)initWithCollectionList:(PHCollectionList *)collectionList;

/** Additional asset collections that you want displayed.
 
 Instances are PHAssetCollection objects that will be displayed at the top of the list of collections.
 */
@property (nonatomic, copy, nullable) NSArray<PHAssetCollection *> *additionalAssetCollections;

/** The fetch options to use to fetch assets.
 
 This is used to get an acurate count of the number of assets in a given collection and to generate the collection thumbnails.
 */
@property (nonatomic, copy, nullable) PHFetchOptions *assetFetchOptions;

@end

NS_ASSUME_NONNULL_END
