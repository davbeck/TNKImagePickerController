//
//  TNKViewController.m
//  TNKImagePickerController
//
//  Created by David Beck on 02/17/2015.
//  Copyright (c) 2014 David Beck. All rights reserved.
//

#import "TNKViewController.h"

#import <TNKImagePickerController/TNKImagePickerController.h>


@interface TNKViewController ()

@end

@implementation TNKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


#pragma mark - Actions

- (IBAction)pickPhotos:(id)sender
{
    TNKImagePickerController *viewController = [[TNKImagePickerController alloc] init];
    viewController.showsCancelButton = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)pickSinglePhoto:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

@end
