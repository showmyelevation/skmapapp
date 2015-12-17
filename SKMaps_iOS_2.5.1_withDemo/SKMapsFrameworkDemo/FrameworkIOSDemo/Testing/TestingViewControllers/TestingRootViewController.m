//
//  TestingRootViewController.m
//  FrameworkIOSDemo
//
//  Created by BogdanB on 22/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingRootViewController.h"

@interface TestingRootViewController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *rows;
@property (nonatomic, strong) NSArray *rowControllers;

@end

@implementation TestingRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sections = @[@"Map"];

    NSArray *mapRow = @[@"Annotations", @"Map settings", @"Map Cache", @"Last rendered frame", @"CCP animation & custom view", @"Bounding box", @"Internationalization", @"Animate", @"Map style", @"Scale View", @"Callout View", @"Routing", @"Version information", @"Overlays", @"POI Tracker", @"Positioner Logging"];
    NSArray *mapRowControllers = @[@"TestingAnnotationsViewController", @"TestingMapInstancesViewController", @"TestingMapCacheViewController", @"TestingLastFrameViewController", @"TestingCCPViewController", @"TestingRenderImageInBoundingBoxViewController" , @"TestingInternationalizationViewController", @"TestingAnimateViewController", @"TestingMapStyleViewController", @"TestingScaleViewController", @"TestingCalloutViewController", @"TestingRoutingViewController" ,@"TestingMapVersionInformationViewController", @"TestingOverlayViewController", @"TestingPOITrackerViewController", @"TestingPositionerLoggingViewController"];

    self.rows = @[mapRow];
    self.rowControllers = @[mapRowControllers];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rows[section] count];
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rowId"];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rowId"];
    }
    
    cell.textLabel.text = self.rows[indexPath.section][indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class class = NSClassFromString(self.rowControllers[indexPath.section][indexPath.row]);
    UIViewController *controller = [[class alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
