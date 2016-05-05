//
//  TNKAssetCollectionViewController.h
//  TNKImagePickerController
//
//  Created by David Beck on 5/5/16.
//  Copyright © 2016 Think Ultimate LLC. All rights reserved.
//

#import "TNKCollectionViewController.h"

@class PHAssetCollection;
@class PHFetchResult;


@interface TNKAssetCollectionViewController : TNKCollectionViewController

@property (nonatomic, nonnull, readonly) PHAssetCollection *assetCollection;
@property (nonatomic, nonnull, readonly) PHFetchResult *fetchResult;

- (nonnull instancetype)initWithAssetCollection:(nonnull PHAssetCollection *)assetCollection;

@end
