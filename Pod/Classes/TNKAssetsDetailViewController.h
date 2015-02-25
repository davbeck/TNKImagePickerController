//
//  TNKAssetsDetailViewController.h
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import <UIKit/UIKit.h>

@class PHAssetCollection;
@class PHAsset;


@interface TNKAssetsDetailViewController : UIPageViewController

/** The asset collection the picker will display to the user.
 
 nil (the default) will cause the picker to display the user's moments.
 */
@property (nonatomic, strong) PHAssetCollection *assetCollection;

- (void)showAssetAtIndexPath:(NSIndexPath *)indexPath;

@end
