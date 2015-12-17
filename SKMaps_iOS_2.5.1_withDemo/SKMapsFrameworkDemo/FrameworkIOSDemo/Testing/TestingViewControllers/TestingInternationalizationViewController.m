//
//  TestingInternationalizationViewController.m
//  FrameworkIOSDemo
//
//  Created by Cristian Chertes on 28/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingInternationalizationViewController.h"

@interface TestingInternationalizationViewController ()

@property (nonatomic, strong) SKMapInternationalizationSettings *internationalizationSettings;

@end

@implementation TestingInternationalizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createMapInternationalizationSettings];
    [self configureMenuView];
}

#pragma mark - Private methods

- (void)createMapInternationalizationSettings {
    self.internationalizationSettings = [SKMapInternationalizationSettings mapInternationalization];
}

- (void)configureMenuView {
    MenuSection *optionsSection = [self optionsSection];
    
    self.menuView.sections = @[optionsSection];
}

- (void)updateMapInternationalizationSettings {
    __weak TestingInternationalizationViewController *weakSelf = self;
    
    weakSelf.mapView.settings.mapInternationalization = weakSelf.internationalizationSettings;
}

- (MenuSection *)optionsSection {
    __weak TestingInternationalizationViewController *weakSelf = self;
    
    NSArray *primaryOptionsArray = @[@(SKMapInternationalizationOptionNone),@(SKMapInternationalizationOptionLocal),@(SKMapInternationalizationOptionTransliterated),@(SKMapInternationalizationOptionInternational)];
    NSArray *primaryOptionsStrings = @[@"None", @"Local", @"Transliterated", @"International"];
    MenuItem *primaryOptionItem = [MenuItem itemForOptionsWithTitle:@"Primary Option" uniqueID:nil options:primaryOptionsArray readableOptions:primaryOptionsStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKMapInternationalizationOption option = (SKMapInternationalizationOption)item.ulongValue;
        weakSelf.internationalizationSettings.primaryOption = option;
        [weakSelf updateMapInternationalizationSettings];
    }];
    primaryOptionItem.defaultValue = @(SKMapInternationalizationOptionNone);
    
    MenuItem *fallbackOptionItem = [MenuItem itemForOptionsWithTitle:@"Fallback Option" uniqueID:nil options:primaryOptionsArray readableOptions:primaryOptionsStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKMapInternationalizationOption option = (SKMapInternationalizationOption)item.ulongValue;
        weakSelf.internationalizationSettings.fallbackOption = option;
        [weakSelf updateMapInternationalizationSettings];
    }];
    fallbackOptionItem.defaultValue = @(SKMapInternationalizationOptionNone);
    
    NSArray *internationalLanguagesArray = @[@(SKMapLanguageLOCAL),@(SKMapLanguageEN),@(SKMapLanguageDE),@(SKMapLanguageFR),@(SKMapLanguageIT),@(SKMapLanguageES),@(SKMapLanguageRU),@(SKMapLanguageTR)];
    NSArray *internationalLanguagesStrings = @[@"LOCAL", @"EN", @"DE", @"FR",@"IT", @"ES", @"RU", @"TR"];
    MenuItem *primaryInternationalLanguageItem = [MenuItem itemForOptionsWithTitle:@"Primary Option" uniqueID:nil options:internationalLanguagesArray readableOptions:internationalLanguagesStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKLanguage language = (SKLanguage)item.ulongValue;
        weakSelf.internationalizationSettings.primaryInternationalLanguage = language;
        [weakSelf updateMapInternationalizationSettings];
    }];
    primaryInternationalLanguageItem.defaultValue = @(SKMapLanguageLOCAL);
    
    MenuItem *fallbackInternationalLanguageItem = [MenuItem itemForOptionsWithTitle:@"Fallback Option" uniqueID:nil options:internationalLanguagesArray readableOptions:internationalLanguagesStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        SKLanguage language = (SKLanguage)item.ulongValue;
        weakSelf.internationalizationSettings.fallbackInternationalLanguage = language;
        [weakSelf updateMapInternationalizationSettings];
    }];
    fallbackInternationalLanguageItem.defaultValue = @(SKMapLanguageLOCAL);
    
    MenuItem *showBothOptionsItem = [MenuItem itemForToggleWithTitle:@"Show Both Options" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        BOOL showBothOptions = (BOOL)item.boolValue;
        weakSelf.internationalizationSettings.showBothOptions = showBothOptions;
        [weakSelf updateMapInternationalizationSettings];
    }];
    showBothOptionsItem.boolValue = NO;
    
    MenuItem *backupToTransliteratedItem = [MenuItem itemForToggleWithTitle:@"Backup to transliterated" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        BOOL backupToTransliterated = (BOOL)item.boolValue;
        weakSelf.internationalizationSettings.showBothOptions = backupToTransliterated;
        [weakSelf updateMapInternationalizationSettings];
    }];
    backupToTransliteratedItem.boolValue = NO;
    
    MenuSection *optionsSection = [MenuSection sectionWithTitle:@"Internationalization Settings" items:@[primaryOptionItem,fallbackOptionItem,primaryInternationalLanguageItem,fallbackInternationalLanguageItem,showBothOptionsItem,backupToTransliteratedItem]];
    
    return optionsSection;
}

@end
