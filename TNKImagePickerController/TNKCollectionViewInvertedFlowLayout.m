//
//  TNKCollectionViewInvertedFlowLayout.m
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import "TNKCollectionViewInvertedFlowLayout.h"


@implementation TNKCollectionViewInvertedFlowLayout

- (CGRect)_rectForSection:(NSInteger)section {
	NSInteger items = [self.collectionView numberOfItemsInSection:section];
	if (items == 0) {
		return CGRectNull;
	}
	
	NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
	NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:items - 1 inSection:section];
	
	UICollectionViewLayoutAttributes *firstAttributes = [super layoutAttributesForItemAtIndexPath:firstIndexPath];
	UICollectionViewLayoutAttributes *lastAttributes = [super layoutAttributesForItemAtIndexPath:lastIndexPath];
	
	return CGRectMake(firstAttributes.frame.origin.x,
					  firstAttributes.frame.origin.y,
					  CGRectGetMaxX(lastAttributes.frame) - CGRectGetMinX(firstAttributes.frame),
					  CGRectGetMaxY(lastAttributes.frame) - CGRectGetMinY(firstAttributes.frame));
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewLayoutAttributes *attributes = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
	
	attributes.transform = TNKInvertedTransform;
	
	CGRect sectionRect = [self _rectForSection:indexPath.section];
	if (!CGRectIsNull(sectionRect)) {
		CGRect frame = attributes.frame;
		frame.origin.y = sectionRect.origin.y + CGRectGetMaxY(sectionRect) - CGRectGetMaxY(frame);
		attributes.frame = frame;
	}
	
	return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewLayoutAttributes *attributes = [[super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath] copy];
	
	attributes.transform = TNKInvertedTransform;
	
	return attributes;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewLayoutAttributes *attributes = [[super layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath] copy];
	
	attributes.transform = TNKInvertedTransform;
	
	return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSArray *originalAnswer = [super layoutAttributesForElementsInRect:rect];
	NSMutableOrderedSet *answer = [NSMutableOrderedSet orderedSetWithArray:originalAnswer];
	
	NSMutableIndexSet *sections = [NSMutableIndexSet new];
	
	for (UICollectionViewLayoutAttributes *attributes in originalAnswer) {
		attributes.transform = TNKInvertedTransform;
		
		if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
			[answer removeObject:attributes];
			
			[sections addIndex:attributes.indexPath.section];
		}
	}
	
	[sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
		for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
			UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
			
			if (CGRectIntersectsRect(rect, attributes.frame)) {
				[answer addObject:attributes];
			}
		}
	}];
	
	return answer.array;
}

@end
