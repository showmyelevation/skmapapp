//
//  GPSElementsDrawingViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "GPSElementsDrawingViewController.h"
#import <SKMaps/SKMaps.h>
#import <SKMaps/SKMapView+GPSFiles.h>
#import <SKMaps/SKRoutingService+GPSFiles.h>
#import <SKMaps/SKMapScaleView.h>

#import <UIDevice+Additions.h>
#import <SKTNavigationManager.h>
#import <SKTNavigationConfiguration.h>
#import <SKTMainView.h>

@interface GPSElementsDrawingViewController ()<SKMapViewDelegate,SKRoutingDelegate,SKNavigationDelegate>

@property(nonatomic,strong) SKMapView *mapView;
@property(nonatomic,strong) SKGPSFileElement *gpsElement;
@property(nonatomic, strong) SKTNavigationManager *navManager;
@property(nonatomic, strong) SKRouteInformation *routeInfo;
@property(nonatomic, strong) UIButton *navigateButton;

@end

@implementation GPSElementsDrawingViewController

- (id)initWitGPSElement:(SKGPSFileElement*)gpsElement
{
    self = [super init];
    if (self)
    {
        self.gpsElement = gpsElement;
        _navManager = [[SKTNavigationManager alloc] initWithMapView:_mapView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView = [[SKMapView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.mapView.delegate = self;
    self.mapView.mapScaleView.hidden = YES;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    //setting the visible region
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(52.5233, 13.4127);
    region.zoomLevel = 3;
    self.mapView.visibleRegion = region;
    
    self.navManager = [[SKTNavigationManager alloc] initWithMapView:self.mapView];
	[self.view addSubview:self.navManager.mainView];
	self.navManager.mainView.hidden = YES;
    
    [self addNavigateButton];
    [self addStopButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.mapView.settings.showCurrentPosition = YES;

    
    if (self.gpsElement)
    {
        if (self.gpsElement.type == SKGPSFileElementGPXTrack)
        {
            NSLog(@"================in if (self.gpsElement.type == SKGPSFileElementGPXTrack)=====================");
            NSLog(@"Draw GPS viewWillAppear gpsElement=%@",self.gpsElement);
            NSLog(@"=====================================");
            NSArray *gpsElements = [[SKGPSFilesService sharedInstance] childElementsForElement:self.gpsElement error:nil];
            NSLog(@"====GPSElementDrawingViewCtl==gpsElements = %@",gpsElements);
            for (SKGPSFileElement *element in gpsElements)
            {
                NSLog(@"element=%@",element);
                [self.mapView drawGPSFileElement:element];
                [self.mapView fitGPSFileElement:element];
            }
 
        }
        else
        {
            [self.mapView drawGPSFileElement:self.gpsElement];
            [self.mapView fitGPSFileElement:self.gpsElement];
        }
        [self calculateRoute];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapView.settings.showCurrentPosition = NO;
    self.mapView.settings.showCompass = NO;
    
    if (self.gpsElement)
    {
        [self.mapView removeGPSFileElement:self.gpsElement];
        [[SKRoutingService sharedInstance] stopNavigation];
        [SKRoutingService sharedInstance].routingDelegate = self;
    }
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (![UIDevice isiPad]) {
        self.navManager.mainView.orientation = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? SKTUIOrientationLandscape : SKTUIOrientationPortrait;
    }
}

- (void)addNavigateButton
{
    self.navigateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.navigateButton.backgroundColor = [UIColor grayColor];
    [self.navigateButton setTitle:@"Calculating" forState:UIControlStateNormal];
    self.navigateButton.frame = CGRectMake(self.view.frame.size.width - 80, 60, 80, 40);
    self.navigateButton.userInteractionEnabled = NO;
    [self.navigateButton addTarget:self action:@selector(startNavigationOnTrack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.navigateButton];
}

- (void)addStopButton {
    UIButton *stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    stopButton.backgroundColor = [UIColor grayColor];
    [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    stopButton.frame = CGRectMake(self.view.frame.size.width - 80, 100, 80, 40);
    [stopButton addTarget:self action:@selector(stopNavigation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopButton];
}

- (void)calculateRoute
{
    [SKRoutingService sharedInstance].mapView = self.mapView;
    [SKRoutingService sharedInstance].routingDelegate = self;
    [SKRoutingService sharedInstance].navigationDelegate = self;
    SKRouteSettings *routingSettings = [SKRouteSettings routeSettings];
    routingSettings.shouldBeRendered = YES;
    routingSettings.routeMode = SKRouteConnectionHybrid;
    [[SKRoutingService sharedInstance] calculateRouteWithSettings:routingSettings GPSFileElement:self.gpsElement];
}

- (void)routingService:(SKRoutingService *)routingService didFinishRouteCalculationWithInfo:(SKRouteInformation *)routeInformation {
    [routingService zoomToRouteWithInsets:UIEdgeInsetsZero duration:500];
    self.routeInfo = routeInformation;
    [self.navigateButton setTitle:@"Navigate" forState:UIControlStateNormal];
    self.navigateButton.userInteractionEnabled = YES;
}

- (void)startNavigationOnTrack
{
    SKTNavigationConfiguration *config = [SKTNavigationConfiguration defaultConfiguration];
    config.routeInfo = self.routeInfo;
    config.navigationType = SKNavigationTypeSimulation;
    _navManager.mainView.hidden = NO;
    [_navManager startNavigationWithConfiguration:config];
    self.navigationController.navigationBarHidden = YES;
    self.navManager.mainView.isUnderStatusBar = YES;
}

- (void)stopNavigation {
    [self.navManager stopNavigation];
    self.navManager.mainView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
}

@end
