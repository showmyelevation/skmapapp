//
//  SettingsViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <SDKTools/Navigation/Additions/UIDevice+Additions.h>

#import "SettingsViewController.h"
#import "SettingsValuesViewController.h"


typedef enum {
    RowTypeValue,
    RowTypeSwitch
} RowType;

typedef enum {
    RouteSection = 0,
    AlternativesSection,
    NavigationSection,
    DistanceFormatSection,
    LanguageSection,
    WarningInsideSection,
    WarningOutsideSection
} SectionType;

#define kFontSize ([UIDevice isiPad] ? 20.0 : 12.0)

@interface SettingsViewController () <SettingsValuesViewControllerDelegate>

@property (nonatomic, strong) NSArray *rowTypes;
@property (nonatomic, strong) SKTNavigationConfiguration *config;

@property (nonatomic, strong) NSArray *routeTypeTexts;
@property (nonatomic, strong) NSArray *navigationTypeTexts;
@property (nonatomic, strong) NSArray *languageTexts;
@property (nonatomic, strong) NSArray *languageIDs;
@property (nonatomic, strong) NSArray *distanceFormatTexts;
@property (nonatomic, strong) NSArray *speedTexts;
@property (nonatomic, strong) NSArray *warningValues;
@property (nonatomic, strong) NSArray *alternativeValues;
@property (nonatomic, strong) NSArray *settingsValuesTitles;
@property (nonatomic, strong) NSMutableArray *selectedIndexes;

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithConfigObject:(SKTNavigationConfiguration *)config {
    self = [super init];
    if (self) {
        self.config = config;
        
        [self fillFromObject];
    }
    
    return self;
}

- (void)fillFromObject {
    [self.selectedIndexes replaceObjectAtIndex:RouteSection withObject:@(self.config.routeType)];
    [self.selectedIndexes replaceObjectAtIndex:AlternativesSection withObject:@(self.config.numberOfRoutes - 1)];
    [self.selectedIndexes replaceObjectAtIndex:NavigationSection withObject:@(self.config.navigationType)];
    [self.selectedIndexes replaceObjectAtIndex:DistanceFormatSection withObject:@(self.config.distanceFormat)];
    unsigned long langIndex = [self.languageIDs indexOfObject:@(self.config.advisorLanguage)];
    [self.selectedIndexes replaceObjectAtIndex:LanguageSection withObject:@(langIndex)];
    
    unsigned long index = [self.warningValues indexOfObject:@((int)self.config.speedLimitWarningThresholdInCity)];
    [self.selectedIndexes replaceObjectAtIndex:WarningInsideSection withObject:@(index)];
    index = [self.warningValues indexOfObject:@((int)self.config.speedWarningThresholdOutsideCity)];
    [self.selectedIndexes replaceObjectAtIndex:WarningOutsideSection withObject:@(index)];
}

- (void)fillObject {
    self.config.routeType = [self.selectedIndexes[RouteSection] intValue];
    self.config.numberOfRoutes = [self.selectedIndexes[AlternativesSection] intValue] + 1;
    self.config.navigationType = [self.selectedIndexes[NavigationSection] intValue];
    self.config.distanceFormat = [self.selectedIndexes[DistanceFormatSection] intValue];
    self.config.advisorLanguage = [self.languageIDs[[self.selectedIndexes[LanguageSection] intValue]] intValue];
    
    self.config.speedLimitWarningThresholdInCity = [self.warningValues[[self.selectedIndexes[WarningInsideSection] intValue]] intValue];
    self.config.speedWarningThresholdOutsideCity = [self.warningValues[[self.selectedIndexes[WarningOutsideSection] intValue]] intValue];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.settingsValuesTitles = @[@"Route type",
                                  @"Number of routes",
                                  @"Distance format",
                                  @"Navigation type",
                                  @"Language",
                                  @"Warning threshold inside town",
                                  @"Warning threshold out of town"];
    
    self.selectedIndexes = [NSMutableArray arrayWithObjects:@(2),
                                                            @(0),
                                                            @(1),
                                                            @(0),
                                                            @(1),
                                                            @(3),
                                                            @(3),
                                                            @(0),
                                                            @(0),
                                                            @(0),
                                                            @(0),
                                                            @(0),
                                                            @(0),
                                                            @(0),
                                                            @(0),
                                                            @(0),
                                                            @(1),
                                                            nil];
    
    self.rowTypes = @[@(RowTypeValue),
                      @(RowTypeValue),
                      @(RowTypeValue),
                      @(RowTypeValue),
                      @(RowTypeValue),
                      @(RowTypeValue),
                      @(RowTypeValue),
                      @(RowTypeSwitch),
                      @(RowTypeSwitch),
                      @(RowTypeSwitch),
                      @(RowTypeSwitch),
                      @(RowTypeSwitch),
                      @(RowTypeSwitch),
                      @(RowTypeSwitch),
                      @(RowTypeSwitch),
                      @(RowTypeSwitch),
                      @(RowTypeSwitch)];
    
    self.languageTexts = @[@"English",
                           @"English US",
                           @"French",
                           @"Deutsch",
                           @"Italian",
                           @"Spanish",
                           @"Romanian",
                           @"Portuguese",
                           @"Russian",
                           @"Dansk",
                           @"Hungarian",
                           @"Polish",
                           @"Netherlands",
                           @"Turkish",
                           @"Svenska"];
    
    self.languageIDs = @[@(SKAdvisorLanguageEN),
                         @(SKAdvisorLanguageEN_US),
                         @(SKAdvisorLanguageFR),
                         @(SKAdvisorLanguageDE),
                         @(SKAdvisorLanguageIT),
                         @(SKAdvisorLanguageES),
                         @(SKAdvisorLanguageRO),
                         @(SKAdvisorLanguagePT),
                         @(SKAdvisorLanguageRU),
                         @(SKAdvisorLanguageDA),
                         @(SKAdvisorLanguageHU),
                         @(SKAdvisorLanguagePL),
                         @(SKAdvisorLanguageNL),
                         @(SKAdvisorLanguageTR),
                         @(SKAdvisorLanguageDE)];
    
    self.routeTypeTexts = @[@"Car shortest",
                            @"Car fastest",
                            @"Car efficient",
                            @"Pedestrian",
                            @"Bike fastest",
                            @"Bike shortest",
                            @"Bike quietest"];
    
    self.distanceFormatTexts = @[@"Kilometers/meters",
                                 @"Miles/feet",
                                 @"Miles/yards"];

    self.speedTexts = @[@"km/h",
                        @"mi/h",
                        @"mi/h"];
    
    self.navigationTypeTexts = @[@"Real",
                                 @"Simulation",
                                 @"Simulation from log"];
    
    self.warningValues = @[@(5), @(10), @(15), @(20), @(25)];
    
    self.alternativeValues = @[@(1), @(2), @(3)];
    
    [self fillFromObject];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self fillObject];
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
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    RowType type = [self.rowTypes[indexPath.row] intValue];
    if (type == RowTypeValue) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"ValueTypeCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ValueTypeCell"];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:kFontSize];
            cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:kFontSize];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchTypeCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchTypeCell"];
            cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:kFontSize];
            cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:kFontSize];
        }

    }
    
    switch (indexPath.row) {
        case 0:
            [self configureRouteTypeCell:cell];
            break;
            
        case 1:
            [self configureAlternativesCell:cell];
            break;
        
        case 2:
            [self configureNavigationTypeCell:cell];
            break;
            
        case 3:
            [self configureDistanceFormatCell:cell];
            break;
            
        case 4:
            [self configureLanguageCell:cell];
            break;
            
        case 5:
            [self configureSpeedWarningInTownCell:cell];
            break;
            
        case 6:
            [self configureSpeedWarningOutsideTownCell:cell];
            break;
            
        case 7:
            [self configureBackgroundNavigationCell:cell];
            break;
            
        case 8:
            [self configureAutoDayNightCell:cell];
            break;
            
        case 9:
            [self configureAudioDuringCallsCell:cell];
            break;
            
        case 10:
            [self configureFreeDriveAfterNavCell:cell];
            break;
            
        case 11:
            [self configureAvoidTollRoadsCell:cell];
            break;
            
        case 12:
            [self configureAvoidFerriesCell:cell];
            break;
            
        case 13:
            [self configureAvoidHighwaysCell:cell];
            break;
            
        case 14:
            [self configurePreventIdle:cell];
            
        case 15:
            [self configureTTSCell:cell];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.settingsValuesTitles.count && [self.rowTypes[indexPath.row] intValue] == RowTypeValue) {
        NSArray *dataSource = nil;
        
        switch (indexPath.row) {
            case 0:
                dataSource = [self datasourceForRouteType:nil];
                break;
                
            case 1:
                dataSource = [self datasourceForAlternatives:nil];
                break;
                
            case 2:
                dataSource = [self datasourceForNavigationType:nil];
                break;
                
            case 3:
                dataSource = [self datasourceForDistanceFormat:nil];
                break;
                
            case 4:
                dataSource = [self datasourceForLanguage:nil];
                break;
                
            case 5:
                dataSource = [self datasourceForSpeedWarningInsideTown:nil];
                break;
                
            case 6:
                dataSource = [self datasourceForSpeedWarningOutsideTown:nil];
                break;
                
            default:
                break;
        }
        
        SettingsValuesViewController *vc = [[SettingsValuesViewController alloc] initWithTitle:self.settingsValuesTitles[indexPath.row]
                                                                                   datasource:dataSource
                                                                                selectedIndex:[self.selectedIndexes[indexPath.row] intValue]];
        vc.tag = indexPath.row;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)settingsValuesViewController:(SettingsValuesViewController *)vc didSelectIndexPath:(NSIndexPath *)path {
    if (path.row < self.selectedIndexes.count) {
        [self.selectedIndexes replaceObjectAtIndex:vc.tag withObject:@(path.row)];
        [self.tableView reloadData];
    }
}

- (void)configureRouteTypeCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Route type";
    cell.detailTextLabel.text = self.routeTypeTexts[[self.selectedIndexes[RouteSection] intValue]];
}

- (NSArray *)datasourceForRouteType:(id)arg {
    return self.routeTypeTexts;
}

- (void)configureDistanceFormatCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Distance format";
    cell.detailTextLabel.text = self.distanceFormatTexts[[self.selectedIndexes[DistanceFormatSection] intValue]];
}

- (NSArray *)datasourceForDistanceFormat:(id)arg {
    return self.distanceFormatTexts;
}

- (void)configureNavigationTypeCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Navigation type";
    cell.detailTextLabel.text = self.navigationTypeTexts[[self.selectedIndexes[NavigationSection] intValue]];
}

- (NSArray *)datasourceForNavigationType:(id)arg {
    return self.navigationTypeTexts;
}

- (void)configureLanguageCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Language";
    cell.detailTextLabel.text = self.languageTexts[[self.selectedIndexes[LanguageSection] intValue]];
}

- (void)didSelectLanguageIndex:(NSIndexPath *)indexPath {
    [self.selectedIndexes replaceObjectAtIndex:LanguageSection withObject:@(indexPath.row)];
}

- (NSArray *)datasourceForLanguage:(id)arg {
    return self.languageTexts;
}

- (void)configureSpeedWarningInTownCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Speed warning in town";
    int index = [self.selectedIndexes[DistanceFormatSection] intValue];
    NSString *unit = self.speedTexts[index];
    NSNumber *value = self.warningValues[[self.selectedIndexes[WarningInsideSection] intValue]];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", value, unit];
}

- (void)didSelectWarningInsideIndex:(NSIndexPath *)indexPath {
    
}

- (NSArray *)datasourceForSpeedWarningInsideTown:(id)arg {
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSNumber *value in self.warningValues) {
        NSString *unit = self.speedTexts[[self.selectedIndexes[DistanceFormatSection] intValue]];
        [array addObject:[NSString stringWithFormat:@"%d %@", [value intValue], unit]];
    }
    
    return array;
}

- (void)configureSpeedWarningOutsideTownCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Speed warning out of town";
    NSString *unit = self.speedTexts[[self.selectedIndexes[DistanceFormatSection] intValue]];
    NSNumber *value = self.warningValues[[self.selectedIndexes[WarningOutsideSection] intValue]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", value, unit];
}

- (NSArray *)datasourceForSpeedWarningOutsideTown:(id)arg {
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSNumber *value in self.warningValues) {
        NSString *unit = self.speedTexts[[self.selectedIndexes[DistanceFormatSection] intValue]];
        [array addObject:[NSString stringWithFormat:@"%d %@", [value intValue], unit]];
    }
    
    return array;
}

- (void)configureAlternativesCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Number of routes";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.selectedIndexes[AlternativesSection] intValue] + 1];
}

- (NSArray *)datasourceForAlternatives:(id)arg {
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSNumber *value in self.alternativeValues) {
        [array addObject:[NSString stringWithFormat:@"%@", value]];
    }
    
    return array;
}

#pragma mark - Switch cells

- (void)configureBackgroundNavigationCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Allow background navigation";
    ((UISwitch *)cell.accessoryView).on = self.config.allowBackgroundNavigation;
    [((UISwitch *)cell.accessoryView) addTarget:self action:@selector(backgroundNavigationChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)backgroundNavigationChanged:(UISwitch *)theSwitch {
    self.config.allowBackgroundNavigation = theSwitch.on;
}

- (void)configureAutoDayNightCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Automatic day/nignt";
    ((UISwitch *)cell.accessoryView).on = self.config.automaticDayNight;
    [((UISwitch *)cell.accessoryView) addTarget:self action:@selector(autoDayNightChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)autoDayNightChanged:(UISwitch *)theSwitch {
    self.config.automaticDayNight = theSwitch.on;
}

- (void)configureAudioDuringCallsCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Allow audio during calls";
    ((UISwitch *)cell.accessoryView).on = self.config.playAudioDuringCall;
    [((UISwitch *)cell.accessoryView) addTarget:self action:@selector(audioDuringCallsChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)audioDuringCallsChanged:(UISwitch *)theSwitch {
    self.config.playAudioDuringCall = theSwitch.on;
}

- (void)configureFreeDriveAfterNavCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Continue free drive after navigation ends";
    ((UISwitch *)cell.accessoryView).on = self.config.continueFreeDriveAfterNavigationEnd;
    [((UISwitch *)cell.accessoryView) addTarget:self action:@selector(continueFreeDriveChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)continueFreeDriveChanged:(UISwitch *)theSwitch {
    //self.config.continueFreeDriveAfterNavigationEnd = theSwitch.on;on
    self.config.continueFreeDriveAfterNavigationEnd = theSwitch.on;
}

- (void)configureAvoidTollRoadsCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Avoid toll roads";
    ((UISwitch *)cell.accessoryView).on = self.config.avoidTollRoads;
    
    [((UISwitch *)cell.accessoryView) addTarget:self action:@selector(avoidTollRoadsChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)avoidTollRoadsChanged:(UISwitch *)theSwitch {
    self.config.avoidTollRoads = theSwitch.on;
}

- (void)configureAvoidFerriesCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Avoid ferries";
    ((UISwitch *)cell.accessoryView).on = self.config.avoidFerries;
    [((UISwitch *)cell.accessoryView) addTarget:self action:@selector(avoidFerriesChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)avoidFerriesChanged:(UISwitch *)theSwitch {
    self.config.avoidFerries = theSwitch.on;
}

- (void)configureAvoidHighwaysCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Avoid highways";
    ((UISwitch *)cell.accessoryView).on = self.config.avoidHighways;
    [((UISwitch *)cell.accessoryView) addTarget:self action:@selector(avoidHighwaysChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)avoidHighwaysChanged:(UISwitch *)theSwitch {
    self.config.avoidHighways = theSwitch.on;
}

- (void)configurePreventIdle:(UITableViewCell *)cell {
    cell.textLabel.text = @"Prevent standby";
    ((UISwitch *)cell.accessoryView).on = self.config.preventStandBy;
    [((UISwitch *)cell.accessoryView) addTarget:self action:@selector(preventIdleChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)preventIdleChanged:(UISwitch *)theSwitch {
    self.config.preventStandBy = theSwitch.on;
}

- (void)configureTTSCell:(UITableViewCell *)cell {
    cell.textLabel.text = @"Text to speech advices";
    ((UISwitch *)cell.accessoryView).on = self.config.preventStandBy;
    [((UISwitch *)cell.accessoryView) addTarget:self action:@selector(ttsChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)ttsChanged:(UISwitch *)theSwitch {
    self.config.useTTSAdvisor = theSwitch.on;
}

@end
