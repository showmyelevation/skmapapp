//
//  RealReachViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "RealReachViewController.h"
#import <SKMaps/SKMaps.h>

@interface RealReachViewController ()

@property(nonatomic, strong) SKMapView              *mapView;
@property(nonatomic, retain) UISlider               *slider;
@property(nonatomic, strong) UISegmentedControl     *routeMode;
@property(nonatomic, strong) UISegmentedControl     *measurementUnit;
@property(nonatomic, strong) UISegmentedControl     *connectionModeSegmentedControl;
@property(nonatomic, strong) UISwitch               *roundTripSwitch;
@property(nonatomic, strong) UILabel                *infoLabel;
@property(nonatomic, strong) UILabel                *roundTripLabel;

@end

@implementation RealReachViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //display the map
    self.mapView = [[SKMapView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.mapScaleView.hidden = YES;
    [self.view addSubview:self.mapView];
    
    //set the map region
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(52.5233, 13.4127);
    region.zoomLevel = 12;
    self.mapView.visibleRegion = region;
    
    //add a marker to the center location of the real reach layer
    SKAnnotation *annotation3 = [SKAnnotation annotation];
    annotation3.identifier = 13;
    annotation3.annotationType = SKAnnotationTypeRed;
    annotation3.location = CLLocationCoordinate2DMake(52.5233, 13.4127);
    
    SKAnimationSettings *animationSettings = [SKAnimationSettings animationSettings];
    [self.mapView addAnnotation:annotation3 withAnimationSettings:animationSettings];
    
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 20.0)];
    self.infoLabel.text = @"1 minute";
    [self.view addSubview:self.infoLabel];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(5.0f, 20.0, CGRectGetWidth(self.view.frame)/2 - 5.0f, 40.0f)];
    [self.slider setMinimumValue:1];
    [self.slider setMaximumValue:60];
    self.slider.value = 10;
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.slider.tintColor = [UIColor blackColor];
    [self.view addSubview:self.slider];
    
    self.routeMode = [[UISegmentedControl alloc] initWithFrame:CGRectMake(10.0, 60.0, 180.0, 40.0)];
    [self.routeMode insertSegmentWithImage:[UIImage imageNamed:@"icon_pedestrian_route.png"] atIndex:0 animated:NO];
    [self.routeMode insertSegmentWithImage:[UIImage imageNamed:@"icon_bicycle_route.png"] atIndex:1 animated:NO];
    [self.routeMode insertSegmentWithImage:[UIImage imageNamed:@"icon_car_route.png"] atIndex:2 animated:NO];
    self.routeMode.selectedSegmentIndex = 2;
    self.routeMode.tintColor = [UIColor blackColor];
    [self.routeMode addTarget:self action:@selector(routeModeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.routeMode];
    
    self.measurementUnit = [[UISegmentedControl alloc] initWithFrame:CGRectMake(10.0, 110.0, 180.0, 40.0)];
    [self.measurementUnit insertSegmentWithTitle:@"Time" atIndex:0 animated:NO];
    [self.measurementUnit insertSegmentWithTitle:@"Distance" atIndex:1 animated:NO];
    [self.measurementUnit insertSegmentWithTitle:@"Energy" atIndex:2 animated:NO];
    self.measurementUnit.selectedSegmentIndex = 0;
    self.measurementUnit.tintColor = [UIColor blackColor];
    [self.measurementUnit addTarget:self action:@selector(unitChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.measurementUnit];
    
    self.connectionModeSegmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(10.0, 160.0, 180.0, 40.0)];
    [self.connectionModeSegmentedControl insertSegmentWithTitle:@"Online" atIndex:0 animated:NO];
    [self.connectionModeSegmentedControl insertSegmentWithTitle:@"Offline" atIndex:1 animated:NO];
    [self.connectionModeSegmentedControl insertSegmentWithTitle:@"Hybrid" atIndex:2 animated:NO];
    self.connectionModeSegmentedControl.selectedSegmentIndex = 0;
    self.connectionModeSegmentedControl.tintColor = [UIColor blackColor];
    [self.connectionModeSegmentedControl addTarget:self action:@selector(connectionModeChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.connectionModeSegmentedControl];
    
    self.roundTripSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10.0, 210.0, 30.0, 30.0)];
    self.roundTripSwitch.selected = NO;
    self.roundTripSwitch.tintColor = [UIColor blackColor];
    self.roundTripSwitch.onTintColor = [UIColor blackColor];
    [self.roundTripSwitch addTarget:self action:@selector(roundTripChanged:) forControlEvents:UIControlEventValueChanged];

    [self.view addSubview:self.roundTripSwitch];
    
    self.roundTripLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 215.0, 200.0, 20.0)];
    self.roundTripLabel.text = @"Round Trip";
    
    [self.view addSubview:self.roundTripLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateRealReach];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //remove the real reach layer from the map
    [self.mapView clearRealReachDisplay];
    
}

#pragma mark - Private methods

- (void)connectionModeChanged:(UISegmentedControl *)control {
    [self updateRealReach];
}

- (void)routeModeChanged:(UISegmentedControl *)control {
    [self updateRealReach];
}

- (void)unitChanged:(UISegmentedControl *)control {
    if (control.selectedSegmentIndex == 0) {
        self.slider.maximumValue = 60.0;
    } else if (control.selectedSegmentIndex == 1) {
        self.slider.maximumValue = 5000.0;
    } else {
        self.slider.maximumValue = 300.0;
    }
    [self updateRealReach];
}

-(IBAction)sliderValueChanged:(id)sender {
    [self updateRealReach];
}

- (void)roundTripChanged:(UISwitch *)sw {
    [self updateRealReach];
}

- (void)updateRealReach {
    //display the real reach layer
    SKRealReachSettings *realReachSettings = [SKRealReachSettings realReachSettings];
    realReachSettings.centerLocation = CLLocationCoordinate2DMake(52.5233, 13.4127);
    realReachSettings.transportMode = self.routeMode.selectedSegmentIndex;
    if (self.measurementUnit.selectedSegmentIndex == 0) {
        realReachSettings.unit = SKRealReachUnitSecond;
        realReachSettings.range = 60 * self.slider.value;
        self.infoLabel.text = [NSString stringWithFormat:@"%d minutes", (int)self.slider.value];
        
        [self.routeMode setEnabled:YES forSegmentAtIndex:0];
        [self.routeMode setEnabled:YES forSegmentAtIndex:2];
    } else if (self.measurementUnit.selectedSegmentIndex == 1) {
        realReachSettings.unit = SKRealReachUnitMeter;
        realReachSettings.range = self.slider.value;
        self.infoLabel.text = [NSString stringWithFormat:@"%d meters", (int)self.slider.value];
        
        [self.routeMode setEnabled:YES forSegmentAtIndex:0];
        [self.routeMode setEnabled:YES forSegmentAtIndex:2];
    } else {
        realReachSettings.unit = SKRealReachUnitMiliAmp;
        realReachSettings.range = self.slider.value * 1000;//miliwatts/hour
        self.infoLabel.text = [NSString stringWithFormat:@"%d watts/hour", (int)self.slider.value];
        realReachSettings.wattHour = @[@(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(3.7395504), @(4.4476889), @(5.4306439), @(6.722719), @(8.2830299), @(10.0275093),@(11.8820908), @(13.799201), @(15.751434), @(17.7231534), @(19.7051378), @(21.6916725), @(23.679014), @(25.6645696), @(27.6464437), @(29.6231796), @(31.5936073)];
        
        self.routeMode.selectedSegmentIndex = 1;
        [self.routeMode setEnabled:NO forSegmentAtIndex:0];
        [self.routeMode setEnabled:NO forSegmentAtIndex:2];
    }
    realReachSettings.connectionMode = (SKRouteConnectionMode)self.connectionModeSegmentedControl.selectedSegmentIndex;
    realReachSettings.roundTrip = self.roundTripSwitch.on;
    
    [self.mapView displayRealReachWithSettings:realReachSettings];
}

@end
