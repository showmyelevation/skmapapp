//
//  PedestrianNavigationViewController.m
//  FrameworkIOSDemo
//
//  Created by Cristian Chertes on 12/02/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "PedestrianNavigationViewController.h"
#import "AudioService.h"
#import "MenuView.h"
#import "SKTNavigationUtils.h"
#import "SettingsViewController.h"

#import <UIView+Additions.h>
#import <UIDevice+Additions.h>
#import <SKMaps/SKMapView.h>
#import <SKMaps/SKMapScaleView.h>
#import <SKMaps/SKAnnotation.h>
#import <SKMaps/SKPositionerService.h>
#import <SKMaps/SKRoutingService.h>
#import <SKMaps/SKAnimationSettings.h>
#import <SKMaps/SKViaPoint.h>
#import <SDKTools/Navigation/SKTNavigationManager+Styles.h>
#import <SDKTools/Navigation/SKTNavigationManager.h>
#import <SDKTools/Navigation/SKTNavigationUtils.h>
#import <SDKTools/Navigation/SKTNavigationManager+Settings.h>

#define kSizeMultiplier (([UIDevice isiPad] ? 2.0 : 1.0))

const int kStartAnnotationIdentifier = 0;
const int kEndAnnotationIdentifier = 1;
const int kViapointAnnotationIdentifier = 2;

@interface PedestrianNavigationViewController () <SKMapViewDelegate, SKRoutingDelegate, SKNavigationDelegate, SKTNavigationManagerDelegate, SKTNavigationViewDelegate, SKTNavigationFreeDriveViewDelegate>

@property (nonatomic, strong) SKMapView                     *mapView;
@property (nonatomic, strong) MenuView                      *menu;
@property (nonatomic, strong) UILabel                       *longTapInfoLabel;
@property (nonatomic, strong) UILabel                       *pedestrianInfoLabel;
@property (nonatomic, strong) UIButton                      *centerButton;

@property (nonatomic, strong) SKTNavigationManager          *navigationManager;
@property (nonatomic, strong) SKTNavigationConfiguration    *configuration;

@end

@interface PedestrianNavigationViewController (UICreation)

- (void)addMapView;
- (void)addMenu;
- (void)addLongTapInfoLabel;
- (void)addPedestrianInfoLabel;
- (void)addCenterButton;

@end

@implementation PedestrianNavigationViewController

#pragma mark - Overriden

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addMapView];
    [self addMenu];
    [self addLongTapInfoLabel];
    [self addPedestrianInfoLabel];
    [self addCenterButton];
    [self configureNavigation];
    [self configureNavigationManager];
    [self configureRoutingService];
    [self updateAnnotations];
    
    [self registerToNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationManager.navigationStates.count > 0) {
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.navigationManager.mainView.orientation = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? SKTUIOrientationLandscape : SKTUIOrientationPortrait;
}

- (void)dealloc {
    [self.navigationManager stopNavigation];
    
    [self unregisterFromNotifications];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePedestrianInfoLabel) object:nil];
}

#pragma mark - Actions

- (void)navigateButtonClicked {
    self.menu.navigationStyle = YES;
    [self hideLongTapInfoLabel:YES];
    self.menu.frameY = 140 * kSizeMultiplier;
    
    self.navigationManager.mainView.hidden = NO;
    self.navigationController.navigationBarHidden = YES;
    self.navigationManager.mainView.isUnderStatusBar = [UIDevice majorSystemVersion] >= 7;
    //self.configuration.navigationType = SKNavigationTypeSimulation;
    self.configuration.navigationType = SKNavigationTypeReal;
    
    [self.navigationManager startNavigationWithConfiguration:self.configuration];
    [self removeAnnotations];
    self.centerButton.hidden = YES;
}

- (void)freeWalkButtonClicked {
    self.menu.navigationStyle = YES;
    [self hideLongTapInfoLabel:YES];
    self.menu.frameY = 140 * kSizeMultiplier;
    
    [self removeAnnotations];
    self.configuration.navigationType = SKNavigationTypeSimulationFromLogFile;
    [self.navigationManager startFreeDriveWithConfiguration:self.configuration];
    self.navigationManager.mainView.hidden = NO;
    self.navigationManager.mainView.isUnderStatusBar = [UIDevice majorSystemVersion] >= 7;
    self.navigationController.navigationBarHidden = YES;
    self.centerButton.hidden = YES;
}

- (void)cancelButtonClicked {
    [self.navigationManager stopNavigation];
    [self cancelNavigation];
}

- (void)centerButtonClicked {
    [self.mapView centerOnCurrentPosition];
    [self.mapView animateToZoomLevel:14.0];
}

- (void)styleButtonClicked {
    self.menu.styleButton.tag = !self.menu.styleButton.tag;
    if (self.menu.styleButton.tag) {
        [self.navigationManager enableDayStyle];
    } else {
        [self.navigationManager enableNightStyle];
    }
}

- (void)menuButtonClicked {
    [UIView animateWithDuration:0.3 animations:^{
        if (self.menu.menuButton.tag) {
            self.menu.frameX = -self.menu.frameWidth + self.menu.menuButton.frameWidth;
            self.menu.menuButton.tag = NO;
            [self.menu.menuButton setTitle:@">" forState:UIControlStateNormal];
        } else {
            self.menu.frameX = 0.0;
            self.menu.menuButton.tag = YES;
            [self.menu.menuButton setTitle:@"<" forState:UIControlStateNormal];
        }
    }];
}

- (void)clearViaPointClicked {
    self.menu.showClearViaPoint = NO;
    self.configuration.viaPoints = nil;
    [self updateAnnotations];
}

- (void)positionSelectClicked {
    [self hideLongTapInfoLabel:NO];
    [self.pedestrianInfoLabel setHidden:YES];
    
    if (self.menu.positionSelect.selectedSegmentIndex == 0) {
        self.longTapInfoLabel.text = @"Long tap on map to select start point";
        [self hideLongTapInfoLabel:NO];
    } else if (self.menu.positionSelect.selectedSegmentIndex == 1) {
        self.longTapInfoLabel.text = @"Long tap on map to select end point";
        [self hideLongTapInfoLabel:NO];
    }
}

- (void)viaPointSelectClicked {
    [self hideLongTapInfoLabel:NO];
    [self.pedestrianInfoLabel setHidden:YES];
    
    //if (self.menu.viaPointSelect.selectedSegmentIndex >= 0) {
    if (self.menu.wheelPositionSelect.selectedSegmentIndex >=0){
        self.longTapInfoLabel.text = @"Long tap on map to select wheel point";
        [self hideLongTapInfoLabel:NO];
    }
}

- (void)increaseSpeed {
    [[SKPositionerService sharedInstance] increaseRouteSimulationSpeed:1.0];
}

- (void)decreaseSpeed {
    [[SKPositionerService sharedInstance] decreaseRouteSimulationSpeed:1.0];
}

#pragma mark - Private methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context  {
    if ([keyPath isEqualToString:@"prefferedFollowerMode"]) {
        [self updatePedestrianLabelText];
    }
}

- (void)registerToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self.navigationManager addObserver:self forKeyPath:@"prefferedFollowerMode" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)unregisterFromNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationManager removeObserver:self forKeyPath:@"prefferedFollowerMode"];
}

- (void)hidePedestrianInfoLabel {
    [self.pedestrianInfoLabel setHidden:YES];
}

- (void)hideLongTapInfoLabel:(BOOL)value {
    [self.longTapInfoLabel setHidden:value];
}

- (void)cancelNavigation {
    self.navigationManager.mainView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    [self updateAnnotations];
    self.menu.navigationStyle = NO;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [[SKPositionerService sharedInstance] stopPositionReplay];
}

- (void)didEnterBackground {
    if (!self.navigationManager.navigationStarted) {
        [[SKPositionerService sharedInstance] cancelLocationUpdate];
    }
}

- (void)didEnterForeground {
    [[SKPositionerService sharedInstance] startLocationUpdate];
}

- (void)configureRoutingService {
    [SKRoutingService sharedInstance].mapView = self.mapView;
    [SKRoutingService sharedInstance].routingDelegate = self;
    [SKRoutingService sharedInstance].navigationDelegate = self;
}

- (void)configureNavigation {
    self.configuration = [SKTNavigationConfiguration defaultConfiguration];
    self.configuration.navigationType = SKNavigationTypeSimulation;
    self.configuration.routeType = SKRoutePedestrian;
    self.configuration.simulationLogPath = [[NSBundle mainBundle] pathForResource:@"Seattle" ofType:@"log"];
    self.configuration.startCoordinate = CLLocationCoordinate2DMake(_userLocation.coordinate.latitude, _userLocation.coordinate.longitude);
    self.configuration.destination = CLLocationCoordinate2DMake(_userLocation.coordinate.latitude, _userLocation.coordinate.longitude);
}

- (void)configureNavigationManager {
    self.navigationManager = [[SKTNavigationManager alloc] initWithMapView:self.mapView];
    [self.view addSubview:self.navigationManager.mainView];
    self.navigationManager.mainView.hidden = YES;
    self.navigationManager.delegate = self;
    self.navigationManager.configuration.routeType = SKRoutePedestrian;
    self.navigationManager.navigationSettings.transportMode = SKTransportPedestrian;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationManager.mainView.orientation = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? SKTUIOrientationLandscape : SKTUIOrientationPortrait;
    self.navigationManager.mainView.navigationView.delegate = self;
    self.navigationManager.mainView.freeDriveView.delegate = self;
}

- (void)updateAnnotations {
    if (![SKTNavigationUtils locationIsZero:self.configuration.startCoordinate]) {
        SKAnnotation *annotation = [SKAnnotation annotation];
        annotation.location = self.configuration.startCoordinate;
        annotation.identifier = kStartAnnotationIdentifier;
        annotation.annotationType = SKAnnotationTypeGreen;
        [self.mapView addAnnotation:annotation withAnimationSettings:[SKAnimationSettings animationSettings]];
    } else {
        [self.mapView removeAnnotationWithID:kStartAnnotationIdentifier];
    }
    
    if (![SKTNavigationUtils locationIsZero:self.configuration.destination]) {
        SKAnnotation *annotation = [SKAnnotation annotation];
        annotation.location = self.configuration.destination;
        annotation.identifier = kEndAnnotationIdentifier;
        annotation.annotationType = SKAnnotationTypeRed;
        [self.mapView addAnnotation:annotation withAnimationSettings:[SKAnimationSettings animationSettings]];
    } else {
        [self.mapView removeAnnotationWithID:kEndAnnotationIdentifier];
    }
    
    if (self.configuration.viaPoints.count > 0) {
        SKViaPoint *point = self.configuration.viaPoints[0];
        SKAnnotation *annotation = [SKAnnotation annotation];
        annotation.location = point.coordinate;
        annotation.identifier = kViapointAnnotationIdentifier;
        annotation.annotationType = SKAnnotationTypePurple;
        [self.mapView addAnnotation:annotation withAnimationSettings:[SKAnimationSettings animationSettings]];
    } else {
        [self.mapView removeAnnotationWithID:kViapointAnnotationIdentifier];
    }
}

- (void)removeAnnotations {
    [self.mapView removeAnnotationWithID:kStartAnnotationIdentifier];
    [self.mapView removeAnnotationWithID:kEndAnnotationIdentifier];
}

- (void)updatePedestrianLabelText {
    self.pedestrianInfoLabel.hidden = NO;
    
    switch (self.navigationManager.prefferedFollowerMode) {
        case SKMapFollowerModeHistoricPosition:
            self.pedestrianInfoLabel.text = @"The map will turn based on your recent position - touch bottom left icon to change";
            break;
        case SKMapFollowerModePositionPlusHeading:
            self.pedestrianInfoLabel.text = @"The map will turn based on the device's compass, pointing in your movement direction - touch bottom left icon to change";
            break;
        case SKMapFollowerModePosition:
            self.pedestrianInfoLabel.text = @"The map will not turn - it will always stay northbound - touch bottom left icon to change";
            break;
            
        default:
            break;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePedestrianInfoLabel) object:nil];
    [self performSelector:@selector(hidePedestrianInfoLabel) withObject:nil afterDelay:5.0];
}

#pragma mark - SKMapViewDelegate methods

- (void)mapView:(SKMapView *)mapView didLongTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self.menu.positionSelect.selectedSegmentIndex == 0) {
        self.configuration.startCoordinate = coordinate;
    } else if (self.menu.positionSelect.selectedSegmentIndex == 1) {
        self.configuration.destination = coordinate;
    } else if (self.menu.wheelPositionSelect.selectedSegmentIndex == 0) {
        SKViaPoint *point = [SKViaPoint viaPoint:1 withCoordinate:coordinate];
        self.configuration.viaPoints = @[point];
        self.menu.showClearViaPoint = YES;
    }
    
    [self hideLongTapInfoLabel:YES];
    
    [self updateAnnotations];
}

#pragma mark - SKTNavigationManagerDelegate methods

- (void)navigationManagerDidStopNavigation:(SKTNavigationManager *)manager withReason:(SKTNavigationStopReason)reason {
    if (reason == SKTNavigationStopReasonRoutingFailed) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Route calculation failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [av show];
    }
    [self cancelNavigation];
    self.mapView.delegate = self;
    self.menu.navigationStyle = NO;
    self.menu.frameY = 40 * kSizeMultiplier;
    self.centerButton.hidden = NO;
    [self updateAnnotations];
}

@end

@implementation PedestrianNavigationViewController (UICreation)

- (void)addMapView {
    self.mapView = [[SKMapView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.settings.showCurrentPosition = YES;
    self.mapView.settings.showCompass = NO;
    self.mapView.delegate = self;
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(_userLocation.coordinate.latitude, _userLocation.coordinate.longitude);
    region.zoomLevel = 16.0;
    self.mapView.visibleRegion = region;
    
    [self.view addSubview:self.mapView];
}

- (void)addLongTapInfoLabel {
    self.longTapInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(roundf((self.view.frameWidth - 140.0 * kSizeMultiplier) / 2.0), self.view.frameMaxY - (60.0 * kSizeMultiplier) - self.navigationController.navigationBar.frameHeight * kSizeMultiplier,
                                                                      160 * kSizeMultiplier,
                                                                      40.0 * kSizeMultiplier)];
    self.longTapInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.longTapInfoLabel.numberOfLines = 2;
    self.longTapInfoLabel.font = [UIFont systemFontOfSize:16 * kSizeMultiplier];
    self.longTapInfoLabel.text = @"Long tap on map to select end point";
    self.longTapInfoLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.longTapInfoLabel.textAlignment = NSTextAlignmentCenter;
    [self hideLongTapInfoLabel:YES];
    
    [self.view addSubview:self.longTapInfoLabel];
}

- (void)addPedestrianInfoLabel {
    CGFloat bottomBarHeight = ([UIDevice isiPad] ? 80 : 44.0);
    self.pedestrianInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.view.frameMaxY - (40.0 * kSizeMultiplier) - self.navigationController.navigationBar.frameHeight * kSizeMultiplier - bottomBarHeight,
                                                                         self.view.frameWidth,
                                                                         80.0 * kSizeMultiplier)];
    self.pedestrianInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.pedestrianInfoLabel.numberOfLines = 4;
    self.pedestrianInfoLabel.font = [UIFont systemFontOfSize:16 * kSizeMultiplier];
    self.pedestrianInfoLabel.text = @"Pedestrian navigation: illustrating optimized 2D view with previous positions trail and pedestrian specific follow-modes: historic, compass & north bound";
    self.pedestrianInfoLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.pedestrianInfoLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:self.pedestrianInfoLabel];
    self.pedestrianInfoLabel.frameX = 0.0;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePedestrianInfoLabel) object:nil];
    [self performSelector:@selector(hidePedestrianInfoLabel) withObject:nil afterDelay:5.0];
}

- (void)addMenu {
    CGFloat sizeMultplier = ([UIDevice isiPad] ? 2.0 : 1.0);
    
    self.menu = [[MenuView alloc] initWithFrame:CGRectMake(0.0, 40.0 * sizeMultplier, 120.0 * sizeMultplier + 50.0, 360.0 * sizeMultplier)];
    self.menu.backgroundColor = [UIColor clearColor];
    self.menu.settingsButton.hidden = YES;
    self.menu.settingsButton = nil;
    [self.menu.freeDriveButton setTitle:@"Start free walk" forState:UIControlStateNormal];
    
    [self.view addSubview:self.menu];
    
    [self.menu.menuButton addTarget:self action:@selector(menuButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.menu.navigateButton addTarget:self action:@selector(navigateButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.menu.freeDriveButton addTarget:self action:@selector(freeWalkButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.menu.cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.menu.styleButton addTarget:self action:@selector(styleButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.menu.plusButton addTarget:self action:@selector(increaseSpeed) forControlEvents:UIControlEventTouchUpInside];
    [self.menu.minusButton addTarget:self action:@selector(decreaseSpeed) forControlEvents:UIControlEventTouchUpInside];
    [self.menu.positionSelect addTarget:self action:@selector(positionSelectClicked) forControlEvents:UIControlEventValueChanged];
    [self.menu.clearViaPoint addTarget:self action:@selector(clearViaPointClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.menu.wheelPositionSelect addTarget:self action:@selector(viaPointSelectClicked) forControlEvents:UIControlEventValueChanged];
}

- (void)addCenterButton {
    _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _centerButton.frame = CGRectMake(12.0, self.view.frameHeight - 62.0, 50.0, 50.0);
    [_centerButton setImage:[UIImage imageNamed:@"nav_arrow.png"] forState:UIControlStateNormal];
    [_centerButton addTarget:self action:@selector(centerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _centerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _centerButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.3 blue:0.6 alpha:0.8];
    
    [self.view addSubview:_centerButton];
}

@end
