//
//  TNKUnauthorizedViewController.m
//  TNKImagePickerController
//
//  Created by David Beck on 7/1/16.
//  Copyright © 2016 Think Ultimate LLC. All rights reserved.
//

#import "TNKUnauthorizedViewController.h"

@interface TNKUnauthorizedViewController ()

@end

@implementation TNKUnauthorizedViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	UILabel *descriptionLabel = [[UILabel alloc] init];
	descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
	descriptionLabel.text = NSLocalizedString(@"You have not given this app access to your photo library. To select photos, you need to turn on access for this app in Settings.", nil);
	descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	descriptionLabel.textAlignment = NSTextAlignmentCenter;
	descriptionLabel.numberOfLines = 0;
	[self.view addSubview:descriptionLabel];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	button.translatesAutoresizingMaskIntoConstraints = NO;
	[button setTitle:NSLocalizedString(@"Open Settings", nil) forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
	[button addTarget:self action:@selector(openSettings:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	
	
	[NSLayoutConstraint activateConstraints:@[
											  [descriptionLabel.bottomAnchor constraintEqualToAnchor:self.view.centerYAnchor],
											  [descriptionLabel.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
											  [descriptionLabel.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
											  
											  [button.topAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:15],
											  [button.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
											  [button.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
											  ]];
}

- (IBAction)openSettings:(id)sender {
	NSURL *url = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
	[[UIApplication sharedApplication] openURL:url];
}

@end
