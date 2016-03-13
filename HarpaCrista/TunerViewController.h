//
//  TunerViewController.h
//  HarpaCrista
//
//  Created by MacAir on 3/12/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTNote.h"
#import "PitchDetector.h"
#import "RWKnobControl.h"

@interface TunerViewController : UIViewController < UIPopoverControllerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) RWKnobControl *knobControl;
@property (strong, nonatomic) UIView *knobPlaceholder;
@property (strong, nonatomic) GTNote *noteData;
@property (nonatomic, strong) UILabel *noteDisplay;
@property (nonatomic, strong) UILabel *freqencyDisplay;
@property (nonatomic, assign) double currentFrequency;
@property (nonatomic, strong) NSString *currentNote;
@property(assign) BOOL isListening;

@property (nonatomic, strong) PitchDetector *pitchDetector;

- (void)updateFrequencyLabel;
- (void)updateToFrequncy:(double)freqency;

@end
