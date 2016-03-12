#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Metronome : NSObject

- (id)initWithInitialBPM:(int)speed;
- (void)timerFireMethod:(NSTimer*)theTimer;
- (void)start;
- (void)stop;

@property (nonatomic, assign) int beatsPerMinute;

@end
