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
    UITapGestureRecognizer *_tapGestureRecognizer;
}

@end

@implementation PageItemViewController

@synthesize itemIndex;
@synthesize imageName;
@synthesize contentImageView;

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    emailTextField.hidden = YES;
    submitButton.hidden = YES;
    contentImageView.image = [UIImage imageNamed: imageName];
    submitButton.layer.cornerRadius = 5;
    submitButton.layer.masksToBounds = YES;
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    // Add tapGestureRecognizer for view to hide the keyboard
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                             initWithTarget:self
                             action:@selector(dismissKeyboard)];
}

#pragma mark - Actions
- (void)keyboardDidShow {
    [self.view addGestureRecognizer:_tapGestureRecognizer];
}

- (void)keyboardDidHide {
    [self.view removeGestureRecognizer:_tapGestureRecognizer];
}

- (void)dismissKeyboard {
    [emailTextField resignFirstResponder];
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
