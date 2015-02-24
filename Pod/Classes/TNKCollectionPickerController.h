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


@protocol TNKCollectionPickerControllerDelegate <NSObject>

- (void)collectionPicker:(TNKCollectionPickerController *)collectionPicker didSelectCollection:(PHAssetCollection *)collection;

@end


@interface TNKCollectionPickerController : UITableViewController

@property (nonatomic, weak) id<TNKCollectionPickerControllerDelegate> delegate;

/** Additional asset collections that you want displayed.
 
 Instances are PHAssetCollection objects that will be displayed at the top of the list of collections.
 */
@property (nonatomic, copy) NSArray *additionalAssetCollections;

@end
