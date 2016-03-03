//
//  HirosDetailViewController.m
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "HinosDetailViewController.h"

@interface HinosDetailViewController () {
    __weak IBOutlet UIWebView *webView;
}

@end

@implementation HinosDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.currentCDSong) {
        self.title = [NSString stringWithFormat:@"%@ - %@",self.currentCDSong.cdSongID,self.currentCDSong.cdTitle];
        [webView loadHTMLString:[self.currentCDSong.cdChord stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"] baseURL:nil];
        NSString *bodyStyle = @"document.getElementsByTagName('body')[0].style.textAlign = 'center';";
        NSString *mapStyle = @"document.getElementById('mapid').style.margin = 'auto';";
        [webView stringByEvaluatingJavaScriptFromString:bodyStyle];
        [webView stringByEvaluatingJavaScriptFromString:mapStyle];
    }
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
