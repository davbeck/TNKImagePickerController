//
//  TNKCollectionsTitleButton.m
//  Pods
//
//  Created by David Beck on 2/23/15.
//
//

#import "TNKCollectionsTitleButton.h"

@implementation TNKCollectionsTitleButton

- (CGSize)sizeThatFits:(CGSize)size
{
    size = [super sizeThatFits:size];
    
    size.width += self.titleEdgeInsets.right + self.titleEdgeInsets.left + self.imageEdgeInsets.right + self.imageEdgeInsets.left;
    
    return size;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect frame = [super imageRectForContentRect:contentRect];
    frame.origin.x = CGRectGetMaxX(contentRect) - CGRectGetWidth(frame) - self.imageEdgeInsets.right + self.imageEdgeInsets.left;
    return frame;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect frame = [super titleRectForContentRect:contentRect];
    frame.origin.x = CGRectGetMinX(frame) - CGRectGetWidth([self imageRectForContentRect:contentRect]);
    return frame;
}

@end
