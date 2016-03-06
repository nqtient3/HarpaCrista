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

typedef enum {
    tone1,
    tone2
} tone;

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
    CGRect partScreenRect;
    NSString *fullString;
    
    NSMutableArray *selectedRange;
}

@end

@implementation HinosDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Init data for tone item
    if ([self currentTone] == tone1) {
        toneItemDataArray = @[@"A ", @"A#", @"B ", @"C ", @"C#", @"D ", @"D#", @"E ", @"F ", @"F#", @"G ", @"G#"];
    } else {
        toneItemDataArray = @[@"A ", @"Bb", @"B ", @"C ", @"Db", @"D ", @"Eb", @"E ", @"F ", @"Gb", @"G ", @"Ab"];
    }
    [self changeRangeArray];
    [self changeSelectedRangeAtIndex:0];
    //Corner for zoomView
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:zoomView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    zoomView.layer.mask = maskLayer;
    
    //Corner for exitZoomView
    UIBezierPath *exitMaskPath = [UIBezierPath bezierPathWithRoundedRect:exitZoomView.bounds byRoundingCorners:(UIRectCornerTopLeft) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *exitMaskLayer = [[CAShapeLayer alloc] init];
    exitMaskLayer.frame = self.view.bounds;
    exitMaskLayer.path  = exitMaskPath.CGPath;
    exitZoomView.layer.mask = exitMaskLayer;
    
    //Corner for pauseAutoScView
    UIBezierPath *pauseMaskPath = [UIBezierPath bezierPathWithRoundedRect:pauseAutoScView.bounds byRoundingCorners:(UIRectCornerBottomLeft) cornerRadii:CGSizeMake(5.0, 5.0)];
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
        fullString = @"<body>";
        fullString = [fullString stringByAppendingString:self.currentCDSong.cdChord];
        fullString = [fullString stringByAppendingString:@"</body>"];
        [currenWebView loadHTMLString:[fullString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"] baseURL:nil];
    }
}

- (void)changeRangeArray {
    NSString *firstRange = [self getFirstRange];
    NSMutableArray *changedRange = [[NSMutableArray alloc] initWithArray:toneItemDataArray];
    __block NSInteger firstRangeIndex = 0;
    [toneItemDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *range = [(NSString *)obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([range isEqualToString:firstRange]) {
            firstRangeIndex = idx;
            *stop = YES;
        }
    }];
    for (NSInteger i=0; i<toneItemDataArray.count; i++) {
        NSString *tone = toneItemDataArray[(firstRangeIndex+i)%12];
        changedRange[i] = tone;
    }
    
    toneItemDataArray = [changedRange copy];
}

- (NSString *)getFirstRange {
    NSString *inputString = self.currentCDSong.cdChord;
    NSArray *components = [inputString componentsSeparatedByString:@"</p>"];
    NSString *firstText = [components firstObject];
    if (firstText) {
        NSArray *range = [firstText componentsSeparatedByString:@"<span class=\"s1\">"];
        NSString *lastString;
        NSArray *nextString;
        if ([firstText containsString:@"<span class=\"s1\">"]) {
            lastString = [range objectAtIndex:1];
            lastString = [lastString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            nextString = [lastString componentsSeparatedByString:@" "];
        } else if ([firstText containsString:@"<p class=\"p1\">"]) {
            lastString = [range firstObject];
            nextString = [lastString componentsSeparatedByString:@"<p class=\"p1\">"];
            lastString = [nextString objectAtIndex:1];
            lastString = [lastString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            nextString = [lastString componentsSeparatedByString:@" "];
        }
        return [nextString firstObject];
    }
    return @"";
}

- (void)changeSelectedRangeAtIndex:(NSInteger)index {
    if (!selectedRange) {
        selectedRange = [[NSMutableArray alloc] init];
        for (int i = 0; i<toneItemDataArray.count; i++) {
            [selectedRange addObject:@(0)];
        }
    }
    for (int i = 0; i<toneItemDataArray.count; i++) {
        if (i == index) {
            selectedRange[i] = @(1);
        } else {
            selectedRange[i] = @(0);
        }
    }
}

- (NSInteger)currentTone {
    if ([self.currentCDSong.cdChord containsString:@"Eb"] ||
        [self.currentCDSong.cdChord containsString:@"Gb"] ||
        [self.currentCDSong.cdChord containsString:@"Ab"] ||
        [self.currentCDSong.cdChord containsString:@"Bb"] ||
        [self.currentCDSong.cdChord containsString:@"Db"]) {
        return tone2;
    }
    return tone1;
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
    changeToneCollectionViewCell.titleLabel.text = [toneItemDataArray objectAtIndex:indexPath.row];
    NSNumber *isSelected = [selectedRange objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        [changeToneCollectionViewCell setBackgroundColor:[UIColor blackColor] textColor:[UIColor whiteColor]];
    } else {
        [changeToneCollectionViewCell setBackgroundColor:[UIColor whiteColor] textColor:[UIColor blackColor]];
    }
    if ([isSelected boolValue]) {
        [changeToneCollectionViewCell setBackgroundColor:[UIColor colorWithRed:87/255.0f green:161/255.0f blue:(230/255.0f) alpha:1] textColor:[UIColor whiteColor]];
    }
    return changeToneCollectionViewCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self changeSelectedRangeAtIndex:indexPath.row];
    changeToneView.hidden = YES;
    ChangeToneCollectionViewCell *cell = (ChangeToneCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSString *rangeString = cell.titleLabel.text;
    __block NSInteger toneIndex;
    [toneItemDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *range = (NSString *)obj;
        if ([range isEqualToString:rangeString]) {
            toneIndex = idx;
            *stop = YES;
        }
    }];
    //NSString *newString = toneItemDataArray[(toneIndex-idx)%12];
    //NSString *oldString = toneItemDataArray[idx];
    NSArray *arrayComponents = [fullString componentsSeparatedByString:@"</p>"];
    NSMutableArray *resultArray = [arrayComponents mutableCopy];
    [arrayComponents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx%2 == 0) {
            NSString *oldString = [(NSString *)obj stringByAppendingString:@" "];
            __block NSMutableString *newString = [[NSMutableString alloc] initWithString:oldString];
            for (NSInteger i = 0; i< toneItemDataArray.count; i++) {
                NSRange searchRange = NSMakeRange(0,oldString.length);
                NSRange foundRange;
                while (searchRange.location < oldString.length) {
                    searchRange.length = oldString.length-searchRange.location;
                    foundRange = [oldString rangeOfString:toneItemDataArray[i] options:0 range:searchRange];
                    if (foundRange.location != NSNotFound) {
                        if (newString.length == 3118) {
                            NSLog(@"");
                        }
                        NSString *replaceString = toneItemDataArray[(labs(toneIndex - i))%12];
                        [newString replaceOccurrencesOfString:toneItemDataArray[i] withString:replaceString options:NSCaseInsensitiveSearch range:foundRange];
                        searchRange.location = foundRange.location+foundRange.length;
                    } else {
                        break;
                    }
                }
            }
            NSRange rng = [oldString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:NSBackwardsSearch];
            resultArray[idx] = [newString substringToIndex:rng.location+1];
        }
    }];
    NSString *resultString = [resultArray componentsJoinedByString:@"</p>"];
    [currenWebView loadHTMLString:[resultString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"] baseURL:nil];
    [changeToneCollectionView reloadData];
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

#pragma mark - Fullscreen and Exit fullscreen modes
- (IBAction)fullScreenWebViewAction:(id)sender {
    _isFullScreenMode = YES;
    changeToneView.hidden = YES;
    toolView.hidden = YES;
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.tabBarController.tabBar.hidden = YES;
    exitZoomView.hidden = NO;
    pauseAutoScView.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    partScreenRect = currenWebView.frame;
    currenWebView.frame = self.view.frame;
    
    scrollViewContentHeight = currenWebView.scrollView.contentSize.height;
    
    [self pauseAutoScWebViewAction:nil];
}

- (IBAction)exitFullScreenWebViewAction:(id)sender {
    _isFullScreenMode = NO;
    toolView.hidden = NO;
    
    self.navigationController.navigationBar.hidden = NO;
    
    self.tabBarController.tabBar.hidden = NO;
    
    exitZoomView.hidden = YES;
    pauseAutoScView.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (_isAutoScroll) {
        [self pauseAutoScWebViewAction:nil];
    } else {
        [self stopScriptTimer];
    }
    currenWebView.frame = partScreenRect;
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
