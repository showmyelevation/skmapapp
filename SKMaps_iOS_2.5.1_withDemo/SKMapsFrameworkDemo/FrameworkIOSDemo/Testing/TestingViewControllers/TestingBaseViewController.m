//
//  TestingBaseViewController.m
//  FrameworkIOSDemo
//
//  Created by BogdanB on 22/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingBaseViewController.h"
#import "UIView+Additions.h"

@interface TestingBaseViewController ()

@property (nonatomic, strong) UILabel *messageLabel;

@end

static int testingVCInstanceCount = 0;

@implementation TestingBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    testingVCInstanceCount++;
    self.instanceID = testingVCInstanceCount;
    
    [self addMap];
    
    [self addMenu];

    [self addMessageLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)addMap {
    //display the map
    self.mapView = [[SKMapView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.settings.showDebugView = YES;
    
    [self.view addSubview:self.mapView];
    
    //set map region
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(52.5233, 13.4127);
    region.zoomLevel = 17.0f;
    [self.mapView setVisibleRegion:region];
}

- (void)addMenu {
    self.menuView = [MenuUIView rootMenuWithSections:@[] frame:CGRectMake(0.0, 0.0, 200.0, 300.0)];
    self.menuView.centerX = self.view.frameWidth / 2.0;
    self.menuView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:self.menuView];
}

- (void)addMessageLabel {
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 20.0, self.view.frame.size.width - 20.0, 20.0)];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.backgroundColor = [UIColor colorWithRed:0.1 green:0.2 blue:1.0 alpha:0.7];
    [self.view addSubview:self.messageLabel];
}

- (void)viewDidLayoutSubviews {
    self.messageLabel.frameHeight = [self.messageLabel.text sizeWithAttributes:@{NSFontAttributeName : self.messageLabel.font}].height;
}

- (void)showToastWithMessage:(NSString *)message {
    self.messageLabel.alpha = 1.0;

    CGSize size = [message sizeWithAttributes:@{NSFontAttributeName : self.messageLabel.font}];

    self.messageLabel.frameHeight = size.height;
    self.messageLabel.text = message;

    [UIView animateWithDuration:2.0 delay:1.0 options:0 animations:^{
        self.messageLabel.alpha = 0.0;
    } completion:nil];
}

@end
