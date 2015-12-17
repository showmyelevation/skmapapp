//
//  TestingLastFrameViewController.m
//  FrameworkIOSDemo
//
//  Created by BogdanB on 22/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingLastFrameViewController.h"

@interface TestingLastFrameViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TestingLastFrameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addImageView];

    [self addMenuItems];

    [self.view bringSubviewToFront:self.menuView];
}

- (void)addImageView {
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.5, 0.0, self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5)];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.layer.borderWidth = 1.0;
    self.imageView.layer.borderColor = [[UIColor blackColor] CGColor];

    [self.view addSubview:self.imageView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.imageView.frame = CGRectMake(self.view.frame.size.width * 0.5, 0.0, self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    MenuItem *snapshot = [MenuItem itemWithID:@"continuousSnapshot"];
    if (snapshot.boolValue) {
        self.imageView.image = [self.mapView lastRenderedFrame];
    }
}

- (void)addMenuItems {

    __weak TestingLastFrameViewController *weakSelf = self;

    MenuItem *showImgView = [MenuItem itemForToggleWithTitle:@"Show frame" uniqueID:@"testingToggleFrame" changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.imageView.hidden = !item.boolValue;
    }];
    showImgView.boolValue = YES;

    MenuItem *continuousSnapshot = [MenuItem itemForToggleWithTitle:@"Continuous snapshot" uniqueID:@"continuousSnapshot" changeBlock:nil];
    continuousSnapshot.boolValue = YES;

    MenuItem *takeSnapshot = [MenuItem itemForButtonWithTitle:@"Take snapshot" selectionBlock:^(MenuItem *item) {
        weakSelf.imageView.image = [weakSelf.mapView lastRenderedFrame];
    }];

    MenuItem *clearSnapshot = [MenuItem itemForButtonWithTitle:@"Clear snapshot" selectionBlock:^(MenuItem *item) {
        weakSelf.imageView.image = nil;
    }];

    MenuSection *section = [MenuSection sectionWithTitle:@"Options" items:@[showImgView, continuousSnapshot, takeSnapshot, clearSnapshot]];
    self.menuView.sections = @[section];
}

- (void)mapView:(SKMapView *)mapView didChangeToRegion:(SKCoordinateRegion)region {
    MenuItem *snapshot = [MenuItem itemWithID:@"continuousSnapshot"];
    if (snapshot.boolValue) {
        self.imageView.image = [self.mapView lastRenderedFrame];
    }
}

@end
