//
//  TestingPOITrackerViewController.m
//  FrameworkIOSDemo
//
//  Created by Cristian Chertes on 28/05/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingPOITrackerViewController.h"
#import "TestingUtils.h"

static NSString* const kLogFileName = @"Seattle";
static int const kTrackablePOITypeIncident = 1000;

@interface TestingPOITrackerViewController ()<SKMapViewDelegate,SKRoutingDelegate,SKNavigationDelegate,SKPOITrackerDataSource,SKPOITrackerDelegate>

@property (nonatomic,assign) CGFloat                trackerRadius;
@property (nonatomic,assign) CGFloat                trackerRefreshMargin;
@property (nonatomic,strong) SKPOITracker           *poiTracker;
@property (nonatomic,strong) SKTrackablePOIRule     *rule;
@property (nonatomic,assign) SKLongTapType          longTapType;
@property (nonatomic,strong) NSMutableArray         *trackablePOIs;
@property (nonatomic,assign) CLLocationCoordinate2D startCoordinate;
@property (nonatomic,assign) CLLocationCoordinate2D destinationCoordinate;
@property (nonatomic,strong) MenuItem               *detectedPOIsItem;

@end

@implementation TestingPOITrackerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trackablePOIs = [NSMutableArray array];
    [self configureMenuView];
    [self configureMapAndRoutingService];
    [self addAnnotations];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[SKRoutingService sharedInstance] stopNavigation];
    [self.poiTracker stopPOITracker];
    [self removeAnnotations];
}

#pragma mark - Actions

- (void)startPOITracking
{
    __weak TestingPOITrackerViewController *weakSelf = self;
    
    [weakSelf configureMapAndRoutingService];
    [weakSelf startRouteCalculation];
    
    weakSelf.poiTracker = [SKPOITracker sharedInstance];
    weakSelf.poiTracker.dataSource = weakSelf;
    weakSelf.poiTracker.delegate = weakSelf;
    [weakSelf.poiTracker startPOITrackerWithRadius:weakSelf.trackerRadius refreshMargin:weakSelf.trackerRefreshMargin forPOITypes:@[@(kTrackablePOITypeIncident)]];;
    [weakSelf.poiTracker setRule:weakSelf.rule forPOIType:kTrackablePOITypeIncident];
}

- (void)stopPOITracking {
    __weak TestingPOITrackerViewController *weakSelf = self;
    
    [weakSelf.mapView clearAllAnnotations];
    [[SKRoutingService sharedInstance] clearCurrentRoutes];
    [[SKRoutingService sharedInstance] stopNavigation];
    [weakSelf.poiTracker stopPOITracker];
    [weakSelf removeAnnotations];
    [weakSelf.trackablePOIs removeAllObjects];
}

#pragma mark - Private methods

- (void)configureMenuView {
    MenuSection *trackerSettingsSection = [self trackerSettingsSection];
    MenuSection *settingsSection = [self settingsSection];
    MenuSection *advancedSettingsSection = [self advancedSettingsSection];
    MenuSection *actionsSection = [self actionsSection];
    MenuSection *infoSection = [self infoSection];
    
    self.menuView.sections = @[trackerSettingsSection, settingsSection, advancedSettingsSection, actionsSection, infoSection];
}

- (MenuSection *)trackerSettingsSection {
    __weak TestingPOITrackerViewController *weakSelf = self;
    
    MenuItem *radiusItem = [MenuItem itemForSliderWithTitle:@"Tracker Radius" uniqueID:nil minValue:1.0 maxValue:9000.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.trackerRadius = item.floatValue;
    }];
    radiusItem.intValue = 5000;

    MenuItem *refreshMarginItem = [MenuItem itemForSliderWithTitle:@"Refresh Margin" uniqueID:nil minValue:0.0 maxValue:1.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.trackerRefreshMargin = item.floatValue;
    }];
    refreshMarginItem.floatValue = 0.1;
    
    MenuSection *trackerSettingsSection = [MenuSection sectionWithTitle:@"Tracker Settings" items:@[radiusItem, refreshMarginItem]];
    
    return trackerSettingsSection;
}

- (MenuSection *)settingsSection {
    __weak TestingPOITrackerViewController *weakSelf = self;
    
    MenuItem *routeDistanceItem = [MenuItem itemForSliderWithTitle:@"Route Distance" uniqueID:nil minValue:1.0 maxValue:3000.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.rule.routeDistance = item.intValue;
    }];
    routeDistanceItem.intValue = 1500;
    
    MenuItem *aerialDistanceItem = [MenuItem itemForSliderWithTitle:@"Aerial Distance" uniqueID:nil minValue:1.0 maxValue:3000.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.rule.aerialDistance = item.intValue;
    }];
    aerialDistanceItem.intValue = 3000;
    
    MenuItem *numberOfTurnsItem = [MenuItem itemForTextWithTitle:@"Number of Turns" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.rule.numberOfTurns = item.intValue;
    } editEndBlock:nil];
    numberOfTurnsItem.value = @(2);
    
    MenuItem *longTapForStartItem = [MenuItem itemForButtonWithTitle:@"Add Start Location" selectionBlock:^(MenuItem *item) {
        weakSelf.longTapType = SKLongTapTypeStart;
    }];
    
    MenuItem *longTapForDestItem = [MenuItem itemForButtonWithTitle:@"Add Dest Location" selectionBlock:^(MenuItem *item) {
        weakSelf.longTapType = SKLongTapTypeEnd;
    }];
    
    MenuItem *longTapForPOIItem = [MenuItem itemForButtonWithTitle:@"Add POI Location" selectionBlock:^(MenuItem *item) {
        weakSelf.longTapType = SKLongTapTypeViaPoint;
    }];
    
    MenuSection *settingsSection = [MenuSection sectionWithTitle:@"Rule Settings" items:@[routeDistanceItem, aerialDistanceItem, numberOfTurnsItem, longTapForStartItem, longTapForDestItem, longTapForPOIItem]];
    
    return settingsSection;
}

- (MenuSection *)advancedSettingsSection {
    __weak TestingPOITrackerViewController *weakSelf = self;
    
    MenuItem *maxGPSAccuracy = [MenuItem itemForSliderWithTitle:@"Max GPS Accuracy" uniqueID:nil minValue:1.0 maxValue:400.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.rule.maxGPSAccuracy = item.intValue;
    }];
    maxGPSAccuracy.intValue = 100;
    
    MenuItem *minSpeedIgnoreDistanceAfterTurnItem = [MenuItem itemForSliderWithTitle:@"Min Speed Ignore Dist" uniqueID:nil minValue:1.0 maxValue:400.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.rule.minSpeedIgnoreDistanceAfterTurn = item.floatValue;
    }];
    minSpeedIgnoreDistanceAfterTurnItem.intValue = 80;
    
    MenuItem *maxDistanceAfterTurnItem = [MenuItem itemForSliderWithTitle:@"Max Distance After Turn" uniqueID:nil minValue:1.0 maxValue:400.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.rule.maxDistanceAfterTurn = item.intValue;
    }];
    maxDistanceAfterTurnItem.intValue = 300;

    MenuItem *eliminateIfUTurnItem = [MenuItem itemForToggleWithTitle:@"Eliminate If UTurn" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.rule.eliminateIfUTurn = item.boolValue;
    }];
    eliminateIfUTurnItem.boolValue = YES;
    
    MenuItem *playAudioWarningItem = [MenuItem itemForToggleWithTitle:@"Play Audio Warning" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.rule.playAudioWarning = item.boolValue;
    }];
    playAudioWarningItem.boolValue = NO;
    
    MenuSection *advancedSettingsSection = [MenuSection sectionWithTitle:@"Rule Advanced Settings" items:@[maxGPSAccuracy, minSpeedIgnoreDistanceAfterTurnItem, maxDistanceAfterTurnItem, eliminateIfUTurnItem, playAudioWarningItem]];
    
    return advancedSettingsSection;
}

- (MenuSection *)actionsSection {
    __weak TestingPOITrackerViewController *weakSelf = self;
    
    MenuItem *startItem = [MenuItem itemForButtonWithTitle:@"Start POI Tracker" selectionBlock:^(MenuItem *item) {
        [weakSelf startPOITracking];
    }];
    
    MenuItem *stopItem = [MenuItem itemForButtonWithTitle:@"Stop POI Tracker" selectionBlock:^(MenuItem *item) {
        [weakSelf stopPOITracking];
    }];
    
    MenuSection *actionsSection = [MenuSection sectionWithTitle:@"Actions" items:@[startItem, stopItem]];
    
    return actionsSection;
}

- (MenuSection *)infoSection {
    self.detectedPOIsItem = [MenuItem itemForOptionsWithTitle:@"Detected POIs" uniqueID:nil options:@[] readableOptions:@[] changeBlock:nil];
    MenuSection *infoSection = [MenuSection sectionWithTitle:@"Detected POIs" items:@[self.detectedPOIsItem]];
    
    return infoSection;
}

- (void)configureMapAndRoutingService {
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(48.207407, 16.376916);
    region.zoomLevel = 17.0f;
    
    self.mapView.visibleRegion = region;
    self.mapView.settings.followUserPosition = YES;
    self.mapView.settings.headingMode = SKHeadingModeRoute;
    self.trackablePOIs = [self trackablePOIs];
    
    [SKRoutingService sharedInstance].navigationDelegate = self;
    [SKRoutingService sharedInstance].routingDelegate = self;
    [SKRoutingService sharedInstance].mapView = self.mapView;
    [[SKRoutingService sharedInstance] setAdvisorConfigurationSettings:[SKAdvisorSettings advisorSettings]];
    
    self.rule = [SKTrackablePOIRule trackablePOIRule];
}

- (void)addStartCoordinateAnnotation {
    __weak TestingPOITrackerViewController *weakSelf = self;
    
    SKAnnotation *startCoordinateAnnotation = [SKAnnotation annotation];
    startCoordinateAnnotation.identifier = 9998;
    startCoordinateAnnotation.annotationType = SKAnnotationTypeGreen;
    startCoordinateAnnotation.location = weakSelf.startCoordinate;
    
    [self.mapView addAnnotation:startCoordinateAnnotation withAnimationSettings:nil];
}

- (void)addDestinationCoordinateAnnotation {
    __weak TestingPOITrackerViewController *weakSelf = self;
    
    SKAnnotation *destinationFlagAnnotation = [SKAnnotation annotation];
    destinationFlagAnnotation.identifier = 9999;
    destinationFlagAnnotation.annotationType = SKAnnotationTypeDestinationFlag;
    destinationFlagAnnotation.location = weakSelf.destinationCoordinate;
    
    [self.mapView addAnnotation:destinationFlagAnnotation withAnimationSettings:nil];
}

- (void)addPOICoordinateAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    __weak TestingPOITrackerViewController *weakSelf = self;
    
    SKAnnotation *viaPontAnnotation = [SKAnnotation annotation];
    viaPontAnnotation.identifier = weakSelf.trackablePOIs.count;
    viaPontAnnotation.annotationType = SKAnnotationTypePurple;
    viaPontAnnotation.location = coordinate;
    
    [self.mapView addAnnotation:viaPontAnnotation withAnimationSettings:nil];
}

- (void)addTrackablePOIforLocation:(CLLocationCoordinate2D)location {
    SKTrackablePOI *trackablePOI = [SKTrackablePOI trackablePOI];
    trackablePOI.poiID = self.trackablePOIs.count;
    trackablePOI.type = kTrackablePOITypeIncident;
    trackablePOI.coordinate = location;

    [self.trackablePOIs addObject:trackablePOI];
}

- (void)startRouteCalculation {
    __weak TestingPOITrackerViewController *weakSelf = self;
    
    SKRouteSettings *route = [SKRouteSettings routeSettings];
    route.startCoordinate = weakSelf.startCoordinate;
    route.destinationCoordinate = weakSelf.destinationCoordinate;
    route.shouldBeRendered = YES;
    route.maximumReturnedRoutes = 1;
    
    [[SKRoutingService sharedInstance] calculateRoute:route];
}

- (void)addAnnotations {
    [self.trackablePOIs enumerateObjectsUsingBlock:^(SKTrackablePOI *poi,NSUInteger index,BOOL *stop) {
        SKAnnotation *annotation = [SKAnnotation annotation];
        annotation.identifier = poi.poiID;
        annotation.location = poi.coordinate;
        annotation.annotationType = SKAnnotationTypeMarker;
        
        SKAnimationSettings *animationSettings = [SKAnimationSettings animationSettings];
        [self.mapView addAnnotation:annotation withAnimationSettings:animationSettings];
    }];
}

- (void)removeAnnotations {
    [self.trackablePOIs enumerateObjectsUsingBlock:^(SKTrackablePOI *poi,NSUInteger index,BOOL *stop) {
        SKAnnotation *annotation = [SKAnnotation annotation];
        annotation.identifier = poi.poiID;
        [self.mapView removeAnnotationWithID:annotation.identifier];
    }];
}

#pragma mark - SKPOITrakcerDataSource

- (NSArray *)poiTracker:(SKPOITracker *)poiTracker trackablePOIsAroundLocation:(CLLocationCoordinate2D)location inRadius:(int)radius withType:(int)poiType {
    NSLog(@"Give: %d",self.trackablePOIs.count);
    return self.trackablePOIs;
}

#pragma mark - SKPOITrackerDelegate

- (void)poiTracker:(SKPOITracker *)poiTracker didDectectPOIs:(NSArray *)detectedPOIs withType:(int)type {
    NSMutableArray *strings = [NSMutableArray array];
    
    [detectedPOIs enumerateObjectsUsingBlock:^(SKDetectedPOI *detectedPOI, NSUInteger index, BOOL *stop){
        NSLog(@"Detected: %@",[detectedPOI description]);
        NSString *string = [NSString stringWithFormat:@"Id:%d Dist:%d RefDist:%d",detectedPOI.poiID, detectedPOI.distance, detectedPOI.referenceDistance];
        [strings addObject:string];
    }];
    NSLog(@"Recieve Count: %d",strings.count);
    self.detectedPOIsItem.readableOptions = strings;
    self.detectedPOIsItem.itemOptions = strings;
    [self.detectedPOIsItem fireRefresh];
}

#pragma mark - SKMapViewDelegate methods

- (void)mapView:(SKMapView *)mapView didLongTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    switch (self.longTapType) {
        case SKLongTapTypeNone:
            break;

        case SKLongTapTypeStart:
            self.startCoordinate = coordinate;
            [self addStartCoordinateAnnotation];
            break;
            
        case SKLongTapTypeEnd:
            self.destinationCoordinate = coordinate;
            [self addDestinationCoordinateAnnotation];
            break;
            
        case SKLongTapTypeViaPoint:
            [self addTrackablePOIforLocation:coordinate];
            [self addPOICoordinateAnnotationWithCoordinate:coordinate];
            break;
            
        default:
            break;
    }
    self.longTapType = SKLongTapTypeNone;
}

#pragma mark - SKRoutingDelegate methods

- (void)routingService:(SKRoutingService *)routingService didFinishRouteCalculationWithInfo:(SKRouteInformation *)routeInformation {
    SKNavigationSettings *navigationSettings = [SKNavigationSettings navigationSettings];
    navigationSettings.navigationType = SKNavigationTypeSimulation;
    [[SKRoutingService sharedInstance] startNavigationWithSettings:navigationSettings];
}

- (void)routingService:(SKRoutingService *)routingService didFailWithErrorCode:(SKRoutingErrorCode)errorCode {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Route Calculation Failed" message:[NSString stringWithFormat:@"Failed with error code: %ld",(long)errorCode] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - SKNavigationDelegate methods

- (void)routingServiceDidReachDestination:(SKRoutingService *)routingService {
    [self removeAnnotations];
    [[SKRoutingService sharedInstance] clearCurrentRoutes];
}

@end
