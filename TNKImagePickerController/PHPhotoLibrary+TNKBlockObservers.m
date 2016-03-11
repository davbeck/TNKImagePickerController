//
//  PHPhotoLibrary+TNKBlockObservers.m
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import "PHPhotoLibrary+TNKBlockObservers.h"

NS_ASSUME_NONNULL_BEGIN

@interface TNKBlockObserverToken () <PHPhotoLibraryChangeObserver>

@property (nonatomic, copy) TNKPhotoLibraryChangeObserverBlock changeObserverBlock;
@property (nonatomic, strong, nullable) TNKBlockObserverToken *strongSelf;

@end

@implementation TNKBlockObserverToken

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    _changeObserverBlock(changeInstance);
}

@end

@implementation PHPhotoLibrary (TNKBlockObservers)

- (TNKBlockObserverToken *)tnk_registerChangeObserverBlock:(TNKPhotoLibraryChangeObserverBlock)observer
{
    TNKBlockObserverToken *token = [[TNKBlockObserverToken alloc] init];
    token.changeObserverBlock = observer;
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

NS_ASSUME_NONNULL_END
