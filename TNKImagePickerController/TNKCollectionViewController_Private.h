//
//  TNKCollectionViewController_Private.h
//  TNKImagePickerController
//
//  Created by David Beck on 5/5/16.
//  Copyright © 2016 Think Ultimate LLC. All rights reserved.
//

#import "TNKImagePickerController.h"

@class TNKAssetSelection;


@interface TNKCollectionViewController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, nullable) TNKAssetSelection *assetSelection;

@end
