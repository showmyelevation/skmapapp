//
//  TextCell.h
//  CoreDemo
//
//  Created by BogdanB on 22/01/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MenuItem.h"

@interface TextCell : UITableViewCell

@property (nonatomic, strong) MenuItem *item;
@property (nonatomic, strong) UITextView *field;

@end
