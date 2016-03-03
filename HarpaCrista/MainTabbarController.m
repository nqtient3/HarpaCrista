//
//  MainTabbarController.m
//  HarpaCrista
//
//  Created by MacAir on 3/3/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "MainTabbarController.h"

@interface MainTabbarController ()

@end

@implementation MainTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.mainTabBarController setTintColor:[UIColor colorWithRed:80/255.f green:187/255.f blue:250/255.f alpha:1.0]];
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
