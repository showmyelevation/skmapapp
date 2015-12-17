//
//  RootViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "RootViewController.h"
#import "MapXMLViewController.h"
#import "MapDownloadViewController.h"
#import "GPSFilesViewController.h"
#import "NavigationUIViewController.h"
#import "MapJSONViewController.h"
#import "AppDelegate.h"
#import "SKTMapsObject.h"
#import "PedestrianNavigationViewController.h"
#import "InputStartEndViewController.h"
#import "downloadRountesController.h"

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation RootViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.delegate =self;
    [locationManager startUpdatingLocation];
    
    self.navigationItem.title = @"SKMaps Demo";
    
    UITableView *featuresTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    featuresTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    featuresTableView.delegate = self;
    featuresTableView.dataSource = self;
    [self.view addSubview:featuresTableView];
    
    //self.dataSource = @[@[@"Download Maps"],@[@"Navigation",@"Pedestrain Navigation"],@[@"Add your destination"]];
    self.dataSource = @[@"Download Maps",@"Navigation",@"Pederstrain Navigation",@"Add your address",@"Download routes"];
}

#pragma mark - UITableView delegate & datasource

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    currentLocation = [locations lastObject];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numberOfRows = (int)[self.dataSource count];
    return numberOfRows;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    cell.accessoryView = nil;
    
    
    cell.textLabel.text = [self.dataSource objectAtIndex:[indexPath row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //switch ([indexPath section]) {
    switch ([indexPath row]) {
  
        case 0: //Map
        {

                    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    NSArray *packages = [appDelegate.skMapsObject packagesForType:SKTPackageTypeContinent];
                    MapJSONViewController *mapXMLVC = [[MapJSONViewController alloc]initWithNibName:@"MapJSONViewController" bundle:nil withSKMapPackages:packages];
                    [self.navigationController pushViewController:mapXMLVC animated:YES];
                    break;

        }
            return;
            
        case 1: //Navigation
        {

            
                    NavigationUIViewController *navUIVC = [[NavigationUIViewController alloc] init];
                    
                    navUIVC.userLocation = currentLocation;
                    NSLog(@"In RootViewCtl currentLocation = (%lf,%lf",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
                    [self.navigationController pushViewController:navUIVC animated:YES];
                    break;
        }
                    
            return;
        case 2:
        {
                    PedestrianNavigationViewController *pedestrianNavVC = [[PedestrianNavigationViewController alloc] init];
                    pedestrianNavVC.userLocation = currentLocation;
                    [self.navigationController pushViewController:pedestrianNavVC animated:YES];
                    break;
        }
 
            return;
            
        case 3:
        {
            
                    InputStartEndViewController *addreInputCtl = [[InputStartEndViewController alloc] init];
                    [self.navigationController pushViewController:addreInputCtl animated:YES];
                    
                    break;
           
        }
            
            return;
            
        case 4:
        {
            
            
            downloadRountesController  *downloadRtCtl = [[downloadRountesController alloc] init];
            [self.navigationController pushViewController:downloadRtCtl animated:YES];
            
            break;
            
        }
            
            return;
    
            
            
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
