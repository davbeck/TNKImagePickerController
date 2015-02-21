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


@interface PHImageManager (TNKThumbnail)

- (NSDictionary *)requestImagesForAssets:(NSArray *)assets
                              targetSize:(CGSize)targetSize
                             contentMode:(PHImageContentMode)contentMode
                                 options:(PHImageRequestOptions *)options
                           resultHandler:(void (^)(NSDictionary *results,
                                                   NSDictionary *infos))resultHandler;

@end
