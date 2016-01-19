# TNKImagePickerController

[![Carthage compatible](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/TNKImagePickerController.svg?style=flat)](http://cocoadocs.org/docsets/TNKImagePickerController)
[![License](https://img.shields.io/cocoapods/l/TNKImagePickerController.svg?style=flat)](http://cocoadocs.org/docsets/TNKImagePickerController)
[![Platform](https://img.shields.io/cocoapods/p/TNKImagePickerController.svg?style=flat)](http://cocoadocs.org/docsets/TNKImagePickerController)

A replacement for UIImagePickerController that can select multiple photos.

![Screenshots](http://f.cl.ly/items/3n3C1W3N0v082y211U1o/screenshots.png)

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

### Cocoapods

TNKImagePickerController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TNKImagePickerController", "~> 0.2"

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate TNKImagePickerController into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "davbeck/TNKImagePickerController" ~> 0.2
```

Run `carthage` to build the framework and drag the built `TNKImagePickerController.framework` into your Xcode project.

## Author

David Beck, code@thinkultimate.com

Special thanks to [The City](http://www.onthecity.org) for allowing me to open source this project.

## License

TNKImagePickerController is available under the MIT license. See the LICENSE file for more info.

