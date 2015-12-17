//
//  TestingBaseViewController.h
//  FrameworkIOSDemo
//
//  Created by BogdanB on 22/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SKMaps/SKMaps.h>

#import "MenuUIView.h"

@interface TestingBaseViewController : UIViewController<SKMapViewDelegate>

@property (nonatomic, strong) SKMapView *mapView;
@property (nonatomic, strong) MenuUIView *menuView;
@property (nonatomic, assign) int instanceID;

- (void)showToastWithMessage:(NSString *)message;

@end
