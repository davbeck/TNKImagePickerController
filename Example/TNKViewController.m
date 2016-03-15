//
//  TNKViewController.m
//  TNKImagePickerController
//
//  Created by David Beck on 02/17/2015.
//  Copyright (c) 2014 David Beck. All rights reserved.
//

#import "TNKViewController.h"

#import <TNKImagePickerController/TNKImagePickerController.h>


@interface TNKViewController () <TNKImagePickerControllerDelegate>

@end

@implementation TNKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self pickPhotos:nil];
    });
}


#pragma mark - Actions

- (IBAction)pickPhotos:(id)sender
{
    TNKImagePickerController *picker = [[TNKImagePickerController alloc] init];
    picker.mediaTypes = @[ (id)kUTTypeImage ];
	picker.delegate = self;
    
    picker.maximumSelectionCount = 3;
    
    typeof(picker) __weak weakPicker = picker;
    picker.maximumSelectionCountExceededHandler = ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:[NSString stringWithFormat:@"You can only add %lu items at a time", weakPicker.maximumSelectionCount]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [weakPicker presentViewController:alertController animated:YES completion:nil];
    };
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:picker];
    navigationController.toolbarHidden = NO;
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    
    navigationController.popoverPresentationController.sourceView = self.pickPhotosButton;
    navigationController.popoverPresentationController.sourceRect = self.pickPhotosButton.bounds;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)pickSinglePhoto:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark - TNKImagePickerControllerDelegate

- (void)imagePickerController:(TNKImagePickerController *)picker
       didFinishPickingAssets:(NSArray *)assets {
    [[PHImageManager defaultManager] tnk_requestImagesForAssets:assets targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(NSDictionary *results, NSDictionary *infos) {
        NSArray *images = results.allValues;
        NSLog(@"images: %@", images);
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(TNKImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)imagePickerControllerTitleForDoneButton:(TNKImagePickerController *)picker {
	if (picker.selectedAssets.count > 0) {
		return [NSString localizedStringWithFormat:NSLocalizedString(@"Next (%d)", @"Title for photo picker done button (short)."), picker.selectedAssets.count];
	} else {
		return NSLocalizedString(@"Next", nil);
	}
}

@end
