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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selected"] && object == _selectButton) {
        if (_selectButton.selected) {
            self.imageView.layer.borderWidth = 1.0;
        } else {
            self.imageView.layer.borderWidth = 0.0;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [_selectButton removeObserver:self forKeyPath:@"selected"];
}

- (void)_init {
    _imageView = [[TNKAssetImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [UIColor colorWithRed:0.921 green:0.921 blue:0.946 alpha:1.000];
    [self.contentView addSubview:_imageView];
    
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_selectButton setImage:TNKImagePickerControllerImageNamed(@"checkmark") forState:UIControlStateNormal];
    [_selectButton setImage:TNKImagePickerControllerImageNamed(@"checkmark-selected") forState:UIControlStateSelected];
    self.imageView.layer.borderColor = [UIColor colorWithRed:0.401 green:0.682 blue:0.017 alpha:1.000].CGColor;
    [self.contentView addSubview:_selectButton];
    
    [_selectButton addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionInitial context:nil];
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
