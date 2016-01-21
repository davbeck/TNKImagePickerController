//
//  PHCollection+TNKThumbnail.h
//  Pods
//
//  Created by David Beck on 2/20/15.
//
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHCollection (TNKThumbnail)

+ (void)tnk_requestThumbnailForMomentsWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler;
- (void)tnk_requestThumbnailWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler;

+ (void)tnk_clearThumbnailCache;

@end

NS_ASSUME_NONNULL_END
