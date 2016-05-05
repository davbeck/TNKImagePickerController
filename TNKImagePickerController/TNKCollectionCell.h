//
//  TNKCollectionListCell.h
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

@import UIKit;
@import Photos;


NS_ASSUME_NONNULL_BEGIN

@interface TNKCollectionCell : UITableViewCell

@property (nonatomic, strong, nullable) PHCollection *collection;

@property (nonatomic, readonly, strong) UILabel *titleLabel;
@property (nonatomic, readonly, strong) UILabel *subtitleLabel;
@property (nonatomic, readonly, strong) UIImageView *thumbnailView;

@end

NS_ASSUME_NONNULL_END
