//
//  MetronomoViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/11/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "MetronomoViewController.h"
#import <UIKit/UIKit.h>
#import <iAD/iAD.h>
#import "Metronome.h"
#import <AVFoundation/AVFoundation.h>


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
    Metronome *currentMetronome;
    NSTimer *myTime;
    int count;
}

@end

@implementation MetronomoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Metrónomo";
    slider.value = 10;
    tone44Button.selected = YES;
    beat5Button.hidden = YES;
    beat6Button.hidden = YES;
    beat7Button.hidden = YES;
    beat8Button.hidden = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - discreaseBPMButton

- (IBAction)tone44Action:(UIButton *)sender {
    sender.selected =! sender.selected;
    if (sender.selected) {
        beat5Button.hidden = YES;
        beat6Button.hidden = YES;
        beat7Button.hidden = YES;
        beat8Button.hidden = YES;
        
    }
}

#pragma mark - discreaseBPMButton

- (IBAction)tone34Action:(UIButton *)sender {
    sender.selected =! sender.selected;
    if (sender.selected) {
        beat5Button.hidden = YES;
        beat6Button.hidden = YES;
        beat7Button.hidden = YES;
        beat8Button.hidden = YES;
    }
}

#pragma mark - discreaseBPMButton

- (IBAction)tone24Action:(UIButton *)sender {
    sender.selected =! sender.selected;
    if (sender.selected) {
        beat5Button.hidden = YES;
        beat6Button.hidden = YES;
        beat7Button.hidden = YES;
        beat8Button.hidden = YES;
    }
}

#pragma mark - discreaseBPMButton

- (IBAction)tone68Action:(UIButton *)sender {
    sender.selected =! sender.selected;
    if (sender.selected) {
        beat5Button.hidden = NO;
        beat6Button.hidden = NO;
        beat7Button.hidden = NO;
        beat8Button.hidden = NO;
    }
}

#pragma mark - increaseBPMButton

- (IBAction)increaseBPMButton:(UIButton *)sender {
    [currentMetronome stop];
    currentMetronome = nil;
    slider.value = slider.value + 1;
    [self setValueToSide:slider.value];
}

#pragma mark - discreaseBPMButton

- (IBAction)discreaseBPMButton:(UIButton *)sender {
    [currentMetronome stop];
    currentMetronome = nil;
    slider.value = slider.value - 1;
    [self setValueToSide:slider.value];
    
}

- (void)setValueToSide:(float) slideValue {
    [currentMetronome stop];
    currentMetronome = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.roundingIncrement = [NSNumber numberWithDouble:1];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    if (playPauseBeatButton.selected) {
        [currentMetronome start];
    }
    currentMetronome = [[Metronome alloc] initWithInitialBPM:[slider value]];
    [tempoButton setTitle:[formatter stringFromNumber:[NSNumber numberWithFloat:slideValue]] forState: UIControlStateNormal];
}

#pragma mark - playPauseBeatAction

- (IBAction)playPauseBeatAction:(UIButton *)sender {
    //currentMetronome = nil;
    [self setValueToSide:slider.value];
    sender.selected = !sender.selected;
    if (sender.selected) {
        [currentMetronome start];
        myTime = [NSTimer scheduledTimerWithTimeInterval: 60.0/slider.value
                                                  target: self
                                                selector: @selector (updateBackgroundButton:)
                                                userInfo: nil
                                                 repeats: YES];
    } else {
        [currentMetronome stop];
        if (myTime != nil) {
            [myTime invalidate];
            myTime = nil;
        }
    }
}

- (void)updateBackgroundButton:(NSTimer *)theTimer {
    count = count + 1;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 60.0/slider.value];
    if (count == 5) {
        count = 1;
    }
        if (count == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                beat1Button.selected = YES;
                beat2Button.selected = NO;
                beat3Button.selected = NO;
                beat4Button.selected = NO;
            });
        } else if (count == 2) {
            dispatch_async(dispatch_get_main_queue(), ^{
                beat1Button.selected = NO;
                beat2Button.selected = YES;
                beat3Button.selected = NO;
                beat4Button.selected = NO;
            });
        } else if (count == 3) {
             dispatch_async(dispatch_get_main_queue(), ^{
                beat1Button.selected = NO;
                beat2Button.selected = NO;
                beat3Button.selected = YES;
                beat4Button.selected = NO;
             });
        } else if (count == 4) {
             dispatch_async(dispatch_get_main_queue(), ^{
                beat1Button.selected = NO;
                beat2Button.selected = NO;
                beat3Button.selected = NO;
                beat4Button.selected = YES;
             });
        }

        [UIView commitAnimations];
}

#pragma mark - Alter Metronome

- (IBAction)changeTempo:(id)sender {
    [self setValueToSide:slider.value];
}

- (void) dealloc {
    [currentMetronome stop];
}

@end
