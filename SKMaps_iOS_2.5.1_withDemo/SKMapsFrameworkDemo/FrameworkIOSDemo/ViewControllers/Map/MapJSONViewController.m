//
//  MapJSONViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "MapJSONViewController.h"
#import "SKTMapsObject.h"
#import "SKTPackage.h"
#import "XMLParser.h"
#import "AppDelegate.h"
#import "MapDownloadViewController.h"
#import <SDKTools/SKTDownloadManager/Helper/SKTDownloadObjectHelper.h>

@interface MapJSONViewController () <UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic,strong) IBOutlet UITableView *mapRegionsTableView;
@property(nonatomic,strong) NSArray *packages;
@property (nonatomic, strong) NSArray *resultsArray;
@end

@implementation MapJSONViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withSKMapPackages:(NSArray*)packages
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.packages = packages;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( ![XMLParser sharedInstance].isParsingFinished )
    {
        self.activityIndicatorView.hidden = NO;
        [self.activityIndicatorView startAnimating];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(populateTableView) name:kParsingFinishedNotificationName object:nil];
    }
    else
    {
        self.activityIndicatorView.hidden = YES;
        [self populateTableView];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    SKTPackage *package = [self.resultsArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = [package nameForLanguageCode:@"en"];
    
    if ([[package childObjects] count] != 0)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (package.type != SKTPackageTypeContinent )
    {
        if (![package.packageCode isEqualToString:@"US"]) {
            UIButton *positionMeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            positionMeButton.frame = CGRectMake(200.0f, 2.0f, 100.0f, 40.0f);
            positionMeButton.tag = [indexPath row];
            [positionMeButton setTitle:@"Download" forState:UIControlStateNormal];
            [positionMeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [positionMeButton addTarget:self action:@selector(didTapDownloadButtonForRegion:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:positionMeButton];
        } else {
            //remove the download button
            for (UIView *subView in cell.contentView.subviews) {
                if ([subView isKindOfClass:[UIButton class]]) {
                    UIButton *button = (UIButton*)subView;
                    if ([button.currentTitle isEqualToString:@"Download"]) {
                        [button removeFromSuperview];
                    }
                }
            }
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"TL:(%f,%f) BR:(%f,%f)",package.bbox.latMin,package.bbox.longMax,package.bbox.latMax,package.bbox.longMin];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKTPackage *package = [self.resultsArray objectAtIndex:[indexPath row]];
    
    NSArray *childObjects = [package childObjects];
    if ([childObjects count] != 0)
    {
        MapJSONViewController *regionsVC = [[MapJSONViewController alloc] initWithNibName:@"MapJSONViewController" bundle:nil withSKMapPackages:childObjects];
        [self.navigationController pushViewController:regionsVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UI

-(void)populateTableView
{
    NSArray *sortedPackages = [self.packages sortedArrayUsingComparator:^NSComparisonResult(SKTPackage *package1, SKTPackage *package2) {
        return [[package1 nameForLanguageCode:@"en"] compare:[package2 nameForLanguageCode:@"en"]];
    }];
    
    self.resultsArray = sortedPackages;
    [self.mapRegionsTableView reloadData];
}

-(void)didTapDownloadButtonForRegion:(id)sender
{
    UIButton *downloadButton = (UIButton*)sender;
    SKTPackage *package = [_resultsArray objectAtIndex:downloadButton.tag];
    
    MapDownloadViewController *mapDownloadVC = [[MapDownloadViewController alloc]initWithNibName:@"MapDownloadViewController" bundle:nil];
    mapDownloadVC.regionToDownload = package;
    [self.navigationController pushViewController:mapDownloadVC animated:YES];
}

@end
