//
//  TestingMapInstancesViewController.m
//  FrameworkIOSDemo
//
//  Created by BogdanB on 22/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingMapInstancesViewController.h"

@interface TestingMapInstancesViewController ()

@property (nonatomic,strong) UILabel            *tapLabel;

@end

#define menuID(x) ([NSString stringWithFormat:@"%@%d", x, self.instanceID])

@implementation TestingMapInstancesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addMenuItems];
    [self addAnnotation];
    [self addTapLabel];
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

- (void)hideTapLabel {
    self.tapLabel.hidden = YES;
}

- (void)addAnnotation {
    SKAnnotation *annotation = [SKAnnotation annotation];
    annotation.location = self.mapView.visibleRegion.center;
    annotation.minZoomLevel = 4.0;
    annotation.identifier = 100;
    
    [self.mapView addAnnotation:annotation withAnimationSettings:[SKAnimationSettings animationSettings]];
}

- (void)addOverlay {
    SKCircle *circle = [SKCircle circle];
    circle.identifier = 100;
    circle.centerCoordinate = self.mapView.visibleRegion.center;
    circle.radius = 100.0f;
    circle.fillColor = [UIColor redColor];
    circle.strokeColor = [UIColor blueColor];
    circle.isMask = NO;
    circle.borderWidth = 1.0;
    [self.mapView addCircle:circle];
}

- (void)showMapObjects {
    [self addOverlay];
}

- (void)hideMapObjects {
    [self.mapView removeAnnotationWithID:100];
    [self.mapView clearOverlayWithID:100];
}

- (void)addMenuItems {
    
    __weak TestingMapInstancesViewController *weakSelf = self;
    
    NSArray *headingOptions = @[@(SKHeadingModeNone), @(SKHeadingModeRoute), @(SKHeadingModeRotatingMap), @(SKHeadingModeRotatingHeading), @(SKHeadingModeHistoricPositions)];
    NSArray *headingText = @[@"None", @"Route", @"RotatingMap", @"RotatingHeading", @"HistoricPositions"];
    MenuItem *headingItem = [MenuItem itemForOptionsWithTitle:@"Heading mode" uniqueID:menuID(@"InstancesHeading") options:headingOptions readableOptions:headingText changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.headingMode = (SKHeadingMode)item.ulongValue;
    }];
    headingItem.value = @(SKHeadingModeNone);
    
    MenuItem *rotationItem = [MenuItem itemForToggleWithTitle:@"Rotation" uniqueID:menuID(@"InstancesRotation") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.rotationEnabled = item.boolValue;
    }];
    rotationItem.boolValue = YES;
    
    MenuItem *followPositionItem = [MenuItem itemForToggleWithTitle:@"Follow user position" uniqueID:menuID(@"InstancesFollowPosition") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.followUserPosition = item.boolValue;
    }];
    rotationItem.boolValue = NO;
    
    MenuItem *showUserPositionItem = [MenuItem itemForToggleWithTitle:@"Show current position" uniqueID:menuID(@"ShowUserPosition") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.showCurrentPosition = item.boolValue;
    }];
    showUserPositionItem.boolValue = YES;
    
    MenuItem *centerOnCurrentPosition = [MenuItem itemForButtonWithTitle:@"Center on current position" selectionBlock:^(MenuItem *item) {
        [weakSelf.mapView centerOnCurrentPosition];
    }];
    
    MenuItem *panningItem = [MenuItem itemForToggleWithTitle:@"Panning" uniqueID:menuID(@"InstancesPanning") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.panningEnabled = item.boolValue;
    }];
    panningItem.boolValue = YES;

    MenuItem *minZoomItem = [MenuItem itemForSliderWithTitle:@"Min zoom" uniqueID:menuID(@"InstancesMinZoom") minValue:0.0 maxValue:18.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKMapZoomLimits limits = weakSelf.mapView.settings.zoomLimits;
        limits.mapZoomLimitMin = item.floatValue;
        weakSelf.mapView.settings.zoomLimits = limits;
    }];
    minZoomItem.floatValue = 0.0;

    MenuItem *maxZoomItem = [MenuItem itemForSliderWithTitle:@"Max zoom" uniqueID:menuID(@"InstancesMaxZoom") minValue:0.0 maxValue:18.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKMapZoomLimits limits = weakSelf.mapView.settings.zoomLimits;
        limits.mapZoomLimitMax = item.floatValue;
        weakSelf.mapView.settings.zoomLimits = limits;
    }];
    maxZoomItem.floatValue = 18.0;

    MenuItem *zoomItem = [MenuItem itemForSliderWithTitle:@"Zoom" uniqueID:menuID(@"InstancesZoomItem") minValue:0.0 maxValue:18.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKCoordinateRegion region = weakSelf.mapView.visibleRegion;
        region.zoomLevel = item.floatValue;
        weakSelf.mapView.visibleRegion = region;
    }];
    zoomItem.floatValue = 17.0;
    
    MenuItem *centerLatItem = [MenuItem itemForTextWithTitle:@"Lat" uniqueID:menuID(@"InstancesLatItem") changeBlock:nil editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {
        SKCoordinateRegion region = weakSelf.mapView.visibleRegion;
        region.center.latitude = item.doubleValue;
        weakSelf.mapView.visibleRegion = region;
    }];
    centerLatItem.doubleValue = self.mapView.visibleRegion.center.latitude;
    
    MenuItem *centerLongItem = [MenuItem itemForTextWithTitle:@"Long" uniqueID:menuID(@"InstancesLongItem") changeBlock:nil editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {
        SKCoordinateRegion region = weakSelf.mapView.visibleRegion;
        region.center.longitude = item.doubleValue;
        weakSelf.mapView.visibleRegion = region;
    }];
    centerLongItem.doubleValue = self.mapView.visibleRegion.center.latitude;
    
    MenuItem *bearingItem = [MenuItem itemForSliderWithTitle:@"bearing" uniqueID:menuID(@"InstancesBearingItem") minValue:0.0 maxValue:360.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.bearing = item.floatValue;
    }];
    bearingItem.floatValue = 0.0;
    
    MenuItem *mapStateItem = [MenuItem itemForMenuTypeWithTitle:@"Map state" sections:@[[MenuSection sectionWithTitle:@"Map state" items:@[zoomItem, centerLatItem, centerLongItem, bearingItem]]] selectionBlock:nil];
    
    MenuItem *zoomLevelItem = [MenuItem itemForMenuTypeWithTitle:@"Zoom levels" sections:@[[MenuSection sectionWithTitle:@"Levels" items:@[minZoomItem, maxZoomItem]]] selectionBlock:nil];
    
    MenuItem *annotationTapZoomLimit = [MenuItem itemForSliderWithTitle:@"Annotation tap zoom limit" uniqueID:menuID(@"InstancesAnnotationTappZoomLimit") minValue:0.0 maxValue:18.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.annotationTapZoomLimit = item.floatValue;
    }];
    annotationTapZoomLimit.floatValue = 12;
    
    MenuItem *compassToggleItem = [MenuItem itemForToggleWithTitle:@"Enable compass" uniqueID:menuID(@"InstancesEnableCompass") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.showCompass = item.boolValue;
    }];
    compassToggleItem.boolValue = YES;
    
    MenuItem *compassXOffsetItem = [MenuItem itemForTextWithTitle:@"Compass X offset" uniqueID:menuID(@"InstancesCompassX") changeBlock:nil editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {
        CGPoint offset = weakSelf.mapView.settings.compassOffset;
        offset.x = item.floatValue;
        weakSelf.mapView.settings.compassOffset = offset;
    }];
    compassXOffsetItem.floatValue = 0;
    
    MenuItem *compassYOffsetItem = [MenuItem itemForTextWithTitle:@"Compass Y offset" uniqueID:menuID(@"InstancesCompassY") changeBlock:nil editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {
        CGPoint offset = weakSelf.mapView.settings.compassOffset;
        offset.y = item.floatValue;
        weakSelf.mapView.settings.compassOffset = offset;
    }];
    compassYOffsetItem.floatValue = 0;
    
    MenuItem *compassMenuItem = [MenuItem itemForMenuTypeWithTitle:@"Compass options" sections:@[[MenuSection sectionWithTitle:@"Options" items:@[compassToggleItem, compassXOffsetItem, compassYOffsetItem]]] selectionBlock:nil];
    
    MenuItem *inertiaToggle = [MenuItem itemForToggleWithTitle:@"Enable inertia" uniqueID:menuID(@"InstancesEnableInertia") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.inertiaEnabled = item.boolValue;
    }];
    inertiaToggle.boolValue = YES;
    
    MenuItem *enable3D = [MenuItem itemForToggleWithTitle:@"Enable 3D" uniqueID:menuID(@"InstancesEnable3D") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        if (item.boolValue) {
            weakSelf.mapView.settings.displayMode = SKMapDisplayMode3D;
        } else {
            weakSelf.mapView.settings.displayMode = SKMapDisplayMode2D;
        }
    }];
    enable3D.boolValue = NO;
    
    MenuItem *poiOptionCity = [MenuItem itemForToggleWithTitle:@"City" uniqueID:menuID(@"InstancesPOIOptionCity") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updatePOIDisplayOption];
    }];
    poiOptionCity.boolValue = YES;
    
    MenuItem *poiOptionGeneral = [MenuItem itemForToggleWithTitle:@"General" uniqueID:menuID(@"InstancesPOIOptionGeneral") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updatePOIDisplayOption];
    }];
    poiOptionGeneral.boolValue = YES;
    
    MenuItem *poiOptionImportant = [MenuItem itemForToggleWithTitle:@"Important" uniqueID:menuID(@"InstancesPOIOptionImportant") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updatePOIDisplayOption];
    }];
    poiOptionImportant.boolValue = YES;
    
    MenuItem *poiDisplayOptionsMenuItem = [MenuItem itemForMenuTypeWithTitle:@"POI display options" sections:@[[MenuSection sectionWithTitle:@"Options" items:@[poiOptionCity, poiOptionGeneral, poiOptionImportant]]] selectionBlock:nil];
    
    MenuItem *oneWaysItem = [MenuItem itemForToggleWithTitle:@"One ways" uniqueID:menuID(@"InstancesOneWays") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.showOneWays = item.boolValue;
    }];
    oneWaysItem.boolValue = YES;
    
    MenuItem *streetBadgesItem = [MenuItem itemForToggleWithTitle:@"Street badges" uniqueID:menuID(@"InstancesStreetBadges") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.showStreetBadges = item.boolValue;
    }];
    streetBadgesItem.boolValue = YES;
    
    MenuItem *mapObjects = [MenuItem itemForToggleWithTitle:@"Show objects" uniqueID:menuID(@"InstancesShowMapObjects") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        if (item.boolValue) {
            [self showMapObjects];
        } else {
            [self hideMapObjects];
        }
    }];
    mapObjects.boolValue = NO;
    
    MenuItem *drawingOrder = [MenuItem itemForOptionsWithTitle:@"Drawing order" uniqueID:menuID(@"InstancesDrawingOrder") options:@[@(SKDrawableObjectsOverAnnotations), @(SKAnnotationsOverDrawableObjects)] readableOptions:@[@"Objects over annotations", @"Annotations over objects"] changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.drawingOrderType = (SKDrawingOrderType)item.intValue;
    }];
    drawingOrder.intValue = SKDrawableObjectsOverAnnotations;
    
    MenuItem *drawOrderMenu = [MenuItem itemForMenuTypeWithTitle:@"Draw order" sections:@[[MenuSection sectionWithTitle:@"Draw order" items:@[mapObjects, drawingOrder]]] selectionBlock:nil];
    
    MenuItem *accuracyCircle = [MenuItem itemForToggleWithTitle:@"Show accuracy circle" uniqueID:menuID(@"InstancesAccuracyCircle") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.showAccuracyCircle = item.boolValue;
    }];
    accuracyCircle.boolValue = YES;
    
    MenuItem *bicycleLanes = [MenuItem itemForToggleWithTitle:@"Show bycicle lanes" uniqueID:menuID(@"InstancesBicycleLanes") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.showBicycleLanes = item.boolValue;
    }];
    bicycleLanes.boolValue = YES;
    
    MenuItem *streetNamePopups = [MenuItem itemForToggleWithTitle:@"Street name popups" uniqueID:menuID(@"InstancesStreetPopups") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.showStreetNamePopUps = item.boolValue;
    }];
    streetNamePopups.boolValue = NO;
    
    MenuItem *showCurrentPosition = [MenuItem itemForToggleWithTitle:@"Show current position" uniqueID:menuID(@"InstancesCurrentPosition") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.showCurrentPosition = item.boolValue;
    }];
    showCurrentPosition.boolValue = YES;

//    MenuItem *ccpConstantZoom = [MenuItem itemForToggleWithTitle:@"CCP constant zoom" uniqueID:menuID(@"InstancesCCPConstantZoom") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
//        weakSelf.mapView.settings.c = item.boolValue;
//    }];
//    ccpConstantZoom.boolValue = YES;

    NSArray *attribPos = @[@(SKAttributionPositionTopLeft), @(SKAttributionPositionTopMiddle), @(SKAttributionPositionTopRight), @(SKAttributionPositionBottomLeft), @(SKAttributionPositionBottomMiddle), @(SKAttributionPositionBottomRight)];
    NSArray *attribNames = @[@"SKAttributionPositionTopLeft", @"SKAttributionPositionTopMiddle", @"SKAttributionPositionTopRight", @"SKAttributionPositionBottomLeft", @"SKAttributionPositionBottomMiddle", @"SKAttributionPositionBottomRight"];
    
    MenuItem *osmAttribution = [MenuItem itemForOptionsWithTitle:@"OSM attribution position" uniqueID:menuID(@"InstancesOSMPosition") options:attribPos readableOptions:attribNames changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.osmAttributionPosition = (SKAttributionPosition)item.intValue;
    }];
    osmAttribution.intValue = SKAttributionPositionBottomRight;
    osmAttribution.numberOfLines = 2;
    
    MenuItem *companyAttribution = [MenuItem itemForOptionsWithTitle:@"Company attribution position" uniqueID:menuID(@"InstancesCompanyPosition") options:attribPos readableOptions:attribNames changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.companyAttributionPosition = (SKAttributionPosition)item.intValue;
    }];
    companyAttribution.intValue = SKAttributionPositionBottomRight;
    companyAttribution.numberOfLines = 2;
    
    MenuItem *zoomWithAnchor = [MenuItem itemForToggleWithTitle:@"Zoom with center anchor" uniqueID:menuID(@"InstancesZoomWithAnchor") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.zoomWithCenterAnchor = item.boolValue;
    }];
    zoomWithAnchor.boolValue = NO;
    
    MenuItem *houseNumbers = [MenuItem itemForToggleWithTitle:@"Show house numbers" uniqueID:menuID(@"InstancesHpouseNumbers") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.mapView.settings.showHouseNumbers = item.boolValue;
    }];
    houseNumbers.boolValue = YES;
    
    MenuItem *trailToggle = [MenuItem itemForToggleWithTitle:@"Enabled" uniqueID:menuID(@"InstancesTrailToggle") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updateTrailSettings];
    }];
    trailToggle.boolValue = NO;
    
    MenuItem *trailDotted = [MenuItem itemForToggleWithTitle:@"Dotted" uniqueID:menuID(@"InstancesDottedToggle") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updateTrailSettings];
    }];
    trailDotted.boolValue = NO;
    
    MenuItem *trailColor = [MenuItem itemForColorWithTitle:@"Color" uniqueID:menuID(@"InstancesTrailColor") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updateTrailSettings];
    }];
    trailColor.colorValue = [UIColor blueColor];
    
    MenuItem *trailWidth = [MenuItem itemForSliderWithTitle:@"Width" uniqueID:menuID(@"InstancesTrailWidth") minValue:1 maxValue:10 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updateTrailSettings];
    }];
    trailWidth.uintValue = 1.0;
    trailWidth.integerSlider = YES;
    
    MenuItem *trailPedestrian = [MenuItem itemForToggleWithTitle:@"Pedestrian trail" uniqueID:menuID(@"InstancesTrailPedestrian") changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updateTrailSettings];
    }];
    trailPedestrian.boolValue = NO;
    
    MenuItem *trailSmooth = [MenuItem itemForSliderWithTitle:@"Smooth level" uniqueID:menuID(@"InstancesTrailSmoothLevel") minValue:1 maxValue:10 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updateTrailSettings];
    }];
    trailSmooth.intValue = 1;
    trailSmooth.integerSlider = YES;
    
    MenuItem  *trailSettingsMenu = [MenuItem itemForMenuTypeWithTitle:@"Trail settings" sections:@[[MenuSection sectionWithTitle:@"Trail settings" items:@[trailToggle, trailDotted, trailColor, trailWidth, trailPedestrian, trailSmooth]]] selectionBlock:nil];
    
    MenuItem *newInstance = [MenuItem itemForButtonWithTitle:@"New instance" selectionBlock:^(MenuItem *item) {
        TestingMapInstancesViewController *vc = [[TestingMapInstancesViewController alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    
    MenuItem *cameraCenter = [MenuItem itemForSliderWithTitle:@"Center" uniqueID:menuID(@"InstancesCameraCenter") minValue:0.1 maxValue:0.9 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updateCameraSettings];
    }];
    cameraCenter.floatValue = 0.3;
    
    MenuItem *cameraTilt = [MenuItem itemForSliderWithTitle:@"Tilt" uniqueID:menuID(@"InstancesCameraTilt") minValue:0.0 maxValue:90.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updateCameraSettings];
    }];
    cameraTilt.floatValue = 15.0;
    
    MenuItem *cameraDistance = [MenuItem itemForSliderWithTitle:@"Distance" uniqueID:menuID(@"InstancesCameraDistance") minValue:30.0 maxValue:300.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf updateCameraSettings];
    }];
    cameraDistance.floatValue = 144.0;
    
    MenuItem *cameraSettingsMenu = [MenuItem itemForMenuTypeWithTitle:@"Camera settings" sections:@[[MenuSection sectionWithTitle:@"Camera settings" items:@[cameraCenter, cameraTilt, cameraDistance]]] selectionBlock:nil];
    
    NSArray *items = @[headingItem,
                       followPositionItem,
                       showUserPositionItem,
                       centerOnCurrentPosition,
                       rotationItem,
                       panningItem,
                       annotationTapZoomLimit,
                       compassMenuItem,
                       trailSettingsMenu,
                       inertiaToggle,
                       zoomLevelItem,
                       mapStateItem,
                       enable3D,
                       cameraSettingsMenu,
                       poiDisplayOptionsMenuItem,
                       streetNamePopups,
                       oneWaysItem,
                       streetBadgesItem,
                       drawOrderMenu,
                       accuracyCircle,
                       bicycleLanes,
                       osmAttribution,
                       companyAttribution,
                       zoomWithAnchor,
                       houseNumbers,
                       newInstance];
    
    MenuSection *section = [MenuSection sectionWithTitle:@"Options" items:items];
    
    NSArray *sections = @[section];
    
    self.menuView.sections = sections;
}

#pragma mark - Private methods

- (void)updatePOIDisplayOption {
    MenuItem *cityItem = [MenuItem itemWithID:menuID(@"InstancesPOIOptionCity")];
    MenuItem *generalItem = [MenuItem itemWithID:menuID(@"InstancesPOIOptionGeneral")];
    MenuItem *importantItem = [MenuItem itemWithID:menuID(@"InstancesPOIOptionImportant")];
    
    SKPOIDisplayingOption option = SKPOIDisplayingOptionNone;
    if (cityItem.boolValue) {
        option |= SKPOIDisplayingOptionCity;
    }
    if (generalItem.boolValue) {
        option |= SKPOIDisplayingOptionGeneral;
    }
    if (importantItem.boolValue) {
        option |= SKPOIDisplayingOptionImportant;
    }
    
    self.mapView.settings.poiDisplayingOption = option;
}

#pragma mark - SKMapViewDelegateMethods

- (void)mapViewDidSelectCurrentPositionIcon:(SKMapView *)mapView {
    [self showToastWithMessage:@"Current position tapped"];
}

- (void)mapView:(SKMapView *)mapView didChangeToRegion:(SKCoordinateRegion)region {
    MenuItem *zoom = [MenuItem itemWithID:menuID(@"InstancesZoomItem")];
    MenuItem *lat = [MenuItem itemWithID:menuID(@"InstancesLatItem")];
    MenuItem *lon = [MenuItem itemWithID:menuID(@"InstancesLongItem")];
    MenuItem *bearing = [MenuItem itemWithID:menuID(@"InstancesBearingItem")];
    
    zoom.floatValue = region.zoomLevel;
    lat.floatValue = region.center.latitude;
    lon.floatValue = region.center.longitude;
    [lat fireRefresh];
    [lon fireRefresh];
    bearing.floatValue = mapView.bearing;
}

- (void)updateTrailSettings {
    MenuItem *enabled = [MenuItem itemWithID:menuID(@"InstancesTrailToggle")];
    
    if (enabled.boolValue) {
        MenuItem *dotted = [MenuItem itemWithID:menuID(@"InstancesDottedToggle")];
        MenuItem *color = [MenuItem itemWithID:menuID(@"InstancesTrailColor")];
        MenuItem *width = [MenuItem itemWithID:menuID(@"InstancesTrailWidth")];
        MenuItem *pedestrian = [MenuItem itemWithID:menuID(@"InstancesTrailPedestrian")];
        MenuItem *smoothLevel = [MenuItem itemWithID:menuID(@"InstancesTrailSmoothLevel")];
        
        SKTrailSettings *settings = [SKTrailSettings trailSettings];
        settings.dotted = dotted.boolValue;
        settings.color = color.colorValue;
        settings.width = width.uintValue;
        settings.enablePedestrianTrail = pedestrian.boolValue;
        settings.pedestrianTrailSmoothLevel = smoothLevel.intValue;
        self.mapView.settings.trailSettings = settings;
    } else {
        self.mapView.settings.trailSettings = nil;
    }
}

- (void)updateCameraSettings {
    MenuItem *center = [MenuItem itemWithID:menuID(@"InstancesCameraCenter")];
    MenuItem *tilt = [MenuItem itemWithID:menuID(@"InstancesCameraTilt")];
    MenuItem *distance = [MenuItem itemWithID:menuID(@"InstancesCameraDistance")];
    
    SKCameraSettings *settings = [SKCameraSettings cameraSettings];
    settings.center = center.floatValue;
    settings.tilt = tilt.floatValue;
    settings.distance = distance.floatValue;
    
    self.mapView.settings.cameraSettings = settings;
}

#pragma mark - SKMapViewDelegate methods

- (void)mapView:(SKMapView *)mapView didSelectAnnotation:(SKAnnotation *)annotation {
    self.tapLabel.hidden = NO;
    
    [self performSelector:@selector(hideTapLabel) withObject:nil afterDelay:3.0];
}

@end
