//
//  TNKAssetsDetailViewController.m
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import "TNKAssetsDetailViewController.h"

@import Photos;
@import ObjectiveC;

#import "TNKAssetViewController.h"
#import "NSDate+TNKFormattedDay.h"
#import "TNKAssetSelection.h"


NS_ASSUME_NONNULL_BEGIN

NSString *const TNKImagePickerControllerWillShowAssetNotification = @"TNKImagePickerControllerWillShowAsset";
NSString *const TNKImagePickerControllerAssetViewControllerNotificationKey = @"AssetViewController";

@interface TNKAssetsDetailViewController () <UIGestureRecognizerDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource>
{
    PHFetchResult *_fetchResult;
    
    BOOL _fullscreen;
    
    UIView *_titleView;
    UILabel *_titleLabel;
	UILabel *_subtitleLabel;
	UIBarButtonItem *_selectButton;
	UIBarButtonItem *_deselectButton;
}

@end

@implementation TNKAssetsDetailViewController

#pragma mark - Properties

- (void)setAssetCollection:(nullable PHAssetCollection *)assetCollection {
    _assetCollection = assetCollection;
    
    [self _refetch];
}

- (void)setAssetFetchOptions:(nullable PHFetchOptions *)assetFetchOptions {
    _assetFetchOptions = [assetFetchOptions copy];
    
    [self _refetch];
}

- (void)_refetch {
    if (_assetCollection != nil) {
        _fetchResult = [PHAsset fetchAssetsInAssetCollection:_assetCollection options:self.assetFetchOptions];
    } else {
        _fetchResult = [PHAsset fetchAssetsWithOptions:self.assetFetchOptions];
    }
}

- (void)setAssetViewControllerClass:(Class)assetViewControllerClass {
    NSAssert([assetViewControllerClass isSubclassOfClass:[TNKAssetViewController class]], @"assetViewControllerClass must be a subclass of TNKAssetViewController");
    
    _assetViewControllerClass = assetViewControllerClass;
    
    PHAsset *asset = [(TNKAssetViewController *)self.viewControllers.firstObject asset];
    [self showAsset:asset];
}


#pragma mark - Initialization

- (void)_init
{
    self.delegate = self;
    self.dataSource = self;
    self.hidesBottomBarWhenPushed = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _assetViewControllerClass = [TNKAssetViewController class];
	
	_selectButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", nil) style:UIBarButtonItemStylePlain target:self action:@selector(toggleSelection)];
	_deselectButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Deselect", nil) style:UIBarButtonItemStylePlain target:self action:@selector(toggleSelection)];
	self.navigationItem.rightBarButtonItem = _selectButton;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(nullable NSDictionary<NSString *, id> *)originalOptions
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

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleBars:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
    
    _titleView = [UIView new];

    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline] size:15.0];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_titleView addSubview:_titleLabel];

    _subtitleLabel = [UILabel new];
    _subtitleLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote] size:11.0];
    _subtitleLabel.textAlignment = NSTextAlignmentCenter;
    _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_titleView addSubview:_subtitleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],

        [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_titleView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
    ]];

    self.navigationItem.titleView = _titleView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _titleLabel.textColor = self.navigationController.navigationBar.titleTextAttributes[NSForegroundColorAttributeName];
    _subtitleLabel.textColor = self.navigationController.navigationBar.titleTextAttributes[NSForegroundColorAttributeName];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (BOOL)prefersStatusBarHidden {
    return _fullscreen;
}

- (void)_updateTitle {
    TNKAssetViewController *next = self.viewControllers.firstObject;
    PHAsset *asset = next.asset;
    
    PHAssetCollection *moment = [PHAssetCollection fetchAssetCollectionsContainingAsset:asset withType:PHAssetCollectionTypeMoment options:nil].firstObject;
    _titleLabel.text = moment.localizedTitle;
    
    static NSDateFormatter *timeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateStyle = NSDateFormatterNoStyle;
        timeFormatter.timeStyle = kCFDateFormatterShortStyle;
    });
    
    if (_titleLabel.text == nil) {
        _titleLabel.text = [asset.creationDate tnk_localizedDay];
        _subtitleLabel.text = [timeFormatter stringFromDate:asset.creationDate];
    } else {
        _subtitleLabel.text = [NSString stringWithFormat:@"%@ %@", [asset.creationDate tnk_localizedDay], [timeFormatter stringFromDate:asset.creationDate]];
    }
    
    CGRect titleFrame = CGRectZero;
    titleFrame.size = [_titleView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    _titleView.frame = titleFrame;
	
    // Fix detail title view jumping
    self.navigationItem.titleView = nil;
    self.navigationItem.titleView = _titleView;
	
	BOOL selected = [self.assetSelection isAssetSelected:asset];
	if (selected) {
		[self.navigationItem setRightBarButtonItem:_deselectButton animated:YES];
	} else {
		[self.navigationItem setRightBarButtonItem:_selectButton animated:YES];
	}
}


#pragma mark - Actions

- (IBAction)toggleBars:(id)sender {
    _fullscreen = !_fullscreen;
    [self.navigationController setNavigationBarHidden:_fullscreen animated:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        if (_fullscreen) {
            self.view.backgroundColor = [UIColor blackColor];
        } else {
            self.view.backgroundColor = [UIColor whiteColor];
        }
    }];
}

- (IBAction)toggleSelection {
	PHAsset *asset = [(TNKAssetViewController *)self.viewControllers.firstObject asset];
	
	BOOL selected = ![self.assetSelection isAssetSelected:asset];
	
	if (selected) {
		[self.assetSelection selectAsset:asset];
	} else {
		[self.assetSelection deselectAsset:asset];
    }
	
	[self _updateTitle];
	
	
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (PHAsset *)_assetAtIndexPath:(NSIndexPath *)indexPath {
	PHAsset *asset = nil;
	if (self.assetCollection != nil) {
		asset = _fetchResult[indexPath.row];
	} else {
		PHFetchResult *moment = [PHAsset fetchAssetsInAssetCollection:_fetchResult[indexPath.section] options:self.assetFetchOptions];
		asset = moment[indexPath.row];
	}
	
	return asset;
}

- (TNKAssetViewController *)_assetViewControllerWithAsset:(PHAsset *)asset {
    TNKAssetViewController *next = [[self.assetViewControllerClass alloc] init];
    next.view.backgroundColor = [UIColor clearColor];
    next.view.frame = self.view.bounds;
    
    next.asset = asset;
    
    return next;
}

- (void)showAsset:(PHAsset *)asset
{
	TNKAssetViewController *next = [self _assetViewControllerWithAsset:asset];
    [self setViewControllers:@[next] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self _updateTitle];
    
    NSDictionary *userInfo = @{
                               TNKImagePickerControllerAssetViewControllerNotificationKey : next,
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:TNKImagePickerControllerWillShowAssetNotification object:self userInfo:userInfo];
}


#pragma mark - UIPageViewControllerDelegate

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(TNKAssetViewController *)last
{
	NSInteger lastIndex = [_fetchResult indexOfObject:last.asset];
	NSInteger nextIndex = lastIndex - 1;
	if (lastIndex != NSNotFound && nextIndex >= 0) {
		PHAsset *nextAsset = [_fetchResult objectAtIndex:nextIndex];
		
		return [self _assetViewControllerWithAsset:nextAsset];
	}
    
    return nil;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(TNKAssetViewController *)last {
	
	NSInteger lastIndex = [_fetchResult indexOfObject:last.asset];
	NSInteger nextIndex = lastIndex + 1;
	if (lastIndex != NSNotFound && nextIndex < _fetchResult.count) {
		PHAsset *nextAsset = [_fetchResult objectAtIndex:nextIndex];
		
		return [self _assetViewControllerWithAsset:nextAsset];
	}
	
	return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    for (TNKAssetViewController *viewController in pendingViewControllers) {
        NSDictionary *userInfo = @{
                                   TNKImagePickerControllerAssetViewControllerNotificationKey : viewController,
                                   };
        [[NSNotificationCenter defaultCenter] postNotificationName:TNKImagePickerControllerWillShowAssetNotification object:self userInfo:userInfo];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
	[self _updateTitle];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

NS_ASSUME_NONNULL_END
