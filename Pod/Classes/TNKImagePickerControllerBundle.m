//
//  TNKImagePickerControllerBundle.m
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import "TNKImagePickerControllerBundle.h"

#import "TNKCollectionPickerController.h"


NSBundle *TNKImagePickerControllerBundle() {
    return [NSBundle bundleWithURL:[[NSBundle bundleForClass:[TNKCollectionPickerController class]] URLForResource:@"TNKImagePickerController" withExtension:@"bundle"]];
}
