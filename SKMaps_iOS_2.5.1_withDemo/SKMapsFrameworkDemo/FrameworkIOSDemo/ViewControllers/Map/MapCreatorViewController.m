//
//  MapCreatorViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "MapCreatorViewController.h"
#import <SKMaps/SKMaps.h>

@interface MapCreatorViewController ()
@property(nonatomic,strong) SKMapView *mapView;
@end

@implementation MapCreatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //adding the map
    self.mapView = [[SKMapView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    //setting the visible region
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(52.5233, 13.4127);
    region.zoomLevel = 18.0f;
    self.mapView.visibleRegion = region;
    
    //map creator
    [self.mapView applySettingsFromFileAtPath:[[NSBundle mainBundle] pathForResource:@"MapCreator" ofType:@"json"]];
}

@end
