//
//  SettingsViewController.m
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController () <UITableViewDelegate,UITableViewDataSource> {
    //nameArray
    NSArray *_contactSectionArray;
    NSArray *_blogSectionArray;
    NSArray *_socialSectionArray;
    
    //ImageArray
    NSArray *_contactSectionArrayImage;
    NSArray *_blogSectionArrayImage;
    NSArray *_socialSectionArrayImage;
    __weak IBOutlet UITableView *_maisTableView;
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
    [self initData];
}

- (void)initData {
    //Init Name Array
    _contactSectionArray = [NSArray arrayWithObjects:@"Ajuda",@"Contactar",@"Avaliacao",@"Compatihar", nil];
    _blogSectionArray = [NSArray arrayWithObjects:@"Loja",@"Blog",@"Boletim", nil];
    _socialSectionArray = [NSArray arrayWithObjects:@"Instagram",@"Facebook",@"Twitter", nil];
    
    //Init ImageArray
    
    _contactSectionArrayImage = [NSArray arrayWithObjects:@"ic_azuda",@"ic_person",@"ic_star_settings",@"ic_share", nil];
    _blogSectionArrayImage = [NSArray arrayWithObjects:@"ic_trolley",@"ic_book",@"ic_mail", nil];
    _socialSectionArrayImage = [NSArray arrayWithObjects:@"ic_instagram",@"ic_facebook",@"ic_twiiter", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Coming soon" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.instagram.com/harpacrista7"]];
        } else if (indexPath.row == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://m.facebook.com/harpacca"]];
        } else if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/HarpaCrista7"]];
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

@end
