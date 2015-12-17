//
//  CategorySearchViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.


#import "CategorySearchViewController.h"
#import "SearchResultsViewController.h"
#import <SKMaps/SKMaps.h>

@interface CategorySearchViewController ()<UITableViewDataSource, UITableViewDelegate, SKSearchServiceDelegate>
@property(nonatomic,strong) IBOutlet UISegmentedControl *distanceSegmentedControl;
@property(nonatomic,strong) IBOutlet UITableView *categoryTableView;
@property(atomic,strong) NSMutableDictionary *datasource;

@end

@implementation CategorySearchViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.datasource = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startSearch];
}

#pragma mark - Private methods

- (IBAction) distanceChanged:(id)sender
{
    [self startSearch];
}

- (int) radiusFromSegmentedControl
{
    int index = (int)[self.distanceSegmentedControl selectedSegmentIndex];
    
    switch (index) {
        case 0:
            return 2000;
            break;
        case 1:
            return 5000;
            break;
        case 2:
            return 8000;
            break;
            
        default:
            return 1000;
            break;
    }
}

- (NSString*) categoryNameForId:(NSNumber*) category
{
    NSString* stringValue = @"";
    
    switch ([category intValue]) {
        case 1:
            stringValue = @"Food";
            break;
        case 2:
            stringValue = @"Health";
            break;
        case 3:
            stringValue = @"Leisure";
            break;
        case 4:
            stringValue = @"Nightlife";
            break;
        case 5:
            stringValue = @"Public";
            break;
        case 6:
            stringValue = @"Service";
            break;
        case 7:
            stringValue = @"Shopping";
            break;
        case 8:
            stringValue = @"Sleeping";
            break;
        case 9:
            stringValue = @"Transport";
            break;
        default:
            break;
    }
    return NSLocalizedString(stringValue, nil);
}

- (void) startSearch
{
    int radius = [self radiusFromSegmentedControl];
    
    [[SKSearchService sharedInstance]cancelSearch];
    [SKSearchService sharedInstance].searchServiceDelegate = self;
    
    SKNearbySearchSettings* searchObject = [SKNearbySearchSettings nearbySearchSettings];
    searchObject.coordinate = CLLocationCoordinate2DMake(37.9667, 23.7167);
    searchObject.searchTerm=@"";
    searchObject.radius=radius;
    searchObject.searchMode=SKSearchHybrid;
    searchObject.searchResultSortType=SKProximitySort;
    searchObject.searchCategories = @[@(SKPOICategoryAirport),@(SKPOICategoryAtm),@(SKPOICategoryAccessoires),@(SKPOICategoryCar),@(SKPOICategoryUniversity),@(SKPOICategorySupermarket)];
    [[SKSearchService sharedInstance] setSearchResultsNumber:10000];
    [[SKSearchService sharedInstance]startNearbySearchWithSettings:searchObject];
}


#pragma mark - SKSearchServiceDelegate

-(void)searchService:(SKSearchService *)searchService didRetrieveNearbySearchResults:(NSArray *)searchResults withSearchMode:(SKSearchMode)searchMode
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.datasource removeAllObjects];
        
        for (int index = 0; index < [searchResults count]; index++) {
            SKSearchResult *currentsearchObject = [searchResults objectAtIndex:index];
            SKPOIMainCategory mainCateg = [currentsearchObject mainCategory];
            
            NSNumber* categID = [NSNumber numberWithInt:mainCateg];
            
            if (mainCateg) {
                NSMutableArray *elements = [self.datasource objectForKey:categID];
                if (!elements) {
                    elements = [[NSMutableArray alloc] init];
                    [self.datasource setObject:elements forKey:categID];
                }
                [elements addObject:currentsearchObject];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.categoryTableView reloadData];
        });
    });
}

-(void)searchService:(SKSearchService *)searchService didFailToRetrieveNearbySearchResultsWithSearchMode:(SKSearchMode)searchMode
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Failed to retrieve category search results." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Categories";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [self.datasource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSNumber* categoryID = [[self.datasource allKeys] objectAtIndex:indexPath.row];
    int nrOfPois = (int)[[self.datasource objectForKey:categoryID] count];
    
    cell.textLabel.text = [self categoryNameForId:categoryID];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Nr. of pois: %d",nrOfPois];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber* categoryID = [[self.datasource allKeys] objectAtIndex:indexPath.row];
    
    SearchResultsViewController *searchResultsVC = [[SearchResultsViewController alloc]initWithNibName:@"SearchResultsViewController" bundle:Nil searchResults:[self.datasource objectForKey:categoryID] searchType:SearchTypeNearby] ;
    [self.navigationController pushViewController:searchResultsVC animated:YES];
}

@end
