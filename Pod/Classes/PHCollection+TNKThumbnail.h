//
//  PHCollection+TNKThumbnail.h
//  Pods
//
//  Created by David Beck on 2/20/15.
//
//

#import <Photos/Photos.h>

@interface PHCollection (TNKThumbnail)

+ (void)requestThumbnailForMomentsWithAssetsFetchOptions:(PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *result))resultHandler;
- (void)requestThumbnailWithAssetsFetchOptions:(PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *result))resultHandler;

+ (void)clearThumbnailCache;

@end
