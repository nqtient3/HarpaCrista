// MEMenuViewController.m
// TransitionFun
//
// Copyright (c) 2013, Michael Enriquez (http://enriquez.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MEMenuViewController.h"
#import "MenuSlideBarTableViewCell.h"
#import "UIViewController+ECSlidingViewController.h"
#import <MessageUI/MessageUI.h>

static MEMenuViewController *__shared = nil;

@interface MEMenuViewController ()<UITableViewDataSource,UITableViewDelegate, MFMailComposeViewControllerDelegate> {
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UILabel *_lblTitle;
    
    NSArray *_arrayMenuItems;
    
    UINavigationController *_hinosNavigationController;
}

@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation MEMenuViewController

- (void)viewDidLoad {
    _arrayMenuItems = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SlideMenuItems" ofType:@"plist"]] mutableCopy];
    
    _hinosNavigationController = (UINavigationController *)self.slidingViewController.topViewController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuItemChoose:) name:@"MenuItemChoose" object:nil];
}

- (void) menuItemChoose:(NSNotification*)notification {
    if ([notification.name isEqualToString:@"MenuItemChoose"]) {
        int index = [(NSNumber*)notification.object intValue];
        switch (index) {
            case 1:
                self.slidingViewController.topViewController = _hinosNavigationController;
                [self.slidingViewController resetTopViewAnimated:YES];
                break;
            case 2:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritosNavigationController"];
                [self.slidingViewController resetTopViewAnimated:YES];
                break;
            case 5:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsNavigationController"];
                [self.slidingViewController resetTopViewAnimated:YES];
                break;
            default:
                break;
        }
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return 5;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = _arrayMenuItems[indexPath.section*5 + indexPath.row];
    
    static NSString *cellIdentifier = @"MenuSlideBarTableViewCell";
    MenuSlideBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MenuSlideBarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    cell.lblTitle.text = dict[@"title"];
    cell.imvIcon.image  = [UIImage imageNamed:dict[@"icon"]];
    
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (float)3/4 * screenRect.size.width, 44.0)];
    //headerView.contentMode = UIViewContentModeScaleToFill;
    
    // Add the label
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (float)3/4 * screenRect.size.width, 44.0)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.highlightedTextColor = [UIColor blackColor];
    
    //this is what you asked
    headerLabel.font = [UIFont systemFontOfSize:11];
    
    headerLabel.shadowColor = [UIColor clearColor];
    headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    headerLabel.numberOfLines = 0;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview: headerLabel];
    
    if (section == 1) {
        headerLabel.text = @"Harpa Cristã com Acordes © 2016";
    }
    
    return headerView;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                self.slidingViewController.topViewController = _hinosNavigationController;
                break;
            case 1:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritosNavigationController"];
                break;
            case 2:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TunerNavigationController"];
                break;
            case 3:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MetronomoNavigationController"];
                break;
            case 4:
                self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsNavigationController"];
                break;
                
            default:
                break;
        }
        [self.slidingViewController resetTopViewAnimated:YES];
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://harpacca.com/perguntas-e-respostas/"]];
                break;
            case 1:
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
                break;
            case 2:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/harpa-crista-com-acordes/id903898552?mt=8"]];
                break;
            case 3: {
                NSString *textToShare = @"Achei o melhor aplicativo evangélico! @harpacrista7\n- Android: https://play.google.com/store/apps/details?id=com.harpacrista\n- iOS: https://itunes.apple.com/us/app/harpa-crista-com-acordes/id903898552?mt=8";
                
                UISimpleTextPrintFormatter *printData = [[UISimpleTextPrintFormatter alloc]
                                                         initWithText:textToShare];
                NSArray *itemsToShare = [[NSArray alloc] initWithObjects:textToShare,printData, nil];
                
                UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
                
                // Present the controller
                [self presentViewController:controller animated:YES completion:nil];
                break;
            }
            case 4:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://harpacca.com/"]];
                break;
                
            default:
                break;
        }
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

#pragma mark - Storyboard prepare segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToMais"]) {
        NSLog(@"about");
    }
    else if ([segue.identifier isEqualToString:@"upgradeAccount"]) {
        NSLog(@"upgradeAccount");
    }
}

@end
