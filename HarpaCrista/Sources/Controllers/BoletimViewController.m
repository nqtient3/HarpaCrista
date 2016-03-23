//
//  BoletimViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/10/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "BoletimViewController.h"
#import "BaseApi.h"

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
    // Border for submitButton
    _submitButton.layer.cornerRadius = 8;
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.borderColor =[[UIColor whiteColor]CGColor];
    _submitButton.layer.borderWidth= 2.0;
    _submitButton.backgroundColor = [UIColor colorWithRed:62/255.0f green:158/255.0f blue:239/255.0f alpha:1];
    // Border for emailTextField
    _emailTextField.layer.cornerRadius = 5;
    _emailTextField.layer.masksToBounds = YES;
    _emailTextField.layer.borderColor =[[UIColor grayColor]CGColor];
    _emailTextField.layer.borderWidth= 1.0;
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

#pragma mark - Submit Email Action 

- (IBAction)submitEmailAction:(id)sender {
    if ([self validateEmailWithString:_emailTextField.text]) {
        NSDictionary *object = @{@"email":_emailTextField.text};
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[BaseApi client] postJSON:object headers:nil toUri:@"http://harpacca.com/mobile_submit_email.php" onSuccess:^(id data, id header) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Harpa Crista" message:@"Submit the email successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }onError:^(NSInteger code, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"Failed with error: %@", error.description);
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Harpa Crista" message:@"This email is invalid. Please check it again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)validateEmailWithString:(NSString*)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
