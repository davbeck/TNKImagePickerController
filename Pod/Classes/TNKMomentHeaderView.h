//
//  TNKMomentHeaderView.h
//  Pods
//
//  Created by David Beck on 2/23/15.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TNKMomentHeaderView : UICollectionReusableView

@property (nonatomic, strong, readonly) UILabel *primaryLabel;
@property (nonatomic, strong, readonly) UILabel *secondaryLabel;
@property (nonatomic, strong, readonly) UILabel *detailLabel;

@end

NS_ASSUME_NONNULL_END
