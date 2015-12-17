//
//  SettingsValuesViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <SDKTools/Navigation/Additions/UIDevice+Additions.h>

#import "SettingsValuesViewController.h"

#define kFontSize ([UIDevice isiPad] ? 20.0 : 12.0)

@interface SettingsValuesViewController ()

@property (nonatomic, strong) NSString *sectionTitle;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) NSIndexPath *selectedPath;

@end

@implementation SettingsValuesViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTitle:(NSString *)title datasource:(NSArray *)datasource selectedIndex:(int)selectedIndex {
    self = [super init];
    if (self) {
        self.sectionTitle = title;
        self.datasource = datasource;
        self.selectedPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsValueCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsValueCell"];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:kFontSize];
    }

    cell.textLabel.text = self.datasource[indexPath.row];
    if (indexPath.row == self.selectedPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitle uppercaseString];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(settingsValuesViewController:didSelectIndexPath:)]) {
        [self.delegate settingsValuesViewController:self didSelectIndexPath:self.selectedPath];
    }
}

@end
