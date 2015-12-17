//
//  MapXMLViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "MapXMLViewController.h"
#import "TBXML.h"
#import "AppDelegate.h"
#import <SKMaps/SKMaps.h>
#import "XMLParser.h"
#import "MapDownloadViewController.h"
#import <SDKTools/SKTMaps/SKTPackages/SKTBBox.h>

@interface MapXMLViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic,strong) IBOutlet UITableView *mapRegionsTableView;
@property(nonatomic,strong) NSMutableArray *resultsArray;
@property(nonatomic,strong) SKTPackage *mapRegion;
@end

@implementation MapXMLViewController

@synthesize mapRegionsTableView,resultsArray,activityIndicatorView;

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mapRegion:(SKTPackage*)mapRegion
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.mapRegion=mapRegion;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.mapRegion)
    {
        self.navigationItem.title = [self.mapRegion nameForLanguageCode:@"en"];
    }
    else
    {
        self.navigationItem.title = @"Map Regions";
    }
    
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
    return [resultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    SKTPackage *package = [resultsArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = [package nameForLanguageCode:@"en"];
    if ([[package childObjects] count] != 0)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (package.type != SKTPackageTypeContinent)
    {
        UIButton *positionMeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        positionMeButton.frame = CGRectMake(200.0f, 2.0f, 100.0f, 40.0f);
        positionMeButton.tag = [indexPath row];
        [positionMeButton setTitle:@"Download" forState:UIControlStateNormal];
        [positionMeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [positionMeButton addTarget:self action:@selector(didTapDownloadButtonForRegion:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:positionMeButton];

        cell.detailTextLabel.text = [NSString stringWithFormat:@"TL:(%f,%f) BR:(%f,%f)",package.bbox.latMax,package.bbox.longMin,package.bbox.latMax,package.bbox.longMax];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKTPackage *package = [self.resultsArray objectAtIndex:[indexPath row]];
    if ([[package childObjects] count] != 0)
    {
        MapXMLViewController *regionsVC = [[MapXMLViewController alloc] initWithNibName:@"MapXMLViewController" bundle:nil mapRegion:package];
        [self.navigationController pushViewController:regionsVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UI

-(void)populateTableView
{
    self.resultsArray = [NSMutableArray array];
    if(self.mapRegion)
    {
        self.resultsArray = [[self.mapRegion childObjects] mutableCopy];
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.resultsArray=appDelegate.cachedMapRegions;
    }
    [mapRegionsTableView reloadData];
}

-(IBAction)didTapDownloadButtonForRegion:(id)sender
{
    UIButton *downloadButton = (UIButton*)sender;
    SKTPackage *region = [resultsArray objectAtIndex:downloadButton.tag];
    
    MapDownloadViewController *mapDownloadVC = [[MapDownloadViewController alloc]initWithNibName:@"MapDownloadViewController" bundle:nil];
    mapDownloadVC.regionToDownload = region;
    [self.navigationController pushViewController:mapDownloadVC animated:YES];
}

@end

