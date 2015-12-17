//
//  ColorCell.h
//  FrameworkIOSDemo
//
//  Created by BogdanB on 20/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuItem;

@interface ColorCell : UITableViewCell

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) MenuItem *item;

@end
