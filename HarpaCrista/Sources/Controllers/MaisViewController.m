//
//  SettingsViewController.m
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "MaisViewController.h"

@interface MaisViewController () <UITableViewDelegate,UITableViewDataSource> {
    //nameArray
    NSArray *contactSectionArray;
    NSArray *blogSectionArray;
    NSArray *socialSectionArray;
    
    //ImageArray
    NSArray *contactSectionArrayImage;
    NSArray *blogSectionArrayImage;
    NSArray *socialSectionArrayImage;
}

@property (weak, nonatomic) IBOutlet UITableView *maisTableView;

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


@implementation MaisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
}

- (void) initData {
    //Init Name Array
    contactSectionArray = [NSArray arrayWithObjects:@"Notificatoes",@"Ajuda",@"Contactar",@"Avaliacao",@"Compatihar", nil];
    blogSectionArray = [NSArray arrayWithObjects:@"Loja",@"Blog",@"Boletim", nil];
    socialSectionArray = [NSArray arrayWithObjects:@"Instagram",@"Facebook",@"Twitter", nil];
    
    //Init ImageArray
    contactSectionArrayImage = [NSArray arrayWithObjects:@"ic_notification",@"ic_azuda",@"ic_person",@"ic_star_settings",@"ic_share", nil];
    blogSectionArrayImage = [NSArray arrayWithObjects:@"ic_trolley",@"ic_book",@"ic_mail", nil];
    socialSectionArrayImage = [NSArray arrayWithObjects:@"ic_instagram",@"ic_facebook",@"ic_twiiter", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        return [contactSectionArray count];
    } else if (section == BlogSection ) {
        return [blogSectionArray count];
    } else {
        return [socialSectionArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"customMaisCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryDetailButton;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    if (indexPath.section == ContactSection) {
        nameLabel.text = [contactSectionArray objectAtIndex:indexPath.row];
        imageView.image = [UIImage imageNamed:[contactSectionArrayImage objectAtIndex:indexPath.row]];
    } else if (indexPath.section == BlogSection) {
        nameLabel.text = [blogSectionArray objectAtIndex:indexPath.row];
        imageView.image = [UIImage imageNamed:[blogSectionArrayImage objectAtIndex:indexPath.row]];
    } else {
        nameLabel.text = [socialSectionArray objectAtIndex:indexPath.row];
        imageView.image = [UIImage imageNamed:[socialSectionArrayImage objectAtIndex:indexPath.row]];
    }
}

@end
