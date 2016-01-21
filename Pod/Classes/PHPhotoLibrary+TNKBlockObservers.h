//
//  PHPhotoLibrary+TNKBlockObservers.h
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import <Photos/Photos.h>

@interface TNKBlockObserverToken : NSObject

@end

typedef void (^TNKPhotoLibraryChangeObserverBlock)(PHChange *change);

@interface PHPhotoLibrary (TNKBlockObservers)

- (TNKBlockObserverToken *)tnk_registerChangeObserverBlock:(TNKPhotoLibraryChangeObserverBlock)observer;
- (void)tnk_unregisterChangeObserverBlock:(TNKBlockObserverToken *)token;

@end
