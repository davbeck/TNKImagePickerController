//
//  TNKAssetSelection.h
//  TNKImagePickerController
//
//  Created by David Beck on 5/5/16.
//  Copyright © 2016 Think Ultimate LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset;
@class TNKAssetSelection;


#define TNKAssetSelectionDidChangeNotification @"TNKAssetSelectionDidChange"


NS_ASSUME_NONNULL_BEGIN

@protocol TNKAssetSelectionDelegate <NSObject>
@optional

/** Asks the delegate to confirm or modify a new selection.
 
 When the user taps on an asset, or takes a photo or does anything to select assets, this will be called to verify the new selection. You can return `assets` unchanged, modified, or an empty array to block selection entirely.
 
 Use this method for things like limiting the number of selected assets. You can perform aditional actions to let the user know why they can't select more photos, or unselect older assets.
 
 @param assets The new assets to be added to the selection.
 @return The assets that the delegate wants to add.
 */
- (NSArray<PHAsset *> *)assetSelection:(TNKAssetSelection *)assetSelection shouldSelectAssets:(NSArray<PHAsset *> *)assets;

/** Tells the delegate that selection has been changed.
 
 @param assets The new assets that were selected.
 */
- (void)assetSelection:(TNKAssetSelection *)assetSelection didSelectAssets:(NSArray<PHAsset *> *)assets;

@end


@interface TNKAssetSelection : NSObject

@property (nonatomic, weak, nullable) id<TNKAssetSelectionDelegate> delegate;

@property (nonatomic, copy) NSArray<PHAsset *> *assets;
@property (nonatomic, readonly) NSInteger count;
- (BOOL)isAssetSelected:(PHAsset *)asset;

- (void)addAssets:(NSOrderedSet *)objects;
- (void)selectAsset:(PHAsset *)asset;

- (void)removeAssets:(NSOrderedSet *)objects;
- (void)deselectAsset:(PHAsset *)asset;

@end

NS_ASSUME_NONNULL_END
