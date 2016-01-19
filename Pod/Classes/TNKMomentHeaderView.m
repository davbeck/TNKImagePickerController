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
}
@end


@implementation TNKMomentHeaderView

- (void)_init
{
    _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
	_backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_backgroundView];
    
	UILayoutGuide *centeringGuide = [[UILayoutGuide alloc] init];
    [self addLayoutGuide:centeringGuide];
    
	_primaryLabel = [[UILabel alloc] init];
	_primaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _primaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self addSubview:_primaryLabel];
    
	_secondaryLabel = [[UILabel alloc] init];
	_secondaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _secondaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    [self addSubview:_secondaryLabel];
    
	_detailLabel = [[UILabel alloc] init];
	_detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    [self addSubview:_detailLabel];
    [_detailLabel setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
	
	
	[NSLayoutConstraint activateConstraints:@[
											  [_backgroundView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
											  [_backgroundView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
											  [_backgroundView.topAnchor constraintEqualToAnchor:self.topAnchor],
											  [_backgroundView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
											  
											  [centeringGuide.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8],
											  [centeringGuide.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8],
											  [centeringGuide.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
											  
											  [_primaryLabel.topAnchor constraintEqualToAnchor:centeringGuide.topAnchor],
											  [_primaryLabel.leadingAnchor constraintEqualToAnchor:centeringGuide.leadingAnchor],
											  [_primaryLabel.trailingAnchor constraintEqualToAnchor:centeringGuide.trailingAnchor],
											  
											  [_secondaryLabel.topAnchor constraintEqualToAnchor:_primaryLabel.bottomAnchor],
											  [_secondaryLabel.leadingAnchor constraintEqualToAnchor:centeringGuide.leadingAnchor],
											  [_secondaryLabel.bottomAnchor constraintEqualToAnchor:centeringGuide.bottomAnchor],
											  
											  [_detailLabel.topAnchor constraintEqualToAnchor:_primaryLabel.bottomAnchor],
											  [_detailLabel.leadingAnchor constraintEqualToAnchor:_secondaryLabel.trailingAnchor constant:8],
											  [_detailLabel.trailingAnchor constraintEqualToAnchor:centeringGuide.trailingAnchor],
											  [_detailLabel.bottomAnchor constraintEqualToAnchor:centeringGuide.bottomAnchor],
											  ]];
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
