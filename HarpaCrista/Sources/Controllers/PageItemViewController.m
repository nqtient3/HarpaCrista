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
#import "BaseApi.h"
#import "CDSong.h"

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
    _submitButton.enabled = NO;
    _contentImageView.image = [UIImage imageNamed:imageName];
    _submitButton.layer.cornerRadius = 8;
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.borderColor =[[UIColor whiteColor]CGColor];
    _submitButton.layer.borderWidth= 2.0;
    _submitButton.backgroundColor = [UIColor colorWithRed:15/255.0f green:128/255.0f blue:252/255.0f alpha:1];
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
    
    // Init data
    [self initData];
}

#pragma mark - Init data
- (void)initData {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[BaseApi client] getJSON:nil headers:nil toUri:@"http://harpacca.com/mobile_get_songs.php" onSuccess:^(id data, id header) {
        NSDictionary *dictData = (NSDictionary *)data;
        if (dictData) {
            NSArray *arrayData = dictData[@"data"];
            for (NSDictionary *dictItem in arrayData) {
                NSString *title = dictItem[@"post_title"];
                NSArray *arrayString = [title componentsSeparatedByString:@" - "];
                NSString *songID = arrayString[0];
                NSString *songTitle = arrayString[1];
                NSString *songChord = dictItem[@"post_content"];
                
                CDSong *song = [CDSong getOrCreateSongWithId:[songID intValue]];
                song.cdTitle = songTitle;
                song.cdChord = songChord;
                [CDSong saveContext];
            }
        }
        _submitButton.enabled = YES;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }onError:^(NSInteger code, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    // Set today to be the initial value for last_update_time
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *stringCurrentDate = [dateFormatter stringFromDate:[NSDate date]];
    [standardUserDefaults setObject:stringCurrentDate forKey:@"last_update_time"];
    [standardUserDefaults synchronize];
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
    if ([self validateEmailWithString:_emailTextField.text]) {
        NSDictionary *object = @{@"email":_emailTextField.text};
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[BaseApi client] postJSON:object headers:nil toUri:@"http://harpacca.com/mobile_submit_email.php" onSuccess:^(id data, id header) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            // Post email successfully. Continue!
            //
            NSUserDefaults *userDefault = [[NSUserDefaults alloc] init];
            [userDefault setObject:[NSNumber numberWithBool:YES] forKey:keyLoadTutorial];
            [userDefault synchronize];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MainTabbarController *mainTabbarController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabbarController"];
            [self presentViewController:mainTabbarController animated:YES completion:^{
            }];
        }onError:^(NSInteger code, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"Failed with error: %@", error.description);
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Harpa Crista" message:@"This email is invalid. Please check it again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)validateEmailWithString:(NSString*)checkString {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
