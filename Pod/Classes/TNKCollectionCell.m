//
//  TNKCollectionListCell.m
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import "TNKCollectionCell.h"


@interface TNKCollectionCell ()

@end


@implementation TNKCollectionCell

- (void)_init
{
    // we hide collections by making them 0pts tall
    self.clipsToBounds = YES;
    
    
    UILayoutGuide *labelsGuide = [[UILayoutGuide alloc] init];
    [self addLayoutGuide:labelsGuide];
    
    
	_titleLabel = [[UILabel alloc] init];
	_titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_titleLabel];
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _titleLabel.textColor = [UIColor blackColor];
    
    
    _subtitleLabel = [[UILabel alloc] init];
	_subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_subtitleLabel];
    _subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _subtitleLabel.textColor = [UIColor blackColor];
	
    
	_thumbnailView = [[UIImageView alloc] init];
	_thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_thumbnailView];
    _thumbnailView.contentMode = UIViewContentModeCenter;
    _thumbnailView.clipsToBounds = YES;
	
	
	[NSLayoutConstraint activateConstraints:@[
											  [labelsGuide.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
											  [labelsGuide.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
											  
											  [_titleLabel.topAnchor constraintEqualToAnchor:labelsGuide.topAnchor],
											  [_titleLabel.leadingAnchor constraintEqualToAnchor:labelsGuide.leadingAnchor],
											  [_titleLabel.trailingAnchor constraintEqualToAnchor:labelsGuide.trailingAnchor],
											  
											  [_subtitleLabel.bottomAnchor constraintEqualToAnchor:labelsGuide.bottomAnchor],
											  [_subtitleLabel.leadingAnchor constraintEqualToAnchor:labelsGuide.leadingAnchor],
											  [_subtitleLabel.trailingAnchor constraintEqualToAnchor:labelsGuide.trailingAnchor],
											  [_subtitleLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor],
											  
											  [_thumbnailView.topAnchor constraintEqualToAnchor:self.topAnchor constant:4],
											  [_thumbnailView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:4],
											  [_thumbnailView.widthAnchor constraintEqualToConstant:76],
											  [_thumbnailView.heightAnchor constraintEqualToConstant:76],
											  
											  [labelsGuide.leadingAnchor constraintEqualToAnchor:_thumbnailView.trailingAnchor constant:18],
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
