//
//  HirosDetailViewController.m
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "HinosDetailViewController.h"
#import "ChangeToneCollectionViewCell.h"

#define DISTANCE_ONCE 10
#define DEFAULT_TIME_EACH_LOOP 0.05


@interface HinosDetailViewController ()<UIWebViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate> {
    __weak IBOutlet UIWebView *currenWebView;
    __weak IBOutlet UIView *zoomView;
    __weak IBOutlet UIView *toolView;
    __weak IBOutlet UIView *exitZoomView;
    __weak IBOutlet UIView *pauseAutoScView;
    __weak IBOutlet UIView *changeToneView;
    __weak IBOutlet UIButton *maxZoomWebViewButton;
    __weak IBOutlet UIButton *minZoomWebViewButton;
    __weak IBOutlet UIButton *fullScreenWebViewButton;
    __weak IBOutlet UIButton *exitFullScreenWebViewButton;
    __weak IBOutlet UIButton *pauseAutoScButton;
    __weak IBOutlet UICollectionView *changeToneCollectionView;
    int textFontSize;
    float scrollViewContentHeight;
    float scrollViewContentOffset;
    NSTimer *scriptTimer;
    float timeEachLoop;
    
    // Status of AutoScroll/Pause button
    BOOL _isAutoScroll;
    // Status of Fullscreen mode
    BOOL _isFullScreenMode;
    NSArray *toneItemDataArray;
}

@end

@implementation HinosDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init data for tone item
    toneItemDataArray = [NSArray arrayWithObjects:@"Bb",@"B",@"C",@"Db",@"D",@"Eb",@"E",@"F",@"Gb",@"G",@"Ab",@"A",nil];
    
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
    
    //Corner radius for changeToneCollectionView
    changeToneCollectionView.layer.cornerRadius = 5;
    changeToneCollectionView.layer.masksToBounds = YES;
    
    exitZoomView.hidden = YES;
    pauseAutoScView.hidden = YES;
    // Set default time for each loop
    timeEachLoop = DEFAULT_TIME_EACH_LOOP;
    changeToneView.hidden = YES;
    
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [toneItemDataArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ChangeToneCollectionViewCell";
    ChangeToneCollectionViewCell *changeToneCollectionViewCell = (ChangeToneCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[changeToneCollectionViewCell viewWithTag:1];
    titleLabel.text = [toneItemDataArray objectAtIndex:indexPath.row];
    return changeToneCollectionViewCell;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *bodyStyle = @"document.getElementsByTagName('body')[0].style.textAlign = 'center';";
    [currenWebView stringByEvaluatingJavaScriptFromString:bodyStyle];
    textFontSize = 100;
}

#pragma mark - MaxZoomWebViewAction

- (IBAction)maxZoomWebViewAction:(id)sender {
    if (!_isFullScreenMode) {
        textFontSize = (textFontSize < 160) ? textFontSize +10 : textFontSize;
        NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
                              textFontSize];
        [currenWebView stringByEvaluatingJavaScriptFromString:jsString];
    } else {
        if (timeEachLoop > 0.01) {
            timeEachLoop -= 0.01;
        }
    }
    [self reAutoScroll];
}

#pragma mark - MinZoomWebViewAction

- (IBAction)minZoomWebViewAction:(id)sender {
    if (!_isFullScreenMode) {
        textFontSize = (textFontSize > 50) ? textFontSize -10 : textFontSize;
        NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
                              textFontSize];
        [currenWebView stringByEvaluatingJavaScriptFromString:jsString];
    } else {
        if (timeEachLoop < 0.1) {
            timeEachLoop += 0.01;
        }
    }
    [self reAutoScroll];
}

- (void)reAutoScroll {
    [self pauseAutoScWebViewAction:nil];
    [self pauseAutoScWebViewAction:nil];
}

#pragma mark - MinZoomWebViewAction

- (IBAction)fullScreenWebViewAction:(id)sender {
    _isFullScreenMode = YES;
    changeToneView.hidden = YES;
    toolView.hidden = YES;
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = YES;
    exitZoomView.hidden = NO;
    pauseAutoScView.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    currenWebView.frame = self.view.bounds;
    
    scrollViewContentHeight = currenWebView.scrollView.contentSize.height;

    [self pauseAutoScWebViewAction:nil];
}

- (void)stopScriptTimer {
    if (scriptTimer != nil) {
        [scriptTimer invalidate];
        scriptTimer = nil;
    }
}

- (void)startAnimationTimer {
    if (currenWebView.scrollView.contentOffset.y >= scrollViewContentHeight - currenWebView.scrollView.frame.size.height) {
        [self stopScriptTimer];
    } else {
        CGPoint point = currenWebView.scrollView.contentOffset;
        
        [currenWebView.scrollView setContentOffset:CGPointMake(point.x, point.y + 1)];
    }
}

#pragma mark - exitFullScreenWebViewAction

- (IBAction)exitFullScreenWebViewAction:(id)sender {
    _isFullScreenMode = NO;
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
    _isAutoScroll = !_isAutoScroll;
    
    [self stopScriptTimer];
    
    if (_isAutoScroll) {
        scriptTimer = [NSTimer scheduledTimerWithTimeInterval:timeEachLoop target:self selector:@selector(startAnimationTimer) userInfo:nil repeats:YES];
    }
}

- (IBAction)changeToneAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        changeToneView.hidden = NO;
    } else {
        changeToneView.hidden = YES;
    }
}

@end
