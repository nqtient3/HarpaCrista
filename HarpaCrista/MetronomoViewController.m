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
    __weak IBOutlet UISlider *slider;
    __weak IBOutlet UIButton *tempoButton;
    __weak IBOutlet UIButton *increaseBPMButton;
    __weak IBOutlet UIButton *discreaseBPMButton;
    __weak IBOutlet UIButton *playPauseBeatButton;
    
    __weak IBOutlet UIButton *tone44Button;
    __weak IBOutlet UIButton *tone34Button;
    __weak IBOutlet UIButton *tone24Button;
    __weak IBOutlet UIButton *tone68Button;
    
    __weak IBOutlet UIButton *beat1Button;
    __weak IBOutlet UIButton *beat2Button;
    __weak IBOutlet UIButton *beat3Button;
    __weak IBOutlet UIButton *beat4Button;
    __weak IBOutlet UIButton *beat5Button;
    __weak IBOutlet UIButton *beat6Button;
    __weak IBOutlet UIButton *beat7Button;
    __weak IBOutlet UIButton *beat8Button;
    
    NSTimer *timerBeat;
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
    slider.value = 10;
    // Set beat type 3/4 to be the default
    [self tone34Action:tone34Button];
    
    //Set the current beat number to be 1 as default
    _currentBeatNumber = 1;
    
    //
    NSError *error = nil;
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"Pop-02"
                                              withExtension:@"wav"];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (timerBeat) {
        [timerBeat invalidate];
        timerBeat = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - discreaseBPMButton

- (IBAction)tone44Action:(UIButton *)sender {
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

- (IBAction)tone34Action:(UIButton *)sender {
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

- (IBAction)tone24Action:(UIButton *)sender {
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

- (IBAction)tone68Action:(UIButton *)sender {
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
    beat5Button.hidden = isHidden;
    beat6Button.hidden = isHidden;
    beat7Button.hidden = isHidden;
    beat8Button.hidden = isHidden;
}

- (void)changeBeatTypeToType:(BeatType)beatType {
    switch (_beatType) {
        case BeatType4DevisionBy4:
            tone44Button.selected = NO;
            
            break;
        case BeatType3DevisionBy4:
            tone34Button.selected = NO;
            
            break;
        case BeatType2DevisionBy4:
            tone24Button.selected = NO;

            break;
        case BeatType6DevisionBy8:
            tone68Button.selected = NO;

            break;
        default:
            break;
    }
    _beatType = beatType;
}

- (IBAction)changeTempo:(id)sender {
    [self beginBeating];
}

- (IBAction)increaseBPMButton:(UIButton *)sender {
    slider.value = slider.value + 1;
    [self beginBeating];
}

- (IBAction)discreaseBPMButton:(UIButton *)sender {
    slider.value--;
    [self beginBeating];
}

- (IBAction)playPauseBeatAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    [self beginBeating];
}

- (void)beginBeating {
    [tempoButton setTitle:[NSString stringWithFormat:@"%i", (int)slider.value] forState: UIControlStateNormal];
    
    if (timerBeat) {
        [timerBeat invalidate];
        timerBeat = nil;
    }
    
    if (playPauseBeatButton.selected) {
        timerBeat = [NSTimer timerWithTimeInterval:60.0/slider.value target:self selector:@selector(timerFireMethod) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timerBeat forMode:NSDefaultRunLoopMode];
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
    
    switch (_currentBeatNumber) {
        case 1:
            beat1Button.selected = NO;
            beat2Button.selected = YES;
            break;
        case 2:
            if (maxBeatNumber == 2) {
                beat2Button.selected = NO;
                beat1Button.selected = YES;
            } else {
                beat2Button.selected = NO;
                beat3Button.selected = YES;
            }
            
            break;
        case 3:
            if (maxBeatNumber == 3) {
                beat3Button.selected = NO;
                beat1Button.selected = YES;
            } else {
                beat3Button.selected = NO;
                beat4Button.selected = YES;
            }
            
            break;
        case 4:
            if (maxBeatNumber == 4) {
                beat4Button.selected = NO;
                beat1Button.selected = YES;
            } else {
                beat4Button.selected = NO;
                beat5Button.selected = YES;
            }
            
            break;
        case 5:
            beat5Button.selected = NO;
            beat6Button.selected = YES;
            break;
        case 6:
            beat6Button.selected = NO;
            beat1Button.selected = YES;
            break;
        default:
            break;
    }
    
    if (_currentBeatNumber == maxBeatNumber) {
        _currentBeatNumber = 1;
    } else {
        _currentBeatNumber++;
    }
}

#pragma mark - Alter Metronome
- (void) dealloc {
    if (timerBeat) {
        [timerBeat invalidate];
        timerBeat = nil;
    }
}

@end
