//
//  ChoiceMenu.h
//  DemoiOS
//
//  Created by BogdanB on 11/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MenuUIView.h"
#import "MenuItem.h"
#import "DisclosureView.h"


@interface ChoiceMenu : DisclosureView

+ (instancetype)menuForItem:(MenuItem *)item frame:(CGRect)frame;

@end
