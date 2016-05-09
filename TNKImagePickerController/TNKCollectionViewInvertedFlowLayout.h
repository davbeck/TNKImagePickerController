//
//  TNKCollectionViewInvertedFlowLayout.h
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import <UIKit/UIKit.h>


#define TNKInvertedTransform CGAffineTransformMake(1, 0, 0, -1, 0, 0)


/** 
 A layout that flips all of it's views vertically.
 
 In order to flip the origin of our moments collection view to the bottom so that new content is inserted at the top without pushing content down, we use a transform to invert scrolling. We then need to flip all of the views (cells and suplementary views) so that they aren't upside down.
 
 Inspired by https://github.com/slackhq/SlackTextViewController.
*/
@interface TNKCollectionViewInvertedFlowLayout : UICollectionViewFlowLayout

@end
