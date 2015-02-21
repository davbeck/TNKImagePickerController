//
//  PHCollection+TNKThumbnail.m
//  Pods
//
//  Created by David Beck on 2/20/15.
//
//

#import "PHCollection+TNKThumbnail.h"


#define TNKCollectionThumbnailFormat @"PHCollectionThumbnail"


#define TNKPrimaryThumbnailWidth 68.0
#define TNKTotalThumbnailWidth 76.0
#define TNKListRows 3.0



@implementation PHCollection (TNKThumbnail)

+ (NSCache *)_thumbnailImageCache
{
    static NSCache *imageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [[NSCache alloc] init];
        imageCache.name = @"PHCollection/TNKThumbnail";
    });
    
    return imageCache;
}

- (void)requestThumbnail:(void (^)(UIImage *result))resultHandler
{
    UIImage *thumbnail = [[[self class] _thumbnailImageCache] objectForKey:self.localIdentifier];
    if (thumbnail == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self _requestThumbnail:^(UIImage *result) {
                [[[self class] _thumbnailImageCache] setObject:result forKey:self.localIdentifier];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultHandler(result);
                });
            }];
        });
    } else {
        resultHandler(thumbnail);
    }
}

- (void)_requestThumbnail:(void (^)(UIImage *result))resultHandler
{
    resultHandler(nil);
}

@end


@implementation PHAssetCollection (TNKThumbnail)



@end


@implementation PHCollectionList (TNKThumbnail)

- (NSArray *)_TNKKeyAssets {
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

- (void)_requestThumbnail:(void (^)(UIImage *result))resultHandler {
    CGFloat individualWidth = (TNKPrimaryThumbnailWidth - TNKListRows + 1.0) / TNKListRows;
    CGSize assetSize = CGSizeMake(individualWidth, individualWidth);
    assetSize.width *= [UIScreen mainScreen].scale;
    assetSize.height *= [UIScreen mainScreen].scale;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    NSArray *assets = [self _TNKKeyAssets];
    
    [[PHImageManager defaultManager] requestImagesForAssets:assets targetSize:assetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(NSDictionary *results, NSDictionary *infos) {
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
                
                PHAsset *asset = assets[row * 3 + column];
                UIImage *image = results[asset.localIdentifier];
                if (image != nil) {
                    [image drawInRect:assetFrame];
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




@implementation PHImageManager (TNKThumbnail)

- (NSDictionary *)requestImagesForAssets:(NSArray *)assets
                              targetSize:(CGSize)targetSize
                             contentMode:(PHImageContentMode)contentMode
                                 options:(PHImageRequestOptions *)options
                           resultHandler:(void (^)(NSDictionary *results,
                                                   NSDictionary *infos))resultHandler {
    NSMutableDictionary *results = [NSMutableDictionary new];
    NSMutableDictionary *infos = [NSMutableDictionary new];
    NSMutableDictionary *requestIDs = [NSMutableDictionary new];
    dispatch_group_t group = dispatch_group_create();
    
    [assets enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        dispatch_group_enter(group);
        
        PHImageRequestID requestID = [self requestImageForAsset:asset targetSize:targetSize contentMode:contentMode options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            results[asset.localIdentifier] = result;
            infos[asset.localIdentifier] = info;
            
            dispatch_group_leave(group);
        }];
        
        requestIDs[asset.localIdentifier] = @(requestID);
    }];
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        resultHandler(results, infos);
    });
    
    return requestIDs;
}

@end
