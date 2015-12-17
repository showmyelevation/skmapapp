//
//  MultiStepSearchViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "MultiStepSearchViewController.h"

@implementation MultiStepSearchViewController

#pragma mark - Lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [SKSearchService sharedInstance].searchServiceDelegate = self;
    [SKSearchService sharedInstance].searchResultsNumber = 500;
    [SKMapsService sharedInstance].connectivityMode = SKConnectivityModeOffline;
    
    if ([self.dataSource count] == 0)
    {
        if (self.multiStepObject.listLevel == SKCountryList)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"No packages are downloaded. For downloading map packages go to the Map XML & download screen." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"The OpenStreetMap does not have feature any street/house number in your selected city." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SKMapsService sharedInstance].connectivityMode = SKConnectivityModeOnline;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (self.multiStepObject.listLevel == SKCountryList)
    {
        SKMapPackage *mapPackage = (SKMapPackage*)[self.dataSource objectAtIndex:[indexPath row]];
        cell.textLabel.text = mapPackage.name;
    }
    else
    {
        SKSearchResult *searchResult = (SKSearchResult*)[self.dataSource objectAtIndex:[indexPath row]];
        cell.textLabel.text = searchResult.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Coordinate: (%f,%f)", searchResult.coordinate.latitude,searchResult.coordinate.longitude];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.dataSource objectAtIndex:[indexPath row]] isKindOfClass:[SKMapPackage class]])
    {
        SKMapPackage *mapPackage = (SKMapPackage*)[self.dataSource objectAtIndex:[indexPath row]];
        
        SKMultiStepSearchSettings *multiStepSearchObject = [SKMultiStepSearchSettings multiStepSearchSettings];
        multiStepSearchObject.listLevel = SKCityList;
        multiStepSearchObject.offlinePackageCode = mapPackage.name;
        multiStepSearchObject.searchTerm = @"";
        multiStepSearchObject.parentIndex = -1;
        [[SKSearchService sharedInstance]startMultiStepSearchWithSettings:multiStepSearchObject];
        self.multiStepObject = multiStepSearchObject;
    }
    else
    {
        SKSearchResult *searchResult = (SKSearchResult*)[self.dataSource objectAtIndex:[indexPath row]];
        
        SKMultiStepSearchSettings *multiStepSearchObject = [SKMultiStepSearchSettings multiStepSearchSettings];
        multiStepSearchObject.listLevel = self.multiStepObject.listLevel;
        multiStepSearchObject.offlinePackageCode = self.multiStepObject.offlinePackageCode;
        multiStepSearchObject.searchTerm = @"";
        multiStepSearchObject.parentIndex = searchResult.identifier;
        [[SKSearchService sharedInstance]startMultiStepSearchWithSettings:multiStepSearchObject];
    }
}

#pragma mark - SKSearchServiceDelegate delegate

-(void)searchService:(SKSearchService *)searchService didRetrieveMultiStepSearchResults:(NSArray *)searchResults
{
    SKMultiStepSearchSettings *multiStepObjectCopy = [SKMultiStepSearchSettings multiStepSearchSettings];
    multiStepObjectCopy.offlinePackageCode = self.multiStepObject.offlinePackageCode;
    multiStepObjectCopy.listLevel = (self.multiStepObject.listLevel == SKCountryList) ? SKCityList : self.multiStepObject.listLevel + 1;
    
    MultiStepSearchViewController *multiStepSearchVC = [[MultiStepSearchViewController alloc]initWithNibName:@"MultiStepSearchViewController" bundle:nil];
    multiStepSearchVC.dataSource = searchResults;
    multiStepSearchVC.multiStepObject = multiStepObjectCopy;
    [self.navigationController pushViewController:multiStepSearchVC animated:YES];
}

-(void)searchServiceDidFailToRetrieveMultiStepSearchResults:(SKSearchService *)searchService
{
    NSLog(@"Search service did fail to retrieve results!\n");
}

@end
