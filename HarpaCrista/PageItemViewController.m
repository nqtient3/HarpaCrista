//
//  PageItemViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/5/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "PageItemViewController.h"
#import "MainTabbarController.h"

@interface PageItemViewController () {
    __weak IBOutlet UITextField *emailTextField;
    __weak IBOutlet UIButton *submitButton;
}

@end

@implementation PageItemViewController

@synthesize itemIndex;
@synthesize imageName;
@synthesize contentImageView;

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    emailTextField.hidden = YES;
    submitButton.hidden = YES;
    [super viewDidLoad];
    contentImageView.image = [UIImage imageNamed: imageName];
}

#pragma mark -
#pragma mark Content

- (void) setImageName: (NSString *) name {
    imageName = name;
    contentImageView.image = [UIImage imageNamed: imageName];
    if ([imageName isEqualToString:@"Tutorial-9.png"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            emailTextField.hidden = NO;
            submitButton.hidden = NO;
        });
    }
}

- (IBAction)submitEmailActiion:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainTabbarController *mainTabbarController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabbarController"];
    [self presentViewController:mainTabbarController animated:YES completion:^{
    }];
}
@end
