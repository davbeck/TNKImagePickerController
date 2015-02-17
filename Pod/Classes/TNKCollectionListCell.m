//
//  TNKCollectionListCell.m
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import "TNKCollectionListCell.h"

#import <TULayoutAdditions/TULayoutAdditions.h>


#define TNKGridSize (3)
#define TNKTotalThumbnailWidth (68.0)
#define TNKSingleThumbnailWidth round((TNKTotalThumbnailWidth - 2.0) / TNKGridSize)


@interface TNKCollectionListCell ()
{
    UIView *_thumbnailView;
}

@end


@implementation TNKCollectionListCell

- (void)_init
{
    _titleLabel = [[UILabel alloc] init];
    [self addSubview:_titleLabel];
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.constrainedCenterY = @0.0;
    _titleLabel.constrainedTrailing = @0;
    
    
    _thumbnailView = [[UIView alloc] init];
    [self addSubview:_thumbnailView];
    _thumbnailView.constrainedTop = @8.0;
    _thumbnailView.constrainedLeading = @8.0;
    _thumbnailView.constrainedWidth = @TNKTotalThumbnailWidth;
    _thumbnailView.constrainedHeight = @TNKTotalThumbnailWidth;
    
    
    NSMutableArray *thumbnailViews = [NSMutableArray new];
    UIView *lastColumnView = nil;
    for (NSUInteger row = 0; row < TNKGridSize; row++) {
        for (NSUInteger column = 0; column < TNKGridSize; column++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [_thumbnailView addSubview:imageView];
            imageView.backgroundColor = [UIColor colorWithRed:0.921 green:0.921 blue:0.946 alpha:1.000];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.constrainedWidth = @(TNKSingleThumbnailWidth);
            imageView.constrainedHeight = @(TNKSingleThumbnailWidth);
            
            if (row == 0) {
                imageView.constrainedTop = @0.0;
            } else if (column == 0) {
                imageView.constrainedTop = [lastColumnView.constrainedBottom plus:1.0];
            } else {
                imageView.constrainedTop = [thumbnailViews.lastObject constrainedTop];
            }
            
            if (column == 0) {
                imageView.constrainedLeading = @0.0;
                lastColumnView = imageView;
            } else {
                imageView.constrainedLeading = [[thumbnailViews.lastObject constrainedTrailing] plus:1.0];
            }
            
            [thumbnailViews addObject:imageView];
        }
    }
    _thumbnailViews = [thumbnailViews copy];
    
    
    _titleLabel.constrainedLeading = [_thumbnailView.constrainedTrailing plus:18.0];
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

@end
