//
//  BoletimViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/10/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "BoletimViewController.h"

@interface BoletimViewController () {
    __weak IBOutlet UITextField *_emailTextField;
    __weak IBOutlet UIButton *_submitButton;
    UITapGestureRecognizer *_tapGestureRecognizer;
}
@end

@implementation BoletimViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Boletim";
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)keyboardWillShow:(NSNotification *)notification {
    [self.view addGestureRecognizer:_tapGestureRecognizer];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [self.view removeGestureRecognizer:_tapGestureRecognizer];
}

- (void)dismissKeyboard {
    [_emailTextField resignFirstResponder];
}

#pragma mark -Submit Email Action

- (IBAction)submitEmailAction:(id)sender {
    // To do
}
@end
