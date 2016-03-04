//
//  HirosDetailViewController.h
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDSong.h"

@interface HinosDetailViewController : UIViewController

@property (nonatomic, strong) CDSong *currentCDSong;
- (IBAction)maxZoomWebViewAction:(id)sender;
- (IBAction)minZoomWebViewAction:(id)sender;
- (IBAction)fullScreenWebViewAction:(id)sender;

@end
