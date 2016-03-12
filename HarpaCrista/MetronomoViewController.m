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
    Metronome *currentMetronome;
}

@end

@implementation MetronomoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Metrónomo";
    slider.value = 10;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - discreaseBPMButton

- (IBAction)tone44Action:(UIButton *)sender {
    sender.selected =! sender.selected;
}

#pragma mark - discreaseBPMButton

- (IBAction)tone24Action:(UIButton *)sender {
    sender.selected =! sender.selected;
}

#pragma mark - discreaseBPMButton

- (IBAction)tone34Action:(UIButton *)sender {
    sender.selected =! sender.selected;
}

#pragma mark - discreaseBPMButton

- (IBAction)tone68Action:(UIButton *)sender {
    sender.selected =! sender.selected;
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
    } else {
        [currentMetronome stop];
    }
}

#pragma mark - Alter Metronome

- (IBAction)changeTempo:(id)sender {
    [self setValueToSide:slider.value];
}

- (void) dealloc {
    [currentMetronome stop];
}

@end
