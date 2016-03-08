//
//  PageItemViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/5/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "PageItemViewController.h"
#import "MainTabbarController.h"
#import "Constants.h"

@interface PageItemViewController () {
    __weak IBOutlet UITextField *_emailTextField;
    __weak IBOutlet UIButton *_submitButton;
    UITapGestureRecognizer *_tapGestureRecognizer;
    __weak IBOutlet UIImageView *_contentImageView;
}

@end

@implementation PageItemViewController

@synthesize itemIndex,imageName;

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _emailTextField.hidden = YES;
    _submitButton.hidden = YES;
    _contentImageView.image = [UIImage imageNamed:imageName];
    _submitButton.layer.cornerRadius = 5;
    _submitButton.layer.masksToBounds = YES;
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    // Add tapGestureRecognizer for view to hide the keyboard
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                             initWithTarget:self
                             action:@selector(dismissKeyboard)];
}

#pragma mark - Actions
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = -keyboardSize.height;
        self.view.frame = frame;
    }];
    [self.view addGestureRecognizer:_tapGestureRecognizer];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0.0f;
        self.view.frame = frame;
    }];
    [self.view removeGestureRecognizer:_tapGestureRecognizer];
}

- (void)dismissKeyboard {
    [_emailTextField resignFirstResponder];
}

#pragma mark -
#pragma mark Content

- (void) setImageName:(NSString *)name {
    imageName = name;
    _contentImageView.image = [UIImage imageNamed:imageName];
    if ([imageName isEqualToString:@"Tutorial-9.png"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _emailTextField.hidden = NO;
            _submitButton.hidden = NO;
        });
    }
}

#pragma mark -Submit Email Action

- (IBAction)submitEmailAction:(id)sender {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] init];
    [userDefault setObject:[NSNumber numberWithBool:YES] forKey:keyLoadTutorial];
    [userDefault synchronize];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainTabbarController *mainTabbarController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabbarController"];
    [self presentViewController:mainTabbarController animated:YES completion:^{
    }];
}
@end
