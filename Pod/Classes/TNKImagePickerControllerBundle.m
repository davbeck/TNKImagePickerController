//
//  TNKImagePickerControllerBundle.m
//  Pods
//
//  Created by David Beck on 2/19/15.
//
//

#import "TNKImagePickerControllerBundle.h"

#import "TNKImagePickerController.h"


NSBundle *TNKImagePickerControllerBundle() {
    return [NSBundle bundleWithURL:[[NSBundle bundleForClass:[TNKImagePickerController class]] URLForResource:@"TNKImagePickerController" withExtension:@"bundle"]];
}
