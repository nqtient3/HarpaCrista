//
//  PageItemViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/5/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "PageItemViewController.h"
#import "Constants.h"
#import "BaseApi.h"
#import "ECSlidingViewController.h"
#import <MediaPlayer/MediaPlayer.h>
@import GoogleMobileAds;

@interface PageItemViewController () {
    __weak IBOutlet UITextField *_emailTextField;
    __weak IBOutlet UIButton *_submitButton;
    __weak IBOutlet UIButton *_skipButton;
    UITapGestureRecognizer *_tapGestureRecognizer;
    __weak IBOutlet UIImageView *_contentImageView;
    
    MPMoviePlayerController *_moviePlayer;
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
    _skipButton.hidden = YES;
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
    
    //Play the video
    [self playVideo];
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
            _skipButton.hidden = NO;
        });
    }
}

#pragma mark - Play/stop video
- (void)playVideo {
    [self stopVideo];
    
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Introduction" ofType:@"mp4"]];
    
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    _moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    _moviePlayer.repeatMode = MPMovieRepeatModeOne;
    _moviePlayer.view.transform = CGAffineTransformConcat(_moviePlayer.view.transform, CGAffineTransformMakeRotation(M_PI_2));
    UIWindow *backgroundWindow = [[UIApplication sharedApplication] keyWindow];
    [_moviePlayer.view setFrame:backgroundWindow.frame];
    [backgroundWindow addSubview:_moviePlayer.view];
    [_moviePlayer play];
}

- (void)stopVideo {
    if (_moviePlayer) {
        [_moviePlayer stop];
        _moviePlayer = nil;
    }
}

#pragma mark - Submit Email Action

- (IBAction)submitEmailAction:(id)sender {
    if ([self validateEmailWithString:_emailTextField.text]) {
        NSDictionary *object = @{@"email":_emailTextField.text};
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[BaseApi client] postJSON:object headers:nil toUri:@"http://harpacca.com/mobile_submit_email.php" onSuccess:^(id data, id header) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            // Post email successfully. Continue!
            //
            [self goToMainView];
        }onError:^(NSInteger code, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"Failed with error: %@", error.description);
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Harpa Crista" message:@"This email is invalid. Please check it again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)skipAction:(id)sender {
    [self goToMainView];
}

- (void)goToMainView {
    //Stop the video
    [self stopVideo];
    
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] init];
    [userDefault setObject:[NSNumber numberWithBool:YES] forKey:keyLoadTutorial];
    [userDefault synchronize];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ECSlidingViewController *slidingViewController = [storyboard instantiateViewControllerWithIdentifier:@"slideMenu"];
    [self presentViewController:slidingViewController animated:YES completion:^{
    }];
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
