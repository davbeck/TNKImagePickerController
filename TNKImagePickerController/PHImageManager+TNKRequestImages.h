//
//  PHImageManager+TNKRequestImages.h
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHImageManager (TNKRequestImages)

- (NSDictionary<NSString *, NSNumber *> *)tnk_requestImagesForAssets:(NSArray<PHAsset *> *)assets
                                                          targetSize:(CGSize)targetSize
                                                         contentMode:(PHImageContentMode)contentMode
                                                             options:(nullable PHImageRequestOptions *)options
                                                       resultHandler:(void (^)(NSDictionary<NSString *, UIImage *> *__nullable results,
                                                                               NSDictionary<NSString *, NSDictionary *> *__nullable infos))resultHandler;

@end

NS_ASSUME_NONNULL_END
