//
//  PHImageManager+TNKRequestImages.h
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import <Photos/Photos.h>

@interface PHImageManager (TNKRequestImages)

- (NSDictionary *)requestImagesForAssets:(NSArray *)assets
                              targetSize:(CGSize)targetSize
                             contentMode:(PHImageContentMode)contentMode
                                 options:(PHImageRequestOptions *)options
                           resultHandler:(void (^)(NSDictionary *results,
                                                   NSDictionary *infos))resultHandler;

@end
