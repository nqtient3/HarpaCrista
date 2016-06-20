//
//  SettingsViewController.m
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "SettingsViewController.h"
#import <MessageUI/MessageUI.h>
#import "BoletimViewController.h"
#import "Reachability.h"
#import "UIViewController+ECSlidingViewController.h"
@import GoogleMobileAds;

@interface SettingsViewController () <UITableViewDelegate,UITableViewDataSource, MFMailComposeViewControllerDelegate, GADBannerViewDelegate> {
    //nameArray
    NSArray *_contactSectionArray;
    NSArray *_blogSectionArray;
    NSArray *_socialSectionArray;
    
    //ImageArray
    NSArray *_contactSectionArrayImage;
    NSArray *_blogSectionArrayImage;
    NSArray *_socialSectionArrayImage;
    __weak IBOutlet UITableView *_maisTableView;
    
    __weak IBOutlet GADBannerView *_bannerView;
    __weak IBOutlet NSLayoutConstraint *_heightBannerConstraint;
}

typedef enum {
    ContactSection,
    BlogSection,
    SocialSection
} NumberSection;

typedef enum {
    Notificatoes,
    Ajuda,
    Contactar,
    Avaliacao,
    Compatihar
} ContactsSection;

typedef enum {
    Loja,
    Blog,
    Boletim
} BlogsSection;

typedef enum {
    Instagram,
    Facebook,
    Twitter
} SocialsSection;
@end


@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setSlideBarViewController];
    
    [self initData];
}

- (void)initData {
    //Init Name Array
    _contactSectionArray = [NSArray arrayWithObjects:@"Ajuda",@"Contactar",@"Avaliação",@"Compatihar", nil];
    _blogSectionArray = [NSArray arrayWithObjects:@"Loja",@"Blog",@"Boletim", nil];
    _socialSectionArray = [NSArray arrayWithObjects:@"Instagram",@"Facebook",@"Twitter", nil];
    
    //Init ImageArray
    
    _contactSectionArrayImage = [NSArray arrayWithObjects:@"ic_azuda",@"ic_person",@"ic_star_settings",@"ic_share", nil];
    _blogSectionArrayImage = [NSArray arrayWithObjects:@"ic_trolley",@"ic_book",@"ic_mail", nil];
    _socialSectionArrayImage = [NSArray arrayWithObjects:@"ic_instagram",@"ic_facebook",@"ic_twiiter", nil];
    
    //Load Ads if the network is connectable
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        //Set height of banner to 0
        _heightBannerConstraint.constant = 0.0f;
    } else {
        [self loadGoogleAds];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GoogleAds - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    _bannerView.hidden = NO;
}

- (void)loadGoogleAds {
    _bannerView.hidden = YES;
    //Google AdMob
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    _bannerView.adUnitID = @"ca-app-pub-5569929039117299/9402430169";
    _bannerView.adSize = kGADAdSizeSmartBannerPortrait;
    _bannerView.rootViewController = self;
    _bannerView.delegate = self;
    
    [_bannerView loadRequest:[GADRequest request]];
}

#pragma mark - ECSlidingViewControllerAnchoredGesture
- (void)setSlideBarViewController {
    self.slidingViewController.delegate = nil;
    self.slidingViewController.anchorRightRevealAmount = 240.f;
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    self.slidingViewController.customAnchoredGestures = @[];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (IBAction)revealMenu:(id)sender {
    ECSlidingViewController *slidingViewController = self.slidingViewController;
    if (slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [slidingViewController resetTopViewAnimated:YES];
    } else {
        [slidingViewController anchorTopViewToRightAnimated:YES];
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == ContactSection) {
        return [_contactSectionArray count];
    } else if (section == BlogSection ) {
        return [_blogSectionArray count];
    } else {
        return [_socialSectionArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"customMaisCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryDetailButton;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://harpacca.com/perguntas-e-respostas/"]];
        } else if (indexPath.row == 1) {
            if ([MFMailComposeViewController canSendMail]) {
                // Email Subject
                NSString *emailTitle = @"Contact from app";
                // Email Content
                NSString *messageBody = @"";
                // To address
                NSArray *toRecipents = @[@"contact@harpacca.com"];
                
                MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                mc.mailComposeDelegate = self;
                [mc setSubject:emailTitle];
                [mc setMessageBody:messageBody isHTML:NO];
                [mc setToRecipients:toRecipents];
                
                // Present mail view controller on screen
                [self presentViewController:mc animated:YES completion:NULL];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Harpa Crista" message:@"Please setup a mail account in your phone first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        } else if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/harpa-crista-com-acordes/id903898552?mt=8"]];
        } else if (indexPath.row == 3) {
            NSString *textToShare = @"Achei o melhor aplicativo evangélico! @harpacrista7\n- Android: https://play.google.com/store/apps/details?id=com.harpacrista\n- iOS: https://itunes.apple.com/us/app/harpa-crista-com-acordes/id903898552?mt=8";
            
            UISimpleTextPrintFormatter *printData = [[UISimpleTextPrintFormatter alloc]
                                                     initWithText:textToShare];
            NSArray *itemsToShare = [[NSArray alloc] initWithObjects:textToShare,printData, nil];
            
            UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
            
            // Present the controller
            [self presentViewController:controller animated:YES completion:nil];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://harpacca.com/shop/"]];
        } else if (indexPath.row == 1) {
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://harpacca.com/artigos-recentes/"]];
        } else if (indexPath.row == 2 ) {
            [self performSegueWithIdentifier:@"boletimSegue" sender:nil];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            NSURL *url = [NSURL URLWithString:@"instagram://user?username=harpacrista7"];
            if ([[UIApplication sharedApplication] canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.instagram.com/harpacrista7"]];
            }
        } else if (indexPath.row == 1) {
            NSURL *url = [NSURL URLWithString:@"fb://profile/harpacca"];
            if ([[UIApplication sharedApplication] canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://facebook.com/harpacca"]];
            }
        } else if (indexPath.row == 2) {
            NSURL *url = [NSURL URLWithString:@"twitter://user?screen_name=HarpaCrista7"];
            if ([[UIApplication sharedApplication] canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/HarpaCrista7"]];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    if (indexPath.section == ContactSection) {
        nameLabel.text = [_contactSectionArray objectAtIndex:indexPath.row];
        imageView.image = [UIImage imageNamed:[_contactSectionArrayImage objectAtIndex:indexPath.row]];
    } else if (indexPath.section == BlogSection) {
        nameLabel.text = [_blogSectionArray objectAtIndex:indexPath.row];
        imageView.image = [UIImage imageNamed:[_blogSectionArrayImage objectAtIndex:indexPath.row]];
    } else {
        nameLabel.text = [_socialSectionArray objectAtIndex:indexPath.row];
        imageView.image = [UIImage imageNamed:[_socialSectionArrayImage objectAtIndex:indexPath.row]];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
