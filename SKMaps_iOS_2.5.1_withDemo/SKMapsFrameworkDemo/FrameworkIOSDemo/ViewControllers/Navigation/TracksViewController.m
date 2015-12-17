//
//  TracksViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TracksViewController.h"
#import "GPSFilesViewController.h"

@interface TracksViewController()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSMutableArray *dataSource;
@property(nonatomic,strong) UITableView *tracksTableView;

@end

@implementation TracksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    static BOOL showGPxWarning = YES;
    if (showGPxWarning)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"GPX track navigation is available for commercial use with a enterprise license. Usage without such a license will lead to your API KEY being suspended." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        showGPxWarning = NO;
    }
    
    self.tracksTableView = [[UITableView alloc]initWithFrame:self.view.frame];
    self.tracksTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tracksTableView.delegate = self;
    self.tracksTableView.dataSource = self;
    [self.view addSubview:self.tracksTableView];
    
    self.dataSource = [NSMutableArray array];
    
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] resourcePath] error:nil];
    for (NSString *fileName in dirContents)
    {
        if ([[fileName pathExtension] isEqualToString:@"gpx"])
        {
            [self.dataSource addObject:[fileName stringByDeletingPathExtension]];
        }
    }
}

#pragma mark - UITableView delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = [self.dataSource objectAtIndex:[indexPath row]];
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GPSFilesViewController *tracksVC = [[GPSFilesViewController alloc]initWithFileName:[self.dataSource objectAtIndex:[indexPath row]]];
    [self.navigationController pushViewController:tracksVC animated:YES];
}

@end
