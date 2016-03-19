//
//  TunerViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/12/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "TunerViewController.h"
#import "mo_audio.h" //stuff that helps set up low-level audio
#import "FFTHelper.h"
#import "Constants.h"
#include <math.h>


#define SAMPLE_RATE 44100  //22050 //44100
#define FRAMESIZE  512
#define NUMCHANNELS 2

#define kOutputBus 0
#define kInputBus 1

static NSInteger _checkToneType;
static NSDictionary *_standToneTypeDict, *_downAHalfStepToneTypeDict, *_droppedDToneDictTypeDict, *_doubleDroppedDToneTypeDict, *_openAToneTypeDict,*_openCToneTypeDict, *_openDToneTypeDict, *_openEToneTypeDict, *_openEmToneTypeDict, *_openGToneTypeDict;

/// Nyquist Maximum Frequency
const Float32 NyquistMaxFreq = SAMPLE_RATE/2.0;
/// caculates HZ value for specified index from a FFT bins vector
Float32 frequencyHerzValue(long frequencyIndex, long fftVectorSize, Float32 nyquistFrequency ) {
    return ((Float32)frequencyIndex/(Float32)fftVectorSize) * nyquistFrequency;
}

// The Main FFT Helper
FFTHelperRef *fftConverter = NULL;

//Accumulator Buffer=====================

const UInt32 accumulatorDataLenght = 131072;  //16384; //32768; 65536; 131072;
UInt32 accumulatorFillIndex = 0;
Float32 *dataAccumulator = nil;
static void initializeAccumulator() {
    dataAccumulator = (Float32*) malloc(sizeof(Float32)*accumulatorDataLenght);
    accumulatorFillIndex = 0;
}
static void destroyAccumulator() {
    if (dataAccumulator!=NULL) {
        free(dataAccumulator);
        dataAccumulator = NULL;
    }
    accumulatorFillIndex = 0;
}

static BOOL accumulateFrames(Float32 *frames, UInt32 lenght) { //returned YES if full, NO otherwise.
    //    float zero = 0.0;
    //    vDSP_vsmul(frames, 1, &zero, frames, 1, lenght);
    if (accumulatorFillIndex>=accumulatorDataLenght) {
        return YES;
    } else {
        memmove(dataAccumulator+accumulatorFillIndex, frames, sizeof(Float32)*lenght);
        accumulatorFillIndex = accumulatorFillIndex+lenght;
        if (accumulatorFillIndex>=accumulatorDataLenght) {
            return YES;
        }
    }
    return NO;
}

static void emptyAccumulator() {
    accumulatorFillIndex = 0;
    memset(dataAccumulator, 0, sizeof(Float32)*accumulatorDataLenght);
}
//=======================================


//==========================Window Buffer
const UInt32 windowLength = accumulatorDataLenght;
Float32 *windowBuffer= NULL;
//=======================================

/// max value from vector with value index (using Accelerate Framework)
static Float32 vectorMaxValueACC32_index(Float32 *vector, unsigned long size, long step, unsigned long *outIndex) {
    Float32 maxVal;
    vDSP_maxvi(vector, step, &maxVal, outIndex, size);
    return maxVal;
}

///returns HZ of the strongest frequency.
static Float32 strongestFrequencyHZ(Float32 *buffer, FFTHelperRef *fftHelper, UInt32 frameSize, Float32 *freqValue) {
    //the actual FFT happens here
    //****************************************************************************
    Float32 *fftData = computeFFT(fftHelper, buffer, frameSize);
    //****************************************************************************
    fftData[0] = 0.0;
    unsigned long length = frameSize/2.0;
    Float32 max = 0;
    unsigned long maxIndex = 0;
    max = vectorMaxValueACC32_index(fftData, length, 1, &maxIndex);
    if (freqValue!=NULL) { *freqValue = max; }
    Float32 HZ = frequencyHerzValue(maxIndex, length, NyquistMaxFreq);
    return HZ;
}

__weak UILabel *labelToUpdate = nil;
__weak UILabel *_toneTypeToUpdateLabel = nil;

#pragma mark MAIN CALLBACK
void AudioCallback( Float32 * buffer, UInt32 frameSize, void * userData ) {
    //take only data from 1 channel
    Float32 zero = 0.0;
    vDSP_vsadd(buffer, 2, &zero, buffer, 1, frameSize*NUMCHANNELS);
    if (accumulateFrames(buffer, frameSize)==YES) { //if full
        //windowing the time domain data before FFT (using Blackman Window)
        if (windowBuffer==NULL) { windowBuffer = (Float32*) malloc(sizeof(Float32)*windowLength); }
        vDSP_blkman_window(windowBuffer, windowLength, 0);
        vDSP_vmul(dataAccumulator, 1, windowBuffer, 1, dataAccumulator, 1, accumulatorDataLenght);
        //=========================================
    
        Float32 maxHZValue = 0;
        Float32 maxHZ = strongestFrequencyHZ(dataAccumulator, fftConverter, accumulatorDataLenght, &maxHZValue);
        
        NSLog(@" max HZ = %0.2f ", maxHZ);
        dispatch_async(dispatch_get_main_queue(), ^{ //update UI only on main thread
            labelToUpdate.text = [NSString stringWithFormat:@"%0.2f HZ",maxHZ];
            TunerViewController *tunerViewController = [[TunerViewController alloc]init];
            [tunerViewController updateCoresspondingToneType:ceilf((float)maxHZ*100)/100];
        });
        emptyAccumulator(); //empty the accumulator when finished
    }
    memset(buffer, 0, sizeof(Float32)*frameSize*NUMCHANNELS);
}


@interface TunerViewController () <UITableViewDataSource,UITableViewDelegate>
@end

@implementation TunerViewController {
    __weak IBOutlet UILabel *_toneTypeLabel;
    __weak IBOutlet UILabel *_hzValueLabel;
    __weak IBOutlet UIButton *_toneTypeButton;
    __weak IBOutlet UITableView *_toneTypeTableView;
    NSArray *_toneTypeArray;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Afinador";
    _checkToneType = 0;
    [self initToneTypeData];
    [self initToneDictionarry];
    labelToUpdate = _hzValueLabel;
    _toneTypeToUpdateLabel = _toneTypeLabel;
    // Border for toneTypeTableView
    _toneTypeTableView.layer.cornerRadius = 5;
    _toneTypeTableView.layer.masksToBounds = YES;
    _toneTypeTableView.layer.borderColor =[[UIColor grayColor]CGColor];
    _toneTypeTableView.layer.borderWidth= 1.0;
    _toneTypeTableView.hidden = YES;
    //Set value default for tone type
    [_toneTypeButton setTitle:[_toneTypeArray objectAtIndex:0] forState:UIControlStateNormal];
    //initialize stuff
    fftConverter = FFTHelperCreate(accumulatorDataLenght);
    initializeAccumulator();
    [self initMomuAudio];
}

- (void) initToneDictionarry {
    // Init data with standard tone
    NSArray *_standardToneNumber = @[@(82.41), @(110.00),@(146.83),@(196.00),@(246.94),@(329.63)];
    NSArray *_standardToneString = @[@"E",@"A",@"D",@"G",@"B",@"E"];
    NSDictionary *_standToneDict = [NSDictionary dictionaryWithObjects:_standardToneString forKeys:_standardToneNumber];
   _standToneTypeDict = [NSDictionary dictionaryWithObject:_standToneDict forKey:keyStandard];

    // Init data with down a half step tone
    NSArray *_downAHalfStepToneNumber = @[@(77.78), @(103.83),@(138.59),@(185.00),@(233.08),@(311.13)];
    NSArray *_downAHalfStepToneString = @[@"D#",@"G#",@"C#",@"F#",@"A#",@"D#"];
    NSDictionary *_downAHalfStepToneDict = [NSDictionary dictionaryWithObjects:_downAHalfStepToneString forKeys:_downAHalfStepToneNumber];
    _downAHalfStepToneTypeDict = [NSDictionary dictionaryWithObject:_downAHalfStepToneDict forKey:keyDownAHalfStep];
    
    // Init data with dropped D tone
    NSArray *_droppedDToneNumber = @[@(73.42), @(110.00),@(146.83),@(196.00),@(246.94),@(329.63)];
    NSArray *_droppedDToneString = @[@"D",@"A",@"D",@"G",@"B",@"E"];
    NSDictionary *_droppedDToneDict = [NSDictionary dictionaryWithObjects:_droppedDToneString forKeys:_droppedDToneNumber];
    _droppedDToneDictTypeDict = [NSDictionary dictionaryWithObject:_droppedDToneDict forKey:keyDroppedD];
    
    // Init data with double Dropped D tone
    NSArray *_doubleDroppedDToneNumber = @[@(73.42), @(110.00),@(146.83),@(196.00),@(246.94),@(329.63)];
    NSArray *_doubleDroppedDToneString = @[@"D",@"A",@"D",@"G",@"B",@"D"];
    NSDictionary *_doubleDroppedDToneDict = [NSDictionary dictionaryWithObjects:_doubleDroppedDToneString forKeys:_doubleDroppedDToneNumber];
    _doubleDroppedDToneTypeDict = [NSDictionary dictionaryWithObject:_doubleDroppedDToneDict forKey:keyDoubleDroppedD];
    
    // Init data with open A tone
    NSArray *_openAToneNumber = @[@(82.41), @(110.00),@(164.81),@(220.00),@(277.18),@(329.63)];
    NSArray *_openAToneString = @[@"E",@"A",@"E",@"A",@"C#",@"E"];
    NSDictionary *_openAToneDict = [NSDictionary dictionaryWithObjects:_openAToneString forKeys:_openAToneNumber];
    _openAToneTypeDict = [NSDictionary dictionaryWithObject:_openAToneDict forKey:keyOpenA];
    
    // Init data with open C tone
    NSArray *_openCToneNumber = @[@(65.41), @(98.00),@(130.81),@(196.00),@(261.63),@(329.63)];
    NSArray *_openCToneString = @[@"C",@"G",@"C",@"G",@"C",@"E"];
    NSDictionary *_openCToneDict = [NSDictionary dictionaryWithObjects:_openCToneString forKeys:_openCToneNumber];
    _openCToneTypeDict = [NSDictionary dictionaryWithObject:_openCToneDict forKey:keyOpenC];
    
    // Init data with open D tone
    NSArray *_openDToneNumber = @[@(73.42), @(110.00),@(146.83),@(185.00),@(220.00),@(293.66)];
    NSArray *_openDToneString = @[@"D",@"A",@"D",@"F#",@"A",@"D"];
    NSDictionary *_openDToneDict = [NSDictionary dictionaryWithObjects:_openDToneString forKeys:_openDToneNumber];
    _openDToneTypeDict = [NSDictionary dictionaryWithObject:_openDToneDict forKey:keyOpenD];
    
    // Init data with open E tone
    NSArray *_openEToneNumber = @[@(82.41), @(123.47),@(164.81),@(207.65),@(246.94),@(329.63)];
    NSArray *_openEToneString = @[@"E",@"B",@"E",@"G#",@"B",@"E"];
    NSDictionary *_openEToneDict = [NSDictionary dictionaryWithObjects:_openEToneString forKeys:_openEToneNumber];
    _openEToneTypeDict = [NSDictionary dictionaryWithObject:_openEToneDict forKey:keyOpenE];
    
    // Init data with open Em tone
    NSArray *_openEmToneNumber = @[@(82.41), @(123.47),@(164.81),@(196.00),@(246.94),@(329.63)];
    NSArray *_openEmToneString = @[@"E",@"B",@"E",@"G",@"B",@"E"];
    NSDictionary *_openEmToneDict = [NSDictionary dictionaryWithObjects:_openEmToneString forKeys:_openEmToneNumber];
    _openEmToneTypeDict = [NSDictionary dictionaryWithObject:_openEmToneDict forKey:keyOpenEm];
    
    // Init data with open G tone
    NSArray *_openGToneNumber = @[@(98.00), @(123.47),@(146.83),@(196.00),@(246.94),@(293.66)];
    NSArray *_openGToneString = @[@"E",@"B",@"E",@"G",@"B",@"E"];
    NSDictionary *_openGToneDict = [NSDictionary dictionaryWithObjects:_openGToneString forKeys:_openGToneNumber];
    _openGToneTypeDict = [NSDictionary dictionaryWithObject:_openGToneDict forKey:keyOpenG];
}

- (void)initToneTypeData {
    _toneTypeArray = [NSArray arrayWithObjects:@"Standard (E,A,D,G,B)",@"Down a half step(D#,G#,C#,F#,A#,D#)",@"Dropped D (D,A,D,G,B,D)",@"Double Dropped D(D,A,D,G,B,D)",@"Open A (E,A,E,A,C#,E)",@"Open C (C,G,C,G,C,E)",@"Open D (D,A,D,F#,A,D)",@"Open E (E,B,E,G#,B,E)",@"Open Em (E,B,E,G,B,E)",@"Open G (G,B,D,G,B,D)", nil];
}
- (void)initMomuAudio {
    bool result = false;
    result = MoAudio::init( SAMPLE_RATE, FRAMESIZE, NUMCHANNELS, false);
    if (!result) { NSLog(@" MoAudio init ERROR"); }
    result = MoAudio::start( AudioCallback, NULL );
    if (!result) { NSLog(@" MoAudio start ERROR"); }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)updateCoresspondingToneType:(float)hzValue {
    NSLog(@"updateCoresspondingToneType : %f",hzValue);
    NSString *toneValueString;
    switch (_checkToneType) {
            //standard tone
        case 0:
            toneValueString = [[_standToneTypeDict objectForKey:keyStandard] objectForKey:@(hzValue)];
            break;
            // Down a half step
        case 1:
            toneValueString = [[_downAHalfStepToneTypeDict objectForKey:keyDownAHalfStep] objectForKey:@(hzValue)];
            break;
            // Dropped D
        case 2:
            toneValueString = [[_droppedDToneDictTypeDict objectForKey:keyDroppedD] objectForKey:@(hzValue)];
            break;
            // Double Dropped D
        case 3:
            toneValueString = [[_doubleDroppedDToneTypeDict objectForKey:keyDoubleDroppedD] objectForKey:@(hzValue)];
            break;
            // Open A
        case 4:
            toneValueString = [[_openAToneTypeDict objectForKey:keyOpenA] objectForKey:@(hzValue)];
            break;
            // Open C
        case 5:
            toneValueString = [[_openCToneTypeDict objectForKey:keyOpenC] objectForKey:@(hzValue)];
            break;
            // Open D
        case 6:
            toneValueString = [[_openDToneTypeDict objectForKey:keyOpenD] objectForKey:@(hzValue)];
            break;
            // Open E
        case 7:
            toneValueString = [[_openEToneTypeDict objectForKey:keyOpenD] objectForKey:@(hzValue)];
            break;
            // Open Em
        case 8:
            toneValueString = [[_openEmToneTypeDict objectForKey:keyOpenEm] objectForKey:@(hzValue)];
            break;
            // Open G
        case 9:
            toneValueString = [[_openGToneTypeDict objectForKey:keyOpenG] objectForKey:@(hzValue)];
            break;
        default:
            break;
    }
    if([toneValueString length] > 0) {
        _toneTypeToUpdateLabel.text = [NSString stringWithFormat:@"%@",toneValueString];
    } else {
        _toneTypeToUpdateLabel.text = @"?";
    }
   
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 47.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_toneTypeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"customTypeTone";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    nameLabel.text = [NSString stringWithFormat:@"%@", _toneTypeArray[indexPath.row]];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_toneTypeButton setTitle:[_toneTypeArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    _toneTypeTableView.hidden = YES;
    _checkToneType = indexPath.row;
}

- (IBAction)toneTypeButtonAction:(id)sender {
    _toneTypeTableView.hidden = NO;
}
- (void) dealloc {
//    destroyAccumulator();
//    FFTHelperRelease(fftConverter);
}

@end
