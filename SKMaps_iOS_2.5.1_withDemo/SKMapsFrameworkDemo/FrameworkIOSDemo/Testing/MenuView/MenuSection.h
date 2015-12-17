//
//  MenuSection.h
//  DemoiOS
//
//  Created by BogdanB on 10/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MenuItem.h"

@protocol MenuSectionDelegate;

@interface MenuSection : NSObject <MenuItemDelegate>

@property (nonatomic, weak) id<MenuSectionDelegate> refreshDelegate;

/** The name of the section.
 */
@property (nonatomic, strong) NSString *title;

/** An array of MenuItem.
 */
@property (nonatomic, strong) NSArray *items;

+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray *)items;

/** Adds a new item to the section.
 */
- (void)addItem:(MenuItem *)item;

/** Removed the item from the section.
 */
- (void)removeItem:(MenuItem *)item;

@end

@protocol MenuSectionDelegate <NSObject>

- (void)refreshSection:(MenuSection *)section;

- (void)refreshItem:(MenuItem *)item inSection:(MenuSection *)section;

- (void)addItemAtIndex:(NSInteger)index inSection:(MenuSection *)section;

- (void)removeItemAtIndex:(NSInteger)index inSection:(MenuSection *)section;

@end
