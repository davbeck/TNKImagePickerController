//
//  PHCollection+TNKThumbnail.h
//  Pods
//
//  Created by David Beck on 2/20/15.
//
//

#import <Photos/Photos.h>

@interface PHCollection (TNKThumbnail)

+ (void)requestThumbnailForMoments:(void (^)(UIImage *result))resultHandler;
- (void)requestThumbnail:(void (^)(UIImage *result))resultHandler;

+ (void)clearThumbnailCache;

@end
