//
//  TNKCollectionViewInvertedFlowLayout.m
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import "TNKCollectionViewInvertedFlowLayout.h"


@implementation TNKCollectionViewInvertedFlowLayout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
	
	attributes.transform = TNKInvertedTransform;
	
	return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
	
	attributes.transform = TNKInvertedTransform;
	
	return attributes;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
	
	attributes.transform = TNKInvertedTransform;
	
	return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSArray *answer = [super layoutAttributesForElementsInRect:rect];
	
	for (UICollectionViewLayoutAttributes *attributes in answer) {
		attributes.transform = TNKInvertedTransform;
	}
	
	return answer;
}

@end
