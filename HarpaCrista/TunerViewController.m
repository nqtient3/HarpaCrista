//
//  TunerViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/12/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "TunerViewController.h"
#import "FlipsideViewController.h"
#import "FBKVOController.h"
#import "MacroHelpers.h"

@interface TunerViewController ()
@end

@implementation TunerViewController {
    int count;
    UIButton *m_toggleButton;
    FBKVOController *_KVOController;
    NSString *lastFreq;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Afinador";
    self.view.backgroundColor = rgb(36, 42, 50);
    
    count = 0;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:4096 forKey:@"kBufferSize"];
    [userDefaults setInteger:0 forKey:@"percentageOfOverlap"];
    [userDefaults synchronize];
    
    CGRect currentFrame = self.view.frame;
    self.knobPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(currentFrame.size.width/6, currentFrame.size.width/3, currentFrame.size.width/1.5, currentFrame.size.width/1.5)];
    [self.view addSubview:self.knobPlaceholder];
    self.knobControl = [[RWKnobControl alloc] initWithFrame:self.knobPlaceholder.bounds];
    [self.knobPlaceholder addSubview:_knobControl];
    
    self.knobControl.lineWidth = 4.5;
    self.knobControl.pointerLength = 8.0;
    self.knobControl.tintColor = [UIColor colorWithRed:0.237 green:0.504 blue:1.000 alpha:1.000];
    [self.knobControl setValue:0.004 animated:NO];
        
    _noteDisplay = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.65, self.view.frame.size.width/1.8, 80, 80)];
    [_noteDisplay setText:@"-"];
    [_noteDisplay setTextColor:[UIColor whiteColor]];
    [_noteDisplay setTextAlignment:NSTextAlignmentCenter];
    [_noteDisplay setFont:[UIFont boldSystemFontOfSize:40.0f]];
    //[noteDisplay setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:_noteDisplay];
    
    _freqencyDisplay = [[UILabel alloc] initWithFrame:CGRectMake(currentFrame.size.width/4, currentFrame.size.height/1.8, currentFrame.size.width/2, currentFrame.size.height/8)];
    _freqencyDisplay.text = @"0.0";
    [_freqencyDisplay setTextColor:[UIColor whiteColor]];
    [_freqencyDisplay setTextAlignment:NSTextAlignmentCenter];
    [_freqencyDisplay setFont:[UIFont boldSystemFontOfSize:35.0f]];
    [self.view addSubview:_freqencyDisplay];
    
    // Load data components
    _pitchDetector = [PitchDetector sharedDetector];
    [_pitchDetector TurnOnMicrophoneTuner:self];
    _noteData = [[GTNote alloc] init];
    
    _KVOController = [FBKVOController controllerWithObserver:self];
    [_KVOController observe:_noteData keyPath:@"currentNote" options:NSKeyValueObservingOptionNew block:^(TunerViewController *observer, GTNote *object, NSDictionary *change) {
        NSLog(@"Changed: %@", change[NSKeyValueChangeNewKey]);
        [self performSelectorInBackground:@selector(updateNoteLabel) withObject:nil];
    }];
    
    [_KVOController observe:_noteData keyPath:@"currentFrequency" options:NSKeyValueObservingOptionNew block:^(TunerViewController *observer, GTNote *object, NSDictionary *change) {
        [self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
    }];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [_KVOController unobserve:_noteData keyPath:@"currentNote"];
        [_KVOController unobserve:_noteData keyPath:@"currentFrequency"];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    _noteDisplay = nil;
    _freqencyDisplay = nil;
    [super viewDidDisappear:animated];
}

- (void)updateNoteLabel {
    _noteDisplay.text = _noteData.currentNote;
}

- (void)updateFrequencyLabel {
    _freqencyDisplay.text = [NSString stringWithFormat:@"%.2f", _noteData.currentFrequency];
    self.knobControl.minimumValue = _noteData.minFrequency;
    self.knobControl.maximumValue = _noteData.maxFreqency;
    
    count++;
    if (count >= 5 && _noteData.currentFrequency > _noteData.minFrequency && _noteData.currentFrequency < _noteData.maxFreqency) // Keeps tuner view from going crazy
    {
        [self.knobControl setValue:_noteData.currentFrequency animated:YES];
        count = 0;
    }
}

- (void)updateToFrequncy:(double)freqency {
    NSString *huh = [NSString stringWithFormat:@"%.2f", freqency];
    
    if ([huh isEqualToString:lastFreq])
        [_noteData calculateCurrentNote:freqency];
    
    lastFreq = [NSString stringWithFormat:@"%.2f", freqency];
}


- (void)dealloc {
   _pitchDetector = nil;
}

@end
