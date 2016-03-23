//
//  MainTabbarController.m
//  HarpaCrista
//
//  Created by MacAir on 3/3/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "MainTabbarController.h"

@interface MainTabbarController () {
    __weak IBOutlet UITabBar *_mainTabBarController;
}

@end

@implementation MainTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITabBarItem *tabBarHinosItem = [self.tabBar.items objectAtIndex:0];
    tabBarHinosItem.selectedImage = [[UIImage imageNamed:@"ic_hinos_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *tabBarFavoritosItem = [self.tabBar.items objectAtIndex:1];
    tabBarFavoritosItem.selectedImage = [[UIImage imageNamed:@"ic_star_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *tabBarMaisItem = [self.tabBar.items objectAtIndex:2];
    tabBarMaisItem.selectedImage = [[UIImage imageNamed:@"ic_global_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
