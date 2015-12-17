//
//  PositionerLoggingViewController.m
//  FrameworkIOSDemo
//
//  Created by Cristian Chertes on 05/06/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingPositionerLoggingViewController.h"

@interface TestingPositionerLoggingViewController ()

@property (nonatomic, assign) SKPositionsLoggingType    loggingType;
@property (nonatomic, strong) NSString                  *logPath;

@end

@implementation TestingPositionerLoggingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.settings.followUserPosition = YES;
    self.logPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Logs"];
    [self configureMenuView];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[SKPositionsLoggingService sharedInstance] stopLoggingPositions];
}

#pragma mark - Actions

- (void)startLogging {
    __weak TestingPositionerLoggingViewController *weakSelf = self;
    
    [[SKPositionsLoggingService sharedInstance] startLoggingPositionsToFileAtPath:weakSelf.logPath withLoggingType:weakSelf.loggingType];
}

- (void)pauseLogging {
    [[SKPositionsLoggingService sharedInstance] pauseLoggingPositions];
}

- (void)resumeLogging {
    [[SKPositionsLoggingService sharedInstance] resumeLoggingPositions];
}

- (void)stopLogging {
    [[SKPositionsLoggingService sharedInstance] stopLoggingPositions];
}

#pragma mark - Private methods

- (void)configureMenuView {
    MenuSection *loggingOptionsSection = [self loggingOptionsSection];
    MenuSection *loggingActionsSection = [self loggingActionsSection];
    
    self.menuView.sections = @[loggingOptionsSection, loggingActionsSection];
}

- (MenuSection *)loggingOptionsSection {
    __weak TestingPositionerLoggingViewController *weakSelf = self;
    
    NSArray *loggingReadableOptions = @[@"Log", @"GPX"];
    NSArray *loggingOptions = @[@(SKPositionsLoggingTypeLOG),@(SKPositionsLoggingTypeGPX)];
    MenuItem *loggingTypeItem = [MenuItem itemForOptionsWithTitle:@"Logging Type" uniqueID:nil options:loggingOptions readableOptions:loggingReadableOptions changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.loggingType = item.intValue;
    }];
    loggingTypeItem.value = @(SKPositionsLoggingTypeLOG);
    
    MenuItem *logPathItem = [MenuItem itemForButtonWithTitle:@"Path" selectionBlock:nil];
    logPathItem.title = @"/Documents/Logs";
    
    MenuSection *loggingOptionsSection = [MenuSection sectionWithTitle:@"Logging Options" items:@[loggingTypeItem, logPathItem]];
    
    return loggingOptionsSection;
}

- (MenuSection *)loggingActionsSection {
    __weak TestingPositionerLoggingViewController *weakSelf = self;
    
    MenuItem *startLoggingItem = [MenuItem itemForButtonWithTitle:@"Start" selectionBlock:^(MenuItem *item) {
        [weakSelf startLogging];
    }];
    
    MenuItem *pauseLoggingItem = [MenuItem itemForButtonWithTitle:@"Pause" selectionBlock:^(MenuItem *item) {
        [weakSelf pauseLogging];
    }];
    
    MenuItem *resumeLoggingItem = [MenuItem itemForButtonWithTitle:@"Resume" selectionBlock:^(MenuItem *item) {
        [weakSelf resumeLogging];
    }];
    
    MenuItem *stopLoggingItem = [MenuItem itemForButtonWithTitle:@"Stop" selectionBlock:^(MenuItem *item) {
        [weakSelf stopLogging];
    }];
    
    MenuSection *loggingActionsSection = [MenuSection sectionWithTitle:@"Actions" items:@[startLoggingItem, pauseLoggingItem, resumeLoggingItem, stopLoggingItem]];
    
    return loggingActionsSection;
}

@end
