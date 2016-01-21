//
//  TNKAssetCell.m
//  Pods
//
//  Created by David Beck on 2/23/15.
//
//

#import "TNKAssetCell.h"

#import "TNKAssetImageView.h"
#import "TNKImagePickerControllerBundle.h"


@interface TNKAssetCell ()

@property (nonatomic, strong) TNKAssetImageView *imageView;
@property (nonatomic, strong) UIImageView *selectedBadgeImageView;

@end


@implementation TNKAssetCell

- (void)setAsset:(PHAsset *)asset {
	self.imageView.asset = asset;
	
	[self _updateAccessibility];
}

- (PHAsset *)asset {
	return self.imageView.asset;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	
	self.selectedBadgeImageView.hidden = !self.selected;
}

- (void)_init {
    _imageView = [[TNKAssetImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [UIColor colorWithRed:0.921 green:0.921 blue:0.946 alpha:1.000];
    _imageView.layer.borderColor = [UIColor colorWithRed:0.401 green:0.682 blue:0.017 alpha:1.000].CGColor;
    [self.contentView addSubview:_imageView];
    
    _selectedBadgeImageView = [[UIImageView alloc] init];
	_selectedBadgeImageView.hidden = YES;
    [self.contentView addSubview:_selectedBadgeImageView];
	
	
	self.isAccessibilityElement = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = self.contentView.bounds;
    
    _selectedBadgeImageView.frame = CGRectMake(10.0, 10.0, _selectedBadgeImageView.image.size.width, _selectedBadgeImageView.image.size.height);
}

- (void)_updateAccessibility {
	static dispatch_queue_t queue = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// by using a serial queue, we ensure that the final values set will be applied last
		queue = dispatch_queue_create("-[TNKAssetCell _updateAccessibility]", DISPATCH_QUEUE_SERIAL);
	});
	
	
	NSDate *creationDate = self.asset.creationDate;
	
	dispatch_async(queue, ^{
		NSString *date = [NSDateFormatter localizedStringFromDate:creationDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
		NSString *accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Photo, %@", nil), date];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.accessibilityLabel = accessibilityLabel;
		});
	});
}

@end
