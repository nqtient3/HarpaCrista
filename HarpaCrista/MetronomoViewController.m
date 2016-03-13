//
//  MetronomoViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/11/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "MetronomoViewController.h"
#import <AVFoundation/AVFoundation.h>

typedef enum {
    BeatType4DevisionBy4 = 0,
    BeatType3DevisionBy4,
    BeatType2DevisionBy4,
    BeatType6DevisionBy8
} BeatType;

@interface MetronomoViewController () <AVAudioRecorderDelegate> {
    __weak IBOutlet UISlider *_slider;
    __weak IBOutlet UIButton *_buttonShowBPM;
    
    __weak IBOutlet UIButton *_buttonPlayPauseBeating;
    
    __weak IBOutlet UIButton *_buttonTone44;
    __weak IBOutlet UIButton *_buttonTone34;
    __weak IBOutlet UIButton *_buttonTone24;
    __weak IBOutlet UIButton *_buttonTone68;
    
    __weak IBOutlet UIButton *_buttonBeat1;
    __weak IBOutlet UIButton *_buttonBeat2;
    __weak IBOutlet UIButton *_buttonBeat3;
    __weak IBOutlet UIButton *_buttonBeat4;
    __weak IBOutlet UIButton *_buttonBeat5;
    __weak IBOutlet UIButton *_buttonBeat6;
    __weak IBOutlet UIButton *_buttonBeat7;
    __weak IBOutlet UIButton *_buttonBeat8;
    
    NSTimer *_timerBeat;
    int _currentBeatNumber;
    AVAudioPlayer *_audioPlayer;
    BeatType _beatType;
}

@end

@implementation MetronomoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Metrónomo";
    
    // Init the default value for slider and set it for label BPM
    _slider.value = 10;
    [_buttonShowBPM setTitle:[NSString stringWithFormat:@"%i", (int)_slider.value] forState:UIControlStateNormal];
    
    // Set beat type 3/4 to be the default
    [self buttonTone34Tapped:_buttonTone34];
    
    //Set the current beat number to be 0 as default
    _currentBeatNumber = 0;
    
    // Init the audio Player to play sound
    NSError *error = nil;
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"Pop-02"
                                              withExtension:@"wav"];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self removeTimer];
}

#pragma mark - Actions
- (IBAction)buttonTone44Tapped:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    sender.selected = !sender.selected;
    [self changeBeatTypeToType:BeatType4DevisionBy4];
    if (sender.selected) {
        [self hide4LastButtons:YES];
        [self beginBeating];
    }
}

- (IBAction)buttonTone34Tapped:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    sender.selected =!sender.selected;
    [self changeBeatTypeToType:BeatType3DevisionBy4];
    if (sender.selected) {
        [self hide4LastButtons:YES];
        [self beginBeating];
    }
}

- (IBAction)buttonTone24Tapped:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    sender.selected = !sender.selected;
    [self changeBeatTypeToType:BeatType2DevisionBy4];
    if (sender.selected) {
        [self hide4LastButtons:YES];
        [self beginBeating];
    }
}

- (IBAction)buttonTone68Tapped:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    sender.selected = !sender.selected;
    [self changeBeatTypeToType:BeatType6DevisionBy8];
    if (sender.selected) {
        [self hide4LastButtons:NO];
        [self beginBeating];
    }
}

- (void)hide4LastButtons:(BOOL)isHidden {
    _buttonBeat5.hidden = isHidden;
    _buttonBeat6.hidden = isHidden;
    _buttonBeat7.hidden = isHidden;
    _buttonBeat8.hidden = isHidden;
}

- (void)changeBeatTypeToType:(BeatType)beatType {
    switch (_beatType) {
        case BeatType4DevisionBy4:
            _buttonTone44.selected = NO;
            
            break;
        case BeatType3DevisionBy4:
            _buttonTone34.selected = NO;
            
            break;
        case BeatType2DevisionBy4:
            _buttonTone24.selected = NO;

            break;
        case BeatType6DevisionBy8:
            _buttonTone68.selected = NO;

            break;
        default:
            break;
    }
    _beatType = beatType;
}

- (IBAction)sliderChangeBPMValueChanged:(id)sender {
    [self beginBeating];
}

- (IBAction)buttonIncreaseBPMTapped:(UIButton *)sender {
    _slider.value++;
    [self beginBeating];
}

- (IBAction)buttonDecreaseBPMTapped:(UIButton *)sender {
    _slider.value--;
    [self beginBeating];
}

- (IBAction)buttonPlayPauseBeatingTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    [self beginBeating];
}

// Set and start timer to play sound and change the current button background
- (void)beginBeating {
    [_buttonShowBPM setTitle:[NSString stringWithFormat:@"%i", (int)_slider.value] forState:UIControlStateNormal];
    
    [self removeTimer];
    
    if (_buttonPlayPauseBeating.selected) {
        _timerBeat = [NSTimer timerWithTimeInterval:60.0/_slider.value target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timerBeat forMode:NSDefaultRunLoopMode];
    }
}

- (void)timerFireMethod {
    [_audioPlayer play];
    [self changeCurrentButtonBackground];
}

- (void)changeCurrentButtonBackground {
    int maxBeatNumber;
    switch (_beatType) {
        case 0:
            maxBeatNumber = 4;
            break;
        case 1:
            maxBeatNumber = 3;
            break;
        case 2:
            maxBeatNumber = 2;
            break;
        case 3:
            maxBeatNumber = 6;
            break;
        default:
            break;
    }
    
    // If the current beat number reaches to max, back to 1, otherwise increase it
    switch (_currentBeatNumber) {
        case 1:
            _buttonBeat1.selected = NO;
            _buttonBeat2.selected = YES;
            _currentBeatNumber++;
            
            break;
        case 2:
            if (maxBeatNumber == 2) {
                _buttonBeat2.selected = NO;
                _buttonBeat1.selected = YES;
                _currentBeatNumber = 1;
            } else {
                _buttonBeat2.selected = NO;
                _buttonBeat3.selected = YES;
                _currentBeatNumber++;
            }
            
            break;
        case 3:
            if (maxBeatNumber <= 3) {
                _buttonBeat3.selected = NO;
                _buttonBeat1.selected = YES;
                _currentBeatNumber = 1;
            } else {
                _buttonBeat3.selected = NO;
                _buttonBeat4.selected = YES;
                _currentBeatNumber++;
            }
            
            break;
        case 4:
            if (maxBeatNumber <= 4) {
                _buttonBeat4.selected = NO;
                _buttonBeat1.selected = YES;
                _currentBeatNumber = 1;
            } else {
                _buttonBeat4.selected = NO;
                _buttonBeat5.selected = YES;
                _currentBeatNumber++;
            }
            
            break;
        case 5:
            if (maxBeatNumber == 6) {
                _buttonBeat5.selected = NO;
                _buttonBeat6.selected = YES;
                _currentBeatNumber++;
            } else {
                _buttonBeat5.selected = NO;
                _buttonBeat1.selected = YES;
                _currentBeatNumber = 1;
            }
            
            break;
        case 6:
            _buttonBeat6.selected = NO;
            _buttonBeat1.selected = YES;
            _currentBeatNumber = 1;
            
            break;
            
        default:
            _buttonBeat1.selected = YES;
            _currentBeatNumber++;
            
            break;
    }
}

- (void)removeTimer {
    if (_timerBeat) {
        [_timerBeat invalidate];
        _timerBeat = nil;
    }
}

#pragma mark - Alter Metronome
- (void)dealloc {
    [self removeTimer];
}

@end
