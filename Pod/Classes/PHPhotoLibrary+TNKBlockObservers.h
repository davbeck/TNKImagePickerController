//
//  PHPhotoLibrary+TNKBlockObservers.h
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import <Photos/Photos.h>

@interface PHPhotoLibrary (TNKBlockObservers) <PHPhotoLibraryChangeObserver>

- (id)registerChangeObserverBlock:(void(^)(PHChange *change))observer;
- (void)unregisterChangeObserverBlock:(id)observer;

@end
