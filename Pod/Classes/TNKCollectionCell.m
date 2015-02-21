//
//  TNKCollectionListCell.m
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import "TNKCollectionCell.h"

#import <TULayoutAdditions/TULayoutAdditions.h>


@interface TNKCollectionCell ()
{
    UIView *_labelsView;
}

@end


@implementation TNKCollectionCell

- (void)_init
{
    _labelsView = [[UIView alloc] init];
    [self addSubview:_labelsView];
    _labelsView.constrainedCenterY = @0.0;
    _labelsView.constrainedTrailing = @0.0;
    
    
    _titleLabel = [[UILabel alloc] init];
    [_labelsView addSubview:_titleLabel];
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.constrainedTop = @0.0;
    _titleLabel.constrainedLeading = @0.0;
    _titleLabel.constrainedTrailing = @0.0;
    
    
    _subtitleLabel = [[UILabel alloc] init];
    [_labelsView addSubview:_subtitleLabel];
    _subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _subtitleLabel.textColor = [UIColor blackColor];
    _subtitleLabel.constrainedBottom = @0.0;
    _subtitleLabel.constrainedLeading = @0.0;
    _subtitleLabel.constrainedTrailing = @0.0;
    _subtitleLabel.constrainedTop = _titleLabel.constrainedBottom;
    
    
    _thumbnailView = [[UIImageView alloc] init];
    [self addSubview:_thumbnailView];
    _thumbnailView.contentMode = UIViewContentModeCenter;
    _thumbnailView.clipsToBounds = YES;
    _thumbnailView.constrainedTop = @4.0;
    _thumbnailView.constrainedLeading = @4.0;
    _thumbnailView.constrainedWidth = @76.0;
    _thumbnailView.constrainedHeight = @76.0;
    
    
    _labelsView.constrainedLeading = [_thumbnailView.constrainedTrailing plus:18.0];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.titleLabel.text = nil;
    self.subtitleLabel.text = nil;
    self.thumbnailView.image = nil;
}

@end
