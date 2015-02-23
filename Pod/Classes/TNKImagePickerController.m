//
//  TNKImagePickerController.m
//  Pods
//
//  Created by David Beck on 2/21/15.
//
//

#import "TNKImagePickerController.h"

@import Photos;

#import "TNKImagePickerControllerBundle.h"
#import "TNKCollectionsTitleButton.h"
#import "TNKCollectionPickerController.h"
#import "TNKAssetCell.h"
#import "TNKAssetImageView.h"


#define TNKObjectSpacing 5.0


@interface TNKImagePickerController () <UIPopoverPresentationControllerDelegate, TNKCollectionPickerControllerDelegate>
{
    UIButton *_collectionButton;
    PHFetchResult *_fetchResult;
}

@end

@implementation TNKImagePickerController

#pragma mark - Properties

- (void)setAssetCollection:(PHAssetCollection *)assetCollection {
    _assetCollection = assetCollection;
    
    
    if (_assetCollection == nil) {
        self.title = NSLocalizedString(@"Moments", nil);
    } else {
        self.title = _assetCollection.localizedTitle;
    }
    [_collectionButton setTitle:self.title forState:UIControlStateNormal];
    [_collectionButton sizeToFit];
    
    
    if (_assetCollection != nil) {
        _fetchResult = [PHAsset fetchAssetsInAssetCollection:_assetCollection options:nil];
    } else {
        _fetchResult = nil;
    }
    [self.collectionView reloadData];
}


#pragma mark - Initialization

- (void)_init
{
    self.title = NSLocalizedString(@"Moments", nil);
    
    _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = _cancelButton;
    
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", nil) style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    _doneButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = _doneButton;
    
    _collectionButton = [TNKCollectionsTitleButton buttonWithType:UIButtonTypeSystem];
    [_collectionButton addTarget:self action:@selector(changeCollection:) forControlEvents:UIControlEventTouchUpInside];
    _collectionButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _collectionButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 3.0, 0.0, 0.0);
    [_collectionButton setTitle:self.title forState:UIControlStateNormal];
    [_collectionButton setImage:[TNKImagePickerControllerImageNamed(@"nav-disclosure") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_collectionButton sizeToFit];
    self.navigationItem.titleView = _collectionButton;
}

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = TNKObjectSpacing;
    layout.minimumInteritemSpacing = 0.0;
    return [self initWithCollectionViewLayout:layout];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[TNKAssetCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    
    UIFont *font = self.navigationController.navigationBar.titleTextAttributes[NSFontAttributeName];
    if (font != nil) {
        _collectionButton.titleLabel.font = font;
        [_collectionButton sizeToFit];
    }
}


#pragma mark - Actions

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeCollection:(id)sender {
    TNKCollectionPickerController *collectionPicker = [[TNKCollectionPickerController alloc] init];
    collectionPicker.delegate = self;
    
    collectionPicker.modalPresentationStyle = UIModalPresentationPopover;
    collectionPicker.popoverPresentationController.sourceView = _collectionButton;
    collectionPicker.popoverPresentationController.sourceRect = _collectionButton.bounds;
    collectionPicker.popoverPresentationController.delegate = self;
    [self presentViewController:collectionPicker animated:YES completion:nil];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TNKAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell layoutIfNeeded];
    PHAsset *asset = _fetchResult[indexPath.row];
    
    cell.backgroundColor = [UIColor redColor];
    cell.imageView.asset = asset;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger columns = floor(collectionView.bounds.size.width / 70.0);
    CGFloat width = floor((collectionView.bounds.size.width + TNKObjectSpacing) / columns) - TNKObjectSpacing;
    
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0);
}


#pragma mark - TNKCollectionPickerControllerDelegate

- (void)collectionPicker:(TNKCollectionPickerController *)collectionPicker didSelectCollection:(PHAssetCollection *)collection {
    self.assetCollection = collection;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
