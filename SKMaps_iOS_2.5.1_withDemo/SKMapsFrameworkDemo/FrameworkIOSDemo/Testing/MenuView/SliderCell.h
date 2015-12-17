//
//  SliderCell.h
//  MapTest
//
//  Created by BogdanB on 12/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MenuItem;

@interface SliderCell : UITableViewCell

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) MenuItem *item;

@end
