//
//  TCImageZoomView.h
//  The City
//
//  Created by David Beck on 1/13/14.
//  Copyright (c) 2014 ACS Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNKImageZoomView : UIScrollView

@property (nonatomic) CGSize imageSize;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, readonly) UIView *imageView;
@property (nonatomic, readonly) CGFloat fullZoomLevel;
@property (nonatomic, readonly) CGFloat defaultZoomLevel;
@property (nonatomic, readonly) UITapGestureRecognizer *zoomRecognizer;

@end
