//
//  TestingMapCacheViewController.m
//  FrameworkIOSDemo
//
//  Created by Cristian Chertes on 20/05/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingMapCacheViewController.h"

@interface TestingMapCacheViewController ()

@property (nonatomic, assign) long      seconds;
@property (nonatomic, strong) NSString  *deleteCachePath;

@end

@implementation TestingMapCacheViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureMenuView];
}

#pragma mark - Actions

- (void)setCacheSize:(long long)size {
    [[SKMapsService sharedInstance].tilesCacheManager setCacheLimit:size];
}

- (void)deleteAllCache {
    [[SKMapsService sharedInstance].tilesCacheManager deleteAllCache];
}

- (void)deleteOlderCache {
    __weak TestingMapCacheViewController *weakSelf = self;
    
    [[SKMapsService sharedInstance].tilesCacheManager deleteCacheOlderThan:weakSelf.seconds];
}

- (void)deleteCacheFromPath {
    __weak TestingMapCacheViewController *weakSelf = self;
    
    [[SKMapsService sharedInstance].tilesCacheManager deleteAllMapsDataWithCachesPath:weakSelf.deleteCachePath];
}

#pragma mark - Private methods

- (void)configureMenuView {
    MenuSection *infoSection = [self infoSection];
    MenuSection *deleteSection = [self deleteSection];
    
    self.menuView.sections = @[infoSection, deleteSection];
}

- (MenuSection *)infoSection {
    __weak TestingMapCacheViewController *weakSelf = self;
    
    MenuItem *cacheSizeItem = [MenuItem itemForButtonWithTitle:@"Cache Size" selectionBlock:nil];
    cacheSizeItem.title = [NSString stringWithFormat:@"Cache Size: %llu",[SKMapsService sharedInstance].tilesCacheManager.cacheSize];
    
    MenuItem *setCacheSizeItem = [MenuItem itemForTextWithTitle:@"Set Cache Size" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        [weakSelf setCacheSize:item.longlongtValue];
    } editEndBlock:nil];
    setCacheSizeItem.longValue = 2767304;
    
    MenuSection *infoSection = [MenuSection sectionWithTitle:@"Cache Info" items:@[cacheSizeItem, setCacheSizeItem]];
    
    return infoSection;
}

- (MenuSection *)deleteSection {
    __weak TestingMapCacheViewController *weakSelf = self;
    
    NSString *libPath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Caches"] stringByAppendingPathComponent:@"maps"];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *cachePathsOptions = @[libPath, docPath];
    MenuItem *cachePathsItem = [MenuItem itemForOptionsWithTitle:@"Cache Paths" uniqueID:nil options:cachePathsOptions readableOptions:cachePathsOptions changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.deleteCachePath = item.stringValue;
    }];
    cachePathsItem.stringValue = libPath;
    
    MenuItem *deleteCacheFromPathItem = [MenuItem itemForButtonWithTitle:@"Delete Cache From Path" selectionBlock:^(MenuItem *item) {
        [weakSelf deleteCacheFromPath];
    }];
    
    MenuItem *deleteAllCacheItem = [MenuItem itemForButtonWithTitle:@"Delete All Cache" selectionBlock:^(MenuItem *item) {
        [weakSelf deleteAllCache];
    }];
    
    MenuItem *secondsItem = [MenuItem itemForSliderWithTitle:@"Seconds" uniqueID:nil minValue:1.0 maxValue:200.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.seconds = item.longValue;
    }];
    secondsItem.longValue = 50.0;
    
    MenuItem *deleteCacheOlderThanItem = [MenuItem itemForButtonWithTitle:@"Delete Cache Older" selectionBlock:^(MenuItem *item) {
        [weakSelf deleteOlderCache];
    }];
    
    MenuSection *deleteSection = [MenuSection sectionWithTitle:@"Delete Cache" items:@[cachePathsItem, deleteCacheFromPathItem, deleteAllCacheItem, secondsItem, deleteCacheOlderThanItem]];
    
    return deleteSection;
}

@end
