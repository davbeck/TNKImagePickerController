# TNKImagePickerController

[![CI Status](http://img.shields.io/travis/David Beck/TNKImagePickerController.svg?style=flat)](https://travis-ci.org/David Beck/TNKImagePickerController)
[![Version](https://img.shields.io/cocoapods/v/TNKImagePickerController.svg?style=flat)](http://cocoadocs.org/docsets/TNKImagePickerController)
[![License](https://img.shields.io/cocoapods/l/TNKImagePickerController.svg?style=flat)](http://cocoadocs.org/docsets/TNKImagePickerController)
[![Platform](https://img.shields.io/cocoapods/p/TNKImagePickerController.svg?style=flat)](http://cocoadocs.org/docsets/TNKImagePickerController)

A replacement for UIImagePickerController that can select multiple photos.

![Screenshot](http://f.cl.ly/items/3c1h0N2X0N0y0a1U240P/IMG_0011.PNG)
![Screenshot](http://f.cl.ly/items/0U473h2X2u211g3A1n0j/IMG_0012.PNG)
![Screenshot](http://f.cl.ly/items/2n0A372v151R1P3p0g0o/IMG_0013.PNG)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

---

To present the picker, use something similar to the following:

```objc
TNKImagePickerController *picker = [[TNKImagePickerController alloc] init];
picker.delegate = self;

UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:picker];
// while this is not stricktly necessary, not including this line will disable taking photos with the camera, pasting images, and selecting all assts in a collection
navigationController.toolbarHidden = NO;

// present the picker as a popover on iPad and landscape iPhone 6+ and a modal sheet on iPhone
navigationController.modalPresentationStyle = UIModalPresentationPopover;
navigationController.popoverPresentationController.sourceView = self.pickPhotosButton;
navigationController.popoverPresentationController.sourceRect = self.pickPhotosButton.bounds;

[self presentViewController:navigationController animated:YES completion:nil];
```

Your delegate should impliment the following methods in order to get the image assets:

```objc
#pragma mark - TNKImagePickerControllerDelegate

- (void)imagePickerController:(TNKImagePickerController *)picker
       didFinishPickingAssets:(NSSet *)assets {
    [[PHImageManager defaultManager] requestImagesForAssets:assets.allObjects targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(NSDictionary *results, NSDictionary *infos) {
        NSArray *images = results.allValues;
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(TNKImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
```

## Installation

TNKImagePickerController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TNKImagePickerController", "~> 0.1.0"

## Author

David Beck, code@thinkultimate.com

Special thanks to [The City](http://www.onthecity.org) for allowing me to open source this project.

## License

TNKImagePickerController is available under the MIT license. See the LICENSE file for more info.

