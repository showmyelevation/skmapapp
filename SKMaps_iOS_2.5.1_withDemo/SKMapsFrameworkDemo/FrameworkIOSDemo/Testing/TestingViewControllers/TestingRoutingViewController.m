//
//  TestingRoutingViewController.m
//  FrameworkIOSDemo
//
//  Created by Cristian Chertes on 05/05/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingRoutingViewController.h"
#import "TestingUtils.h"
#import <SKMaps/SKViaPoint.h>
#import <SKMaps/SKRoutingService.h>
#import <SKMaps/SKViaPointState.h>

@interface TestingRoutingViewController () <SKMapViewDelegate ,SKRoutingDelegate>

//Route settings
@property (nonatomic,assign) CGFloat                startLatitude;
@property (nonatomic,assign) CGFloat                startLongitude;
@property (nonatomic,assign) CGFloat                destinationLatitude;
@property (nonatomic,assign) CGFloat                destinationLongitude;
@property (nonatomic,assign) BOOL                   shouldBeRendered;
@property (nonatomic,assign) BOOL                   requestAdvices;
@property (nonatomic,assign) BOOL                   requestCountryCodes;
@property (nonatomic,assign) BOOL                   requestExtendedRoutePointsInfo;
@property (nonatomic,assign) SKRouteRestrictions    routeRestrictions;
@property (nonatomic,assign) SKRouteMode            routeMode;
@property (nonatomic,assign) SKRouteConnectionMode  routeConnectionMode;
@property (nonatomic,assign) CGFloat                zoomInsetTop;
@property (nonatomic,assign) CGFloat                zoomInsetLeft;
@property (nonatomic,assign) CGFloat                zoomInsetBottom;
@property (nonatomic,assign) CGFloat                zoomInsetRight;
@property (nonatomic,assign) CGFloat                blockRoadDistance;
@property (nonatomic,assign) SKRouteID              saveRouteId;
@property (nonatomic,assign) SKRouteID              loadRouteId;
@property (nonatomic,assign) int                    numberOfRoutes;

//Advanced settings
@property (nonatomic,assign) BOOL                   useSlopes;
@property (nonatomic,assign) BOOL                   downloadRouteCorridor;
@property (nonatomic,assign) int                    routeCorridorWidth;
@property (nonatomic,assign) BOOL                   waitForCorridorDownload;
@property (nonatomic,assign) BOOL                   destinationIsPoint;

//Via Points
@property (nonatomic,assign) int                    viaPointIdentifier;
@property (nonatomic,assign) int                    afterViaPointIdentifier;
@property (nonatomic,assign) int                    removeViaPointIdentifier;
@property (nonatomic,assign) CGFloat                viaPointLatitude;
@property (nonatomic,assign) CGFloat                viaPointLongitude;

//Menu Items for settings
@property (nonatomic,strong) MenuItem               *startLatitudeItem;
@property (nonatomic,strong) MenuItem               *startLongitudeItem;
@property (nonatomic,strong) MenuItem               *destinationLatitudeItem;
@property (nonatomic,strong) MenuItem               *destinationLongitudeItem;

//Menu Items for viaPoints

@property (nonatomic,strong) MenuItem               *viaPointLatitudeItem;
@property (nonatomic,strong) MenuItem               *viaPointLongitudeItem;

//Menu Items for output
@property (nonatomic,strong) MenuItem               *routeIdItem;
@property (nonatomic,strong) MenuItem               *distanceItem;
@property (nonatomic,strong) MenuItem               *timeItem;
@property (nonatomic,strong) MenuItem               *corridorDownloadedItem;
@property (nonatomic,strong) MenuItem               *calculatedAfterReroutingItem;
@property (nonatomic,strong) MenuItem               *containsHighwaysItem;
@property (nonatomic,strong) MenuItem               *containsTollRoadsItem;
@property (nonatomic,strong) MenuItem               *containsFerryLinesItem;
@property (nonatomic,strong) MenuItem               *viaPointsOnRouteItem;
@property (nonatomic,strong) MenuItem               *adviceListItem;
@property (nonatomic,strong) MenuItem               *coordinatesItem;
@property (nonatomic,strong) MenuItem               *countryCodesItem;

@property (nonatomic,assign) SKLongTapType          longTapType;
@property (nonatomic,strong) NSMutableArray         *viaPointsArray;
@property (nonatomic,strong) SKRouteInformation     *routeInfo;
@property (nonatomic,strong) NSArray                *adviceList;
@property (nonatomic,strong) NSArray                *coordinatesArray;
@property (nonatomic,strong) NSArray                *countriesArray;

@end

@implementation TestingRoutingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setRouteRestrictions];
    [self configureRoutingService];
    
    self.viaPointsArray = [NSMutableArray array];
    self.longTapType = SKLongTapTypeNone;
    
    [self configureMenuView];
}

#pragma mark - Actions

- (void)addAfterViaPoint {
    __weak TestingRoutingViewController *weakSelf = self;
    
    SKViaPoint *viaPoint = [weakSelf getViaPoint];
    
    [[SKRoutingService sharedInstance] addViaPoint:viaPoint afterViaPointWithID:weakSelf.afterViaPointIdentifier];
}

- (void)removeViaPoint {
    __weak TestingRoutingViewController *weakSelf = self;
    
    [[SKRoutingService sharedInstance]removeViaPoint:weakSelf.removeViaPointIdentifier];
}

- (void)addViaPoint {
    __weak TestingRoutingViewController *weakSelf = self;
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(weakSelf.viaPointLatitude, weakSelf.viaPointLongitude);
    SKViaPoint *point = [SKViaPoint viaPoint:weakSelf.viaPointIdentifier withCoordinate:location];
    
    [weakSelf.viaPointsArray addObject:point];
}

- (void)calculateRoute {
    __weak TestingRoutingViewController *weakSelf = self;
    
    SKRouteSettings *settings = [SKRouteSettings routeSettings];
    settings.startCoordinate = CLLocationCoordinate2DMake(weakSelf.startLatitude, weakSelf.startLongitude);
    settings.destinationCoordinate = CLLocationCoordinate2DMake(weakSelf.destinationLatitude, weakSelf.destinationLongitude);
    settings.viaPoints = weakSelf.viaPointsArray;
    settings.routeMode = weakSelf.routeMode;
    settings.routeRestrictions = weakSelf.routeRestrictions;
    settings.routeConnectionMode = weakSelf.routeConnectionMode;
    settings.requestCountryCodes = weakSelf.requestCountryCodes;
    settings.requestExtendedRoutePointsInfo = weakSelf.requestExtendedRoutePointsInfo;
    settings.requestAdvices = weakSelf.requestAdvices;
    settings.useSlopes = weakSelf.useSlopes;
    settings.maximumReturnedRoutes = weakSelf.numberOfRoutes;
    settings.downloadRouteCorridor = weakSelf.downloadRouteCorridor;
    settings.routeCorridorWidth = weakSelf.routeCorridorWidth;
    settings.waitForCorridorDownload = weakSelf.waitForCorridorDownload;
    settings.destinationIsPoint = weakSelf.destinationIsPoint;
    settings.shouldBeRendered = weakSelf.shouldBeRendered;
    
    [[SKRoutingService sharedInstance] calculateRoute:settings];
    
    SKCoordinateRegion region;
    region.center.latitude = settings.destinationCoordinate.latitude;
    region.center.longitude = settings.destinationCoordinate.longitude;
    region.zoomLevel = 13.0;
    self.mapView.visibleRegion = region;
}

- (void)zoomToRoute {
    __weak TestingRoutingViewController *weakSelf = self;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(weakSelf.zoomInsetTop, weakSelf.zoomInsetLeft, weakSelf.zoomInsetBottom, weakSelf.zoomInsetRight);
    
    [[SKRoutingService sharedInstance] zoomToRouteWithInsets:insets duration:500];
}

- (void)blockRoad {
    __weak TestingRoutingViewController *weakSelf = self;
    
    [[SKRoutingService sharedInstance] blockRoads:weakSelf.blockRoadDistance];
}

- (void)unblockRoad {
    [[SKRoutingService sharedInstance] unBlockAllRoads];
}

- (void)clearRoute {
    __weak TestingRoutingViewController *weakSelf = self;
    
    [[SKRoutingService sharedInstance] clearCurrentRoutes];
    [weakSelf.mapView clearAllAnnotations];
    weakSelf.viaPointsArray = [NSMutableArray array];
}

- (void)saveRouteToCache {
    __weak TestingRoutingViewController *weakSelf = self;
    
    [[SKRoutingService sharedInstance] saveRouteToCache:weakSelf.saveRouteId];
}

- (void)loadRouteFromCache {
    __weak TestingRoutingViewController *weakSelf = self;
    
    [[SKRoutingService sharedInstance] clearCurrentRoutes];
    [[SKRoutingService sharedInstance] loadRouteFromCache:weakSelf.loadRouteId];
}

- (void)clearAllRoutesFromCache {
    [[SKRoutingService sharedInstance] clearAllRoutesFromCache];
}

- (void)getAdviceList {
    __weak TestingRoutingViewController *weakSelf = self;
    
    NSArray *adviceList = [[SKRoutingService sharedInstance] routeAdviceListWithDistanceFormat:SKDistanceFormatMetric];
    if (adviceList) {
        weakSelf.adviceList = adviceList;
        
        NSArray *adviceStrings = [weakSelf arrayOfStringsFromAdviceList:adviceList];
        weakSelf.adviceListItem.readableOptions = adviceStrings;
        weakSelf.adviceListItem.itemOptions = adviceStrings;
        [weakSelf.adviceListItem fireRefresh];
    }
}

- (void)routeCoordinatesForRoute {
    __weak TestingRoutingViewController *weakSelf = self;
    
    NSArray *coordinates = [[SKRoutingService sharedInstance] routeCoordinatesForRouteWithId:weakSelf.routeInfo.routeID];
    if (coordinates) {
        weakSelf.coordinatesArray = coordinates;
        NSArray *arr = [weakSelf arrayOfStringsFromLocations:coordinates];
        
        weakSelf.coordinatesItem.readableOptions = arr;
        weakSelf.coordinatesItem.itemOptions = arr;
        [weakSelf.coordinatesItem fireRefresh];
    }
}

- (void)routeCountriesForRoute {
    __weak TestingRoutingViewController *weakSelf = self;
    
    NSArray *countries = [[SKRoutingService sharedInstance] routeCountriesForRouteWithId:weakSelf.routeInfo.routeID];
    if (countries) {
        weakSelf.countriesArray = countries;
        
        weakSelf.countryCodesItem.readableOptions = weakSelf.countriesArray;
        weakSelf.countryCodesItem.itemOptions = weakSelf.countriesArray;
        [weakSelf.countryCodesItem fireRefresh];
    }
}

#pragma mark - Private methods

- (SKViaPoint *)getViaPoint {
    __weak TestingRoutingViewController *weakSelf = self;
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(weakSelf.viaPointLatitude, weakSelf.viaPointLongitude);
    SKViaPoint *point = [SKViaPoint viaPoint:weakSelf.viaPointIdentifier withCoordinate:location];
    
    return point;
}

- (void)addStartCoordinateAnnotation {
    __weak TestingRoutingViewController *weakSelf = self;
    
    SKAnnotation *startCoordinateAnnotation = [SKAnnotation annotation];
    startCoordinateAnnotation.identifier = 9998;
    startCoordinateAnnotation.annotationType = SKAnnotationTypeGreen;
    startCoordinateAnnotation.location = CLLocationCoordinate2DMake(weakSelf.startLatitude, weakSelf.startLongitude);
    
    [self.mapView addAnnotation:startCoordinateAnnotation withAnimationSettings:nil];
}

- (void)addDestinationCoordinateAnnotation {
    __weak TestingRoutingViewController *weakSelf = self;
    
    SKAnnotation *destinationFlagAnnotation = [SKAnnotation annotation];
    destinationFlagAnnotation.identifier = 9999;
    destinationFlagAnnotation.annotationType = SKAnnotationTypeDestinationFlag;
    destinationFlagAnnotation.location = CLLocationCoordinate2DMake(weakSelf.destinationLatitude, weakSelf.destinationLongitude);
    
    [self.mapView addAnnotation:destinationFlagAnnotation withAnimationSettings:nil];
}

- (void)addViaPointCoordinateAnnotation {
    __weak TestingRoutingViewController *weakSelf = self;
    
    SKAnnotation *viaPontAnnotation = [SKAnnotation annotation];
    viaPontAnnotation.identifier = weakSelf.viaPointIdentifier;
    viaPontAnnotation.annotationType = SKAnnotationTypePurple;
    viaPontAnnotation.location = CLLocationCoordinate2DMake(weakSelf.viaPointLatitude,weakSelf.viaPointLongitude);
    
    [self.mapView addAnnotation:viaPontAnnotation withAnimationSettings:nil];
}

- (void)configureRoutingService {
    [SKRoutingService sharedInstance].mapView = self.mapView;
    [SKRoutingService sharedInstance].routingDelegate = self;
    self.mapView.delegate = self;
    
    SKCoordinateRegion region;
    region.center.latitude = 37.9667;
    region.center.longitude = 23.7166;
    region.zoomLevel = 13.0;
    self.mapView.visibleRegion = region;
}

- (void)setRouteRestrictions {
    SKRouteRestrictions restrictions;
    restrictions.avoidHighways = NO;
    restrictions.avoidTollRoads = NO;
    restrictions.avoidFerryLines = NO;
    restrictions.avoidBicycleWalk = NO;
    restrictions.avoidBicycleCarry = NO;
    
    self.routeRestrictions = restrictions;
}

- (NSString *)stringFromBool:(BOOL)value {
    if (value) {
        return @"YES";
    }
    
    return @"NO";
}

- (NSArray *)arrayOfStringsFromViaPoints:(NSArray *)viaPoints {
    NSMutableArray *array = [NSMutableArray array];
    if (viaPoints && viaPoints.count > 0) {
        for (SKViaPointState *point in viaPoints) {
            NSString *string = [NSString stringWithFormat:@"Id:%d Distance:%d Time:%d",point.identifier,point.distance,point.estimatedTime];
            [array addObject:string];
        }
    }
    
    return array;
}

- (NSArray *)arrayOfStringsFromAdviceList:(NSArray *)adviceList {
    NSMutableArray *array = [NSMutableArray array];
    if (adviceList && adviceList.count > 0) {
        for (SKRouteAdvice *advice in adviceList) {
            NSString *identifier = [NSString stringWithFormat:@"Identifier:%d",advice.adviceID];
            NSString *string = [NSString stringWithFormat:@"TTD:%d DTD:%d DTA:%d",advice.timeToDestination, advice.distanceToDestination, advice.distanceToAdvice];
            NSString *string2 = [NSString stringWithFormat:@"TDA:%d", advice.timeToAdvice];
            NSString *string3 = [NSString stringWithFormat:@"Instr:%@", advice.adviceInstruction];
            NSString *string4 = [NSString stringWithFormat:@"Str.Name:%@", advice.streetName];
            NSString *string5 = [NSString stringWithFormat:@"Str.Type:%d Country Code:%@", advice.streetType,advice.countryCode];
            [array addObject:identifier];
            [array addObject:string];
            [array addObject:string2];
            [array addObject:string3];
            [array addObject:string4];
            [array addObject:string5];
        }
    }
    
    return array;
}

- (NSArray *)arrayOfStringsFromLocations:(NSArray *)locations {
    NSMutableArray *arr = [NSMutableArray array];
    
    for (CLLocation *location in locations) {
        NSString *string = [NSString stringWithFormat:@"Lat:%.5f Lon:%.5f %.1f",location.coordinate.latitude, location.coordinate.longitude,location.altitude];
        [arr addObject:string];
    }
    
    return arr;
}

- (void)configureMenuView {
    MenuSection *settingsSection = [self settingsSection];
    MenuSection *advancedSettingsSection = [self advancedSettingsSection];
    MenuSection *routeInformationSection = [self routeInformationSection];
    MenuSection *actionsSection = [self actionsSection];
    
    self.menuView.sections = @[settingsSection, advancedSettingsSection, routeInformationSection, actionsSection];
}

- (MenuSection *)settingsSection {
    __weak TestingRoutingViewController *weakSelf = self;
    
    self.startLatitudeItem = [MenuItem itemForTextWithTitle:@"Start Latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.startLatitude = item.floatValue;
    } editEndBlock:nil];
    self.startLatitudeItem.defaultValue = @(37.9667);
    
    self.startLongitudeItem = [MenuItem itemForTextWithTitle:@"Start Longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.startLongitude = item.floatValue;
    } editEndBlock:nil];
    self.startLongitudeItem.defaultValue = @(23.7166);
    
    MenuItem *startLongTapItem = [MenuItem itemForButtonWithTitle:@"Long Tap For Start Coord." selectionBlock:^(MenuItem *item) {
        weakSelf.longTapType = SKLongTapTypeStart;
    }];
    
    self.destinationLatitudeItem= [MenuItem itemForTextWithTitle:@"Destination Latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.destinationLatitude = item.floatValue;
    } editEndBlock:nil];
    self.destinationLatitudeItem.defaultValue = @(37.9667);
    
    self.destinationLongitudeItem = [MenuItem itemForTextWithTitle:@"Destination Longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.destinationLongitude = item.floatValue;
    } editEndBlock:nil];
    self.destinationLongitudeItem.defaultValue = @(23.7566);
    
    MenuItem *destLongTapItem = [MenuItem itemForButtonWithTitle:@"Long Tap For Dest Coord." selectionBlock:^(MenuItem *item) {
        weakSelf.longTapType = SKLongTapTypeEnd;
    }];
    
    MenuItem *numberOfRoutesItem = [MenuItem itemForTextWithTitle:@"Number Of Routes" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.numberOfRoutes = item.intValue;
    } editEndBlock:nil];
    numberOfRoutesItem.defaultValue = @(3);
    
    MenuSection *viaPointSection = [self viaPointSection];
    MenuItem *viaPointItem = [MenuItem itemForMenuTypeWithTitle:@"Via Points" sections:@[viaPointSection] selectionBlock:nil];
    
    NSArray *routeModeOptions = @[@(SKRouteCarShortest), @(SKRouteCarFastest), @(SKRouteCarEfficient), @(SKRoutePedestrian), @(SKRouteBicycleFastest), @(SKRouteBicycleShortest), @(SKRouteBicycleQuietest)];
    NSArray *routeModeStrings = @[@"CarShortest", @"CarFastest", @"CarEfficient", @"Pedestrian", @"BicycleFastest", @"BicycleShortest", @"BicycleQuietest"];
    
    MenuItem *routeModeItem = [MenuItem itemForOptionsWithTitle:@"Route Mode" uniqueID:nil options:routeModeOptions readableOptions:routeModeStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.routeMode = (SKRouteMode)item.intValue;
    }];
    routeModeItem.defaultValue = @(SKRouteCarEfficient);
    
    NSArray *routeConnectionModeOptions = @[@(SKRouteConnectionOnline), @(SKRouteConnectionOffline), @(SKRouteConnectionHybrid)];
    NSArray *routeConnectionModeStrings = @[@"Online", @"Offline", @"Hybrid"];
    
    MenuItem *routeConnectionModeItem = [MenuItem itemForOptionsWithTitle:@"Route Connection Mode" uniqueID:nil options:routeConnectionModeOptions readableOptions:routeConnectionModeStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.routeConnectionMode = (SKRouteConnectionMode)item.intValue;
    }];
    routeConnectionModeItem.defaultValue = @(SKRouteConnectionHybrid);
    
    MenuItem *shouldBeRenderedItem = [MenuItem itemForToggleWithTitle:@"Should Be Rendered" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.shouldBeRendered = item.boolValue;
    }];
    shouldBeRenderedItem.boolValue = YES;
    
    MenuSection *routeRestrictionsSection = [weakSelf routeRestrictionsSection];
    MenuItem *routeRestrictionsItem = [MenuItem itemForMenuTypeWithTitle:@"Route Restrictions" sections:@[routeRestrictionsSection] selectionBlock:nil];
    
    MenuItem *requestAdvicesItem = [MenuItem itemForToggleWithTitle:@"Request Advices" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.requestAdvices = item.boolValue;
    }];
    requestAdvicesItem.boolValue = YES;
    
    MenuItem *requestAdviceExtendedRoutePointsItem = [MenuItem itemForToggleWithTitle:@"Request Extended Route Points Info" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.requestExtendedRoutePointsInfo = item.boolValue;
    }];
    requestAdviceExtendedRoutePointsItem.boolValue = NO;
    
    MenuItem *requestCountryCodesItem = [MenuItem itemForToggleWithTitle:@"Request Country Codes" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.requestCountryCodes = item.boolValue;
    }];
    requestCountryCodesItem.boolValue = NO;
    
    MenuSection *settingsSection = [MenuSection sectionWithTitle:@"Settings" items:@[self.startLatitudeItem, self.startLongitudeItem, startLongTapItem,self.destinationLatitudeItem, self.destinationLongitudeItem, destLongTapItem, numberOfRoutesItem, viaPointItem, routeModeItem, routeConnectionModeItem, routeRestrictionsItem, shouldBeRenderedItem, requestAdvicesItem, requestAdviceExtendedRoutePointsItem, requestCountryCodesItem]];
    
    return settingsSection;
}

- (MenuSection *)routeInformationSection {
    __weak TestingRoutingViewController *weakSelf = self;
    
    NSString *routeIdString = [NSString stringWithFormat:@"Route Id: %d",weakSelf.routeInfo.routeID];
    self.routeIdItem = [MenuItem itemForTextWithTitle:routeIdString uniqueID:nil changeBlock:nil editEndBlock:nil];
    
    NSString *routeDistanceString = [NSString stringWithFormat:@"Distance: %d",weakSelf.routeInfo.distance];
    self.distanceItem = [MenuItem itemForTextWithTitle:routeDistanceString uniqueID:nil changeBlock:nil editEndBlock:nil];
    
    NSString *routeTimeString = [NSString stringWithFormat:@"Estimated Time: %d",weakSelf.routeInfo.estimatedTime];
    self.timeItem = [MenuItem itemForTextWithTitle:routeTimeString uniqueID:nil changeBlock:nil editEndBlock:nil];
    
    NSString *corridorDownloadedString = [NSString stringWithFormat:@"Corridor Downloaded: %@",[weakSelf stringFromBool:weakSelf.routeInfo.corridorIsDownloaded]];
    self.corridorDownloadedItem = [MenuItem itemForTextWithTitle:corridorDownloadedString uniqueID:nil changeBlock:nil editEndBlock:nil];
    
    NSString *calculatedAfterReroutingString = [NSString stringWithFormat:@"Calculated After Rerouting: %@", [weakSelf stringFromBool:weakSelf.routeInfo.distance]];
    self.calculatedAfterReroutingItem = [MenuItem itemForTextWithTitle:calculatedAfterReroutingString uniqueID:nil changeBlock:nil editEndBlock:nil];
    
    NSString *containsHighwaysString = [NSString stringWithFormat:@"Contains Highways: %@",[weakSelf stringFromBool:weakSelf.routeInfo.distance]];
    self.containsHighwaysItem = [MenuItem itemForTextWithTitle:containsHighwaysString uniqueID:nil changeBlock:nil editEndBlock:nil];
    
    NSString *containsTollRoadsString = [NSString stringWithFormat:@"Contains Toll Roads: %@",[weakSelf stringFromBool:weakSelf.routeInfo.distance]];
    self.containsTollRoadsItem = [MenuItem itemForTextWithTitle:containsTollRoadsString uniqueID:nil changeBlock:nil editEndBlock:nil];
    
    NSString *containsFerryLinesString = [NSString stringWithFormat:@"Contains Ferry Lines: %@",[weakSelf stringFromBool:weakSelf.routeInfo.distance]];
    self.containsFerryLinesItem = [MenuItem itemForTextWithTitle:containsFerryLinesString uniqueID:nil changeBlock:nil editEndBlock:nil];
    
    self.viaPointsOnRouteItem = [MenuItem itemForOptionsWithTitle:@"Via Points On Route" uniqueID:nil options:nil readableOptions:weakSelf.viaPointsArray changeBlock:nil];
    self.adviceListItem = [MenuItem itemForOptionsWithTitle:@"Advice List" uniqueID:nil options:nil readableOptions:weakSelf.adviceList changeBlock:nil];
    self.countryCodesItem = [MenuItem itemForOptionsWithTitle:@"Country Codes" uniqueID:nil options:nil readableOptions:weakSelf.countriesArray changeBlock:nil];
    self.coordinatesItem = [MenuItem itemForOptionsWithTitle:@"Coordinates" uniqueID:nil options:nil readableOptions:weakSelf.coordinatesArray changeBlock:nil];
    self.coordinatesItem.numberOfLines = 2;
    
    MenuSection *section = [MenuSection sectionWithTitle:@"Route Information" items:@[self.routeIdItem, self.distanceItem, self.timeItem, self.corridorDownloadedItem, self.calculatedAfterReroutingItem, self.containsTollRoadsItem, self.containsHighwaysItem, self.containsFerryLinesItem, self.viaPointsOnRouteItem, self.adviceListItem, self.coordinatesItem, self.countryCodesItem]];
    
    return section;
}

- (MenuSection *)advancedSettingsSection {
    __weak TestingRoutingViewController *weakSelf = self;
    
    MenuItem *useSlopesItem = [MenuItem itemForToggleWithTitle:@"Use Slopes" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.useSlopes = item.boolValue;
    }];
    useSlopesItem.boolValue = NO;
    
    MenuItem *downloadRouteCorirdorItem = [MenuItem itemForToggleWithTitle:@"Download Route Corridor" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.downloadRouteCorridor = item.boolValue;
    }];
    downloadRouteCorirdorItem.boolValue = YES;
    
    MenuItem *routeCorridorWidthItem = [MenuItem itemForTextWithTitle:@"Route Corridor Width" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.routeCorridorWidth = item.intValue;
    } editEndBlock:nil];
    routeCorridorWidthItem.defaultValue = @(2000);
    
    MenuItem *waitForCorridorDownloadItem = [MenuItem itemForToggleWithTitle:@"Wait Corridor Download" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.waitForCorridorDownload = item.boolValue;
    }];
    waitForCorridorDownloadItem.boolValue = NO;
    
    MenuItem *requestAdvicesItem = [MenuItem itemForToggleWithTitle:@"Destination Is Point" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.destinationIsPoint = item.boolValue;
    }];
    requestAdvicesItem.boolValue = YES;
    
    MenuSection *settingsSection = [MenuSection sectionWithTitle:@"Advanced Settings" items:@[useSlopesItem, downloadRouteCorirdorItem, routeCorridorWidthItem, waitForCorridorDownloadItem, requestAdvicesItem]];
    
    return settingsSection;
}

- (MenuSection *)actionsSection {
    __weak TestingRoutingViewController *weakSelf = self;
    
    MenuItem *calculateRouteItem = [MenuItem itemForButtonWithTitle:@"Calculate Route" selectionBlock:^(MenuItem *item) {
        [weakSelf calculateRoute];
    }];
    
    MenuItem *topItem = [MenuItem itemForTextWithTitle:@"Top Inset" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.zoomInsetTop = item.floatValue;
    } editEndBlock:nil];
    topItem.defaultValue = @(0.0);
    
    MenuItem *leftItem = [MenuItem itemForTextWithTitle:@"Left Inset" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.zoomInsetLeft = item.floatValue;
    } editEndBlock:nil];
    leftItem.defaultValue = @(0.0);
    
    MenuItem *bottomItem = [MenuItem itemForTextWithTitle:@"Bottom Inset" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.zoomInsetBottom = item.floatValue;
    } editEndBlock:nil];
    bottomItem.defaultValue = @(0.0);
    
    MenuItem *rightItem = [MenuItem itemForTextWithTitle:@"Right Inset" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.zoomInsetRight = item.floatValue;
    } editEndBlock:nil];
    rightItem.defaultValue = @(0.0);
    
    MenuItem *zoomToRouteItem = [MenuItem itemForButtonWithTitle:@"Zoom To Route" selectionBlock:^(MenuItem *item) {
        [weakSelf zoomToRoute];
    }];
    
    MenuItem *distanceItem = [MenuItem itemForTextWithTitle:@"Block Road Distance" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.blockRoadDistance = item.intValue;
    } editEndBlock:nil];
    distanceItem.defaultValue = @(20);
    
    MenuItem *blockRoadItem = [MenuItem itemForButtonWithTitle:@"Block Road" selectionBlock:^(MenuItem *item) {
        [weakSelf blockRoad];
    }];
    
    MenuItem *unblockRoadItem = [MenuItem itemForButtonWithTitle:@"Unlock Road" selectionBlock:^(MenuItem *item) {
        [weakSelf unblockRoad];
    }];
    
    MenuItem *routeToCacheIdItem = [MenuItem itemForTextWithTitle:@"Save Route ID" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.saveRouteId = item.intValue;
    } editEndBlock:nil];
    routeToCacheIdItem.intValue = 1;
    
    MenuItem *routeToCacheItem = [MenuItem itemForButtonWithTitle:@"Save Route To Cache" selectionBlock:^(MenuItem *item) {
        [weakSelf saveRouteToCache];
    }];
    
    MenuItem *routeFromCacheIdItem = [MenuItem itemForTextWithTitle:@"Load Route ID" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.loadRouteId = item.intValue;
    } editEndBlock:nil];
    routeFromCacheIdItem.intValue = 1;
    
    MenuItem *routeFromCacheItem = [MenuItem itemForButtonWithTitle:@"Load Route From Cache" selectionBlock:^(MenuItem *item) {
        [weakSelf loadRouteFromCache];
    }];
    
    MenuItem *clearAllRoutesFromCacheItem = [MenuItem itemForButtonWithTitle:@"Clear All Routes From Cache" selectionBlock:^(MenuItem *item) {
        [weakSelf clearAllRoutesFromCache];
    }];
    
    MenuItem *getAdviceListItem = [MenuItem itemForButtonWithTitle:@"Get Advice List" selectionBlock:^(MenuItem *item) {
        [weakSelf getAdviceList];
    }];
    
    MenuItem *routeCoordinatesForRouteWithIDItem = [MenuItem itemForButtonWithTitle:@"Route Coordinates From Route With ID" selectionBlock:^(MenuItem *item) {
        [weakSelf routeCoordinatesForRoute];
    }];
    
    MenuItem *requestCountryCodesItem = [MenuItem itemForButtonWithTitle:@"Request Country Codes" selectionBlock:^(MenuItem *item) {
        [weakSelf routeCountriesForRoute];
    }];
    
    MenuItem *clearRoutesItem = [MenuItem itemForButtonWithTitle:@"Clear Routes" selectionBlock:^(MenuItem *item) {
        [weakSelf clearRoute];
    }];
    
    MenuSection *actionsSection = [MenuSection sectionWithTitle:@"Actions" items:@[calculateRouteItem, topItem, leftItem, bottomItem, rightItem ,zoomToRouteItem, distanceItem, blockRoadItem, unblockRoadItem, routeToCacheIdItem, routeToCacheItem, routeFromCacheIdItem, routeFromCacheItem, clearAllRoutesFromCacheItem, getAdviceListItem, routeCoordinatesForRouteWithIDItem, requestCountryCodesItem, clearRoutesItem]];
    
    return actionsSection;
}

- (MenuSection *)viaPointSection {
    __weak TestingRoutingViewController *weakSelf = self;
    
    MenuItem *viaPointIdentifier = [MenuItem itemForTextWithTitle:@"Identifier" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.viaPointIdentifier = item.intValue;
    } editEndBlock:nil];
    viaPointIdentifier.defaultValue = @(123);
    
    self.viaPointLatitudeItem = [MenuItem itemForTextWithTitle:@"Latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.viaPointLatitude = [(NSNumber*)newValue floatValue];
    } editEndBlock:nil];
    self.viaPointLatitudeItem.defaultValue = @(37.9367);
    
    self.viaPointLongitudeItem = [MenuItem itemForTextWithTitle:@"Longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.viaPointLongitude = [(NSNumber*)newValue floatValue];
    } editEndBlock:nil];
    self.viaPointLongitudeItem.defaultValue = @(23.5166);
    
    MenuItem *viaPointLongTapItem = [MenuItem itemForButtonWithTitle:@"Long Tap For Coordinate" selectionBlock:^(MenuItem *item) {
        weakSelf.longTapType = SKLongTapTypeViaPoint;
    }];
    
    MenuItem *addViaPointItem = [MenuItem itemForButtonWithTitle:@"Add Via Point" selectionBlock:^(MenuItem *item) {
        [weakSelf addViaPoint];
    }];
    
    MenuItem *afterPointIdentifier = [MenuItem itemForTextWithTitle:@"After Via Point Identifier" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.afterViaPointIdentifier = item.intValue;
    } editEndBlock:nil];
    afterPointIdentifier.defaultValue = @(0);
    
    MenuItem *addAfterViaPointItem = [MenuItem itemForButtonWithTitle:@"Add Via Point" selectionBlock:^(MenuItem *item) {
        [weakSelf addAfterViaPoint];
    }];
    
    MenuItem *removeViaPointIdentifier = [MenuItem itemForTextWithTitle:@"Identifier" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.removeViaPointIdentifier = item.intValue;
    } editEndBlock:nil];
    removeViaPointIdentifier.defaultValue = @(0);
    
    MenuItem *removeViaPointItem = [MenuItem itemForButtonWithTitle:@"Remove Via Point" selectionBlock:^(MenuItem *item) {
        [weakSelf removeViaPoint];
    }];
    
    MenuSection *section = [MenuSection sectionWithTitle:@"Via Point" items:@[viaPointIdentifier, self.viaPointLatitudeItem, self.viaPointLongitudeItem,viaPointLongTapItem ,addViaPointItem, afterPointIdentifier, addAfterViaPointItem, removeViaPointIdentifier, removeViaPointItem]];
    
    return section;
}

- (MenuSection *)routeRestrictionsSection {
    __weak TestingRoutingViewController *weakSelf = self;
    
    MenuItem *avoidTollRoadsItem = [MenuItem itemForToggleWithTitle:@"Avoid Toll Roads" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKRouteRestrictions restrictions = weakSelf.routeRestrictions;
        restrictions.avoidTollRoads = item.boolValue;
        
        weakSelf.routeRestrictions = restrictions;
    }];
    avoidTollRoadsItem.boolValue = NO;
    
    MenuItem *avoidHighwaysItem = [MenuItem itemForToggleWithTitle:@"Avoid Highways" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKRouteRestrictions restrictions = weakSelf.routeRestrictions;
        restrictions.avoidHighways = item.boolValue;
        
        weakSelf.routeRestrictions = restrictions;
    }];
    avoidHighwaysItem.boolValue = NO;
    
    MenuItem *avoidFerryLinesItem = [MenuItem itemForToggleWithTitle:@"Avoid Ferry Lines" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKRouteRestrictions restrictions = weakSelf.routeRestrictions;
        restrictions.avoidFerryLines = item.boolValue;
        
        weakSelf.routeRestrictions = restrictions;
    }];
    avoidFerryLinesItem.boolValue = NO;
    
    MenuItem *avoidBicycleWalkItem = [MenuItem itemForToggleWithTitle:@"Avoid Bicycle Walk" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKRouteRestrictions restrictions = weakSelf.routeRestrictions;
        restrictions.avoidBicycleWalk = item.boolValue;
        
        weakSelf.routeRestrictions = restrictions;
    }];
    avoidBicycleWalkItem.boolValue = NO;
    
    MenuItem *avoidBicycleCarryItem = [MenuItem itemForToggleWithTitle:@"Avoid Bicycle Carry" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKRouteRestrictions restrictions = weakSelf.routeRestrictions;
        restrictions.avoidBicycleCarry = item.boolValue;
        
        weakSelf.routeRestrictions = restrictions;
    }];
    avoidBicycleCarryItem.boolValue = NO;
    
    MenuSection *section = [MenuSection sectionWithTitle:@"Route Restrictions" items:@[avoidTollRoadsItem, avoidHighwaysItem, avoidFerryLinesItem, avoidBicycleWalkItem, avoidBicycleCarryItem]];
    
    return section;
}

#pragma mark - SKMapViewDelegate methods

- (void)mapView:(SKMapView *)mapView didLongTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    switch (self.longTapType) {
        case SKLongTapTypeNone:
            break;
            
        case SKLongTapTypeStart:
            self.startLatitude = coordinate.latitude;
            self.startLatitude = coordinate.longitude;
            self.startLatitudeItem.floatValue = coordinate.latitude;
            self.startLongitudeItem.floatValue = coordinate.longitude;
            
            [self.startLatitudeItem fireRefresh];
            [self.startLongitudeItem fireRefresh];
            
            [self addStartCoordinateAnnotation];
            
            break;
            
        case SKLongTapTypeEnd:
            self.destinationLatitude = coordinate.latitude;
            self.destinationLongitude = coordinate.longitude;
            self.destinationLatitudeItem.floatValue = coordinate.latitude;
            self.destinationLongitudeItem.floatValue = coordinate.longitude;
            
            [self.destinationLatitudeItem fireRefresh];
            [self.destinationLongitudeItem fireRefresh];
            
            [self addDestinationCoordinateAnnotation];
            
            break;
            
        case SKLongTapTypeViaPoint:
            self.viaPointLatitude = coordinate.latitude;
            self.viaPointLongitude = coordinate.longitude;
            self.viaPointLatitudeItem.floatValue = coordinate.latitude;
            self.viaPointLongitudeItem.floatValue = coordinate.longitude;
            
            [self.viaPointLatitudeItem fireRefresh];
            [self.viaPointLongitudeItem fireRefresh];
            
            [self addViaPointCoordinateAnnotation];
            
            break;
            
        default:
            break;
    }
    self.longTapType = SKLongTapTypeNone;
}

#pragma mark - SKRoutingDelegate methods

- (void)routingService:(SKRoutingService *)routingService didFinishRouteCalculationWithInfo:(SKRouteInformation *)routeInformation {
    if (routeInformation) {
        self.routeInfo = routeInformation;
        
        self.routeIdItem.stringValue = [NSString stringWithFormat:@"Route Id: %d",self.routeInfo.routeID];
        self.distanceItem.stringValue = [NSString stringWithFormat:@"Distance: %d",self.routeInfo.distance];
        self.timeItem.stringValue = [NSString stringWithFormat:@"Estimated Time: %d",self.routeInfo.estimatedTime];
        self.corridorDownloadedItem.stringValue = [NSString stringWithFormat:@"Corridor Downloaded: %@",[self stringFromBool:self.routeInfo.corridorIsDownloaded]];
        self.calculatedAfterReroutingItem.stringValue = [NSString stringWithFormat:@"Calculated After Rerouting: %@", [self stringFromBool:self.routeInfo.calculatedAfterRerouting]];
        self.containsHighwaysItem.stringValue = [NSString stringWithFormat:@"Contains Highways: %@",[self stringFromBool:self.routeInfo.containsHighways]];
        self.containsTollRoadsItem.stringValue = [NSString stringWithFormat:@"Contains Toll Roads: %@",[self stringFromBool:self.routeInfo.containsTollRoads]];
        self.containsFerryLinesItem.stringValue = [NSString stringWithFormat:@"Contains Ferry Lines: %@",[self stringFromBool:self.routeInfo.containsFerryLines]];
        
        NSArray *viaPoints = [self arrayOfStringsFromViaPoints:routeInformation.viaPointsOnRoute];
        if (viaPoints) {
            self.viaPointsOnRouteItem.readableOptions = viaPoints;
            self.viaPointsOnRouteItem.itemOptions = viaPoints;
        }
        
        [self.routeIdItem fireRefresh];
        [self.distanceItem fireRefresh];
        [self.timeItem fireRefresh];
        [self.corridorDownloadedItem fireRefresh];
        [self.calculatedAfterReroutingItem fireRefresh];
        [self.containsHighwaysItem fireRefresh];
        [self.containsTollRoadsItem fireRefresh];
        [self.containsFerryLinesItem fireRefresh];
        [self.viaPointsOnRouteItem fireRefresh];
        
        [[SKRoutingService sharedInstance] zoomToRouteWithInsets:UIEdgeInsetsZero duration:500];
    }
}

- (void)routingService:(SKRoutingService *)routingService didFailWithErrorCode:(SKRoutingErrorCode)errorCode {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Route Calculation Failed" message:[NSString stringWithFormat:@"Failed with error code: %ld",(long)errorCode] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alert show];
}

@end
