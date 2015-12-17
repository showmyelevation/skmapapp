//
//  NavigationUIViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

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

#import <UIView+Additions.h>
#import <UIDevice+Additions.h>

#import "NavigationUIViewController.h"
#import "MenuView.h"
#import "SettingsViewController.h"
#import "SelectByWheelViewController.h"
#import "GPSFilesViewController.h"

#define kSizeMultiplier (([UIDevice isiPad] ? 2.0 : 1.0))

const int kStartAnnotationId = 0;
const int kEndAnnotationId = 1;
const int kViapointAnnotationId = 2;



@interface NavigationUIViewController () <SKMapViewDelegate, SKTNavigationManagerDelegate>

@property (nonatomic, strong) SKMapView *mapView;
@property (nonatomic, strong) SKTNavigationManager *navigationManager;
@property (nonatomic, strong) UIView *poiView;
@property (nonatomic, strong) SKTNavigationConfiguration *configuration;
@property (nonatomic, strong) MenuView *menu;
@property (nonatomic, strong) UIButton *centerButton;
@property (nonatomic, strong) UILabel *longTapInfoLabel;
@property NSMutableArray *arrAddress;


@end

@implementation NavigationUIViewController

@synthesize managedObjectContext;
@synthesize arrAddress;
@synthesize pickerView;
@synthesize destinationLat;
@synthesize destinationLng;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc {
    [self.navigationManager stopNavigation];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    arrAddress = [[NSMutableArray alloc] init];
    
    //*******code for Core data***********
    NSError *error;
    NSFetchRequest *fetchReuqets = [[NSFetchRequest alloc] init];
    //NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    
    AppDelegate *sharedDelegate = [AppDelegate appDelegate];
    NSManagedObjectContext *context = [sharedDelegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AddressMapping" inManagedObjectContext:context];
    [fetchReuqets setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchReuqets error:&error];
    for(NSManagedObject *address in fetchedObjects){
        NSLog(@"City: %@",[address valueForKey:@"city"]);
        NSLog(@"lat: %@",[address valueForKey:@"lat"]);
        //[self.arrAddress addObject:address];
        
        //NSLog(@"inloop the numbre of arrAddress is %ld",[arrAddress count]);
    }
    //*******code for core data***********
    
    //+++++++code for UIPicker++++++++++++
    
    pickerView = [[UIPickerView alloc] init];
    
    //[pickerView setDataSource:self];
    pickerView.dataSource = self;
    //[pickerView setDelegate:self];
    pickerView.delegate = self;
    //pickerView.hidden = NO;
    
    [pickerView setFrame:CGRectMake(0, 0, 320, 216)];
    
    pickerView.showsSelectionIndicator = YES;
    
    //[self.view addSubview:pickerView];
    
    
    //+++++++code for UIPicker++++++++++++
    
    self.configuration = [SKTNavigationConfiguration defaultConfiguration];
    //self.configuration.navigationType = SKNavigationTypeSimulation;
    self.configuration.navigationType = SKNavigationTypeReal;
    self.configuration.simulationLogPath = [[NSBundle mainBundle] pathForResource:@"Seattle" ofType:@"log"];
    self.configuration.startCoordinate = CLLocationCoordinate2DMake(_userLocation.coordinate.latitude, _userLocation.coordinate.longitude);
    if([destinationLat isKindOfClass:[NSNull class]] || destinationLat==nil || [destinationLat isEqualToString:@""]){
        NSLog(@"NavigationView destination not changed cherryborrk");
        self.configuration.destination = CLLocationCoordinate2DMake(-33.722919, 151.035413);
        
    }else{
        NSLog(@" in NavigationUIView destination changed : %@",self.destinationLat);
        self.configuration.destination = CLLocationCoordinate2DMake([self.destinationLat doubleValue], [self.destinationLng doubleValue]);
    }
    
    [self addMapView];
    [self addPoiView];
    
    [self updateAnnotations];
    
    self.navigationManager = [[SKTNavigationManager alloc] initWithMapView:self.mapView];
    [self.view addSubview:self.navigationManager.mainView];
    self.navigationManager.mainView.hidden = YES;
    self.navigationManager.delegate = self;
    self.navigationController.navigationBar.translucent = NO;
    
    
    _longTapInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(roundf((self.view.frameWidth - 140.0 * kSizeMultiplier) / 2.0), 0.0,
                                                                  160 * kSizeMultiplier,
                                                                  40.0 * kSizeMultiplier)];
    _longTapInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _longTapInfoLabel.numberOfLines = 2;
    _longTapInfoLabel.font = [UIFont systemFontOfSize:16 * kSizeMultiplier];
    _longTapInfoLabel.text = @"Long tap on map to select end point";
    _longTapInfoLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    _longTapInfoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_longTapInfoLabel];
    
    _navigationManager.mainView.orientation = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? SKTUIOrientationLandscape : SKTUIOrientationPortrait;
    
    [self addMenu];
    [self addCenter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
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


//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSLog(@"titleForRow number key for row = %@",[arrAddress objectAtIndex:row]);
    return [arrAddress objectAtIndex:row];
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 50;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSLog(@"in numberOfRowsInComponent:%ld",(unsigned long)[arrAddress count]);
    
    return [arrAddress count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

#pragma mark - Overidden

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    _navigationManager.mainView.orientation = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? SKTUIOrientationLandscape : SKTUIOrientationPortrait;
}

#pragma mark - UI creation

- (void)addMapView {
    self.mapView = [[SKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frameWidth, self.view.frameHeight)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.mapScaleView.hidden = YES;
    self.mapView.settings.rotationEnabled = NO;
    self.mapView.settings.showCurrentPosition = YES;
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(_userLocation.coordinate.latitude, _userLocation.coordinate.longitude);
    region.zoomLevel = 12.0;
    self.mapView.visibleRegion = region;
    self.mapView.settings.showCompass = YES;
    [self.view addSubview:self.mapView];
    
}

- (void)addPoiView {
    self.poiView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 5.0, 5.0)];
    self.poiView.backgroundColor = [UIColor redColor];
    self.poiView.hidden = YES;
    [self.view addSubview:self.poiView];
}

- (void)addMenu {
    CGFloat sizeMultplier = ([UIDevice isiPad] ? 2.0 : 1.0);
    
    _menu = [[MenuView alloc] initWithFrame:CGRectMake(0.0, 40.0 * sizeMultplier, 120.0 * sizeMultplier + 50.0, 360.0 * sizeMultplier)];
    _menu.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_menu];
    
    [_menu.menuButton addTarget:self action:@selector(menuButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_menu.navigateButton addTarget:self action:@selector(navigateButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_menu.freeDriveButton addTarget:self action:@selector(freeDriveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_menu.cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_menu.styleButton addTarget:self action:@selector(styleButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_menu.plusButton addTarget:self action:@selector(increaseSpeed) forControlEvents:UIControlEventTouchUpInside];
    [_menu.minusButton addTarget:self action:@selector(decreaseSpeed) forControlEvents:UIControlEventTouchUpInside];
    [_menu.positionSelect addTarget:self action:@selector(positionSelectClicked) forControlEvents:UIControlEventValueChanged];
    [_menu.settingsButton addTarget:self action:@selector(settingsButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_menu.clearViaPoint addTarget:self action:@selector(countByEnumeratingWithState:objects:count:) forControlEvents:UIControlEventTouchUpInside];
    [_menu.wheelPositionSelect addTarget:self action:@selector(selWheelButtonClicked) forControlEvents:UIControlEventValueChanged];
    [_menu.inputAddrButton addTarget:self action:@selector(inputAddrButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_menu.gpsTrackButton addTarget:self action:@selector(gpsTrackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addCenter {
    _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _centerButton.frame = CGRectMake(12.0, self.view.frameHeight - 62.0, 50.0, 50.0);
    [_centerButton setImage:[UIImage imageNamed:@"nav_arrow.png"] forState:UIControlStateNormal];
    [_centerButton addTarget:self action:@selector(centerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _centerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _centerButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.3 blue:0.6 alpha:0.8];
    [self.view addSubview:_centerButton];
}

#pragma mark - Actions

- (void)navigateButtonClicked {
    _menu.navigationStyle = YES;
    _centerButton.hidden = YES;
    _longTapInfoLabel.hidden = YES;
    _menu.frameY = 140 * kSizeMultiplier;
    
    self.navigationManager.mainView.hidden = NO;
    self.navigationController.navigationBarHidden = YES;
    self.navigationManager.mainView.isUnderStatusBar = [UIDevice majorSystemVersion] >= 7;
    
    [self.navigationManager startNavigationWithConfiguration:self.configuration];
    
    [self removeAnnotations];
}

- (void)freeDriveButtonClicked {
    _menu.navigationStyle = YES;
    _centerButton.hidden = YES;
    _longTapInfoLabel.hidden = YES;
    _menu.frameY = 140 * kSizeMultiplier;
    
    if (self.configuration.routeType == SKRoutePedestrian) {
        self.configuration.navigationType = SKNavigationTypeSimulationFromLogFile;
        self.configuration.simulationLogPath = [[NSBundle mainBundle] pathForResource:@"Seattle" ofType:@"log"];
    }
    
    [self removeAnnotations];
    [self.navigationManager startFreeDriveWithConfiguration:self.configuration];
    self.navigationManager.mainView.hidden = NO;
    self.navigationManager.mainView.isUnderStatusBar = [UIDevice majorSystemVersion] >= 7;
    self.navigationController.navigationBarHidden = YES;
}

- (void)cancelButtonClicked {
    [self.navigationManager stopNavigation];
    [self cancelNavigation];
}

- (void)centerButtonClicked {
    [_mapView centerOnCurrentPosition];
    [_mapView animateToZoomLevel:14.0];
}

- (void)styleButtonClicked {
    _menu.styleButton.tag = !_menu.styleButton.tag;
    if (_menu.styleButton.tag) {
        [_navigationManager enableDayStyle];
    } else {
        [_navigationManager enableNightStyle];
    }
}

- (void)settingsButtonClicked {
    SettingsViewController *controller = [[SettingsViewController alloc] initWithConfigObject:self.configuration];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)inputAddrButtonClicked{
    InputStartEndViewController *inptController = [[InputStartEndViewController alloc] init];
    [self.navigationController pushViewController:inptController animated:YES];
}

- (void)selWheelButtonClicked{
    
    SelectByWheelViewController *selByWheelClt = [[SelectByWheelViewController alloc] init];
    [self.navigationController pushViewController:selByWheelClt animated:YES];
}

- (void)gpsTrackButtonClicked{
    GPSFilesViewController *gpsFileViewCtl = [[GPSFilesViewController alloc] init];
    [self.navigationController pushViewController:gpsFileViewCtl animated:YES];
}

- (void)menuButtonClicked {
    [UIView animateWithDuration:0.3 animations:^{
        if (_menu.menuButton.tag) {
            _menu.frameX = -_menu.frameWidth + _menu.menuButton.frameWidth;
            _menu.menuButton.tag = NO;
            [_menu.menuButton setTitle:@">" forState:UIControlStateNormal];
        } else {
            _menu.frameX = 0.0;
            _menu.menuButton.tag = YES;
            [_menu.menuButton setTitle:@"<" forState:UIControlStateNormal];
        }
    }];
}

- (void)clearViaPointClicked {
    _menu.showClearViaPoint = NO;
    self.configuration.viaPoints = nil;
    [self updateAnnotations];
}

- (void)positionSelectClicked {
    if (_menu.positionSelect.selectedSegmentIndex == 0) {
        _longTapInfoLabel.text = @"Long tap on map to select start point";
        _longTapInfoLabel.hidden = NO;
    } else if (_menu.positionSelect.selectedSegmentIndex == 1) {
        _longTapInfoLabel.text = @"Long tap on map to select end point";
        _longTapInfoLabel.hidden = NO;
    }
}

- (void)viaPointSelectClicked {
    if (_menu.wheelPositionSelect.selectedSegmentIndex >= 0) {
        _longTapInfoLabel.text = @"Long tap on map to select via point";
        _longTapInfoLabel.hidden = NO;
    }
}

- (void)increaseSpeed {
    [[SKPositionerService sharedInstance] increaseRouteSimulationSpeed:1.0];
}

- (void)decreaseSpeed {
    [[SKPositionerService sharedInstance] decreaseRouteSimulationSpeed:1.0];
}

- (void)updateAnnotations {
    if (![SKTNavigationUtils locationIsZero:_configuration.startCoordinate]) {
        SKAnnotation *annotation = [SKAnnotation annotation];
        //annotation.imageSize = 64;
        annotation.location = _configuration.startCoordinate;
        annotation.identifier = kStartAnnotationId;
        annotation.annotationType = SKAnnotationTypeGreen;
        [self.mapView addAnnotation:annotation withAnimationSettings:[SKAnimationSettings animationSettings]];
    } else {
        [self.mapView removeAnnotationWithID:kStartAnnotationId];
    }
    
    if (![SKTNavigationUtils locationIsZero:_configuration.destination]) {
        SKAnnotation *annotation = [SKAnnotation annotation];
        //annotation.imageSize = 64;
        annotation.location = _configuration.destination;
        annotation.identifier = kEndAnnotationId;
        annotation.annotationType = SKAnnotationTypeRed;
        [self.mapView addAnnotation:annotation withAnimationSettings:[SKAnimationSettings animationSettings]];
    } else {
        [self.mapView removeAnnotationWithID:kEndAnnotationId];
    }
    
    if (self.configuration.viaPoints.count > 0) {
        SKViaPoint *point = _configuration.viaPoints[0];
        SKAnnotation *annotation = [SKAnnotation annotation];
        //annotation.imageSize = 64;
        annotation.location = point.coordinate;
        annotation.identifier = kViapointAnnotationId;
        annotation.annotationType = SKAnnotationTypePurple;
        [self.mapView addAnnotation:annotation withAnimationSettings:[SKAnimationSettings animationSettings]];
    } else {
        [self.mapView removeAnnotationWithID:kViapointAnnotationId];
    }
}

- (void)removeAnnotations {
    [_mapView removeAnnotationWithID:kStartAnnotationId];
    [_mapView removeAnnotationWithID:kEndAnnotationId];
}

#pragma mark - SKMapViewDelegate methods

- (void)mapView:(SKMapView *)mapView didLongTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (_menu.positionSelect.selectedSegmentIndex == 0) {
        self.configuration.startCoordinate = coordinate;
    } else if (_menu.positionSelect.selectedSegmentIndex == 1) {
        //self.destinationLat = [NSString stringWithFormat:@"%f", coordinate.latitude];
        //self.destinationLng = [NSString stringWithFormat:@"%f", coordinate.longitude];
        self.configuration.destination = coordinate;
    } else if (_menu.wheelPositionSelect.selectedSegmentIndex == 0) {
        SKViaPoint *point = [SKViaPoint viaPoint:1 withCoordinate:coordinate];
        self.configuration.viaPoints = @[point];
        _menu.showClearViaPoint = YES;
    }
    
    _longTapInfoLabel.hidden = YES;
    
    [self updateAnnotations];
}

#pragma mark - SKTNavigationManagerDelegate methods

- (void)navigationManagerDidStopNavigation:(SKTNavigationManager *)manager withReason:(SKTNavigationStopReason)reason {
    if (reason == SKTNavigationStopReasonRoutingFailed) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Route calculation failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [av show];
    }
    [self cancelNavigation];
    _mapView.delegate = self;
    _menu.navigationStyle = NO;
    _centerButton.hidden = NO;
    _menu.frameY = 40 * kSizeMultiplier;
    [self updateAnnotations];
}

- (void)cancelNavigation {
    self.navigationManager.mainView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    [self updateAnnotations];
    _centerButton.hidden = NO;
    _menu.navigationStyle = NO;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [[SKPositionerService sharedInstance] stopPositionReplay];
}

- (void)didEnterBackground {
    if (!_navigationManager.navigationStarted) {
        [[SKPositionerService sharedInstance] cancelLocationUpdate];
    }
}

- (void)didEnterForeground {
    [[SKPositionerService sharedInstance] startLocationUpdate];
}

@end
