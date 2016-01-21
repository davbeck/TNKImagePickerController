//
//  TNKCollectionListCell.m
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import "TNKCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TNKCollectionCell ()
{
    UIView *_labelsView;
}

@end


@implementation TNKCollectionCell

- (void)_init
{
    // we hide collections by making them 0pts tall
    self.clipsToBounds = YES;

    _labelsView = [[UIView alloc] init];
    _labelsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_labelsView];


    _titleLabel = [[UILabel alloc] init];
    [_labelsView addSubview:_titleLabel];
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    
    _subtitleLabel = [[UILabel alloc] init];
    [_labelsView addSubview:_subtitleLabel];
    _subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _subtitleLabel.textColor = [UIColor blackColor];
    _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    
    _thumbnailView = [[UIImageView alloc] init];
    [self.contentView addSubview:_thumbnailView];
    _thumbnailView.contentMode = UIViewContentModeCenter;
    _thumbnailView.clipsToBounds = YES;
    _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [NSLayoutConstraint activateConstraints:@[
        [NSLayoutConstraint constraintWithItem:_labelsView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_labelsView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-18],

        [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_labelsView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_labelsView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_labelsView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],

        [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_labelsView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_labelsView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_labelsView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],

        [NSLayoutConstraint constraintWithItem:_thumbnailView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:4],
        [NSLayoutConstraint constraintWithItem:_thumbnailView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:4],
        [NSLayoutConstraint constraintWithItem:_thumbnailView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:76],
        [NSLayoutConstraint constraintWithItem:_thumbnailView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:76],

        [NSLayoutConstraint constraintWithItem:_labelsView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_thumbnailView attribute:NSLayoutAttributeTrailing multiplier:1 constant:18],
    ]];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
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

NS_ASSUME_NONNULL_END
