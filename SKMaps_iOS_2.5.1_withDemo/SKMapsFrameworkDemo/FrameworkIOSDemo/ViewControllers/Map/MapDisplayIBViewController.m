//
//  MapDisplayIBViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "MapDisplayIBViewController.h"
#import <SKMaps/SKMaps.h>

@interface MapDisplayIBViewController ()<SKMapViewDelegate>
@property(nonatomic,strong) IBOutlet SKMapView *mapView;
@end

@implementation MapDisplayIBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //setting the visible region
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(52.5233, 13.4127);
    region.zoomLevel = 17;
    self.mapView.visibleRegion = region;
    
    [self addUI];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapView.settings.showCurrentPosition = NO;
    self.mapView.settings.showCompass = NO;
}

#pragma mark - UI

- (void)addUI
{
    UIButton *positionMeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    positionMeButton.frame = CGRectMake(10.0f, CGRectGetHeight(self.view.frame) - 60.0f, 100.0f, 40.0f);
    [positionMeButton setTitle:@"Position me" forState:UIControlStateNormal];
    [positionMeButton addTarget:self action:@selector(positionMe) forControlEvents:UIControlEventTouchUpInside];
    positionMeButton.backgroundColor = [UIColor lightGrayColor];
    positionMeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    positionMeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:positionMeButton];
    
    UIButton *positionPlusHeadingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    positionPlusHeadingButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 110.0f, CGRectGetHeight(self.view.frame) - 60.0f, 100.0f, 40.0f);
    [positionPlusHeadingButton setTitle:@"Show heading" forState:UIControlStateNormal];
    [positionPlusHeadingButton addTarget:self action:@selector(showPositionerWithHeading) forControlEvents:UIControlEventTouchUpInside];
    positionPlusHeadingButton.backgroundColor = [UIColor lightGrayColor];
    positionPlusHeadingButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    positionPlusHeadingButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:positionPlusHeadingButton];
}

-(void)positionMe
{
    self.mapView.settings.showCurrentPosition = YES;
    self.mapView.settings.followUserPosition = YES;
    self.mapView.settings.headingMode = SKHeadingModeRotatingHeading;
    
    [self.mapView centerOnCurrentPosition];
}

- (void)showPositionerWithHeading
{
    self.mapView.settings.followUserPosition = YES;
    self.mapView.settings.headingMode = SKHeadingModeRotatingMap;
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
