# TUMessagePackSerialization CHANGELOG

## 3.0.0

A big thanks to [Alexsander Akers](https://github.com/a2) on this release for all of his pull requests.

- [Added nullability and generics annotations.](https://github.com/davbeck/TNKImagePickerController/pull/8)
- [Refactored auto layout constraints to use iOS 8 compatible API.](https://github.com/davbeck/TNKImagePickerController/pull/2)
- [Prefix category methods to prevent namespace collisions.](https://github.com/davbeck/TNKImagePickerController/pull/3)
- [Fix for asset selection persistence issues.](https://github.com/davbeck/TNKImagePickerController/pull/9)
- [Add ability to customize selected asset badge image.](https://github.com/davbeck/TNKImagePickerController/pull/10)

> Note that if you were using any of the extensions provided by this framework, they are now prefixed with `tnk_`.

## 2.1.0

- [Set designated initializer.](https://github.com/davbeck/TNKImagePickerController/commit/dfe88eb9f49963c2ed72110edd5d23b020ac73f3)
- [Added support for Carthage](https://github.com/davbeck/TNKImagePickerController/commit/13e3211dbd51e7667d38bd1ce240a869dae7b305)

# 2.0.0

- [Added support for shared albums.](https://github.com/davbeck/TNKImagePickerController/commit/c29025aadfe2a02f0ce3c0b06d3c98b47c6d1aec)
- [Increased thumbnail size.](https://github.com/davbeck/TNKImagePickerController/commit/b42add14e0d7656ea297ee08d51ec48c762715ca)
- [Fixed bug related to setting selected assets.](https://github.com/davbeck/TNKImagePickerController/commit/34e57a20fcb88dcceecf3a25da4472ef47c7d58a)
- [Changed image picker to select on tap.](https://github.com/davbeck/TNKImagePickerController/commit/89849dacd48438399efabc539f5aae39487beb42) A user can preview an image fullscreen by long pressing on the thumbnail.
- [Added accessibility labels for photos.](https://github.com/davbeck/TNKImagePickerController/commit/0c6541059e1959d2d13f72786ef3ec82cb20b21f)

## 0.2.2

- Fixed `mediaTypes` filter (1556ff01d85e8e756f9a6c40cc531fe5cad461a1, 92a6aa1fe9204cb295764035e723b0ddb91f6d42).
- Fixed asset image loading (c97fc4de3cd3ea76fcbfbbce3337f34307826ce2).
- Added ability to customize the asset detail view controller (37f4aa31d4c6f87c756bad4548b81a11065d1ec2).
- Fixed custom asset view controller class handling (1127d80bf7a198492a6f0305c7e34217c4cd59ef).
- Added notifications for displaying assets (473bf99c2752890cf2c8b9eb08e884e344887ed8).
- Added state restoration (737e8bbff3103b19338d332e69e2ab4ac60a748d).
- Fixed fullscreen image view swiping (276bda5b51b17751865ca945235713cb2dd15471).
