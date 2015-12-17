//
//  TestingMapStyleViewController.m
//  FrameworkIOSDemo
//
//  Created by Cristian Chertes on 28/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingMapStyleViewController.h"
//#import <SKMaps/SKMapView+Style.h>

@interface TestingMapStyleViewController ()

@property (nonatomic,strong) NSArray            *mapStylesDatasource;
@property (nonatomic,strong) SKMapViewStyle     *alternativeStyle;

@end

@implementation TestingMapStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setMapViewAlternativeStyle];
    [self registerToNotifications];
    [self setMapViewAlternativeStyle];
    [self createMapStylesDatasource];
    [self configureMenuView];
}

#pragma mark - Notifications

- (void)alternativeStyleParsingFinished {
    [SKMapView loadAlternativeMapStyle:self.alternativeStyle];
}

#pragma mark - Private methods

- (void)registerToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alternativeStyleParsingFinished) name:@"kSKMapStyleParsingFinishedNotification" object:nil];
}

- (void)setMapViewAlternativeStyle {
    self.alternativeStyle = [SKMapViewStyle mapViewStyle];
    self.alternativeStyle.styleID = 1111;
    self.alternativeStyle.resourcesFolderName = @"OutdoorStyle";
    self.alternativeStyle.styleFileName = @"outdoorstyle.json";
    
    [SKMapView parseAlternativeMapStyle:self.alternativeStyle asynchronously:YES];
}

- (void)createMapStylesDatasource {
    SKMapViewStyle *dayStyle = [SKMapViewStyle mapViewStyle];
    dayStyle.resourcesFolderName = @"DayStyle";
    dayStyle.styleFileName = @"daystyle.json";
    
    SKMapViewStyle *nightStyle = [SKMapViewStyle mapViewStyle];
    nightStyle.resourcesFolderName = @"NightStyle";
    nightStyle.styleFileName = @"nightstyle.json";

    SKMapViewStyle *outdoorStyle = [SKMapViewStyle mapViewStyle];
    outdoorStyle.resourcesFolderName = @"OutdoorStyle";
    outdoorStyle.styleFileName = @"outdoorstyle.json";

    SKMapViewStyle *grayStyle = [SKMapViewStyle mapViewStyle];
    grayStyle.resourcesFolderName = @"GrayscaleStyle";
    grayStyle.styleFileName = @"grayscalestyle.json";
    
    self.mapStylesDatasource = @[dayStyle,nightStyle,outdoorStyle,grayStyle];
}

- (void)configureMenuView {
    MenuSection *mapStyleSection = [self mapStyleSection];
    
    self.menuView.sections = @[mapStyleSection];
}

- (MenuSection*)mapStyleSection {
    __weak TestingMapStyleViewController *weakSelf = self;
    
    NSArray *mapStylesOptions = @[@(0),@(1),@(2),@(3),@(4)];
    NSArray *mapStylesStrings = @[@"Day",@"Night",@"Outdoor",@"Gray",@"Alternative Style"];
    MenuItem *styleItem = [MenuItem itemForOptionsWithTitle:@"Style" uniqueID:nil options:mapStylesOptions readableOptions:mapStylesStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        NSInteger index = item.intValue;
        if (index == 4) {
            [SKMapView useAlternativeMapStyle:YES];
        } else {
            [SKMapView useAlternativeMapStyle:NO];
            [weakSelf changeStyleWithIndex:index];
        }
    }];
    styleItem.defaultValue = @(0);
    
    MenuSection *section = [MenuSection sectionWithTitle:@"Style" items:@[styleItem]];
    
    return section;
}

- (void)changeStyleWithIndex:(NSInteger)index {
    __weak TestingMapStyleViewController *weakSelf = self;

    SKMapViewStyle *style = weakSelf.mapStylesDatasource[index];
    [SKMapView setMapStyle:style];
}

@end
