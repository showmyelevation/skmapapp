//
//  MapStylesViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "MapStylesViewController.h"
#import <SKMaps/SKMaps.h>

@interface MapStylesViewController ()
@property(nonatomic,strong) SKMapView *mapView;
@end

@implementation MapStylesViewController

#pragma mark - Lifecycle

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
    
    //changing to day style
    SKMapViewStyle *mapViewStyle = [SKMapViewStyle mapViewStyle];
    mapViewStyle.resourcesFolderName = @"DayStyle";
    mapViewStyle.styleFileName = @"daystyle.json";
    [SKMapView setMapStyle:mapViewStyle];
    
    [self addUI];
}

#pragma mark - UI

- (void)addUI
{
    UISegmentedControl* segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"Day",@"Night",@"Outdoor",@"Gray"]];
    segmentedControl.backgroundColor = [UIColor lightGrayColor];
    segmentedControl.frame = CGRectMake(5.0f, CGRectGetHeight(self.view.frame) - 55.0f , CGRectGetWidth(self.view.frame) - 10.0f, 30.0f);
    segmentedControl.autoresizingMask=  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
}

-(void)segmentedControlValueChanged:(UISegmentedControl*)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            SKMapViewStyle *mapViewStyle = [SKMapViewStyle mapViewStyle];
            mapViewStyle.resourcesFolderName = @"DayStyle";
            mapViewStyle.styleFileName = @"daystyle.json";
            [SKMapView setMapStyle:mapViewStyle];
            break;
        }
        case 1:
        {
            SKMapViewStyle *mapViewStyle = [SKMapViewStyle mapViewStyle];
            mapViewStyle.resourcesFolderName = @"NightStyle";
            mapViewStyle.styleFileName = @"nightstyle.json";
            [SKMapView setMapStyle:mapViewStyle];
            break;
        }
        case 2:
        {
            SKMapViewStyle *mapViewStyle = [SKMapViewStyle mapViewStyle];
            mapViewStyle.resourcesFolderName = @"OutdoorStyle";
            mapViewStyle.styleFileName = @"outdoorstyle.json";
            [SKMapView setMapStyle:mapViewStyle];
            break;
        }
        case 3:
        {
            SKMapViewStyle *mapViewStyle = [SKMapViewStyle mapViewStyle];
            mapViewStyle.resourcesFolderName = @"GrayscaleStyle";
            mapViewStyle.styleFileName = @"grayscalestyle.json";
            [SKMapView setMapStyle:mapViewStyle];
            break;
        }
        default:
            break;
    }
}

@end
