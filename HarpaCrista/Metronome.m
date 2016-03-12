#import "Metronome.h"

@implementation Metronome {
    NSTimer *tickTimer;
    AVAudioPlayer *audioPlayer;
}

- (id)initWithInitialBPM:(int)speed {
    _beatsPerMinute = speed;
    float timeInterval = 60.0/_beatsPerMinute;

    tickTimer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:tickTimer forMode:NSDefaultRunLoopMode];
    NSError *error = nil;
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"Pop-02"
                                              withExtension:@"wav"];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    return self;
}

- (void)start {
    if([tickTimer isValid]) {
        [tickTimer fire];
    } else {
        [NSException raise:@"MMTimerNotValidException" format:@"You're trying to fire a non-valid timer!"];
    }
}

- (void)stop {
    [tickTimer invalidate];
    tickTimer = nil;
}

- (void)timerFireMethod:(NSTimer*)theTimer {
    [audioPlayer play];
}


@end
