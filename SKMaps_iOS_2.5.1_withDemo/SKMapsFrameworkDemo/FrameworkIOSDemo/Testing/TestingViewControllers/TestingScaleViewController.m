//
//  TestingScaleViewController.m
//  FrameworkIOSDemo
//
//  Created by Cristian Chertes on 29/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingScaleViewController.h"

@interface TestingScaleViewController ()

@end

@implementation TestingScaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureMenuView];
}

#pragma mark - Private methods

- (void)configureMenuView {
    MenuSection *scaleViewSection = [self scaleViewSection];
    
    self.menuView.sections = @[scaleViewSection];
}

- (MenuSection *)scaleViewSection {
    __weak TestingScaleViewController *weakSelf = self;
    
    NSArray *optionsArray = @[@(SKDistanceFormatMetric), @(SKDistanceFormatMilesFeet), @(SKDistanceFormatMilesYards)];
    NSArray *optionsStrings = @[@"Metric", @"MilesFeet", @"MilesYards"];
    MenuItem *distanceFormatItem = [MenuItem itemForOptionsWithTitle:@"Distance Format" uniqueID:nil options:optionsArray readableOptions:optionsStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.mapScaleView.distanceFormat = (SKDistanceFormat)item.intValue;
    }];
    distanceFormatItem.defaultValue = @(SKDistanceFormatMetric);
    
    MenuItem *nightStyleItem = [MenuItem itemForToggleWithTitle:@"Night Style" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.mapScaleView.nightStyle = (BOOL)item.boolValue;
    }];
    
    MenuSection *section = [MenuSection sectionWithTitle:@"Scale View Settings" items:@[distanceFormatItem, nightStyleItem]];
    
    return section;
}

@end
