//
//  POITrackerViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "POITrackerViewController.h"
#import <SKMaps/SKMaps.h>

static NSString* const kLogFileName = @"Seattle";
static int const kRadius = 5000;//meters
static float const kRefreshMargin = 0.1;
static int const kTrackablePOITypeIncident = 1000;

@interface POITrackerViewController ()<SKMapViewDelegate,SKRoutingDelegate,SKNavigationDelegate,SKPOITrackerDataSource,SKPOITrackerDelegate>

@property(nonatomic,strong) SKMapView *mapView;
@property(nonatomic,strong) SKPOITracker *poiTracker;
@property(nonatomic,strong) NSArray *trackablePOIs;

@end

@implementation POITrackerViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.mapView = [[SKMapView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    //set map region
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(48.207407, 16.376916);
    region.zoomLevel = 17.0f;
    self.mapView.visibleRegion = region;
    self.mapView.settings.followUserPosition = YES;
    self.mapView.settings.headingMode = SKHeadingModeRoute;
    self.trackablePOIs = [self trackablePOIs];
    
    //registering to routing & navigation related callbacks
    [SKRoutingService sharedInstance].navigationDelegate = self;
    [SKRoutingService sharedInstance].routingDelegate = self;
    [SKRoutingService sharedInstance].mapView = self.mapView;
     [[SKRoutingService sharedInstance] setAdvisorConfigurationSettings:[SKAdvisorSettings advisorSettings]];
    
    [self startNavigationFromLog];
    [self startPOITracking];
    [self addAnnotations];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[SKRoutingService sharedInstance]stopNavigation];
    [self.poiTracker stopPOITracker];
    [self removeAnnotations];
}

#pragma mark - SKPOITracker

-(void)startPOITracking
{
    SKTrackablePOIRule *rule = [SKTrackablePOIRule trackablePOIRule];
    rule.routeDistance = 1500;
    rule.aerialDistance = 3000;
    
    self.poiTracker = [SKPOITracker sharedInstance];
    self.poiTracker.dataSource = self;
    self.poiTracker.delegate = self;
    [self.poiTracker startPOITrackerWithRadius:kRadius refreshMargin:kRefreshMargin forPOITypes:@[@(kTrackablePOITypeIncident)]];;
    [self.poiTracker setRule:rule forPOIType:kTrackablePOITypeIncident];
}

#pragma mark - SKPOITrakcerDataSource

-(NSArray*)poiTracker:(SKPOITracker *)poiTracker trackablePOIsAroundLocation:(CLLocationCoordinate2D)location inRadius:(int)radius withType:(int)poiType
{
    return self.trackablePOIs;
}

#pragma mark - SKPOITrackerDelegate

- (void)poiTracker:(SKPOITracker *)poiTracker didDectectPOIs:(NSArray *)detectedPOIs withType:(int)type
{
    [detectedPOIs enumerateObjectsUsingBlock:^(SKDetectedPOI *detectedPOI, NSUInteger index, BOOL *stop){
        NSLog(@"Detected: %@",[detectedPOI description]);
    }];
}

#pragma mark - Private methods

-(void)startNavigationFromLog
{
    NSString *logFilePath = [[NSBundle mainBundle] pathForResource:kLogFileName ofType:@"log"];
    [[SKPositionerService sharedInstance] startPositionReplayFromLog:logFilePath];
    [[SKPositionerService sharedInstance] setPositionReplayRate:2.0];
    
    SKNavigationSettings *navigationSettings = [SKNavigationSettings navigationSettings];
    navigationSettings.navigationType = SKNavigationTypeSimulationFromLogFile;
    [[SKRoutingService sharedInstance] startNavigationWithSettings:navigationSettings];
}

-(NSArray*)trackablePOIs
{    
    SKTrackablePOI *trackablePOI1 = [SKTrackablePOI trackablePOI];
    trackablePOI1.poiID = 0;
    trackablePOI1.type = kTrackablePOITypeIncident;
    trackablePOI1.coordinate = CLLocationCoordinate2DMake(47.643421, -122.202824);
    
    SKTrackablePOI *trackablePOI2 = [SKTrackablePOI trackablePOI];
    trackablePOI2.poiID = 1;
    trackablePOI2.type = kTrackablePOITypeIncident;
    trackablePOI2.coordinate = CLLocationCoordinate2DMake(47.641498, -122.197208);

    
    SKTrackablePOI *trackablePOI3 = [SKTrackablePOI trackablePOI];
    trackablePOI3.poiID = 2;
    trackablePOI3.type = kTrackablePOITypeIncident;
    trackablePOI3.coordinate = CLLocationCoordinate2DMake(47.632820, -122.189305);
    
    SKTrackablePOI *trackablePOI4 = [SKTrackablePOI trackablePOI];
    trackablePOI4.poiID = 3;
    trackablePOI4.type = kTrackablePOITypeIncident;
    trackablePOI4.coordinate = CLLocationCoordinate2DMake(47.629637, -122.170254);
    
    SKTrackablePOI *trackablePOI5 = [SKTrackablePOI trackablePOI];
    trackablePOI5.poiID = 4;
    trackablePOI5.type = kTrackablePOITypeIncident;
    trackablePOI5.coordinate = CLLocationCoordinate2DMake(47.643981, -122.134178);
    
    return @[trackablePOI1,trackablePOI2,trackablePOI3,trackablePOI4,trackablePOI5];
}

-(void)addAnnotations
{
    [self.trackablePOIs enumerateObjectsUsingBlock:^(SKTrackablePOI *poi,NSUInteger index,BOOL *stop){
        SKAnnotation *annotation = [SKAnnotation annotation];
        annotation.identifier = poi.poiID;
        annotation.location = poi.coordinate;
        annotation.annotationType = SKAnnotationTypeMarker;
        
        SKAnimationSettings *animationSettings = [SKAnimationSettings animationSettings];
        [self.mapView addAnnotation:annotation withAnimationSettings:animationSettings];
    }];
}

-(void)removeAnnotations
{
    [self.trackablePOIs enumerateObjectsUsingBlock:^(SKTrackablePOI *poi,NSUInteger index,BOOL *stop){
        SKAnnotation *annotation = [SKAnnotation annotation];
        annotation.identifier = poi.poiID;
        [self.mapView removeAnnotationWithID:annotation.identifier];
    }];
}

@end
