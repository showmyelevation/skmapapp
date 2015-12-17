//
//  TestingMapVersionInformationViewController.m
//  FrameworkIOSDemo
//
//  Created by Csongor Korosi on 05/05/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingMapVersionInformationViewController.h"

@interface TestingMapVersionInformationViewController()

@property(nonatomic) SKVersionInformation *versionInformation;

@end

@implementation TestingMapVersionInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.versionInformation = [[SKMapsService sharedInstance].mapsVersioningManager.availableMapVersions objectAtIndex:0];
    [self configureMenuView];
}

- (void)configureMenuView {
    MenuSection *menuSectionForVersionInformation = [self menuSectionForVersionInformation];
    self.menuView.sections = @[menuSectionForVersionInformation];
}

- (MenuSection *)menuSectionForVersionInformation {
    MenuItem *mapVersionMenuItem = [MenuItem itemForTextWithTitle:@"Map version" uniqueID:@"TestingMapVersioningMapVersion" changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {} editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {}];
    mapVersionMenuItem.defaultValue = self.versionInformation.version;
    
    MenuItem *routerVersionMenuItem = [MenuItem itemForTextWithTitle:@"Router version" uniqueID:@"TestingMapVersioningRouterVersion" changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {} editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {}];
    routerVersionMenuItem.defaultValue = self.versionInformation.routerVersion;
    
    MenuItem *nameBrowserVersionMenuItem = [MenuItem itemForTextWithTitle:@"Name browser version" uniqueID:@"TestingMapVersioningNameBrowserVersion" changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {} editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {}];
    nameBrowserVersionMenuItem.defaultValue = self.versionInformation.routerVersion;
    
    MenuSection *settingsSection = [MenuSection sectionWithTitle:@"Version information" items:@[mapVersionMenuItem, routerVersionMenuItem, nameBrowserVersionMenuItem]];
    
    return settingsSection;
}


@end
