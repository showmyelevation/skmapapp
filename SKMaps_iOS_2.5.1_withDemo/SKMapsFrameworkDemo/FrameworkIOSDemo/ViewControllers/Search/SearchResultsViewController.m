//
//  SearchResultsViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "SearchResultsViewController.h"
#import <SKMaps/SKMaps.h>
#import <SKMaps/SKSearch.h>
#import <SKMaps/SKReverseGeocoderService.h>

@interface SearchResultsViewController () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) NSArray *resultsList;
@property(nonatomic,strong) IBOutlet UITableView *resultsTableView;
@property(nonatomic,assign) SearchType searchType;

@end

@implementation SearchResultsViewController

@synthesize resultsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil searchResults:(NSArray*)searchResults searchType:(SearchType)type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.searchType = type;
        self.resultsList=searchResults;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Search results";
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    SKSearchResult *poi = [self.resultsList objectAtIndex:[indexPath row]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[poi name]];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 2;

    NSString* categoryString = [NSString stringWithFormat:@"category_%ld",(long)[poi category]];
    cell.detailTextLabel.text = (self.searchType == SearchTypeNearby) ?[NSString stringWithFormat:@"Subcategory: %@", NSLocalizedString(categoryString, nil)] : @"";

    [poi.parentSearchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        SKSearchResultParent* parent = (SKSearchResultParent*)obj;
        if(idx<2)
        {
            cell.detailTextLabel.text  = [cell.detailTextLabel.text stringByAppendingFormat:@"%@; ",[parent name]];
        }
        else
        {
            *stop=YES;
        }
    }];

    if ([[poi name] isEqualToString:@""])
    {
        if (self.searchType == SearchTypeNearby)
        {
            cell.textLabel.text = NSLocalizedString(categoryString, nil);
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - WikiTravel article delegate

-(void)wikiTravelArticleDownloaded:(NSString *)path {
    if ([[path pathExtension] isEqualToString:@"json"]) {
        if (path) {
            [self displayInfoForArticleAtPath:path];
        }
    }
}


-(void)failedToDownloadWikiTravelArticle:(NSString *)path {
    UIAlertView *errorNet = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed", nil)
                                                       message:NSLocalizedString(@"Download article failed", nil)
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"OK" , nil)
                                             otherButtonTitles:nil];
    [errorNet show];
}

-(void) displayInfoForArticleAtPath:(NSString*) path
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* json = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        if (json) {
            UIAlertView *errorNet = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Download finished", nil)
                                                               message:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Article file was downloaded at path: ", nil), path]
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OK" , nil)
                                                     otherButtonTitles:nil];
            [errorNet show];
            
            
            NSLog(@"%@",json);
        }
    });
}

@end
