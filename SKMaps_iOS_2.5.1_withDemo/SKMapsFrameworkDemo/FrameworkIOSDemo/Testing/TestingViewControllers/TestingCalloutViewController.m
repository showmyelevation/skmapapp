//
//  TestingCalloutViewController.m
//  FrameworkIOSDemo
//
//  Created by Cristian Chertes on 29/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingCalloutViewController.h"

@interface TestingCalloutViewController () <SKCalloutViewDelegate>

@property (nonatomic,assign) CGFloat    locationLatitude;
@property (nonatomic,assign) CGFloat    locationLongitude;
@property (nonatomic,assign) CGFloat    minimumZoomLevel;
@property (nonatomic,assign) CGFloat    offsetX;
@property (nonatomic,assign) CGFloat    offsetY;
@property (nonatomic,assign) BOOL       dynamicArrowPositioning;
@property (nonatomic,assign) BOOL       animated;
@property (nonatomic,assign) BOOL       showCustomCallout;
@property (nonatomic,strong) NSString   *titleText;
@property (nonatomic,strong) NSString   *subtitleText;

@property (nonatomic,strong) UIView     *customView;
@property (nonatomic,strong) UILabel    *tapLabel;

@end

@implementation TestingCalloutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.showCustomCallout = NO;
    
    [self configureCustomCalloutView];
    [self configureMenuView];
    [self addTapLabel];
}

#pragma mark - Actions

- (void)showCallout {
    __weak TestingCalloutViewController *weakSelf = self;
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(weakSelf.locationLatitude, weakSelf.locationLongitude);
    
    SKCoordinateRegion region;
    region.center.latitude = location.latitude;
    region.center.longitude = location.longitude;
    region.zoomLevel = 14.0;
    weakSelf.mapView.visibleRegion = region;
    
    CGPoint offset = CGPointMake(weakSelf.offsetX, weakSelf.offsetY);
    weakSelf.mapView.calloutView.dynamicArrowPositioning = weakSelf.dynamicArrowPositioning;
    weakSelf.mapView.calloutView.minZoomLevel = weakSelf.minimumZoomLevel;
    weakSelf.mapView.calloutView.titleLabel.text = weakSelf.titleText;
    weakSelf.mapView.calloutView.subtitleLabel.text = weakSelf.subtitleText;
    weakSelf.mapView.calloutView.delegate = self;
    
    [weakSelf.mapView showCalloutAtLocation:location withOffset:offset animated:weakSelf.animated];
}

- (void)hideCallout {
    __weak TestingCalloutViewController *weakSelf = self;
    
    [weakSelf.mapView hideCallout];
}

#pragma mark - Private methods

- (void)hideTapLabel {
    self.tapLabel.hidden = YES;
}

- (void)addTapLabel {
    self.tapLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 20.0)];
    self.tapLabel.backgroundColor = [UIColor clearColor];
    self.tapLabel.center = self.view.center;
    self.tapLabel.text = @"Annotation Tapped";
    self.tapLabel.textAlignment = NSTextAlignmentCenter;
    self.tapLabel.backgroundColor = [UIColor whiteColor];
    self.tapLabel.hidden = YES;
    self.tapLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:self.tapLabel];
}

- (void)configureCustomCalloutView {
    self.customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 50.0)];
    self.customView.backgroundColor = [UIColor greenColor];
    self.customView.alpha = 0.5;
}

- (void)configureMenuView {
    MenuSection *settingsSection = [self settingsSection];
    MenuSection *actionsSection = [self actionsSection];
    
    self.menuView.sections = @[settingsSection, actionsSection];
}

- (MenuSection *)settingsSection {
    __weak TestingCalloutViewController *weakSelf = self;
    
    MenuItem *calloutViewLatitudeItem= [MenuItem itemForTextWithTitle:@"Latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.locationLatitude = item.floatValue;
    } editEndBlock:nil];
    calloutViewLatitudeItem.defaultValue = @(52.5233);
    
    MenuItem *calloutViewLongitudeItem = [MenuItem itemForTextWithTitle:@"Longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.locationLongitude = item.floatValue;
    } editEndBlock:nil];
    calloutViewLongitudeItem.defaultValue = @(13.4127);
    
    MenuItem *offsetXItem = [MenuItem itemForTextWithTitle:@"Offset X" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.offsetX = item.floatValue;
    } editEndBlock:nil];
    offsetXItem.defaultValue = @(0.0);
    
    MenuItem *offsetYItem = [MenuItem itemForTextWithTitle:@"Offset Y" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.offsetY = item.floatValue;
    } editEndBlock:nil];
    offsetYItem.defaultValue = @(0.0);
    
    MenuItem *calloutMinZoomLevelItem = [MenuItem itemForTextWithTitle:@"Minimum Zoom Level" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.minimumZoomLevel = item.floatValue;
    } editEndBlock:nil];
    calloutMinZoomLevelItem.defaultValue = @(7.0);
    
    MenuItem *dynamicArrowPositioningItem = [MenuItem itemForToggleWithTitle:@"Dynamic Arrow Positioning" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.dynamicArrowPositioning = (BOOL)item.boolValue;
    }];
    dynamicArrowPositioningItem.defaultValue = @(0);
    
    MenuItem *animatedItem = [MenuItem itemForToggleWithTitle:@"Animated" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.animated = (BOOL)item.boolValue;
    }];
    animatedItem.defaultValue = @(0);
    
    MenuItem *titleTextItem = [MenuItem itemForTextWithTitle:@"Title Text" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.titleText = (NSString *)item.stringValue;
    } editEndBlock:nil];
    titleTextItem.defaultValue = @"";
    
    MenuItem *subtitleTextItem = [MenuItem itemForTextWithTitle:@"Subtitle Text" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.subtitleText = (NSString *)item.stringValue;
    } editEndBlock:nil];
    subtitleTextItem.defaultValue = @"";
    
    MenuSection *settingsSection = [MenuSection sectionWithTitle:@"Settings" items:@[calloutViewLatitudeItem, calloutViewLongitudeItem, offsetXItem, offsetYItem, calloutMinZoomLevelItem, dynamicArrowPositioningItem, titleTextItem, subtitleTextItem]];
    
    return settingsSection;
}

- (MenuSection *)actionsSection {
    __weak TestingCalloutViewController *weakSelf = self;
    
    MenuItem *showItem = [MenuItem itemForButtonWithTitle:@"Show Callout" selectionBlock:^(MenuItem *item) {
        weakSelf.showCustomCallout = NO;
        
        [weakSelf showCallout];
    }];
    
    MenuItem *hideItem = [MenuItem itemForButtonWithTitle:@"Hide Callout" selectionBlock:^(MenuItem *item) {
        [weakSelf hideCallout];
    }];
    
    MenuItem *showCustomItem = [MenuItem itemForButtonWithTitle:@"Show Custom Callout" selectionBlock:^(MenuItem *item) {
        weakSelf.showCustomCallout = YES;
        
        [weakSelf showCallout];
    }];
    
    MenuSection *actionsSection = [MenuSection sectionWithTitle:@"Actions" items:@[showItem, hideItem, showCustomItem]];
    
    return actionsSection;
}

#pragma mark - SKCalloutViewDelegate methods

- (void)calloutView:(SKCalloutView *)calloutView didTapLeftButton:(UIButton *)leftButton {
    self.tapLabel.hidden = NO;
    self.tapLabel.text = @"Left Button tapped";
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideTapLabel) withObject:nil afterDelay:3.0];
}

- (void)calloutView:(SKCalloutView *)calloutView didTapRightButton:(UIButton *)rightButton {
    self.tapLabel.hidden = NO;
    self.tapLabel.text = @"Right Button tapped";
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideTapLabel) withObject:nil afterDelay:3.0];
}

#pragma mark - SKMapViewDelegate methods

- (UIView *)mapView:(SKMapView *)mapView calloutViewForLocation:(CLLocationCoordinate2D)location {
    if (self.showCustomCallout) {
        return self.customView;
    }
    
    return nil;
}

@end
