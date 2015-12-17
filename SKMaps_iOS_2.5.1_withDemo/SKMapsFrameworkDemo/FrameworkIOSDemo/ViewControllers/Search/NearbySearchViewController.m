//
//  LocalSearchViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "NearbySearchViewController.h"
#import "SearchResultsViewController.h"
#import <SKMaps/SKMaps.h>

@interface NearbySearchViewController () <SKSearchServiceDelegate,UITextFieldDelegate>

@property(nonatomic,strong) IBOutlet UISegmentedControl *distanceSegmentedControl;
@property(nonatomic,strong) IBOutlet UITextField *latitudeTextField;
@property(nonatomic,strong) IBOutlet UITextField *longitudeTextField;
@property(nonatomic,strong) IBOutlet UITextField *searchTopicTextField;

-(IBAction)searchButtonCliked:(id)sender;

@end

@implementation NearbySearchViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Nearby search";
    
    self.latitudeTextField.text = @"52.5233";
    self.longitudeTextField.text = @"13.4127";
}


#pragma mark - Private methods

-(IBAction)searchButtonCliked:(id)sender
{
    NSString *searchText = self.searchTopicTextField.text;
    double lonX = [self.longitudeTextField.text doubleValue];
    double latY = [self.latitudeTextField.text doubleValue];
    int radius = [self searchRadiusInMeters];
    
    [[SKSearchService sharedInstance]cancelSearch];
    [SKSearchService sharedInstance].searchServiceDelegate = self;
    
    SKNearbySearchSettings* searchObject = [SKNearbySearchSettings nearbySearchSettings];
    searchObject.coordinate = CLLocationCoordinate2DMake(latY, lonX);
    searchObject.searchTerm=searchText;
    searchObject.radius=radius;
    searchObject.searchMode=SKSearchHybrid;
    searchObject.searchResultSortType=SKMatchSort;
    [[SKSearchService sharedInstance]startNearbySearchWithSettings:searchObject];
    
}

-(int)searchRadiusInMeters
{
    int returnValue = 0;
    switch (self.distanceSegmentedControl.selectedSegmentIndex) {
        case 0:
        {
            returnValue = 5000;
            break;
        }
        case 1:
        {
            returnValue = 10000;
            break;
        }
        case 2:
        {
            returnValue = 20000;
            break;
        }
            
        default:
            break;
    }
    return returnValue;
}


#pragma mark - SKSearchServiceDelegate

-(void)searchService:(SKSearchService *)searchService didRetrieveNearbySearchResults:(NSArray *)searchResults withSearchMode:(SKSearchMode)searchMode
{
    SearchResultsViewController *searchResultsVC = [[SearchResultsViewController alloc]initWithNibName:@"SearchResultsViewController" bundle:Nil searchResults:searchResults searchType:SearchTypeNearby] ;
    [self.navigationController pushViewController:searchResultsVC animated:YES];
}
-(void)failedToRetrieveNearBySearchResults:(SKSearchMode)searchMode
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Failed to retrieve local search results." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
