//
//  TNKMomentHeaderView.m
//  Pods
//
//  Created by David Beck on 2/23/15.
//
//

#import "TNKMomentHeaderView.h"

#import <TULayoutAdditions/TULayoutAdditions.h>


@interface TNKMomentHeaderView ()
{
    UIView *_centeringView;
    UIVisualEffectView *_backgroundView;
}
@end


@implementation TNKMomentHeaderView

- (void)_init
{
    _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    [self addSubview:_backgroundView];
    _backgroundView.constrainedTop = @0.0;
    _backgroundView.constrainedLeft = @0.0;
    _backgroundView.constrainedRight = @0.0;
    _backgroundView.constrainedBottom = @0.0;
    
    _centeringView = [[UIView alloc] init];
    [self addSubview:_centeringView];
    _centeringView.constrainedLeading = @8.0;
    _centeringView.constrainedTrailing = @-8.0;
    _centeringView.constrainedCenterY = @0.0;
    
    _primaryLabel = [[UILabel alloc] init];
    _primaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [_centeringView addSubview:_primaryLabel];
    _primaryLabel.constrainedTop = @0.0;
    _primaryLabel.constrainedLeading = @0.0;
    _primaryLabel.constrainedTrailing = @0.0;
    
    _secondaryLabel = [[UILabel alloc] init];
    _secondaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    [_centeringView addSubview:_secondaryLabel];
    _secondaryLabel.constrainedTop = _primaryLabel.constrainedBottom;
    _secondaryLabel.constrainedLeading = @0.0;
    _secondaryLabel.constrainedBottom = @0.0;
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    [_centeringView addSubview:_detailLabel];
    _detailLabel.constrainedTop = _primaryLabel.constrainedBottom;
    _detailLabel.constrainedLeading = [_secondaryLabel.constrainedTrailing plus:8.0];
    _detailLabel.constrainedTrailing = @0.0;
    _detailLabel.constrainedBottom = @0.0;
    [_detailLabel setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

@end
