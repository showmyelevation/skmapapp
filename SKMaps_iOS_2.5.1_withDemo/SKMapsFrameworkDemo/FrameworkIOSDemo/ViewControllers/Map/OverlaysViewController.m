//
//  OverlaysViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "OverlaysViewController.h"
#import <SKMaps/SKMaps.h>

@interface OverlaysViewController ()
@property(nonatomic,strong) SKMapView *mapView;
@end

@implementation OverlaysViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //display the map
    self.mapView = [[SKMapView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    //set the map region
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(52.5233, 13.4127);
    region.zoomLevel = 17;
    self.mapView.visibleRegion = region;
    
    //add a circle overlay
    SKCircle *circle = [SKCircle circle];
    circle.identifier = 1;
    circle.centerCoordinate = CLLocationCoordinate2DMake(52.5263, 13.4087);
    circle.radius = 100.0f;
    circle.fillColor = [UIColor redColor];
    circle.strokeColor = [UIColor blueColor];
    circle.isMask = NO;
    [self.mapView addCircle:circle];
    
    //add a rhombus overlay with dotted border
    CLLocation *rhombusVertex1 = [[CLLocation alloc]initWithLatitude:52.5253 longitude:13.4092];
    CLLocation *rhombusVertex2 = [[CLLocation alloc]initWithLatitude:52.5233 longitude:13.4077];
    CLLocation *rhombusVertex3 = [[CLLocation alloc]initWithLatitude:52.5213 longitude:13.4092];
    CLLocation *rhombusVertex4 = [[CLLocation alloc]initWithLatitude:52.5233 longitude:13.4117];
    SKPolygon *rhombus = [SKPolygon polygon];
    rhombus.identifier = 2;
    rhombus.coordinates = @[rhombusVertex1, rhombusVertex2, rhombusVertex3, rhombusVertex4, rhombusVertex1];
    rhombus.fillColor = [UIColor blueColor];
    rhombus.strokeColor = [UIColor greenColor];
    rhombus.borderWidth = 5;
    rhombus.borderDotsSize = 20;
    rhombus.borderDotsSpacingSize = 5;
    rhombus.isMask = NO;
    [self.mapView addPolygon:rhombus];
    
    //adding a polyline with the same coordinates as the polygon
    SKPolyline *polyline = [SKPolyline polyline];
    polyline.identifier = 3;
    polyline.coordinates = @[rhombusVertex1, rhombusVertex2, rhombusVertex3, rhombusVertex4];
    polyline.fillColor = [UIColor redColor];
    polyline.lineWidth = 10;
    polyline.backgroundLineWidth = 2;
    polyline.borderDotsSize = 20;
    polyline.borderDotsSpacingSize = 5;
    [self.mapView addPolyline:polyline];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //remove all the overlays from the map
    [self.mapView clearAllOverlays];
    
}

#pragma mark - Overlays

-(void)addCircles
{
    //adds a circle on the map without border
    SKCircle *circle = [SKCircle circle];
    circle.identifier = 4;
    circle.centerCoordinate = CLLocationCoordinate2DMake(52.5233 + 0.003, 13.4127 - 0.004);
    circle.radius = 100;
    circle.fillColor = [UIColor colorWithRed:244/255.0 green:71/255.0 blue:140/255.0 alpha:0.4];
    circle.strokeColor = [UIColor colorWithRed:244/255.0 green:71/255.0 blue:140/255.0 alpha:0.7];;
    circle.isMask = NO;
    [self.mapView addCircle:circle];
    
    //adds a masked circle on the map with solid border
    SKCircle *maskedCircle = [SKCircle circle];
    circle.identifier = 5;
    maskedCircle.centerCoordinate = CLLocationCoordinate2DMake(52.5233 - 0.002, 13.4127 + 0.002);
    maskedCircle.radius = 100;
    maskedCircle.fillColor = [UIColor colorWithRed:255/255.0 green:117/255.0 blue:15/255.0 alpha:0.5];
    maskedCircle.strokeColor = [UIColor colorWithRed:255/255.0 green:117/255.0 blue:15/255.0 alpha:0.8];
    maskedCircle.borderWidth = 5;
    maskedCircle.isMask = YES;
    maskedCircle.maskedObjectScale = 3;
    [self.mapView addCircle:maskedCircle];
}

-(void)addPolygons
{
    //adding a masked triangle overlay without border
    CLLocation *triangleVertexCoordinate1 = [[CLLocation alloc]initWithLatitude:52.5233 + 0.002 longitude:13.4127 + 0.002];
    CLLocation *triangleVertexCoordinate2 = [[CLLocation alloc]initWithLatitude:52.5233 + 0.0028 longitude:13.4127 + 0.0025];
    CLLocation *triangleVertexCoordinate3 = [[CLLocation alloc]initWithLatitude:52.5233 + 0.002 longitude:13.4127 + 0.003];
    NSArray *polygonCoordinates = [NSArray arrayWithObjects:triangleVertexCoordinate1,triangleVertexCoordinate2,triangleVertexCoordinate3, nil];
    
    SKPolygon *triangle = [SKPolygon polygon];
    triangle.identifier = 6;
    triangle.coordinates = polygonCoordinates;
    triangle.fillColor = [UIColor colorWithRed:39/255.0 green:222/255.0 blue:61/255.0 alpha:0.5];
    triangle.borderWidth = 5;
    triangle.isMask = YES;
    triangle.maskedObjectScale = 5;
    [self.mapView addPolygon:triangle];
   
    //add a rhombus overlay with dotted border
    CLLocation *rhombusVertexCoordinate1 = [[CLLocation alloc]initWithLatitude:52.5233 + 0.002 longitude:13.4127 - 0.0035];
    CLLocation *rhombusVertexCoordinate2 = [[CLLocation alloc]initWithLatitude:52.5233  longitude:13.4127 - 0.005];
    CLLocation *rhombusVertexCoordinate3 = [[CLLocation alloc]initWithLatitude:52.5233 - 0.002 longitude:13.4127 - 0.0035];
    CLLocation *rhombusVertexCoordinate4 = [[CLLocation alloc]initWithLatitude:52.5233 longitude:13.4127 - 0.001];
    NSArray *maskedPolygonCoordinates = [NSArray arrayWithObjects:rhombusVertexCoordinate1,rhombusVertexCoordinate2,rhombusVertexCoordinate3,rhombusVertexCoordinate4, nil];
    
    SKPolygon *rhombus = [SKPolygon polygon];
    rhombus.identifier = 7;
    rhombus.coordinates = maskedPolygonCoordinates;
    rhombus.fillColor = [UIColor colorWithRed:65/255.0 green:145/255.0 blue:255/255.0 alpha:0.5];
    rhombus.strokeColor = [UIColor colorWithRed:65/255.0 green:145/255.0 blue:255/255.0 alpha:0.8];
    rhombus.borderWidth = 5;
    rhombus.borderDotsSize = 20;
    rhombus.borderDotsSpacingSize = 5;
    rhombus.isMask = NO;
    [self.mapView addPolygon:rhombus];
}

- (void)addPolyline
{
    CLLocation *polylineCoordinate1 = [[CLLocation alloc]initWithLatitude:52.5233 + 0.004 longitude:13.4127 + 0.004];
    CLLocation *polylineCoordinate2 = [[CLLocation alloc]initWithLatitude:52.5233 + 0.0055 longitude:13.4127 + 0.0051];
    CLLocation *polylineCoordinate3 = [[CLLocation alloc]initWithLatitude:52.5233 + 0.003 longitude:13.4127 + 0.00521];
    NSArray *polylineCoordinates = [NSArray arrayWithObjects:polylineCoordinate1,polylineCoordinate2,polylineCoordinate3, nil];
    
    SKPolyline *polyLine = [SKPolyline polyline];
    polyLine.identifier = 8;
    polyLine.coordinates = polylineCoordinates;
    polyLine.fillColor = [UIColor redColor];
    polyLine.lineWidth = 10.0;
    [self.mapView addPolyline:polyLine];
}

@end
