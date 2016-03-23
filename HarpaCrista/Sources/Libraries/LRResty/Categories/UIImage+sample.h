//
//  UIImage+sample.h
//  Nuscore
//
//  Created by Dimitar Plamenov on 11/4/14.
//  Copyright (c) DP. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage (sample)
+ (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
@end
