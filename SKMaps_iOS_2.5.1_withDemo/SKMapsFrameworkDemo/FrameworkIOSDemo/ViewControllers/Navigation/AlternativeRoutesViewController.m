//
//  AlternativeRoutesViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "AlternativeRoutesViewController.h"
#import <SKMaps/SKMaps.h>

@interface AlternativeRoutesViewController ()<SKRoutingDelegate>
@property(nonatomic,strong) SKMapView *mapView;
@property(nonatomic,assign) int nrOfRoutesAvailable;
@property(nonatomic,strong) NSMutableArray *routes;
@property(nonatomic, strong) UISegmentedControl *alternativeRoutesSegControl;
@end

@implementation AlternativeRoutesViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView = [[SKMapView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    //setting the visible region
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(52.5233, 13.4127);
    region.zoomLevel = 3;
    self.mapView.visibleRegion = region;
    
    [self addSegmentedControl];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    SKRouteSettings* route = [[SKRouteSettings alloc]init];
    route.startCoordinate=CLLocationCoordinate2DMake(37.9667, 23.7167);
    route.destinationCoordinate=CLLocationCoordinate2DMake(37.9677, 23.7567);
    route.maximumReturnedRoutes = 3;
    route.routeMode = SKRouteCarEfficient;
    
    [SKRoutingService sharedInstance].routingDelegate = self;
    [SKRoutingService sharedInstance].mapView = self.mapView;
    [[SKRoutingService sharedInstance] calculateRoute:route];
    
    //add annotation for start coordinate
    SKAnnotation *startCoordinateAnnotation = [SKAnnotation annotation];
    startCoordinateAnnotation.identifier = 9998;
    startCoordinateAnnotation.annotationType = SKAnnotationTypeGreen;
    startCoordinateAnnotation.location = route.startCoordinate;
    [self.mapView addAnnotation:startCoordinateAnnotation withAnimationSettings:nil];
    
    //add destination flag annotation
    SKAnnotation *destinationFlagAnnotation = [SKAnnotation annotation];
    destinationFlagAnnotation.identifier = 9999;
    destinationFlagAnnotation.annotationType = SKAnnotationTypeDestinationFlag;
    destinationFlagAnnotation.location = route.destinationCoordinate;
    [self.mapView addAnnotation:destinationFlagAnnotation withAnimationSettings:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Clear routes
    [[SKRoutingService sharedInstance] clearCurrentRoutes];
}

#pragma mark - UI

- (void)addSegmentedControl
{
    self.alternativeRoutesSegControl = [[UISegmentedControl alloc]initWithItems:@[@"-",@"-",@"-"]];
    self.alternativeRoutesSegControl.frame=CGRectMake(0.0f, 80.0f, CGRectGetWidth(self.view.frame), 30.0f);
    [self.alternativeRoutesSegControl addTarget:self action:@selector(alternativeRouteChanged:) forControlEvents:UIControlEventValueChanged];
    self.alternativeRoutesSegControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.alternativeRoutesSegControl];
    
    self.routes = [NSMutableArray array];
    self.nrOfRoutesAvailable=0;
    for(int i=0;i<self.alternativeRoutesSegControl.numberOfSegments;i++)
    {
        [self.alternativeRoutesSegControl setEnabled:NO forSegmentAtIndex:i];
    }
}

-(void)alternativeRouteChanged:(UISegmentedControl*)control
{
    int index = (int)control.selectedSegmentIndex;
    SKRouteInformation *routeInformation = (SKRouteInformation*)[self.routes objectAtIndex:index];
    [[SKRoutingService sharedInstance] setMainRouteId:routeInformation.routeID];
}

#pragma mark - SKRoutingDelegate

-(void)routingService:(SKRoutingService *)routingService didFinishRouteCalculationWithInfo:(SKRouteInformation *)routeInformation
{
    NSLog(@"Route is calculated with id %d", routeInformation.routeID);
    
    [self.routes addObject:routeInformation];
    [self.alternativeRoutesSegControl setTitle:[NSString stringWithFormat:@"%d",self.nrOfRoutesAvailable] forSegmentAtIndex:self.nrOfRoutesAvailable];
    [self.alternativeRoutesSegControl setEnabled:YES forSegmentAtIndex:self.nrOfRoutesAvailable];
    
    if(self.nrOfRoutesAvailable==0)
    {
        self.alternativeRoutesSegControl.selectedSegmentIndex=0;
        [[SKRoutingService sharedInstance]zoomToRouteWithInsets:UIEdgeInsetsZero duration:500];
    }
    self.nrOfRoutesAvailable++;
}

-(void)routingServiceDidFailRouteCalculation:(SKRoutingService *)routingService
{
    NSLog(@"Route calculation failed.");
}

@end
