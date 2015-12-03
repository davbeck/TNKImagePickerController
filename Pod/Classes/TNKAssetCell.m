//
//  TNKAssetCell.m
//  Pods
//
//  Created by David Beck on 2/23/15.
//
//

#import "TNKAssetCell.h"

#import "TNKAssetImageView.h"
#import "TNKImagePickerControllerBundle.h"


@implementation TNKAssetCell

- (void)_init {
    _imageView = [[TNKAssetImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [UIColor colorWithRed:0.921 green:0.921 blue:0.946 alpha:1.000];
    _imageView.layer.borderColor = [UIColor colorWithRed:0.401 green:0.682 blue:0.017 alpha:1.000].CGColor;
    [self.contentView addSubview:_imageView];
    
    _selectIcon = [[UIImageView alloc] init];
	_selectIcon.image = TNKImagePickerControllerImageNamed(@"checkmark-selected");
    [self.contentView addSubview:_selectIcon];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = self.contentView.bounds;
    
    _selectIcon.frame = CGRectMake(10.0, 10.0, _selectIcon.image.size.width, _selectIcon.image.size.height);
}

@end
