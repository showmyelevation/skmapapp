//
//  MenuView.h
//  DemoiOS
//
//  Created by BogdanB on 10/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DisclosureView.h"
#import "MenuSection.h"

typedef NS_ENUM(NSUInteger, MenuType) {
    MenuTypeRoot,
    MenuTypeMenu
};

@interface MenuUIView : DisclosureView

/** An array of MenuSection.
 */
@property (nonatomic, strong) NSArray *sections;

/** Parent menu.
 */
@property (nonatomic, weak) MenuUIView *rootMenu;

/** The type of the menu.
    Used to display the app
 */
@property (nonatomic, assign) MenuType type;

/** Expand/contract the menu.
*/
@property (nonatomic, assign) BOOL expanded;

/** Shows a disclosure view.
 */
- (void)showDisclosureView:(DisclosureView *)view;

/** Adds a new section.
 */
- (void)addSection:(MenuSection *)section;

/** Removes the section.
 */
- (void)removeSection:(MenuSection *)section;

/** Creates the root menu.
 */
+ (instancetype)rootMenuWithSections:(NSArray *)sections frame:(CGRect)frame;

@end
