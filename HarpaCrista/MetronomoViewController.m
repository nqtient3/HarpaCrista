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
    Metronome *currentMetronome;
}

@end

@implementation MetronomoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Metrónomo";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Alter Metronome

-(IBAction)changeTempo:(id)sender {
    [currentMetronome stop];
    currentMetronome = nil;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.roundingIncrement = [NSNumber numberWithDouble:1];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    currentMetronome = [[Metronome alloc] initWithInitialBPM:[slider value]];
    [currentMetronome start];
    [tempoButton setTitle:[formatter stringFromNumber:[NSNumber numberWithFloat:[slider value]]] forState: UIControlStateNormal];
}

- (void) dealloc {
    [currentMetronome stop];
}

@end
