//
//  TNKMomentHeaderView.m
//  Pods
//
//  Created by David Beck on 2/23/15.
//
//

#import "TNKMomentHeaderView.h"


@interface TNKMomentHeaderView ()
{
    UIVisualEffectView *_backgroundView;
    UIView *_centeringView;
}
@end


@implementation TNKMomentHeaderView

- (void)_init
{
    _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_backgroundView];

    _centeringView = [[UIView alloc] init];
    _centeringView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_centeringView];

    _primaryLabel = [[UILabel alloc] init];
    _primaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _primaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_centeringView addSubview:_primaryLabel];

    _secondaryLabel = [[UILabel alloc] init];
    _secondaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    _secondaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_centeringView addSubview:_secondaryLabel];

    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_centeringView addSubview:_detailLabel];
    [_detailLabel setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];

    [NSLayoutConstraint activateConstraints:@[
        [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0],

        [NSLayoutConstraint constraintWithItem:_centeringView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:8],
        [NSLayoutConstraint constraintWithItem:_centeringView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-8],
        [NSLayoutConstraint constraintWithItem:_centeringView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],

        [NSLayoutConstraint constraintWithItem:_primaryLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_primaryLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_primaryLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],

        [NSLayoutConstraint constraintWithItem:_secondaryLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_primaryLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_secondaryLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_secondaryLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],

        [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_primaryLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_secondaryLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:8],
        [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
    ]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

@end
