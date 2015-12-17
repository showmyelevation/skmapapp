//
//  MenuSection.m
//  DemoiOS
//
//  Created by BogdanB on 10/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "MenuSection.h"

@interface MenuSection ()

@property (nonatomic, strong) NSMutableArray *mutableItems;

@end

@implementation MenuSection

+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray *)items {
    MenuSection *section = [[MenuSection alloc] init];
    section.title = title;
    section.items = items;
    
    return  section;
}

- (id)init {
    self = [super init];
    if (self) {
        self.mutableItems = [NSMutableArray array];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self fireRefresh];
}

- (void)setItems:(NSArray *)items {
    for (MenuItem *item in _mutableItems) {
        item.refreshDelegate = nil;
    }
    
    self.mutableItems = [NSMutableArray arrayWithArray:items];
    
    for (MenuItem *item in _mutableItems) {
        item.refreshDelegate = self;
    }
    
    [self fireRefresh];
}

- (NSArray *)items {
    return _mutableItems;
}

- (void)addItem:(MenuItem *)item {
    [self.mutableItems addObject:item];
    if ([self.refreshDelegate respondsToSelector:@selector(addItemAtIndex:inSection:)]) {
        [self.refreshDelegate addItemAtIndex:_mutableItems.count - 1 inSection:self];
    }
}

- (void)removeItem:(MenuItem *)item {
    NSInteger index = [_mutableItems indexOfObject:item];
    [self.mutableItems removeObject:item];
    if ([self.refreshDelegate respondsToSelector:@selector(removeItemAtIndex:inSection:)]) {
        [self.refreshDelegate removeItemAtIndex:index inSection:self];
    }
}

- (void)fireRefresh {
    if ([self.refreshDelegate respondsToSelector:@selector(refreshSection:)]) {
        [self.refreshDelegate refreshSection:self];
    }
}

- (void)refreshItem:(MenuItem *)item {
    if ([self.refreshDelegate respondsToSelector:@selector(refreshItem:inSection:)]) {
        [self.refreshDelegate refreshItem:item inSection:self];
    }
}

@end
