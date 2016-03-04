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
    __weak IBOutlet UIView *toolView;
    __weak IBOutlet UIView *exitZoomView;
    __weak IBOutlet UIView *pauseAutoScView;
    __weak IBOutlet UIButton *maxZoomWebViewButton;
    __weak IBOutlet UIButton *minZoomWebViewButton;
    __weak IBOutlet UIButton *fullScreenWebViewButton;
    __weak IBOutlet UIButton *exitFullScreenWebViewButton;
    __weak IBOutlet UIButton *pauseAutoScButton;
    int textFontSize;
    NSInteger maxheight;
    NSInteger currentHeight;
    NSTimer *scriptTimer;
}

@end

@implementation HinosDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    maxheight = 0;
    currentHeight = 0;
    // Do any additional setup after loading the view.
    
    //Corner for zoomView
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:zoomView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    zoomView.layer.mask = maskLayer;
    
    //Corner for exitZoomView
    UIBezierPath *exitMaskPath = [UIBezierPath bezierPathWithRoundedRect:exitZoomView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *exitMaskLayer = [[CAShapeLayer alloc] init];
    exitMaskLayer.frame = self.view.bounds;
    exitMaskLayer.path  = exitMaskPath.CGPath;
    exitZoomView.layer.mask = exitMaskLayer;
    
    //Corner for pauseAutoScView
    UIBezierPath *pauseMaskPath = [UIBezierPath bezierPathWithRoundedRect:pauseAutoScView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *pauseMaskLayer = [[CAShapeLayer alloc] init];
    pauseMaskLayer.frame = self.view.bounds;
    pauseMaskLayer.path = pauseMaskPath.CGPath;
    pauseAutoScView.layer.mask = pauseMaskLayer;
    
    exitZoomView.hidden = YES;
    pauseAutoScView.hidden = YES;
    
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
    toolView.hidden = YES;
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = YES;
    exitZoomView.hidden = NO;
    pauseAutoScView.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    currenWebView.frame = self.view.bounds;
    maxheight = [[currenWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    currentHeight = 0;
    [self stopScriptTimer];
    scriptTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(startAnimationTimer) userInfo:nil repeats:YES];
}

- (void)stopScriptTimer {
    if (scriptTimer != nil) {
        [scriptTimer invalidate];
        scriptTimer = nil;
    }
}

- (void)startAnimationTimer {
    if (currentHeight >= maxheight) {
        [self stopScriptTimer];
    } else {
        NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", (long)currentHeight];
        [currenWebView stringByEvaluatingJavaScriptFromString:javascript];
        currentHeight ++;
    }
    
}


#pragma mark - exitFullScreenWebViewAction

- (IBAction)exitFullScreenWebViewAction:(id)sender {
    toolView.hidden = NO;
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.tabBarController.tabBar.hidden = NO;
    exitZoomView.hidden = YES;
    pauseAutoScView.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self stopScriptTimer];
}

#pragma mark - pauseAutoScWebViewAction

- (IBAction)pauseAutoScWebViewAction:(id)sender {
    [self stopScriptTimer];
}
@end
