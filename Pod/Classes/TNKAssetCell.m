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
    [self.contentView addSubview:_imageView];
    
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_selectButton setImage:TNKImagePickerControllerImageNamed(@"checkmark") forState:UIControlStateNormal];
    [_selectButton setImage:TNKImagePickerControllerImageNamed(@"checkmark-selected") forState:UIControlStateSelected];
    [self.contentView addSubview:_selectButton];
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
    
    _selectButton.frame = CGRectMake(0.0, 0.0, 34.0, 34.0);
}

@end
