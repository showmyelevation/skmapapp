//
//  LogFilesViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "LogFilesViewController.h"

@interface LogFilesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *logList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger selectedLogIndex;
@property (nonatomic, strong) NSString *selectedLogPath;

@end

@implementation LogFilesViewController

#pragma mark - View lifecycle

- (id)init {
	self = [super init];
	if (!self) return nil;

	return self;
}

- (void)dealloc {
	self.logList = nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self setupDataSource];
	[self addTableView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (void)setupDataSource {
	self.logList = [NSMutableArray array];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];

	NSFileManager *localFileManager = [NSFileManager defaultManager];
	NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:docsDir];

	NSString *file = @"";
	while (file = [dirEnum nextObject]) {
		if ([[file pathExtension] isEqualToString:@"log"] || [[[file pathExtension]lowercaseString] isEqualToString:@"gpx"]) {
			NSString *logFileWithPath = [docsDir stringByAppendingPathComponent:file];
			NSString *logFileName = file;
            if ([logFileWithPath isEqualToString:self.selectedLogPath]) {
                self.selectedLogIndex = self.logList.count;
            }

			NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:logFileWithPath, @"LogFileWithPath", logFileName, @"LogFileName", nil];

			[self.logList addObject:dictionary];
		}
	}
}

#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.logList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	NSDictionary *dictionary = [self.logList objectAtIndex:indexPath.row];
	cell.textLabel.text = [dictionary objectForKey:@"LogFileName"];
	cell.textLabel.numberOfLines = 2;
	cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.selected = (indexPath.row == self.selectedLogIndex);
    
	return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *dictionary = [self.logList objectAtIndex:indexPath.row];
	self.selectedLogPath = [dictionary objectForKey:@"LogFileWithPath"];
    self.selectedLogIndex = indexPath.row;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedLogPath forKey:@"navigationSelectedLogPath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logSelectedNotification" object:nil userInfo:@{@"logPath" : self.selectedLogPath}];
    
	[self.navigationController popViewControllerAnimated:YES];
}

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

@end
