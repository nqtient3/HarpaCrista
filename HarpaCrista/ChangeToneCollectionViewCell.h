//
//  ChangeToneCollectionViewCell.h
//  HarpaCrista
//
//  Created by MacAir on 3/5/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeToneCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor;
@end
