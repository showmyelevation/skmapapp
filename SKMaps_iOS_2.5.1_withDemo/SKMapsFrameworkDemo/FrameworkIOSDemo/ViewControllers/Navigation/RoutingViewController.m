//
//  NavigationViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "RoutingViewController.h"
#import "AudioService.h"
#import <SKMaps/SKMaps.h>
#import <SKMaps/SKAdvisorTTSSettings.h>
#import <SKMaps/SKTTSPlayer.h>

typedef enum
{
    kTagCalculateRoute=100,
    kTagStartNavigation,
    kTagStopNavigation
}buttonTags;

@interface RoutingViewController ()<SKRoutingDelegate,SKNavigationDelegate, UIAlertViewDelegate>
@property(nonatomic,strong) SKMapView *mapView;
@property(nonatomic,strong) UIButton*  bottomButton;
@end

@implementation RoutingViewController

#pragma mark - Lifecycle

-(id)init
{
    self = [super init];
    if (self)
    {
        [self configureAudioPlayer];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //adding a map
    self.mapView = [[SKMapView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    //setting the visible region
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(52.5233, 13.4127);
    region.zoomLevel = 3;
    self.mapView.visibleRegion = region;
    
    //registering to routing & navigation related callbacks
    [SKRoutingService sharedInstance].mapView = self.mapView;
    [SKRoutingService sharedInstance].routingDelegate = self;
    [SKRoutingService sharedInstance].navigationDelegate = self;
    
    self.mapView.settings.showCurrentPosition = YES;

    [self addButton];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapView.settings.displayMode = SKMapDisplayMode2D;
    [[AudioService sharedInstance]cancel];
    [[SKRoutingService sharedInstance]stopNavigation];
    [[SKRoutingService sharedInstance]clearCurrentRoutes];
}

#pragma mark - UI

- (void)addButton
{
    self.bottomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.bottomButton.frame = CGRectMake(50.0f, CGRectGetHeight(self.view.frame)-40.0f, CGRectGetWidth(self.view.frame)-100.0f, 35.0f);
    [self.bottomButton setTitle:@"Calculate Route" forState:UIControlStateNormal];
    self.bottomButton.autoresizingMask=  UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    self.bottomButton.tag=kTagCalculateRoute;
    [self.bottomButton addTarget:self action:@selector(buttonPressed:)  forControlEvents:UIControlEventTouchUpInside];
    self.bottomButton.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.bottomButton];
}

-(void)buttonPressed:(UIButton*)button
{
    switch (button.tag) {
        case kTagCalculateRoute:
        {
            SKRouteSettings* route = [[SKRouteSettings alloc]init];
            route.startCoordinate=CLLocationCoordinate2DMake(37.9667, 23.7167);
            route.destinationCoordinate=CLLocationCoordinate2DMake(37.9677, 23.7567);
            route.shouldBeRendered = YES; // If NO, the route will not be rendered.
            route.requestAdvices = YES;
            route.maximumReturnedRoutes = 1;
            route.requestExtendedRoutePointsInfo = NO;
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
            
            break;
        }
        case kTagStartNavigation:
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Advice type" message:@"Choose the audio advice type" delegate:self cancelButtonTitle:@"TTS" otherButtonTitles:@"Scout audio", nil];
            [av show];
            break;
        }
        case kTagStopNavigation:
        {
            [[AudioService sharedInstance]cancel];
            [[SKRoutingService sharedInstance]stopNavigation];
            [[SKRoutingService sharedInstance]clearCurrentRoutes];
            self.mapView.settings.displayMode = SKMapDisplayMode2D;
            [self.bottomButton setTitle:@"Calculate Route" forState:UIControlStateNormal];
            self.bottomButton.tag=kTagCalculateRoute;
            break;
        }
        default:
            break;
    }
}

#pragma mark Audio Player configuration

-(void)configureAudioPlayer {
    SKAdvisorSettings *settings = [SKAdvisorSettings advisorSettings];
    settings.advisorType = SKAdvisorTypeAudioFiles;
    
    [SKRoutingService sharedInstance].advisorConfigurationSettings = settings;
    
    
    NSBundle* advisorResourcesBundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SKAdvisorResources.bundle"]];
    NSString* soundFilesFolder = [advisorResourcesBundle pathForResource:@"Languages" ofType:@""];
    NSString* currentLanguage = @"en_us";
    NSString* audioFilesFolderPath = [NSString stringWithFormat:@"%@/%@/sound_files",soundFilesFolder,currentLanguage];
    [AudioService sharedInstance].audioFilesFolderPath = audioFilesFolderPath;
}

- (void)configureTTS {
    SKAdvisorSettings *settings = [SKAdvisorSettings advisorSettings];
    settings.advisorVoice = @"en_us";
    settings.advisorType = SKAdvisorTypeTextToSpeech;
    
    [SKRoutingService sharedInstance].advisorConfigurationSettings = settings;
}

#pragma mark - SKRoutingServiceDelegate

- (void)routingService:(SKRoutingService *)routingService didFinishRouteCalculationWithInfo:(SKRouteInformation*)routeInformation
{
    NSLog(@"Route is calculated.");
    [self.bottomButton setTitle:@"Start Navigation" forState:UIControlStateNormal];
    self.bottomButton.tag=kTagStartNavigation;
    [routingService zoomToRouteWithInsets:UIEdgeInsetsZero duration:500];
}


- (void)routingService:(SKRoutingService *)routingService didFailWithErrorCode:(SKRoutingErrorCode)errorCode
{
    NSLog(@"Route calculation failed.");
}

#pragma mark - SKTNavigationDelegate

-(void)routingService:(SKRoutingService *)routingService didChangeDistanceToDestination:(int)distance withFormattedDistance:(NSString *)formattedDistance
{
    NSLog(@"distanceToDestination %d m", distance);
}

-(void)routingService:(SKRoutingService *)routingService didChangeEstimatedTimeToDestination:(int)time
{
    NSLog(@"timeToDestination %d s", time);
}

-(void)routingService:(SKRoutingService *)routingService didChangeCurrentStreetName:(NSString *)currentStreetName streetType:(SKStreetType)streetType countryCode:(NSString *)countryCode
{
    NSLog(@"Current street name changed to name=%@ type=%ld countryCode=%@",currentStreetName,(long)streetType,countryCode);
}

-(void)routingService:(SKRoutingService *)routingService didChangeNextStreetName:(NSString *)nextStreetName streetType:(SKStreetType)streetType countryCode:(NSString *)countryCode
{
    NSLog(@"Next street name changed to name=%@ type=%ld countryCode=%@",nextStreetName,(long)streetType,countryCode);
}

-(void)routingService:(SKRoutingService *)routingService didChangeCurrentAdviceImage:(UIImage *)adviceImage withLastAdvice:(BOOL)isLastAdvice
{
    NSLog(@"Current visual advice image changed.");
}

-(void)routingService:(SKRoutingService *)routingService didChangeCurrentVisualAdviceDistance:(int)distance withFormattedDistance:(NSString *)formattedDistance
{
    NSLog(@"Current visual advice distance changed to distance=%i %@.",distance,formattedDistance);
}

-(void)routingService:(SKRoutingService *)routingService didChangeSecondaryAdviceImage:(UIImage *)adviceImage withLastAdvice:(BOOL)isLastAdvice
{
    NSLog(@"Secondary visual advice image changed.");
}

-(void)routingService:(SKRoutingService *)routingService didChangeSecondaryVisualAdviceDistance:(int)distance withFormattedDistance:(NSString *)formattedDistance
{
    NSLog(@"Secondary visual advice distance changed to distance=%i %@.",distance,formattedDistance);
}

-(void)routingService:(SKRoutingService *)routingService didChangeCurrentVisualAdviceDistancePercent:(double)percent
{
    NSLog(@"distance percent to current visual advice: %f", percent);
}

-(void)routingService:(SKRoutingService *)routingService didUpdateFilteredAudioAdvices:(NSArray *)audioAdvices
{
    NSLog(@"Filtered audio advice updated.");
    //Play audio advice.
    [[AudioService sharedInstance] play:audioAdvices];
}

-(void)routingService:(SKRoutingService *)routingService didUpdateUnfilteredAudioAdvices:(NSArray *)audioAdvices withDistance:(int)distance
{
    NSLog(@"Unfiltered audio advice updated.");
}

-(void)routingService:(SKRoutingService *)routingService didChangeCurrentSpeed:(double)speed
{
    NSLog(@"Current speed: %f", speed);
}

-(void)routingService:(SKRoutingService *)routingService didChangeCurrentSpeedLimit:(double)speedLimit
{
    NSLog(@"Current speedlimit: %f",speedLimit);
}

-(void)routingServiceDidStartRerouting:(SKRoutingService *)routingService
{
    NSLog(@"Rerouting started.");
}

-(void)routingService:(SKRoutingService *)routingService didUpdateSpeedWarningToStatus:(BOOL)speedWarningIsActive withAudioWarnings:(NSArray *)audioWarnings insideCity:(BOOL)isInsideCity
{
    NSLog(@"Speed warning status updated.");
}

-(void)routingServiceDidReachDestination:(SKRoutingService *)routingService
{
    UIAlertView *quitAlert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"navigation_screen_destination_reached_alert_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navigation_screen_destination_reached_alert_ok_button_title", nil) otherButtonTitles:nil];
    [quitAlert show];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        //tts
        [self configureTTS];
    } else {
        //audio files
        [self configureAudioPlayer];
    }
    
    SKNavigationSettings* navSettings = [SKNavigationSettings navigationSettings];
    navSettings.navigationType=SKNavigationTypeSimulation;
    navSettings.distanceFormat=SKDistanceFormatMilesFeet;
    self.mapView.settings.displayMode = SKMapDisplayMode3D;
    [[SKRoutingService sharedInstance]startNavigationWithSettings:navSettings];
    
    [self.bottomButton setTitle:@"Stop Navigation" forState:UIControlStateNormal];
    self.bottomButton.tag=kTagStopNavigation;
}

@end
