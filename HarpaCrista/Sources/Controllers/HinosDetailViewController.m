//
//  HirosDetailViewController.m
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "HinosDetailViewController.h"

@interface HinosDetailViewController ()<UIWebViewDelegate> {
    __weak IBOutlet UIWebView *currenWebView;
    __weak IBOutlet UIView *zoomView;
    __weak IBOutlet UIButton *maxZoomWebViewButton;
    __weak IBOutlet UIButton *minZoomWebViewButton;
    __weak IBOutlet UIButton *fullScreenWebViewButton;
    int textFontSize;
}

@end

@implementation HinosDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:zoomView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    zoomView.layer.mask = maskLayer;
    if (self.currentCDSong) {
        self.title = [NSString stringWithFormat:@"%@ - %@",self.currentCDSong.cdSongID,self.currentCDSong.cdTitle];
        currenWebView.delegate = self;
        NSString *fullString = @"<body>";
        fullString = [fullString stringByAppendingString:self.currentCDSong.cdChord];
        fullString = [fullString stringByAppendingString:@"</body>"];
        [currenWebView loadHTMLString:[fullString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"] baseURL:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *bodyStyle = @"document.getElementsByTagName('body')[0].style.textAlign = 'center';";
    [currenWebView stringByEvaluatingJavaScriptFromString:bodyStyle];
    textFontSize = 100;
}

#pragma mark - MaxZoomWebViewAction

- (IBAction)maxZoomWebViewAction:(id)sender {
    textFontSize = (textFontSize < 160) ? textFontSize +10 : textFontSize;
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
                          textFontSize];
    [currenWebView stringByEvaluatingJavaScriptFromString:jsString];
}

#pragma mark - MinZoomWebViewAction

- (IBAction)minZoomWebViewAction:(id)sender {
    textFontSize = (textFontSize > 50) ? textFontSize -10 : textFontSize;
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
                          textFontSize];
    [currenWebView stringByEvaluatingJavaScriptFromString:jsString];
}

#pragma mark - MinZoomWebViewAction

- (IBAction)fullScreenWebViewAction:(id)sender {

}
@end
