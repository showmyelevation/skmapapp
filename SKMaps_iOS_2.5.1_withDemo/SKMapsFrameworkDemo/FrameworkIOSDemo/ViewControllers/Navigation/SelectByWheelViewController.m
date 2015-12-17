//
//  SelectByWheelViewController.m
//  FrameworkIOSDemo
//
//  Created by john on 16/11/2015.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "SelectByWheelViewController.h"
#import "NavigationUIViewController.h"



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
#import "MenuView.h"
#import "NavigationUIViewController.h"



@interface SelectByWheelViewController ()<SKMapVersioningDelegate>
    @property NSString *selectedLat;
    @property NSString *selectedLng;
    
    @property NSMutableArray *arrAddress;
    @property NSMutableArray *arrLat;
    @property NSMutableArray *arrLng;
    @property UIActivityIndicatorView *activityIndicator;

    @property (nonatomic, strong) SKMapView *mapView;

@end

@implementation SelectByWheelViewController

@synthesize arrAddress;
@synthesize arrLat;
@synthesize arrLng;
@synthesize pickerView;
@synthesize btnOk;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //**************load address **************
    NSError *error;
    NSFetchRequest *fetchReuqets = [[NSFetchRequest alloc] init];
    
    AppDelegate *sharedDelegate = [AppDelegate appDelegate];
    NSManagedObjectContext *context = [sharedDelegate managedObjectContext];
    
    arrAddress = [[NSMutableArray alloc] init];
    arrLat = [[NSMutableArray alloc] init];
    arrLng = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AddressMapping" inManagedObjectContext:context];
    [fetchReuqets setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchReuqets error:&error];
    for(NSManagedObject *address in fetchedObjects){
        
        NSString *city = [address valueForKey:@"city"];
        NSString *street = [address valueForKey:@"street"];
        NSString *number = [address valueForKey:@"number"];
        NSString *addr = [NSString stringWithFormat:@"%@ %@,%@",number,street,city];
        
        NSLog(@"fetched city:%@",city);
        
        [arrAddress addObject:addr];
        [arrLat addObject:[address valueForKey:@"lat"]];
        [arrLng addObject:[address valueForKey:@"lng"]];
    }
    
    pickerView.delegate = self;
    pickerView.dataSource = self;
    //*************load address****************
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.delegate =self;
    [locationManager startUpdatingLocation];
    
    [self addMapView];
    [self addCenter];
    
    [self.view addSubview:self.lblDestination];
    [self.view addSubview:pickerView];
    [self.view addSubview:btnOk];
    
    self.lblDestination.backgroundColor = [UIColor whiteColor];
    self.lblDestination.alpha = 0.6;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.alpha = 0.6;
    self.btnOk.backgroundColor = [UIColor whiteColor];
    self.btnOk.alpha = 0.6;
    
    [btnOk addTarget:self action:@selector(startNavigateButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    currentLocation = [locations lastObject];
}


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
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.centerButton];
    [self centerButtonClicked];
    
    //[self updateAnnotations];
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

- (void)centerButtonClicked {
    [_mapView centerOnCurrentPosition];
    [_mapView animateToZoomLevel:14.0];
}


-(void)viewDidLayoutSubviews{
    //self.activityIndicator = [[UIActivityIndicatorView alloc] init];
    //self.activityIndicator.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.pickerView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.btnOk.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/1.3);
    self.lblDestination.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/6);
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *lable = (UILabel *)view;
    if(view ==nil){
        //lable = [[UILabel alloc] initWithFrame:CGRectMake(0,0,190.0f,44.0f)];
        lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 39.0f)];
        lable.textAlignment = UITextAlignmentCenter;
    }
    lable.text = [arrAddress objectAtIndex:row];
    return lable;
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"row %ld has been selected",row);
    NSLog(@"selected lat: %@ lng: %@",[arrLat objectAtIndex:row],[arrLng objectAtIndex:row]);
    self.selectedLat = [NSString stringWithFormat:@"%@",[arrLat objectAtIndex:row]];
    self.selectedLng = [NSString stringWithFormat:@"%@",[arrLng objectAtIndex:row]];
    NSLog(@"after assign value to selectedLat");
    self.lblDestination.textAlignment = UITextAlignmentCenter;
    [self.lblDestination setFont:[UIFont systemFontOfSize:15]];
    self.lblDestination.text = [NSString stringWithFormat:@"Destination is : %@",[arrAddress objectAtIndex:row]];
    //btnOk.titleLabel.text = @"Start";
    
    //[self startNavigateButtonClicked];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 50;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSLog(@"in numberOfRowsInComponent:%ld",[arrAddress count]);
    
    return [arrAddress count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


-(void)startNavigateButtonClicked{
    
    NavigationUIViewController *navUIVC = [[NavigationUIViewController alloc] init];
    
    
    navUIVC.userLocation = currentLocation;
    
    navUIVC.destinationLat = self.selectedLat;
    navUIVC.destinationLng = self.selectedLng;
    NSLog(@"startNavigationButtonClicked destinationLAT=%@",self.selectedLat);
    [self.navigationController pushViewController:navUIVC animated:YES];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
