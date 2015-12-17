//
//  InputStartEndViewController.m
//  FrameworkIOSDemo
//
//  Created by john on 27/10/2015.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "InputStartEndViewController.h"
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


#define kSizeMultiplier (([UIDevice isiPad] ? 2.0 : 1.0));
static SKListLevel listLevel;

@interface InputStartEndViewController ()<SKMapViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) SKMapView *mapView;
@property (nonatomic, strong) UIButton *centerButton;
@property (nonatomic, strong) UILabel *longTapInfoLabel;

@property double tappedPointLat;
@property double tappedPointLng;

@property NSString *selectedLat;
@property NSString *selectedLng;

@property NSMutableArray *arrAddress;
@property NSMutableArray *arrLat;
@property NSMutableArray *arrLng;

@end


@implementation InputStartEndViewController

@synthesize txtAddr;
@synthesize txtCity;
@synthesize txtStreet;
@synthesize txtNumber;
@synthesize btnSave;
@synthesize tappedPointLat;
@synthesize tappedPointLng;
@synthesize pickerView;
@synthesize arrAddress;
@synthesize arrLat;
@synthesize arrLng;
@synthesize btnStartNav;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [txtCity setDelegate:self];
    [txtStreet setDelegate:self];
    [txtNumber setDelegate:self];
    
    
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
    
    NSLog(@"InputStartEndViewController viewDidLoad");
    // Do any additional setup after loading the view from its nib.
    [SKSearchService sharedInstance].searchServiceDelegate = self;
    [SKSearchService sharedInstance].searchResultsNumber = 500;
    [SKMapsService sharedInstance].connectivityMode = SKConnectivityModeOffline;
    //[SKMapsService sharedInstance].connectivityMode = SKConnectivityModeOnline;
    
    listLevel = SKCountryList;
    
    NSLog(@"listLevel=%ld",listLevel);
    
    SKMultiStepSearchSettings *multiStepSearchObject = [SKMultiStepSearchSettings multiStepSearchSettings];
    multiStepSearchObject.listLevel = listLevel;
    multiStepSearchObject.offlinePackageCode = @"AU";
    
    multiStepSearchObject.searchTerm = @"";
    
    NSLog(@"searchTerm %@",multiStepSearchObject.searchTerm);
    
    multiStepSearchObject.parentIndex = -1;
    [[SKSearchService sharedInstance]startMultiStepSearchWithSettings:multiStepSearchObject];
    [self addMapView];
    [self addCenter];
        
    _longTapInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(roundf(self.view.frameWidth-140.0)/2, 0.0, 160.0 , 40.0)];
    _longTapInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _longTapInfoLabel.numberOfLines = 2;
    _longTapInfoLabel.font = [UIFont systemFontOfSize:16];
    _longTapInfoLabel.text = @"Long tap on map to select point add to address to you bookmark";
    _longTapInfoLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    _longTapInfoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_longTapInfoLabel];
    [self.view addSubview:pickerView];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.delegate =self;
    [locationManager startUpdatingLocation];
    
    [btnStartNav addTarget:self action:@selector(startNavigateButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    currentLocation = [locations lastObject];
}


-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *lable = (UILabel *)view;
    if(view ==nil){
        lable = [[UILabel alloc] initWithFrame:CGRectMake(0,0,190.0f,44.0f)];
        lable.textAlignment = UITextAlignmentLeft;
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
    
    [self startNavigateButtonClicked];
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

- (void)mapView:(SKMapView *)mapView didLongTapAtCoordinate:(CLLocationCoordinate2D)coordinate {

    tappedPointLat = coordinate.latitude;
    tappedPointLng = coordinate.longitude;
    
    
    
    self.txtNickName = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 40.0, 170, 35.0)];
    self.txtNickName.font = [UIFont fontWithName:@"Arial" size:15];
    self.txtNickName.placeholder = @"Nick Name:";
    self.txtNickName.borderStyle =UITextBorderStyleRoundedRect;
    
    
    
    self.txtCountry = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 80.0, 170, 35.0)];
    self.txtCountry.font = [UIFont fontWithName:@"Arial" size:15];
    self.txtCountry.placeholder = @"country:";
    self.txtCountry.borderStyle =UITextBorderStyleRoundedRect;
    
    self.txtState = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 120.0, 170, 35.0)];
    self.txtState.font = [UIFont fontWithName:@"Arial" size:15];
    self.txtState.placeholder = @"State:";
    self.txtState.borderStyle =UITextBorderStyleRoundedRect;
    
    txtCity = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 160.0, 170, 35.0)];
    txtCity.font = [UIFont fontWithName:@"Arial" size:15];
    txtCity.placeholder = @"City";
    txtCity.borderStyle = UITextBorderStyleRoundedRect;
    
    txtStreet = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 200.0, 170, 35)];
    txtStreet.font = [UIFont fontWithName:@"Arial" size:15];
    txtStreet.placeholder = @"Street";
    txtStreet.borderStyle = UITextBorderStyleRoundedRect;
    
    txtNumber = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 240, 170, 35.0)];
    txtNumber.font = [UIFont fontWithName:@"Arial" size:15];
    txtNumber.placeholder = @"Street Number";
    txtNumber.borderStyle = UITextBorderStyleRoundedRect;
    txtNumber.delegate = self;
    [txtNumber setReturnKeyType:UIReturnKeyDone];
    //txtAddr.clearsOnInsertion = true;
    
    //btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSave = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [btnSave addTarget:self action:@selector(saveAddress) forControlEvents:UIControlEventTouchUpInside];
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    btnSave.frame = CGRectMake(20, 280, 50, 35);
    btnSave.backgroundColor = [UIColor blueColor];
    
    if([self checkRepeat]){
        _longTapInfoLabel.text = @"The point you selected is too close to a adress exist, select the other one please";
        _longTapInfoLabel.backgroundColor = [UIColor redColor];
        
    }else{
        _longTapInfoLabel.text = @"The point you selected is alright";
        _longTapInfoLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        [self.view addSubview:self.txtNickName];
        [self.view addSubview:self.txtCountry];
        [self.view addSubview:self.txtState];
        [self.view addSubview:self.txtCity];
        [self.view addSubview:self.txtStreet];
        [self.view addSubview:self.txtNumber];
        [self.view addSubview:self.btnSave];
    
        NSLog(@"long touched Lat:%f,%f",coordinate.latitude,coordinate.longitude);
        
    }
    SKAnnotation *annotation = [SKAnnotation annotation];
    //annotation.imageSize = 64;
    
    annotation.location = coordinate;
    
    annotation.annotationType = SKAnnotationTypeGreen;
    [self.mapView addAnnotation:annotation withAnimationSettings:[SKAnimationSettings animationSettings]];
    
    //[self updateAnnotations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [txtNumber resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}



-(void)saveAddress{
    self.btnSave.backgroundColor = [UIColor greenColor];
    //*******code for Core data***********
    NSError *error;
    NSFetchRequest *fetchReuqets = [[NSFetchRequest alloc] init];
    //NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    
    AppDelegate *sharedDelegate = [AppDelegate appDelegate];
    NSManagedObjectContext *context = [sharedDelegate managedObjectContext];
    
    NSManagedObject *addressMapping = [NSEntityDescription insertNewObjectForEntityForName:@"AddressMapping" inManagedObjectContext:context];

    [addressMapping setValue:txtCity.text forKey:@"city"];
    [addressMapping setValue:self.txtCountry.text forKey:@"country"];
    [addressMapping setValue:[NSNumber numberWithDouble:tappedPointLat] forKey:@"lat"];
    [addressMapping setValue:[NSNumber numberWithDouble:tappedPointLng] forKey:@"lng"];
    [addressMapping setValue:txtNumber.text forKey:@"number"];
    [addressMapping setValue:self.txtState.text forKey:@"state"];
    [addressMapping setValue:txtStreet.text forKey:@"street"];
    [addressMapping setValue:self.txtNickName.text forKey:@"nickname"];
    
    //NSLog(@"Country:%@,State:%@,City:%@, Street:%@,Number:%@,lat:%f,lng:%f",self.txtCountry.text,self.txtState.text,txtCity.text,txtStreet.text,txtNumber.text,tappedPointLat,tappedPointLng);
    
    [self.btnSave setTitle:@"Saved" forState:UIControlStateDisabled];
    
    if(![context save:&error]) {
        NSLog(@"failed save : %@",[error localizedDescription]);
    }
    
    
     //*******code for core data***********
    
}


-(void)startNavigateButtonClicked{
    
        NavigationUIViewController *navUIVC = [[NavigationUIViewController alloc] init];
        
        
        navUIVC.userLocation = currentLocation;
    
        navUIVC.destinationLat = self.selectedLat;
        navUIVC.destinationLng = self.selectedLng;
        NSLog(@"startNavigationButtonClicked destinationLAT=%@",self.selectedLat);
        [self.navigationController pushViewController:navUIVC animated:YES];
    
    
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

-(void)searchService:(SKSearchService *)searchService didRetrieveMultiStepSearchResults:(NSArray *)searchResults{
    if ([searchResults count] != 0 && listLevel < SKInvalidListLevel) {
        if(listLevel == SKCountryList){
            listLevel = SKCityList;
        }else{
            listLevel++;
        }
    }
    
    NSLog(@"In searchService function");
    NSLog(@"searchResults[0]=%@",searchResults[0]);
    SKSearchResult *searchResult = searchResults[0];
    
    NSLog(@"SKInvalidListLevel = %ld",SKInvalidListLevel);
    
    SKMultiStepSearchSettings *multiStepSearchObject = [SKMultiStepSearchSettings multiStepSearchSettings];
    
    multiStepSearchObject.listLevel = listLevel++;
    
    multiStepSearchObject.offlinePackageCode = searchResult.offlinePackageCode;
    
    NSLog(@"searchResult.offlinePackgaeCode=%@",searchResult.offlinePackageCode);
    NSLog(@"multiStepSearchObject=%@",multiStepSearchObject);
    NSLog(@"listLevel = %ld",listLevel);
    
    
    multiStepSearchObject.searchTerm = @"";
    multiStepSearchObject.parentIndex = searchResult.identifier;
    //[[SKSearchService sharedInstance]startMultiStepSearchWithSettings:multiStepSearchObject];
    
}

-(BOOL)checkRepeat{
    
    NSLog(@"in Metnod checkRepeat");
    
    //*******code for Core data***********
    NSError *error;
    NSFetchRequest *fetchReuqets = [[NSFetchRequest alloc] init];
    
    NSLog(@"After NSFetchRequest *fetchReuqets =  ");
    
    AppDelegate *sharedDelegate = [AppDelegate appDelegate];
    NSManagedObjectContext *context = [sharedDelegate managedObjectContext];
    
    NSLog(@"After NSManagedObjectContext *context =");
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AddressMapping" inManagedObjectContext:context];
    [fetchReuqets setEntity:entity];
    
    NSLog(@"After fetchReuqets setEntity:entity");
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchReuqets error:&error];
    
    NSLog(@"Number of fetchedObjects = %ld",[fetchedObjects count]);
    
    CLLocation *tappedLoc = [[CLLocation alloc] initWithLatitude:tappedPointLat longitude:tappedPointLng];
    
    for(NSManagedObject *address in fetchedObjects){
        double latitd = [[address valueForKey:@"lat"] doubleValue];
        double longitd = [[address valueForKey:@"lng"] doubleValue];
        CLLocation *existLoc = [[CLLocation alloc] initWithLatitude:latitd longitude:longitd];
        
        CLLocationDistance dist = [tappedLoc distanceFromLocation:existLoc]*1.09361;
        NSLog(@"in loop dist");
        if(dist<5){
            NSLog(@"The distance is %f, too closed to existing db",dist);
            return true;
        }else{
            NSLog(@"The distance is %f, good to go",dist);
            //return false;
        }
    }
    
    return false;
    //*******code for core data***********
}

-(void)searchServiceDidFailToRetrieveMultiStepSearchResults:(SKSearchService *)searchService{
    NSLog(@"Search Failed");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
