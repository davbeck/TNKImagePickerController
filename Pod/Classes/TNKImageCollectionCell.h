//
//  TNKImageCollectionCell.h
//  Pods
//
//  Created by David Beck on 2/18/15.
//
//

#import <UIKit/UIKit.h>

@import Photos;


@interface TNKImageCollectionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;

@end
