//
//  ChangeToneCollectionViewCell.m
//  HarpaCrista
//
//  Created by MacAir on 3/5/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "ChangeToneCollectionViewCell.h"

@implementation ChangeToneCollectionViewCell

- (void)awakeFromNib {
    self.layer.cornerRadius = CGRectGetHeight(self.frame)/2;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.0;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor{
    self.backgroundColor = backgroundColor;
    self.titleLabel.textColor = textColor;
    if (backgroundColor == [UIColor whiteColor]) {
        self.layer.borderColor = [UIColor blackColor].CGColor;
    } else {
        self.layer.borderColor = backgroundColor.CGColor;
    }
    
}

@end
