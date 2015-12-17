//
//  HeatMapSettingsViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "HeatMapSettingsViewController.h"
#import "HeatMapsViewController.h"
#import <SKMaps/SKSearchService.h>

@interface HeatMapSettingsViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) NSMutableDictionary *datasource;
@property (nonatomic,retain) NSArray *allKeys;
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSMutableDictionary *subcategoryInfo;
@property (nonatomic,retain) NSMutableArray *selectedArray;

@end


@interface HeatMapSettingsViewController (PrivateUICreation)

-(void)addTableView;
-(void)addButton;

@end


@implementation HeatMapSettingsViewController

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    return self;
}

- (void)dealloc
{
    self.datasource = nil;
    self.tableView = nil;
    self.selectedArray = nil;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupDataSource];
    [self addTableView];
    [self addButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDataSource
{
    self.datasource = [NSMutableDictionary dictionaryWithDictionary:[[SKSearchService sharedInstance] categoriesFromMainCategories]];
    self.selectedArray = [NSMutableArray array];
}

- (void) showMap
{
    HeatMapsViewController* hvc = [[HeatMapsViewController alloc] initWithDatasource:self.selectedArray];
    [self.navigationController pushViewController:hvc animated:YES];
}

#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datasource.allKeys.count - 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSNumber* key = [NSNumber numberWithLong:section + 1];
    NSArray *subCateg = [self.datasource objectForKey:key];
    
    return subCateg.count;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionHeader = nil;
    switch (section) {
        case 0:
            sectionHeader = NSLocalizedString(@"category_food_type_title_key", nil);
            break;
        case 1:
            sectionHeader = NSLocalizedString(@"category_health_type_title_key", nil);
            break;
        case 2:
            sectionHeader = NSLocalizedString(@"category_leisure_type_title_key", nil);
            break;
        case 3:
            sectionHeader = NSLocalizedString(@"category_nightlife_type_title_key", nil);
            break;
        case 4:
            sectionHeader = NSLocalizedString(@"category_public_type_title_key", nil);
            break;
        case 5:
            sectionHeader = NSLocalizedString(@"category_service_type_title_key", nil);
            break;
        case 6:
            sectionHeader = NSLocalizedString(@"category_shopping_type_title_key", nil);
            break;
        case 7:
            sectionHeader = NSLocalizedString(@"category_sleeping_type_title_key", nil);
            break;
        case 8:
            sectionHeader = NSLocalizedString(@"category_transport_type_title_key", nil);
            break;
    }
    
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(10,0,300,44)];
    tempView.backgroundColor=[UIColor clearColor];
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(10,0,300,44)];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.text = sectionHeader;
    tempLabel.textColor = [UIColor whiteColor];
    [tempView addSubview: tempLabel];
    
    return tempView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSNumber* key = [NSNumber numberWithLong:indexPath.section + 1];
    NSArray *subCateg = [self.datasource objectForKey:key];
    
    NSNumber *currentValue = [subCateg objectAtIndex:indexPath.row];
    NSString *categoryValue = [NSString stringWithFormat:@"category_%@",currentValue];
    
    cell.textLabel.text = NSLocalizedString(categoryValue,nil);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.selectedArray containsObject:currentValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
    
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber* key = [NSNumber numberWithLong:indexPath.section + 1];
    NSArray *subCateg = [self.datasource objectForKey:key];
    
    NSNumber *currentValue = [subCateg objectAtIndex:indexPath.row];
 
    if ([self.selectedArray containsObject:currentValue]){
        [self.selectedArray removeObject:currentValue];
    }
    else {
        [self.selectedArray addObject:currentValue];
    }
    
    [self.tableView reloadData];
}

@end

@implementation HeatMapSettingsViewController (PrivateUICreation)

- (void)addTableView {
    CGRect tableViewRect = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 50.0;
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.tableView];
}

-(void)addButton
{
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle: @"Map"
                                                                               style: UIBarButtonItemStyleBordered
                                                                              target: self
                                                                              action: @selector(showMap)];
}

@end
