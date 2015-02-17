//
//  TNKImageCollectionCell.m
//  Pods
//
//  Created by David Beck on 2/18/15.
//
//

#import "TNKImageCollectionCell.h"

@implementation TNKImageCollectionCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (UIImageView *imageView in _imageViews) {
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 1.0 / self.traitCollection.displayScale;
    }
}

@end
