//
//  TestingAnnotationsViewController.m
//  FrameworkIOSDemo
//
//  Created by BogdanB on 22/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingAnnotationsViewController.h"
#import <SKMaps/SKDefinitions.h>
#import "UIView+Additions.h"

@interface TestingAnnotationsViewController ()

@property (nonatomic,strong) SKAnnotation       *annotation;
@property (nonatomic,assign) NSInteger          annotationRemoveIdentifier;
@property (nonatomic,assign) NSInteger          customPOIRemoveIdentifier;
@property (nonatomic,strong) NSArray            *customPOIViews;
@property (nonatomic,strong) UIView             *customPOIView;
@property (nonatomic,assign) NSInteger          customViewSelectedIndex;
@property (nonatomic,strong) UIView             *centerView;
@property (nonatomic,strong) UILabel            *tapLabel;

//Annotation Settings
@property (nonatomic,assign) NSInteger          annotationIdentifier;
@property (nonatomic,assign) SKAnnotationType   annotationType;
@property (nonatomic,assign) CGFloat            annotationOffsetX;
@property (nonatomic,assign) CGFloat            annotationOffsetY;
@property (nonatomic,assign) CGFloat            annotationLatitude;
@property (nonatomic,assign) CGFloat            annotationLongitude;
@property (nonatomic,assign) CGFloat            annotationMinZoomLevel;
@property (nonatomic,assign) CGFloat            annotationMinTapZoomLevel;
@property (nonatomic,strong) UIView             *annotationView;

//Animation Settings
@property (nonatomic,assign) SKAnimationType            animationType;
@property (nonatomic,assign) SKAnimationEasingType      animationEasingType;
@property (nonatomic,assign) CGFloat                    animationDuration;

//Custom POI
@property (nonatomic,assign) NSInteger          customPOIIdentifier;
@property (nonatomic,assign) SKPOIType          customPOIType;
@property (nonatomic,assign) SKPOICategory      customPOICategory;
@property (nonatomic,assign) CGFloat            customPOILatitude;
@property (nonatomic,assign) CGFloat            customPOILongitude;
@property (nonatomic,assign) CGFloat            customPOIMinZoomLevel;

@end

@implementation TestingAnnotationsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setMapViewDelegate];
    [self addTapLabel];
    [self addCenterView];
    [self addCustomPOIViews];
    [self configureMenuView];
}

#pragma mark - Actions

- (void)hideTapLabel {
    self.tapLabel.hidden = YES;
}

- (void)addAnnotationAtCenter:(BOOL)atCenter {
    __weak TestingAnnotationsViewController *weakSelf = self;
    
    SKAnnotation *annotation = [weakSelf getAnnotation];
    
    if (atCenter) {
        annotation.location = weakSelf.mapView.visibleRegion.center;
    }
    
    SKAnimationSettings *animationSettings = [SKAnimationSettings animationSettings];
    animationSettings.animationType = weakSelf.animationType;
    animationSettings.animationEasingType = weakSelf.animationEasingType;
    animationSettings.duration = weakSelf.animationDuration;
    weakSelf.annotation = annotation;
    
    [weakSelf.mapView addAnnotation:annotation withAnimationSettings:animationSettings];
    
    SKCoordinateRegion region;
    region.center.latitude = annotation.location.latitude;
    region.center.longitude = annotation.location.longitude;
    region.zoomLevel = 14.0;
    weakSelf.mapView.visibleRegion = region;
}

- (SKAnnotation *)getAnnotation {
    __weak TestingAnnotationsViewController *weakSelf = self;
    
    SKAnnotation *annotation = [SKAnnotation annotation];
    annotation.annotationType = weakSelf.annotationType;
    
    if (annotation.annotationType == 0) {
        annotation.annotationType = SKAnnotationTypePurple;
    }
    annotation.identifier = weakSelf.annotationIdentifier;
    
    CGPoint offset = CGPointMake(weakSelf.annotationOffsetX, weakSelf.annotationOffsetY);
    annotation.offset = offset;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(weakSelf.annotationLatitude, weakSelf.annotationLongitude);
    annotation.location = coordinate;
    
    annotation.minZoomLevel = weakSelf.annotationMinZoomLevel;
    
    if (weakSelf.customViewSelectedIndex > 0) {
        SKAnnotationView *annotationView = [[SKAnnotationView alloc] initWithView:weakSelf.customPOIViews[weakSelf.customViewSelectedIndex - 1] reuseIdentifier:[NSString stringWithFormat:@"%d",weakSelf.customViewSelectedIndex]];
        annotation.annotationView = annotationView;
    } else {
        annotation.annotationView = nil;
    }
    
    return annotation;
}

- (void)bringAnnotationToFront {
    __weak TestingAnnotationsViewController *weakSelf = self;
    
    [weakSelf.mapView bringToFrontAnnotation:weakSelf.annotation];
}

- (void)updateAnnotation {
    __weak TestingAnnotationsViewController *weakSelf = self;
    SKAnnotation *annotation = [weakSelf getAnnotation];
    
    [weakSelf.mapView updateAnnotation:annotation];
}

- (void)removeAnnotation {
    __weak TestingAnnotationsViewController *weakSelf = self;
    
    [weakSelf.mapView removeAnnotationWithID:weakSelf.annotationRemoveIdentifier];
}

- (void)clearAllAnnotations {
    __weak TestingAnnotationsViewController *weakSelf = self;
    
    [weakSelf.mapView clearAllAnnotations];
}

- (void)addCustomPOIToCenter:(BOOL)toCenter {
    __weak TestingAnnotationsViewController *weakSelf = self;
    
    SKMapCustomPOI *customPOI = [SKMapCustomPOI mapCustomPOI];
    customPOI.identifier = weakSelf.customPOIIdentifier;
    CLLocationCoordinate2D customPOILocation = toCenter ? CLLocationCoordinate2DMake(weakSelf.mapView.visibleRegion.center.latitude, weakSelf.mapView.visibleRegion.center.longitude) : CLLocationCoordinate2DMake(weakSelf.customPOILatitude, weakSelf.customPOILongitude);
    customPOI.coordinate = customPOILocation;
    customPOI.type = weakSelf.customPOIType;
    customPOI.categoryID = weakSelf.customPOICategory;
    customPOI.minZoomLevel = weakSelf.customPOIMinZoomLevel;
    
    [weakSelf.mapView addCustomPOI:customPOI];
    
    SKCoordinateRegion region;
    region.center.latitude = customPOI.coordinate.latitude;
    region.center.longitude = customPOI.coordinate.longitude;
    region.zoomLevel = 14.0;
    weakSelf.mapView.visibleRegion = region;
}

- (void)removeCustomPOI {
    __weak TestingAnnotationsViewController *weakSelf = self;
    
    [weakSelf.mapView removeAnnotationWithID:weakSelf.customPOIRemoveIdentifier];
}

#pragma mark - Private method

- (void)setMapViewDelegate {
    self.mapView.delegate = self;
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

- (void)addCenterView {
    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 5.0, 5.0)];
    self.centerView.centerX = self.mapView.frameWidth / 2.0;
    self.centerView.centerY = self.mapView.frameHeight / 2.0;
    self.centerView.backgroundColor = [UIColor redColor];
    self.centerView.alpha = 0.5;
    self.centerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.mapView addSubview:self.centerView];
}

- (void)addCustomPOIViews {
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture"]];
    imageView1.centerX = view1.frameWidth / 2.0;
    imageView1.centerY = view1.frameHeight / 2.0;
    [view1 addSubview:imageView1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_arrow"]];
    imageView2.centerX = view2.frameWidth / 2.0;
    imageView2.centerY = view2.frameHeight / 2.0;
    [view2 addSubview:imageView2];
    
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"customImage"]];
    imageView3.centerX = view3.frameWidth / 2.0;
    imageView3.centerY = view3.frameHeight / 2.0;
    [view3 addSubview:imageView3];
    
    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    UIImageView *imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redPin"]];
    imageView4.centerX = view4.frameWidth / 2.0;
    imageView4.centerY = view4.frameHeight / 2.0;
    [view4 addSubview:imageView4];
    
    self.customPOIViews = @[view1,view2,view3,view4];
}

- (void)configureMenuView {
    MenuSection *annotationSection = [self annotationSection];
    MenuSection *customPOISection = [self customPOISection];
    
    self.menuView.sections = @[annotationSection,customPOISection];
}

- (MenuSection *)annotationSection {
    MenuSection *settingsSection = [self menuSectionForSettings];
    MenuSection *animationSettingsSection = [self menuSectionForAnimationSettings];
    MenuSection *actionsSection = [self menuSectionForActions];
    
    MenuItem *annotationItem = [MenuItem itemForMenuTypeWithTitle:@"Annotation" sections:@[settingsSection,animationSettingsSection,actionsSection] selectionBlock:^(MenuItem *item) {
        //
    }];
    MenuSection *annotationSection = [MenuSection sectionWithTitle:@"Annotation" items:@[annotationItem]];
    
    return annotationSection;
}

- (MenuSection *)customPOISection {
    MenuItem *menuItem = [self menuItemForCustomPOI];
    MenuSection *customPOISection = [MenuSection sectionWithTitle:@"Custom POI" items:@[menuItem]];
    
    return customPOISection;
}

- (MenuSection *)menuSectionForSettings {
    __weak TestingAnnotationsViewController *weakSelf = self;
    
    MenuItem *annotationIdentifier = [MenuItem itemForTextWithTitle:@"Identifier" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.annotationIdentifier = item.intValue;
    } editEndBlock:nil];
    annotationIdentifier.defaultValue = @(0);
    
    NSArray *annotationTypes = @[@(SKAnnotationTypePurple),@(SKAnnotationTypeBlue),@(SKAnnotationTypeGreen),@(SKAnnotationTypeRed),@(SKAnnotationTypeDestinationFlag),@(SKAnnotationTypeMarker)];
    NSArray *annotationTypesStrings = @[@"Purple", @"Blue", @"Green", @"Red", @"Destination Flag", @"Marker"];
    MenuItem *annotationType = [MenuItem itemForOptionsWithTitle:@"Annotation Type" uniqueID:nil options:annotationTypes readableOptions:annotationTypesStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.annotationType = (SKAnnotationType)item.longValue;
    }];
    annotationType.defaultValue = @(SKAnnotationTypePurple);
    
    MenuItem *annotationOffsetX = [MenuItem itemForTextWithTitle:@"Offset X" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.annotationOffsetX = [(NSNumber*)newValue floatValue];
    } editEndBlock:nil];
    annotationOffsetX.defaultValue = @(0.0);
    
    MenuItem *annotationOffsetY = [MenuItem itemForTextWithTitle:@"Offset Y" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.annotationOffsetY = [(NSNumber*)newValue floatValue];
    } editEndBlock:nil];
    annotationOffsetY.defaultValue = @(0.0);
    
    MenuItem *annotationLatitude = [MenuItem itemForTextWithTitle:@"Latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.annotationLatitude = [(NSNumber*)newValue floatValue];
    } editEndBlock:nil];
    annotationLatitude.defaultValue = @(52.5233);
    
    MenuItem *annotationLongitude = [MenuItem itemForTextWithTitle:@"Longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.annotationLongitude = [(NSNumber*)newValue floatValue];
    } editEndBlock:nil];
    annotationLongitude.defaultValue = @(13.4127);
    
    MenuItem *annotationMinZoomLevel = [MenuItem itemForTextWithTitle:@"Minimum ZoomLevel" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.annotationMinZoomLevel = [(NSNumber*)newValue floatValue];
    } editEndBlock:nil];
    annotationMinZoomLevel.defaultValue = @(10.0);
    
    MenuItem *annotationTapMinZoomLevel = [MenuItem itemForTextWithTitle:@"Minimum Tap ZoomLevel" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.annotationMinTapZoomLevel = [(NSNumber*)newValue floatValue];
        weakSelf.mapView.settings.annotationTapZoomLimit = weakSelf.annotationMinTapZoomLevel;
    } editEndBlock:nil];
    annotationTapMinZoomLevel.defaultValue = @(7.0);
    
    NSArray *annotationViews = @[@(0),@(1),@(2),@(3),@(4)];
    NSArray *annotationViewsStrings = @[@"None",@"Logo",@"Navigate",@"Bug",@"Red Pin"];
    MenuItem *annotationView = [MenuItem itemForOptionsWithTitle:@"Annotation View" uniqueID:nil options:annotationViews readableOptions:annotationViewsStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.customViewSelectedIndex = item.intValue;
    }];
    annotationView.defaultValue = @(0);
    
    MenuSection *settingsSection = [MenuSection sectionWithTitle:@"Settings" items:@[annotationIdentifier,annotationType,annotationOffsetX,annotationOffsetY,annotationLatitude,annotationLongitude,annotationMinZoomLevel,annotationTapMinZoomLevel,annotationView]];
    
    return settingsSection;
}

- (MenuSection *)menuSectionForAnimationSettings {
    __weak TestingAnnotationsViewController *weakSelf = self;
    
    NSArray *animationTypes = @[@(SKAnimationNone),@(SKAnimationPinDrop),@(SKAnimationPopOut),@(SKPulseAnimation)];
    NSArray *animationTypesStrings = @[@"None", @"Pin Drop", @"Pop Out", @"Pulse"];
    
    MenuItem *animationType = [MenuItem itemForOptionsWithTitle:@"Animation Type" uniqueID:nil options:animationTypes readableOptions:animationTypesStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.animationType = (SKAnimationType)item.ulongValue;
    }];
    animationType.defaultValue = @(SKAnimationNone);
    
    NSArray *animationEasingTypes = @[@(SKAnimationEaseLinear),@(SKAnimationEaseInQuad),@(SKAnimationEaseOutQuad),@(SKAnimationEaseInOutQuad),@(SKAnimationEaseInCubic),@(SKAnimationEaseOutCubic),@(SKAnimationEaseInOutCubic),@(SKAnimationEaseInQuart),@(SKAnimationEaseOutQuart),@(SKAnimationEaseInOutQuart),@(SKAnimationEaseInQuint),@(SKAnimationEaseOutQuint),@(SKAnimationEaseInOutQuint),@(SKAnimationEaseInSine),@(SKAnimationEaseOutSine),@(SKAnimationEaseInOutSine),@(SKAnimationEaseInExpo),@(SKAnimationEaseOutExpo),@(SKAnimationnEaseInOutExpo)];
    NSArray *animationEasingTypesStrings = @[@"SKAnimationEaseLinear",@"SKAnimationEaseInQuad",@"SKAnimationEaseOutQuad",@"SKAnimationEaseInOutQuad",@"SKAnimationEaseInCubic",@"SKAnimationEaseOutCubic",@"SKAnimationEaseInOutCubic",@"SKAnimationEaseInQuart",@"SKAnimationEaseOutQuart",@"SKAnimationEaseInOutQuart",@"SKAnimationEaseInQuint",@"SKAnimationEaseOutQuint",@"SKAnimationEaseInOutQuint",@"SKAnimationEaseInSine",@"SKAnimationEaseOutSine",@"SKAnimationEaseInOutSine",@"SKAnimationEaseInExpo",@"SKAnimationEaseOutExpo",@"SKAnimationnEaseInOutExpo"];
    
    MenuItem *animationEasingType = [MenuItem itemForOptionsWithTitle:@"Animation Easing Type" uniqueID:nil options:animationEasingTypes readableOptions:animationEasingTypesStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.animationEasingType = (SKAnimationEasingType)item.longValue;
    }];
    animationEasingType.defaultValue = @(SKAnimationEaseLinear);
    
    MenuItem *animationDuration = [MenuItem itemForSliderWithTitle:@"Animation Duration" uniqueID:@"11" minValue:0.0 maxValue:5000.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.animationDuration = [(NSNumber*)newValue floatValue];
    }];
    animationDuration.defaultValue = @(1.0);
    
    MenuSection *animationSettingsSection = [MenuSection sectionWithTitle:@"Animation Settings" items:@[animationType,animationEasingType,animationDuration]];
    
    return animationSettingsSection;
}

- (MenuSection *)menuSectionForActions {
    __weak TestingAnnotationsViewController *weakSelf = self;
    
    MenuItem *addItem = [MenuItem itemForButtonWithTitle:@"Add" selectionBlock:^(MenuItem *item) {
        [weakSelf addAnnotationAtCenter:NO];
    }];
    
    MenuItem *addToCenterItem = [MenuItem itemForButtonWithTitle:@"Add to center" selectionBlock:^(MenuItem *item) {
        [weakSelf addAnnotationAtCenter:YES];
    }];
    
    MenuItem *bringToFrontItem = [MenuItem itemForButtonWithTitle:@"Bring to front" selectionBlock:^(MenuItem *item) {
        [weakSelf bringAnnotationToFront];
    }];
    
    MenuItem *updateItem = [MenuItem itemForButtonWithTitle:@"Update" selectionBlock:^(MenuItem *item) {
        [weakSelf updateAnnotation];
    }];
    
    MenuItem *removeIDItem = [MenuItem itemForTextWithTitle:@"Remove Identifier" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.annotationRemoveIdentifier = item.intValue;
    } editEndBlock:nil];
    removeIDItem.defaultValue = @(0);
    
    MenuItem *removeItem = [MenuItem itemForButtonWithTitle:@"Remove" selectionBlock:^(MenuItem *item) {
        [weakSelf removeAnnotation];
    }];
    
    MenuItem *clearAllItem = [MenuItem itemForButtonWithTitle:@"Clear All" selectionBlock:^(MenuItem *item) {
        [weakSelf clearAllAnnotations];
    }];
    
    MenuSection *actionsSection = [MenuSection sectionWithTitle:@"Actions" items:@[addItem, addToCenterItem, bringToFrontItem, updateItem, removeIDItem, removeItem, clearAllItem]];
    
    return actionsSection;
}

- (MenuItem *)menuItemForCustomPOI {
    __weak TestingAnnotationsViewController *weakSelf = self;
    
    MenuItem *customPOIIdentifier = [MenuItem itemForTextWithTitle:@"Identifier" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.customPOIIdentifier = item.intValue;
    } editEndBlock:nil];
    customPOIIdentifier.defaultValue = @(0);
    
    NSArray *customPOITypes = @[@(SKCategorySearch),@(SKLocalSearch)];
    NSArray *customPOITypesStrings = @[@"Category", @"Local"];
    MenuItem *customPOIType = [MenuItem itemForOptionsWithTitle:@"CustomPOI Type" uniqueID:nil options:customPOITypes readableOptions:customPOITypesStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.customPOIType = (SKAnnotationType)item.longValue;
    }];
    customPOIType.value = @(SKCategorySearch);
    
    NSArray *customPOICategories = @[@(SKPOICategoryAirport),@(SKPOICategoryInformation),@(SKPOICategoryCinema),@(SKPOICategoryFood),@(SKPOICategoryPharmacy),@(SKPOICategoryTaxi)];
    NSArray *customPOICategoriesStrings = @[@"Airport", @"Informatio", @"Cinema", @"Food", @"Pharmacy", @"Taxi"];
    MenuItem *customPOICategory = [MenuItem itemForOptionsWithTitle:@"CustomPOI Category" uniqueID:nil options:customPOICategories readableOptions:customPOICategoriesStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.customPOICategory = (SKPOICategory)item.longValue;
    }];
    customPOICategory.value = @(SKPOICategoryAirport);
    
    MenuItem *customPOILatitude = [MenuItem itemForTextWithTitle:@"Latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.customPOILatitude = [(NSNumber*)newValue floatValue];
    } editEndBlock:nil];
    customPOILatitude.floatValue = 52.5233;
    
    MenuItem *customPOILongitude = [MenuItem itemForTextWithTitle:@"Longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.customPOILongitude = [(NSNumber*)newValue floatValue];
    } editEndBlock:nil];
    customPOILongitude.floatValue = 13.4127;
    
    MenuItem *customPOIMinZoomLevel = [MenuItem itemForTextWithTitle:@"Minimum Zoom Level" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.customPOIMinZoomLevel = [(NSNumber*)newValue floatValue];
    } editEndBlock:nil];
    customPOIMinZoomLevel.floatValue = 7.0;
    
    MenuSection *settingsSection = [MenuSection sectionWithTitle:@"Settings" items:@[customPOIIdentifier,customPOILatitude,customPOILongitude,customPOIType,customPOICategory,customPOIMinZoomLevel]];
    
    MenuItem *addItem = [MenuItem itemForButtonWithTitle:@"Add" selectionBlock:^(MenuItem *item) {
        [weakSelf addCustomPOIToCenter:NO];
    }];
    
    MenuItem *addToCenterItem = [MenuItem itemForButtonWithTitle:@"Add to center" selectionBlock:^(MenuItem *item) {
        [weakSelf addCustomPOIToCenter:YES];
    }];
    
    MenuItem *removeIDItem = [MenuItem itemForTextWithTitle:@"Remove Identifier" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.customPOIRemoveIdentifier = item.intValue;
    } editEndBlock:nil];
    removeIDItem.defaultValue = @(0);
    
    MenuItem *removeItem = [MenuItem itemForButtonWithTitle:@"Remove" selectionBlock:^(MenuItem *item) {
        [weakSelf removeCustomPOI];
    }];
    
    MenuSection *actionsSection = [MenuSection sectionWithTitle:@"Actions" items:@[addItem, addToCenterItem, removeIDItem, removeItem]];
    
    MenuItem *customPOIItem = [MenuItem itemForMenuTypeWithTitle:@"Custom POI" sections:@[settingsSection,actionsSection] selectionBlock:nil];
    
    return customPOIItem;
}

#pragma mark - SKMapViewDelegate methods 

- (void)mapView:(SKMapView *)mapView didSelectAnnotation:(SKAnnotation *)annotation {
    self.tapLabel.hidden = NO;
    
    [self performSelector:@selector(hideTapLabel) withObject:nil afterDelay:3.0];
}

@end
