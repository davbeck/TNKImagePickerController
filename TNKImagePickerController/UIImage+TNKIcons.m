//
//  UIImage+TNKIcons.m
//  TNKImagePickerController
//
//  Created by David Beck on 5/4/16.
//  Copyright © 2016 Think Ultimate LLC. All rights reserved.
//

#import "UIImage+TNKIcons.h"

@implementation UIImage (TNKIcons)

+ (NSCache *)tnk_iconsCache
{
	static NSCache *cache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = [[NSCache alloc] init];
	});
	
	return cache;
}

+ (UIImage *)tnk_imageWithSize:(CGSize)size cacheKey:(NSString *)cacheKey drawing:(void(^)(CGRect))drawing
{
	UIImage *cachedImage = [[self tnk_iconsCache] objectForKey:cacheKey];
	if (cachedImage != nil) {
		return cachedImage;
	} else {
		UIGraphicsBeginImageContext(size);
		
		drawing(CGRectMake(0, 0, size.width, size.height));
		
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		[[self tnk_iconsCache] setObject:image forKey:cacheKey];
		return image;
	}
}

+ (UIImage *)tnk_defaultCollectionListIcon
{
	CGSize size = CGSizeMake(68, 68);
	NSString *cacheKey = @"defaultCollectionListIcon";
	
	return [self tnk_imageWithSize:size cacheKey:cacheKey drawing:^(CGRect bounds){
		[[UIColor whiteColor] setFill];
		[[UIBezierPath bezierPathWithRect:bounds] fill];
		
		
		[[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0] setFill];
		
		CGFloat pixelWidth = 1 / [[UIScreen mainScreen] scale];
		CGFloat squareWidth = floor((size.width - pixelWidth * 2) / 3);
		
		for (NSInteger ySquare = 0; ySquare < 3; ySquare++) {
			CGFloat y = ySquare * (squareWidth + pixelWidth);
			
			for (NSInteger xSquare = 0; xSquare < 3; xSquare++) {
				CGRect square = CGRectMake(xSquare * (squareWidth + pixelWidth), y,
										   squareWidth, squareWidth);
				if (xSquare == 2) {
					square.size.width = bounds.size.width - square.origin.x;
				}
				if (ySquare == 2) {
					square.size.height = bounds.size.height - square.origin.y;
				}
				
				[[UIBezierPath bezierPathWithRect:square] fill];
			}
		}
	}];
}

+ (UIImage *)tnk_defaultCollectionIcon
{
	CGSize size = CGSizeMake(68, 68);
	NSString *cacheKey = @"defaultCollectionIcon";
	
	return [self tnk_imageWithSize:size cacheKey:cacheKey drawing:^(CGRect bounds){
		UIColor *backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0];
		UIColor *lineColor = [UIColor colorWithRed:0.70 green:0.70 blue:0.71 alpha:1.0];
		
		
		[backgroundColor setFill];
		[[UIBezierPath bezierPathWithRect:bounds] fill];
		
		
		[lineColor setStroke];
		[[UIBezierPath bezierPathWithRect:CGRectMake(15.5, 19.5, 32, 24)] stroke];
		
		CGRect secondSquare = CGRectMake(19, 23, 35, 27);
		[backgroundColor setFill];
		[[UIBezierPath bezierPathWithRect:secondSquare] fill];
		
		[lineColor setStroke];
		[[UIBezierPath bezierPathWithRect:CGRectInset(secondSquare, 1.5, 1.5)] stroke];
		
	}];
}

+ (UIImage *)tnk_checkmarkSelectedIcon
{
	CGSize size = CGSizeMake(24, 24);
	NSString *cacheKey = @"checkmarkSelectedIcon";
	
	return [self tnk_imageWithSize:size cacheKey:cacheKey drawing:^(CGRect bounds){
		[[UIColor colorWithRed: 0.415 green: 0.667 blue: 0.115 alpha: 1] setFill];
		[[UIBezierPath bezierPathWithOvalInRect: bounds] fill];
		
		
		UIBezierPath* linePath = [UIBezierPath bezierPath];
		[linePath moveToPoint: CGPointMake(5, 13)];
		[linePath addLineToPoint: CGPointMake(9, 17)];
		[linePath addLineToPoint: CGPointMake(19, 7)];
		
		linePath.lineWidth = 2;
		linePath.miterLimit = 4;
		linePath.lineCapStyle = kCGLineCapSquare;
		linePath.usesEvenOddFillRule = YES;
		
		[[UIColor whiteColor] setStroke];
		[linePath stroke];
	}];
}

+ (UIImage *)tnk_navDisclosureIcon
{
	CGSize size = CGSizeMake(7, 7);
	NSString *cacheKey = @"navDisclosureIcon";
	
	return [self tnk_imageWithSize:size cacheKey:cacheKey drawing:^(CGRect bounds){
		[[UIColor whiteColor] setFill];
		
		UIBezierPath *path = [UIBezierPath bezierPath];
		[path moveToPoint:CGPointMake(0, 0)];
		[path addLineToPoint:CGPointMake(7, 0)];
		[path addLineToPoint:CGPointMake(3.5, 7)];
		[path closePath];
		[path fill];
	}];
}

@end
