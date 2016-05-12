//
//  PHCollection+TNKThumbnail.m
//  Pods
//
//  Created by David Beck on 2/20/15.
//
//

#import "PHCollection+TNKThumbnail.h"

#import "UIImage+TNKAspectDraw.h"
#import "PHPhotoLibrary+TNKBlockObservers.h"
#import "PHImageManager+TNKRequestImages.h"


#define TNKMomentsIdentifier @"Moments"

#define TNKPrimaryThumbnailWidth 68.0
#define TNKTotalThumbnailWidth 76.0
#define TNKListRows 3.0


NS_ASSUME_NONNULL_BEGIN

@implementation PHCollection (TNKThumbnail)

+ (NSCache *)_tnk_thumbnailImageCache
{
    static NSCache *imageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [[NSCache alloc] init];
        imageCache.name = @"PHCollection/TNKThumbnail";
        
        [[PHPhotoLibrary sharedPhotoLibrary] tnk_registerChangeObserverBlock:^(PHChange *change) {
            [PHCollection tnk_clearThumbnailCache];
        }];
    });
    
    return imageCache;
}

+ (NSString *)_tnk_cacheKeyForOptions:(PHFetchOptions *)assetFetchOptions
{
    NSMutableString *keyString = [NSMutableString new];
    
    [keyString appendString:assetFetchOptions.predicate.predicateFormat];
    
    for (NSSortDescriptor *sortDescriptor in assetFetchOptions.sortDescriptors) {
        [keyString appendString:sortDescriptor.key];
        [keyString appendFormat:@"%d", sortDescriptor.ascending];
    }
    
    [keyString appendFormat:@"%d", assetFetchOptions.includeAllBurstAssets];
    [keyString appendFormat:@"%d", assetFetchOptions.includeHiddenAssets];
    
    return [NSString stringWithFormat:@"%lu", (unsigned long)[keyString hash]];
}

+ (void)tnk_requestThumbnailForMomentsWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler
{
    NSString *cacheKey = nil;
    if (assetFetchOptions == nil) {
        cacheKey = TNKMomentsIdentifier;
    } else {
        cacheKey = [NSString stringWithFormat:@"%@/%@", TNKMomentsIdentifier, [PHCollection _tnk_cacheKeyForOptions:assetFetchOptions]];
    }
    
    UIImage *thumbnail = [[PHCollection _tnk_thumbnailImageCache] objectForKey:cacheKey];
    if (thumbnail == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHCollection _tnk_requestThumbnailForMomentsWithAssetsFetchOptions:assetFetchOptions completion:^(UIImage *result) {
                if (result == nil) {
                    [[PHCollection _tnk_thumbnailImageCache] setObject:[NSNull null] forKey:cacheKey];
                } else {
                    [[PHCollection _tnk_thumbnailImageCache] setObject:result forKey:cacheKey];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultHandler(result);
                });
            }];
        });
    } else {
        if ([thumbnail isKindOfClass:[NSNull class]]) {
            resultHandler(nil);
        } else {
            resultHandler(thumbnail);
        }
    }
}

+ (void)_tnk_requestThumbnailForMomentsWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler
{
    CGSize assetSize = CGSizeMake(TNKPrimaryThumbnailWidth, TNKPrimaryThumbnailWidth);
    assetSize.width *= [UIScreen mainScreen].scale;
    assetSize.height *= [UIScreen mainScreen].scale;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    NSMutableArray *assets = [NSMutableArray new];
    PHFetchResult *moments = [PHAssetCollection fetchMomentsWithOptions:nil];
    [moments enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAssetCollection *moment, NSUInteger idx, BOOL *stop) {
        PHFetchResult *keyResult = [PHAsset fetchAssetsInAssetCollection:moment options:assetFetchOptions];
        
        [keyResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            [assets addObject:asset];
            
            *stop = assets.count >= 3;
        }];
        
        *stop = assets.count >= 3;
    }];
    
    [[PHImageManager defaultManager] tnk_requestImagesForAssets:assets targetSize:assetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(NSDictionary *results, NSDictionary *infos) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(TNKTotalThumbnailWidth, TNKTotalThumbnailWidth), NO, 0.0);
        
        for (NSInteger index = 2; index >= 0; index--) {
            CGRect assetFrame;
            assetFrame.origin.y = (2 - index) * 2.0;
            assetFrame.origin.x = index * 2.0 + 4.0;
            assetFrame.size.width = TNKPrimaryThumbnailWidth - index * 4.0;
            assetFrame.size.height = TNKPrimaryThumbnailWidth - index * 4.0;
            
            UIImage *image = nil;
            if (assets.count > index) {
                PHAsset *asset = assets[index];
                image = results[asset.localIdentifier];
            }
            
            if (image != nil) {
                [image tnk_drawInRectWithAspectFill:assetFrame];
            }
            
            CGFloat lineWidth = 1.0 / [UIScreen mainScreen].scale;
            CGRect borderRect = CGRectInset(assetFrame, -lineWidth / 2.0, -lineWidth / 2.0);
            UIBezierPath *border = [UIBezierPath bezierPathWithRect:borderRect];
            border.lineWidth = lineWidth;
            [[UIColor whiteColor] setStroke];
            [border stroke];
        }
        
        UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        resultHandler(retImage);
    }];
}

- (void)tnk_requestThumbnailWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler
{
    NSString *cacheKey = nil;
    if (assetFetchOptions == nil) {
        cacheKey = self.localIdentifier;
    } else {
        cacheKey = [NSString stringWithFormat:@"%@/%@", self.localIdentifier, [PHCollection _tnk_cacheKeyForOptions:assetFetchOptions]];
    }
    
    UIImage *thumbnail = [[PHCollection _tnk_thumbnailImageCache] objectForKey:cacheKey];
    if (thumbnail == nil) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            [self _tnk_requestThumbnailWithAssetsFetchOptions:assetFetchOptions completion:^(UIImage *result) {
                if (result == nil) {
                    [[PHCollection _tnk_thumbnailImageCache] setObject:[NSNull null] forKey:cacheKey];
                } else {
                    [[PHCollection _tnk_thumbnailImageCache] setObject:result forKey:cacheKey];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultHandler(result);
                });
            }];
        });
    } else {
        if ([thumbnail isKindOfClass:[NSNull class]]) {
            resultHandler(nil);
        } else {
            resultHandler(thumbnail);
        }
    }
}

- (void)_tnk_requestThumbnailWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler
{
    resultHandler(nil);
}

+ (void)tnk_clearThumbnailCache
{
    [[PHCollection _tnk_thumbnailImageCache] removeAllObjects];
}

@end


@implementation PHAssetCollection (TNKThumbnail)

- (void)_tnk_requestThumbnailWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler {
    CGSize assetSize = CGSizeMake(TNKPrimaryThumbnailWidth, TNKPrimaryThumbnailWidth);
    assetSize.width *= [UIScreen mainScreen].scale;
    assetSize.height *= [UIScreen mainScreen].scale;
    
	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    PHFetchResult *keyResult = [PHAsset fetchKeyAssetsInAssetCollection:self options:assetFetchOptions];
    if (keyResult.count <= 0) {
        PHFetchOptions *fetchOptions = [assetFetchOptions copy];
        fetchOptions.sortDescriptors = @[
                                         [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
                                         ];
        keyResult = [PHAsset fetchAssetsInAssetCollection:self options:fetchOptions];
    }
    
    if (keyResult.count == 0) {
        resultHandler(nil);
        return;
    }
    
    NSMutableArray *assets = [NSMutableArray new];
    for (NSUInteger i = 0; i < 3; i++) {
        if (keyResult.count > i) {
            [assets addObject:[keyResult objectAtIndex:i]];
        }
    }
    
    [[PHImageManager defaultManager] tnk_requestImagesForAssets:assets targetSize:assetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(NSDictionary *results, NSDictionary *infos) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(TNKTotalThumbnailWidth, TNKTotalThumbnailWidth), NO, 0.0);
        
        for (NSInteger index = 2; index >= 0; index--) {
            CGRect assetFrame;
            assetFrame.origin.y = (2 - index) * 2.0;
            assetFrame.origin.x = index * 2.0 + 4.0;
            assetFrame.size.width = TNKPrimaryThumbnailWidth - index * 4.0;
            assetFrame.size.height = TNKPrimaryThumbnailWidth - index * 4.0;
            
            UIImage *image = nil;
            if (assets.count > index) {
                PHAsset *asset = assets[index];
                image = results[asset.localIdentifier];
            }
            
            if (image != nil) {
                [image tnk_drawInRectWithAspectFill:assetFrame];
            }
            
            CGFloat lineWidth = 1.0 / [UIScreen mainScreen].scale;
            CGRect borderRect = CGRectInset(assetFrame, -lineWidth / 2.0, -lineWidth / 2.0);
            UIBezierPath *border = [UIBezierPath bezierPathWithRect:borderRect];
            border.lineWidth = lineWidth;
            [[UIColor whiteColor] setStroke];
            [border stroke];
        }
        
        UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        resultHandler(retImage);
    }];
}

@end


@implementation PHCollectionList (TNKThumbnail)

- (NSArray<PHAsset *> *)_tnk_keyAssets {
    PHFetchResult *collections = [PHCollection fetchCollectionsInCollectionList:self options:nil];
    NSMutableArray *assets = [NSMutableArray new];
    
    [collections enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger index, BOOL *stop) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHFetchResult *keyResult = [PHAsset fetchKeyAssetsInAssetCollection:collection options:nil];
            if (keyResult.count <= 0) {
                keyResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            }
            
            PHAsset *asset = keyResult.firstObject;
            [assets addObject:asset];
        }
        
        if (assets.count >= TNKListRows * TNKListRows) {
            *stop = YES;
        }
    }];
    
    return assets;
}

- (void)_tnk_requestThumbnailWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler {
    CGFloat individualWidth = (TNKPrimaryThumbnailWidth - TNKListRows + 1.0) / TNKListRows;
    CGSize assetSize = CGSizeMake(individualWidth, individualWidth);
    assetSize.width *= [UIScreen mainScreen].scale;
    assetSize.height *= [UIScreen mainScreen].scale;
    
	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    NSArray *assets = [self _tnk_keyAssets];
    
    [[PHImageManager defaultManager] tnk_requestImagesForAssets:assets targetSize:assetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(NSDictionary *results, NSDictionary *infos) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(TNKTotalThumbnailWidth, TNKTotalThumbnailWidth), NO, 0.0);
        //        CGContextRef context = UIGraphicsGetCurrentContext();
        
        NSUInteger assetIndex = 0;
        
        for (NSUInteger row = 0; row < 3; row++) {
            for (NSUInteger column = 0; column < 3; column++) {
                CGRect assetFrame;
                assetFrame.size.width = (TNKPrimaryThumbnailWidth - TNKListRows + 1.0) / TNKListRows;
                assetFrame.size.height = assetFrame.size.width;
                assetFrame.origin.y = row * (assetFrame.size.height + 1.0) + 4.0;
                assetFrame.origin.x = column * (assetFrame.size.width + 1.0) + 4.0;
                
                UIImage *image = nil;
                if (assets.count > assetIndex) {
                    PHAsset *asset = assets[assetIndex];
                    image = results[asset.localIdentifier];
                }
                
                if (image != nil) {
                    [image tnk_drawInRectWithAspectFill:assetFrame];
                } else {
                    [[UIColor colorWithRed:0.921 green:0.921 blue:0.946 alpha:1.000] setFill];
                    [[UIBezierPath bezierPathWithRect:assetFrame] fill];
                }
                
                assetIndex++;
            }
        }
        
        UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        resultHandler(retImage);
    }];
}

@end

NS_ASSUME_NONNULL_END
