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
    tabBarHinosItem.image = [[UIImage imageNamed:@"icn_hinos"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarHinosItem.selectedImage = [[UIImage imageNamed:@"icn_hinos_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *tabBarFavoritosItem = [self.tabBar.items objectAtIndex:1];
    tabBarFavoritosItem.image = [[UIImage imageNamed:@"icn_favoritos"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarFavoritosItem.selectedImage = [[UIImage imageNamed:@"icn_favoritos_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *tabBarMaisItem = [self.tabBar.items objectAtIndex:2];
    tabBarMaisItem.image = [[UIImage imageNamed:@"icn_mais"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarMaisItem.selectedImage = [[UIImage imageNamed:@"icn_mais_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
