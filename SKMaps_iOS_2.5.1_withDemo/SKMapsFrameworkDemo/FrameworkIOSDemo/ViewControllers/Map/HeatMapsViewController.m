//
//  HeatMapsViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "HeatMapsViewController.h"
#import <SKMaps/SKMaps.h>

@interface HeatMapsViewController ()<SKMapViewDelegate>
@property(nonatomic,strong) SKMapView *mapView;
@property(nonatomic,strong) NSArray *datasource;
@end


@implementation HeatMapsViewController

#pragma mark - Lifecycle

- (id)initWithDatasource:(NSArray*)datasource
{
    self = [super init];
    if (!self) return nil;
    
    self.datasource = datasource;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //adding the map
    self.mapView = [[SKMapView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(52.5233, 13.4127);
    region.zoomLevel = 17;
    self.mapView.visibleRegion = region;
    
    [self.mapView showHeatMapWithPOIType:self.datasource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapView.settings.showCurrentPosition = NO;
    self.mapView.settings.showCompass = NO;
    
    [self.mapView clearHeatMap];
}

#pragma mark - SKMapViewDelegate

- (void)mapViewDidSelectCompass:(SKMapView*)mapView
{
    self.mapView.settings.followUserPosition = YES;
    self.mapView.settings.headingMode = SKHeadingModeRotatingHeading;
    
    [self.mapView animateToBearing:0.0f];
    self.mapView.settings.showCompass = NO;
}

- (void)mapView:(SKMapView *)mapView didRotateWithAngle:(float)angle
{
    self.mapView.settings.compassOffset = CGPointMake(0.0f, 64.0f);
    self.mapView.settings.showCompass = YES;
}

- (void)mapView:(SKMapView *)mapView didPanFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    self.mapView.settings.followUserPosition = NO;
    self.mapView.settings.headingMode = SKHeadingModeNone;
    
    [self.mapView animateToBearing:0.0f];
    self.mapView.settings.showCompass = NO;
}

@end
