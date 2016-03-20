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
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // iPhone and       iPod touch style UI
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6P (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)

typedef enum {
    tone1,
    tone2
} tone;

@interface HinosDetailViewController ()<UIWebViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate> {
    __weak IBOutlet UIWebView *_webView;
    __weak IBOutlet UIView *_zoomView;
    __weak IBOutlet UIView *_toolView;
    __weak IBOutlet UIView *_exitZoomView;
    __weak IBOutlet UIView *_pausePlayAutoScrollView;
    __weak IBOutlet UIView *_changeToneView;
    __weak IBOutlet UIButton *_maxZoomWebViewButton;
    __weak IBOutlet UIButton *_minZoomWebViewButton;
    __weak IBOutlet UIButton *_fullScreenWebViewButton;
    __weak IBOutlet UIButton *_exitFullScreenWebViewButton;
    __weak IBOutlet UIButton *_pauseAutoScrollButton;
    __weak IBOutlet UIButton *_mudeButton;
    __weak IBOutlet UIButton *_metromomoButton;
    __weak IBOutlet UICollectionView *_changeToneCollectionView;
    int _textFontSize;
    float _scrollViewContentHeight;
    float _scrollViewContentOffset;
    NSTimer *_scriptTimer;
    float timeEachLoop;
    // Status of AutoScroll/Pause button
    BOOL _isAutoScroll;
    // Status of Fullscreen mode
    BOOL _isFullScreenMode;
    NSArray *_toneItemDataArray;
    CGRect _partScreenRect;
    NSString *_fullString;
    NSMutableArray *_selectedRange;
    BOOL _isChangeToneView;
    UITapGestureRecognizer *_tapGestureRecognizer;
}
@end

@implementation HinosDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Init data for tone item
    if ([self currentTone] == tone1) {
        _toneItemDataArray = @[@"A", @"A#", @"B", @"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#"];
    } else {
        _toneItemDataArray = @[@"A", @"Bb", @"B", @"C", @"Db", @"D", @"Eb", @"E", @"F", @"Gb", @"G", @"Ab"];
    }
    [self changeRangeArray];
    [self changeSelectedRangeAtIndex:0];
    //Corner for zoomView
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_zoomView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    _zoomView.layer.mask = maskLayer;
    
    //Corner for exitZoomView
    UIBezierPath *exitMaskPath = [UIBezierPath bezierPathWithRoundedRect:_exitZoomView.bounds byRoundingCorners:(UIRectCornerTopLeft) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *exitMaskLayer = [[CAShapeLayer alloc] init];
    exitMaskLayer.frame = self.view.bounds;
    exitMaskLayer.path  = exitMaskPath.CGPath;
    _exitZoomView.layer.mask = exitMaskLayer;
    
    //Corner for pauseAutoScView
    UIBezierPath *pauseMaskPath = [UIBezierPath bezierPathWithRoundedRect:_pausePlayAutoScrollView.bounds byRoundingCorners:(UIRectCornerBottomLeft) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *pauseMaskLayer = [[CAShapeLayer alloc] init];
    pauseMaskLayer.frame = self.view.bounds;
    pauseMaskLayer.path = pauseMaskPath.CGPath;
    _pausePlayAutoScrollView.layer.mask = pauseMaskLayer;
    
    //Corner radius for changeToneCollectionView
    _changeToneCollectionView.layer.cornerRadius = 5;
    _changeToneCollectionView.layer.masksToBounds = YES;
    
    _exitZoomView.hidden = YES;
    _pausePlayAutoScrollView.hidden = YES;
    // Set default time for each loop
    timeEachLoop = DEFAULT_TIME_EACH_LOOP;
    _changeToneView.hidden = YES;
    
    // Add tapGestureRecognizer for view to hide the ToneView
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                             initWithTarget:self
                             action:@selector(dismissChangeToneView:)];
    _tapGestureRecognizer.delegate = self;
    
    if (self.currentCDSong) {
        self.title = [NSString stringWithFormat:@"%@ - %@",self.currentCDSong.cdSongID,self.currentCDSong.cdTitle];
        _webView.delegate = self;
        _fullString = @"<body>";
        _fullString = [_fullString stringByAppendingString:self.currentCDSong.cdChord];
        _fullString = [_fullString stringByAppendingString:@"</body>"];
//        [_webView loadHTMLString:[_fullString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"] baseURL:nil];
        [_webView loadHTMLString:_fullString baseURL:nil];
    }
}

//Change rangeArray
- (void)changeRangeArray {
    NSString *firstRange = [[self getFirstRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray *changedRange = [[NSMutableArray alloc] initWithArray:_toneItemDataArray];
    __block NSInteger firstRangeIndex = 0;
    [_toneItemDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *range = [(NSString *)obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // String that use to check first String contains m
        NSString *secondString;
        if ([firstRange containsString:@"m"]) {
            secondString = [firstRange substringToIndex:1];
        }
        if ([range isEqualToString:firstRange] || [range isEqualToString:secondString]) {
            firstRangeIndex = idx;
            *stop = YES;
        }
    }];
    for (NSInteger i=0; i<_toneItemDataArray.count; i++) {
        //Apply Caesar_cipher follow link : https://en.wikipedia.org/wiki/Caesar_cipher 
        NSString *tone = _toneItemDataArray[(firstRangeIndex+i)%12];
        changedRange[i] = tone;
    }
    _toneItemDataArray = [changedRange copy];
}

// Get the first Tone
- (NSString *)getFirstRange {
    NSString *inputString = self.currentCDSong.cdChord;
    NSString *outPutString = [self stringByStrippingHTML:inputString];
    return outPutString;
}

// Remove HTML tags from NSString
- (NSString *) stringByStrippingHTML:(NSString *)stringHTML {
    NSRange range;
    while ((range = [stringHTML rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound){
            stringHTML = [stringHTML stringByReplacingCharactersInRange:range withString:@" "];
    }
    stringHTML = [stringHTML stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *stringArray = [stringHTML componentsSeparatedByString:@" "];
    return [stringArray firstObject];
}

- (void)changeSelectedRangeAtIndex:(NSInteger)index {
    if (!_selectedRange) {
        _selectedRange = [[NSMutableArray alloc] init];
        for (int i = 0; i<_toneItemDataArray.count; i++) {
            [_selectedRange addObject:@(0)];
        }
    }
    for (int i = 0; i<_toneItemDataArray.count; i++) {
        if (i == index) {
            _selectedRange[i] = @(1);
        } else {
            _selectedRange[i] = @(0);
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

- (void)dismissChangeToneView:(UIGestureRecognizer *)gestureRecognizer {
    [self changeToneAction:_mudeButton];
    [_changeToneView removeGestureRecognizer:_tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:_changeToneCollectionView]) {
        return NO;
    }
    return YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_toneItemDataArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ChangeToneCollectionViewCell";
    ChangeToneCollectionViewCell *changeToneCollectionViewCell = (ChangeToneCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    changeToneCollectionViewCell.titleLabel.text = [_toneItemDataArray objectAtIndex:indexPath.row];
    NSNumber *isSelected = [_selectedRange objectAtIndex:indexPath.row];
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (IS_IPHONE_6 || IS_IPHONE_6P) {
        return UIEdgeInsetsMake(32, 10, 32, 10);
    }
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self changeSelectedRangeAtIndex:indexPath.row];
    ChangeToneCollectionViewCell *cell = (ChangeToneCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSString *rangeString = cell.titleLabel.text;
    [self findAndReplaceCorrespondingTone:rangeString];
    _isChangeToneView = NO;
    [self changeToneAction:_mudeButton];
    [_changeToneView removeGestureRecognizer:_tapGestureRecognizer];
    [_changeToneCollectionView reloadData];
    
}

#pragma mark - findAndReplaceCorrespondingTone

- (void)findAndReplaceCorrespondingTone:(NSString *)rangeString {
    __block NSInteger toneIndex;
    // Find index of tone want to change
    [_toneItemDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *range = (NSString *)obj;
        if ([range isEqualToString:rangeString]) {
            toneIndex = idx;
            *stop = YES;
        }
    }];
    // Seperate string to array by character </p>
    NSArray *arrayComponents = [_fullString componentsSeparatedByString:@"</p>"];
    NSMutableArray *resultArray = [arrayComponents mutableCopy];
    [arrayComponents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx%2 == 0) {
            // If it is index of tone
            BOOL isSpan = NO;
            NSString *oldString = (NSString *)obj;
            if ([oldString hasSuffix:@"</span>"]) {// The end string has </span>
                oldString = [oldString substringToIndex:oldString.length - 7];
                isSpan = YES;
            }
            oldString = [oldString stringByAppendingString:@" "];
            __block NSMutableString *newString = [[NSMutableString alloc] initWithString:oldString];
            for (NSInteger i = 0; i< _toneItemDataArray.count; i++) {
                NSRange searchRange = NSMakeRange(0,oldString.length);
                NSRange foundRange;
                while (searchRange.location < oldString.length) { // find and replace tone
                    searchRange.length = oldString.length-searchRange.location;
                    foundRange = [oldString rangeOfString:_toneItemDataArray[i] options:0 range:searchRange];
                    if (foundRange.location != NSNotFound) {
                        //Apply Caesar_cipher follow link : https://en.wikipedia.org/wiki/Caesar_cipher
                        NSString *replaceString = _toneItemDataArray[(toneIndex + i)%12];
                        NSString *currentString = _toneItemDataArray[i];
                        if (currentString.length < 2 && replaceString.length < 2) {
                            NSString *nextString = [oldString substringWithRange:NSMakeRange(foundRange.location + 1, 1)];
                            if ([nextString isEqualToString:@"b"] || [nextString isEqualToString:@"#"]) {
                                break;
                            }
                        }
                        if (replaceString.length > currentString.length) {
                            [newString replaceOccurrencesOfString:currentString withString:replaceString options:NSCaseInsensitiveSearch range:NSMakeRange(foundRange.location, foundRange.length+1)];
                        } else if (replaceString.length < currentString.length) {
                            [newString replaceOccurrencesOfString:currentString withString:[replaceString stringByAppendingString:@" "] options:NSCaseInsensitiveSearch range:foundRange];
                        } else {
                            [newString replaceOccurrencesOfString:currentString withString:replaceString options:NSCaseInsensitiveSearch range:foundRange];
                        }
                        searchRange.location = foundRange.location+foundRange.length;
                    } else {
                        break;
                    }
                }
            }
            [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *result;
            if (isSpan) {
                result = [newString stringByAppendingString:@"</span>"];
            } else {
                result = newString;
            }
            // Update array result
            resultArray[idx] = result;
        }
    }];
    // Plus string from all array value
    NSString *resultString = [resultArray componentsJoinedByString:@"</p>"];
    [_webView loadHTMLString:[resultString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"] baseURL:nil];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *bodyStyle = @"document.getElementsByTagName('body')[0].style.textAlign = 'center';";
    [_webView stringByEvaluatingJavaScriptFromString:bodyStyle];
    _textFontSize = 100;
}

#pragma mark - MaxZoomWebViewAction

- (IBAction)maxZoomWebViewAction:(id)sender {
    if (!_isFullScreenMode) {
        _textFontSize = (_textFontSize < 160) ? _textFontSize +10 : _textFontSize;
        NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
                              _textFontSize];
        [_webView stringByEvaluatingJavaScriptFromString:jsString];
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
        _textFontSize = (_textFontSize > 50) ? _textFontSize -10 : _textFontSize;
        NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
                              _textFontSize];
        [_webView stringByEvaluatingJavaScriptFromString:jsString];
    } else {
        if (timeEachLoop < 0.1) {
            timeEachLoop += 0.01;
        }
    }
    [self reAutoScroll];
}


- (void)reAutoScroll {
    [self pausePlayAutoScrollWebViewAction:nil];
    [self pausePlayAutoScrollWebViewAction:nil];
}

- (void)stopScriptTimer {
    if (_scriptTimer != nil) {
        [_scriptTimer invalidate];
        _scriptTimer = nil;
    }
}

- (void)startAnimationTimer {
    if (_webView.scrollView.contentOffset.y >= _scrollViewContentHeight - _webView.scrollView.frame.size.height) {
        [self pausePlayAutoScrollWebViewAction:_pauseAutoScrollButton];
    } else {
        CGPoint point = _webView.scrollView.contentOffset;
        
        [_webView.scrollView setContentOffset:CGPointMake(point.x, point.y + 1)];
    }
}

#pragma mark - Fullscreen and Exit fullscreen modes
- (IBAction)fullScreenWebViewAction:(id)sender {
    _isFullScreenMode = YES;
    _changeToneView.hidden = YES;
    _toolView.hidden = YES;
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.tabBarController.tabBar.hidden = YES;
    _exitZoomView.hidden = NO;
    _pausePlayAutoScrollView.hidden = NO;
    _pauseAutoScrollButton.selected = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    _partScreenRect = _webView.frame;
    _webView.frame = self.view.frame;
    
    _scrollViewContentHeight = _webView.scrollView.contentSize.height;
    
    [self pausePlayAutoScrollWebViewAction:nil];
}

- (IBAction)exitFullScreenWebViewAction:(id)sender {
    _isFullScreenMode = NO;
    _toolView.hidden = NO;
    
    self.navigationController.navigationBar.hidden = NO;
    
    self.tabBarController.tabBar.hidden = NO;
    
    _exitZoomView.hidden = YES;
    _pausePlayAutoScrollView.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (_isAutoScroll) {
        [self pausePlayAutoScrollWebViewAction:nil];
    } else {
        [self stopScriptTimer];
    }
    _webView.frame = _partScreenRect;
}

#pragma mark - pauseAutoScWebViewAction

- (IBAction)pausePlayAutoScrollWebViewAction:(id)sender {
    _isAutoScroll = !_isAutoScroll;
    UIButton *button = (UIButton *)sender;
    button.selected =!button.selected;
    [self stopScriptTimer];
    
    if (_isAutoScroll) {
        _scriptTimer = [NSTimer scheduledTimerWithTimeInterval:timeEachLoop target:self selector:@selector(startAnimationTimer) userInfo:nil repeats:YES];
    }
}

#pragma mark - tunerButtonAction

- (IBAction)tunerAction:(id)sender {
    [self performSegueWithIdentifier:@"tunerSegue" sender:nil];
}

#pragma mark - metronomoAction

- (IBAction)metronomoAction:(id)sender {
    [self performSegueWithIdentifier:@"metronomoSegue" sender:nil];
}

#pragma mark - changeToneAction

- (IBAction)changeToneAction:(UIButton *)sender {
    [_changeToneView addGestureRecognizer:_tapGestureRecognizer];
     sender.selected = !sender.isSelected;
    if (sender.selected) {
        _changeToneView.hidden = NO;
    } else {
        _changeToneView.hidden = YES;
    }
}

#pragma mark - buttonShareTapped

- (IBAction)buttonShareTapped:(id)sender {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[@"Harpa Crista"] applicationActivities:nil];
    
    // Present the controller
    [self presentViewController:controller animated:YES completion:nil];
}

@end
