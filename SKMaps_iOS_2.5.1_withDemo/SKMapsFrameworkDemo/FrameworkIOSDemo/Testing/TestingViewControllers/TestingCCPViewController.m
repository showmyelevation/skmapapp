//
//  TestingCCPAnimation.m
//  FrameworkIOSDemo
//
//  Created by Csongor Korosi on 24/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingCCPViewController.h"
#import <SKMaps/SKMaps.h>

@interface TestingCCPViewController()<SKPositionerServiceDelegate>
@property(nonatomic) SKCurrentPositionAnimationSettings *currentPositionAnimationSettings;

@end

@implementation TestingCCPViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPositionAnimationSettings = [SKCurrentPositionAnimationSettings currentPositionAnimationSettings];
    
    [SKPositionerService sharedInstance].delegate = self;
    
    self.mapView.settings.showCurrentPosition = YES;
    [self.mapView centerOnCurrentPosition];
    [self.mapView startCurrentPositionAnnimationWithSettings:self.currentPositionAnimationSettings];
    
    [self.mapView hideCallout];
    
    [self configureMenuView];
}

#pragma mark - Private methods

- (void)configureMenuView {
    MenuSection *settingsSection = [self menuSectionForAnimationSettings];
    MenuSection *operationsSection = [self menuSectionForOperations];
    
    self.menuView.sections = @[settingsSection, operationsSection];
}

- (MenuSection *)menuSectionForAnimationSettings {
    __weak TestingCCPViewController *weakSelf = self;
    
    MenuItem *colorItem = [MenuItem itemForColorWithTitle:@"Animation color" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.currentPositionAnimationSettings.color = item.colorValue;
        
        [weakSelf.mapView startCurrentPositionAnnimationWithSettings:self.currentPositionAnimationSettings];
    }];
    colorItem.colorValue = self.currentPositionAnimationSettings.color;
    
    MenuItem *continuousAnimationItem = [MenuItem itemForToggleWithTitle:@"Continuos" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.currentPositionAnimationSettings.continuous = item.boolValue;
        
        [weakSelf.mapView startCurrentPositionAnnimationWithSettings:self.currentPositionAnimationSettings];
    }];
    continuousAnimationItem.boolValue = self.currentPositionAnimationSettings.continuous;
    
    MenuItem *spanItem = [MenuItem itemForSliderWithTitle:@"Span" uniqueID:nil minValue:0.0f maxValue:10.0f changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
         weakSelf.currentPositionAnimationSettings.span = item.floatValue;
        
        [weakSelf.mapView startCurrentPositionAnnimationWithSettings:self.currentPositionAnimationSettings];
    }];
    spanItem.defaultValue = @(self.currentPositionAnimationSettings.span);
    
    MenuItem *fadeOutTimeItem = [MenuItem itemForSliderWithTitle:@"Fade out time (ms)" uniqueID:nil minValue:0.0f maxValue:5000.0f changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.currentPositionAnimationSettings.fadeOutTime = item.intValue;
        
        [weakSelf.mapView startCurrentPositionAnnimationWithSettings:self.currentPositionAnimationSettings];
    }];
    fadeOutTimeItem.defaultValue = @(self.currentPositionAnimationSettings.fadeOutTime);
    
    MenuItem *durationTimeItem = [MenuItem itemForSliderWithTitle:@"Duration (ms)" uniqueID:nil minValue:0.0f maxValue:5000.0f changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.currentPositionAnimationSettings.duration = item.intValue;
        
        [weakSelf.mapView startCurrentPositionAnnimationWithSettings:self.currentPositionAnimationSettings];
    }];
    durationTimeItem.defaultValue = @(self.currentPositionAnimationSettings.duration);
    
    MenuItem *currentPositionViewItem = [MenuItem itemForToggleWithTitle:@"Custom view" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        if (item.boolValue) {
            UIImageView *coloredView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
            coloredView.backgroundColor = [UIColor redColor];
            coloredView.image = [UIImage imageNamed:@"picture"];
            coloredView.contentMode = UIViewContentModeTop;
            coloredView.layer.cornerRadius = 10.0;

            weakSelf.mapView.currentPositionView = coloredView;
        } else {
            weakSelf.mapView.currentPositionView = nil;
        }
    }];
    
    MenuSection *settingsSection = [MenuSection sectionWithTitle:@"AnimationSettings" items:@[colorItem, continuousAnimationItem, spanItem, fadeOutTimeItem, durationTimeItem, currentPositionViewItem]];
    
    return settingsSection;
}

- (MenuSection *)menuSectionForOperations {
    __weak TestingCCPViewController *weakSelf = self;
    
    MenuItem *stopAnimationItem = [MenuItem itemForButtonWithTitle:@"Stop animation" selectionBlock:^(MenuItem *item) {
        [weakSelf.mapView stopCurrentPositionAnnimation];
    }];
    
    MenuItem *startAnimationItem = [MenuItem itemForButtonWithTitle:@"Start animation" selectionBlock:^(MenuItem *item) {
        [weakSelf.mapView startCurrentPositionAnnimationWithSettings:self.currentPositionAnimationSettings];
    }];
    
    MenuSection *operationsSection = [MenuSection sectionWithTitle:@"Operations" items:@[stopAnimationItem, startAnimationItem]];
    
    return operationsSection;

}

@end
