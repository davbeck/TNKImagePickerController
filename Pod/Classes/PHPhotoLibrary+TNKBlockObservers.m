//
//  PHPhotoLibrary+TNKBlockObservers.m
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import "PHPhotoLibrary+TNKBlockObservers.h"

#import <objc/runtime.h>

@interface TNKBlockObserverToken () <PHPhotoLibraryChangeObserver>

@property (nonatomic, copy) TNKPhotoLibraryChangeObserverBlock changeObserverBlock;
@property (nonatomic, strong) TNKBlockObserverToken *strongSelf;

@end

@implementation TNKBlockObserverToken

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    self.changeObserverBlock(changeInstance);
}

@end

@implementation PHPhotoLibrary (TNKBlockObservers)

- (TNKBlockObserverToken *)tnk_registerChangeObserverBlock:(TNKPhotoLibraryChangeObserverBlock)block
{
    TNKBlockObserverToken *token = [[TNKBlockObserverToken alloc] init];
    token.changeObserverBlock = block;
    token.strongSelf = token;

    [self registerChangeObserver:token];

    return token;
}

- (void)tnk_unregisterChangeObserverBlock:(TNKBlockObserverToken *)token
{
    [self unregisterChangeObserver:token];
    token.strongSelf = nil;
}

@end
