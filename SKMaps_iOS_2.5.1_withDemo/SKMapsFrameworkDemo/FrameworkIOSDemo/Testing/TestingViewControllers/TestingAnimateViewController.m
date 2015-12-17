//
//  TestingAnimateViewController.m
//  FrameworkIOSDemo
//
//  Created by Cristian Chertes on 28/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingAnimateViewController.h"

@interface TestingAnimateViewController ()

@property (nonatomic,assign) float                  zoomLevel;
@property (nonatomic,assign) float                  bearing;
@property (nonatomic,assign) float                  duration;
@property (nonatomic,assign) float                  locationLatitude;
@property (nonatomic,assign) float                  locationLongitude;

@end

@implementation TestingAnimateViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureMenuView];
}

#pragma mark - Private methods

- (void)configureMenuView {
    MenuSection *animateToZoomLevelSection = [self animateToZoomLevelSection];
    MenuSection *animateToBearingSection = [self animateToBearingSection];
    MenuSection *animateToLocationSection = [self animateToLocationSection];
    
    self.menuView.sections = @[animateToZoomLevelSection,animateToBearingSection,animateToLocationSection];
}

- (void)animateToZoomLevel {
    __weak TestingAnimateViewController *weakSelf = self;

    [weakSelf.mapView animateToZoomLevel:weakSelf.zoomLevel];
}

- (void)animateToBearing {
    __weak TestingAnimateViewController *weakSelf = self;
    
    [weakSelf.mapView animateToBearing:weakSelf.bearing];
}

- (void)animateToLocation {
    __weak TestingAnimateViewController *weakSelf = self;
    
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(weakSelf.locationLatitude, weakSelf.locationLongitude);
    [weakSelf.mapView animateToLocation:loc withDuration:weakSelf.duration];
}

- (MenuSection *)animateToZoomLevelSection {
    __weak TestingAnimateViewController *weakSelf = self;
    
    MenuItem *zoomItem = [MenuItem itemForTextWithTitle:@"Zoom Level" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.zoomLevel = item.floatValue;
    } editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {
        
    }];
    zoomItem.floatValue = 14.0;
    
    MenuItem *animateItem = [MenuItem itemForButtonWithTitle:@"Animate" selectionBlock:^(MenuItem *item) {
        [weakSelf animateToZoomLevel];
    }];
    
    MenuSection *optionsSection = [MenuSection sectionWithTitle:@"Animate To Zoom Level" items:@[zoomItem,animateItem]];
    
    return optionsSection;
}

- (MenuSection *)animateToBearingSection {
    __weak TestingAnimateViewController *weakSelf = self;
    
    MenuItem *bearingItem = [MenuItem itemForTextWithTitle:@"Bearing" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.bearing = item.floatValue;
    } editEndBlock:nil];
    bearingItem.floatValue = 0.0;
    
    MenuItem *animateItem = [MenuItem itemForButtonWithTitle:@"Animate" selectionBlock:^(MenuItem *item) {
        [weakSelf animateToBearing];
    }];
    
    MenuSection *optionsSection = [MenuSection sectionWithTitle:@"Animate To Bearing" items:@[bearingItem,animateItem]];
    
    return optionsSection;
}

- (MenuSection *)animateToLocationSection {
    __weak TestingAnimateViewController *weakSelf = self;
    
    MenuItem *latitudeItem = [MenuItem itemForTextWithTitle:@"Latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.locationLatitude = item.floatValue;
    } editEndBlock:nil];
    latitudeItem.floatValue = 52.5233;
    
    MenuItem *longitudeItem = [MenuItem itemForTextWithTitle:@"Longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.locationLongitude = item.floatValue;
    } editEndBlock:nil];
    longitudeItem.floatValue = 13.4127;
    
    MenuItem *durationItem = [MenuItem itemForTextWithTitle:@"Duration" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.duration = item.floatValue;
    } editEndBlock:nil];
    durationItem.floatValue = 1.0;
    
    MenuItem *animateItem = [MenuItem itemForButtonWithTitle:@"Animate" selectionBlock:^(MenuItem *item) {
        [weakSelf animateToLocation];
    }];
    
    MenuSection *optionsSection = [MenuSection sectionWithTitle:@"Animate To Location" items:@[latitudeItem,longitudeItem,durationItem,animateItem]];
    
    return optionsSection;
}

@end
