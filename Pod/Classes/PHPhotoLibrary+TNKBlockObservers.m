//
//  PHPhotoLibrary+TNKBlockObservers.m
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import "PHPhotoLibrary+TNKBlockObservers.h"

#import <objc/runtime.h>


@implementation PHPhotoLibrary (TNKBlockObservers)

- (dispatch_queue_t)_tnk_blockObserverQueue
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("_TNKBlockObserverQueue", NULL);
    });
    
    return queue;
}

- (NSMutableDictionary *)_tnk_blockObservers
{
    NSMutableDictionary *observers = objc_getAssociatedObject(self, _cmd);
    if (observers == nil) {
        observers = [NSMutableDictionary new];
        objc_setAssociatedObject(self, _cmd, observers, OBJC_ASSOCIATION_RETAIN);
        
        [self registerChangeObserver:self];
    }
    
    return observers;
}

- (id)tnk_registerChangeObserverBlock:(void(^)(PHChange *))observer {
    id key = [NSUUID UUID];
    
    dispatch_sync([self _tnk_blockObserverQueue], ^{
        [[self _tnk_blockObservers] setObject:observer forKey:key];
    });
    
    return key;
}

- (void)tnk_unregisterChangeObserverBlock:(id)observer {
    dispatch_async([self _tnk_blockObserverQueue], ^{
        [[self _tnk_blockObservers] removeObjectForKey:observer];
    });
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    __block NSDictionary *observers;
    dispatch_async([self _tnk_blockObserverQueue], ^{
        observers = [[self _tnk_blockObservers] copy];
    });
    
    for (void(^observerBlock)(PHChange *) in [observers allValues]) {
        observerBlock(changeInstance);
    }
}

@end
