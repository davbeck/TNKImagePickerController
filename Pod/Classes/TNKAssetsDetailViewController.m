//
//  TNKAssetsDetailViewController.m
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import "TNKAssetsDetailViewController.h"

@import Photos;

#import "TNKAssetViewController.h"


@interface TNKAssetsDetailViewController () <UIGestureRecognizerDelegate>
{
    PHFetchResult *_fetchResult;
    
    BOOL _fullscreen;
}

@end

@implementation TNKAssetsDetailViewController

#pragma mark - Properties

- (void)setAssetCollection:(PHAssetCollection *)assetCollection {
    _assetCollection = assetCollection;
    
    if (_assetCollection != nil) {
        _fetchResult = [PHAsset fetchAssetsInAssetCollection:_assetCollection options:nil];
    } else {
        _fetchResult = [PHAssetCollection fetchMomentsWithOptions:nil];
    }
}


#pragma mark - Initialization

- (void)_init
{
    self.hidesBottomBarWhenPushed = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)originalOptions
{
    NSDictionary *options = @{
                              UIPageViewControllerOptionInterPageSpacingKey: @5.0,
                              };
    
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleBars:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
}

- (BOOL)prefersStatusBarHidden {
    return _fullscreen;
}

- (void)_updateTitle {
//    TNKAssetViewController *next = self.viewControllers.firstObject;
    
//    self.title = [NSString localizedStringWithFormat:NSLocalizedString(@"%1$d of %2$d", @"Fullscreen photo editing title showing the index of the current photo in the album. %1$d is the index of the current photo. %2$d is the total number of photos."), index + 1, _assets.count];
}


#pragma mark - Actions

- (IBAction)toggleBars:(id)sender {
    _fullscreen = !_fullscreen;
    [self.navigationController setNavigationBarHidden:_fullscreen animated:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        for (UIViewController *viewController in self.viewControllers) {
            if (_fullscreen) {
                viewController.view.backgroundColor = [UIColor blackColor];
            } else {
                viewController.view.backgroundColor = [UIColor whiteColor];
            }
        }
    }];
}


#pragma mark - Actions

- (void)showAssetAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = nil;
    if (self.assetCollection != nil) {
        asset = _fetchResult[indexPath.row];
    } else {
        PHFetchResult *moment = [PHAsset fetchAssetsInAssetCollection:_fetchResult[indexPath.section] options:nil];
        asset = moment[indexPath.row];
    }
    
    TNKAssetViewController *next = [[TNKAssetViewController alloc] init];
    next.asset = asset;
    [self setViewControllers:@[next] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self _updateTitle];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
