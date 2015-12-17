//
//  DisclosureView.h
//  DemoiOS
//
//  Created by BogdanB on 11/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDisclosureButtonSize (40.0)

@class MenuItem;

@protocol DisclosureViewDelegate;

@interface DisclosureView : UIView

@property (nonatomic, weak) id<DisclosureViewDelegate> delegate;

@property (nonatomic, strong) UIView *topView;

/** This is where custom UI goes.
 */
@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) MenuItem *item;

/** Protected methods.
    Called when X is pressed.
 */
- (void)closeClicked;

@end

@protocol DisclosureViewDelegate <NSObject>

- (void)disclosureViewDidClose:(DisclosureView *)view;

@end
