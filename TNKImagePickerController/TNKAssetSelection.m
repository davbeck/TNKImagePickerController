//
//  TNKAssetSelection.m
//  TNKImagePickerController
//
//  Created by David Beck on 5/5/16.
//  Copyright © 2016 Think Ultimate LLC. All rights reserved.
//

#import "TNKAssetSelection.h"

#import "TNKImagePickerController.h"


@interface TNKAssetSelection () {
	NSMutableOrderedSet *_assets;
}

@end

@implementation TNKAssetSelection

- (instancetype)init {
	self = [super init];
	if (self != nil) {
		_assets = [NSMutableOrderedSet new];
	}
	
	return self;
}


- (void)setAssets:(NSArray *)assets {
	_assets = [NSMutableOrderedSet orderedSetWithArray:assets];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TNKAssetSelectionDidChangeNotification object:self userInfo:nil];
}

- (NSArray *)assets {
	// -[NSOrderedSet array] is an array proxy so copy the result
	return [_assets.array copy];
}

- (NSInteger)count {
	return _assets.count;
}

- (BOOL)isAssetSelected:(PHAsset *)asset {
	return [_assets containsObject:asset];
}

- (void)addAssets:(NSOrderedSet *)objects {
	if ([self.delegate respondsToSelector:@selector(assetSelection:shouldSelectAssets:)]) {
		NSArray *filtered = [self.delegate assetSelection:self shouldSelectAssets:objects.array];
		objects = [NSOrderedSet orderedSetWithArray:filtered];
	}
	
	[_assets unionOrderedSet:objects];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TNKAssetSelectionDidChangeNotification object:self userInfo:nil];
	
	if ([self.delegate respondsToSelector:@selector(assetSelection:didSelectAssets:)]) {
		[self.delegate assetSelection:self didSelectAssets:objects.array];
	}
}

- (void)selectAsset:(PHAsset *)asset {
	[self addAssets:[NSOrderedSet orderedSetWithObject:asset]];
}

- (void)removeAssets:(NSOrderedSet *)objects {
	[_assets minusOrderedSet:objects];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:TNKAssetSelectionDidChangeNotification object:self userInfo:nil];
}

- (void)deselectAsset:(PHAsset *)asset {
	[self removeAssets:[NSOrderedSet orderedSetWithObject:asset]];
}

@end
