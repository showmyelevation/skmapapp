//
//  MenuItem.h
//  DemoiOS
//
//  Created by BogdanB on 10/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, MenuItemType) {
    MenuItemTypeMultipleOptions, //discloses another view containing the available options
    MenuItemTypeText, //discloses an editable text field
    MenuItemTypeToggle, //adds a switch to the cell
    MenuItemTypeButton, //acts as a simple button with text
    MenuItemTypeMenu, //discloses a new menu
    MenuItemTypeCustomView, //discloses the custom view similar to the text field
    MenuItemTypeColor,
    MenuItemTypeSlider
};

@protocol MenuItemDelegate;

@class MenuItem;
@class MenuSection;
@class DisclosureView;

typedef void (^MenuValueChangeBlock)(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue);
typedef void (^MenuItemSelectedBlock)(MenuItem *item);
typedef void (^MenuItemEditEndBlock)(MenuItem *item, NSObject<NSCoding> *value);

@interface MenuItem : NSObject

/** Title of the item.
 */
@property (nonatomic, strong) NSString *title;

/** Unique id used for persistence in NSUserDefaults.
    If nil, the value of the item will not persist.
 */
@property (nonatomic, strong) NSString *uniqueID;

/** The parent section.
 */
@property (nonatomic, weak) id<MenuItemDelegate> refreshDelegate;

/** A custom view to display in the cell or as a disclosure.
 */
@property (nonatomic, strong) DisclosureView *customView;

/** Access to the item's current value.
    Setting the value while having a valid uniqueID will save the value.
 */
@property (nonatomic, strong) NSObject<NSCoding> *value;

#pragma mark - Helper properties

@property (nonatomic, assign) int intValue;
@property (nonatomic, assign) unsigned int uintValue;
@property (nonatomic, assign) long longValue;
@property (nonatomic, assign) unsigned long ulongValue;
@property (nonatomic, assign) long long longlongtValue;
@property (nonatomic, assign) unsigned long long ulonglongValue;
@property (nonatomic, assign) float floatValue;
@property (nonatomic, assign) double doubleValue;
@property (nonatomic, assign) BOOL boolValue;
@property (nonatomic, strong) NSString *stringValue;
@property (nonatomic, strong) UIColor *colorValue;
@property (nonatomic, strong) NSObject<NSCoding> *defaultValue;

@property (nonatomic, assign) void *customData;

/** Min possible value.
 */
@property (nonatomic, assign) float minValue;

/** Max possible value.
 */
@property (nonatomic, assign) float maxValue;

/** Fire value change continuously.
 */
@property (nonatomic, assign) BOOL continuous;

/** Slider jumps between integer values.
 */
@property (nonatomic, assign) BOOL integerSlider;

/** The item's type.
 */
@property (nonatomic, assign) MenuItemType type;

/** A list of NSObject<NSCoding> objects.
    Used only when the type is MenuItemTypeMultipleOptions.
 */
@property (nonatomic, strong) NSArray *itemOptions;

/** A list of NSString to use in place of values for multiple options.
 */
@property (nonatomic, strong) NSArray *readableOptions;

/** A list of MenuSection.
    Used only for MenuItemTypeMenu items.
 */
@property (nonatomic, strong) NSArray *sections;

/** Number of lines that the text uses.
 */
@property (nonatomic, assign) int numberOfLines;

/** An image to be displayed on the left side of the item.
 */
@property (nonatomic, strong) UIImage *image;

/** A generic value attached to this item.
 */
@property (nonatomic, assign) void *customValue;

/** Desired background color of the item.
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/** Fired when the item is clicked.
 */
@property (nonatomic, copy) MenuItemSelectedBlock itemSelectedBlock;

/** Fired when the item value is changed. 
    Used when the type is MenuItemTypeText, MenuItemTypeToggle, MenuItemTypeMultipleOptions.
 */
@property (nonatomic, copy) MenuValueChangeBlock valueChangedBlock;

/** Fired when editing has ended.
    Currently used only with MenuItemTypeText.
 */
@property (nonatomic, copy) MenuItemEditEndBlock editEndBlock;

/** Call this to force reload the cell of this item.
*/
- (void)fireRefresh;

#pragma mark - Factory methods

/** Creates an item with MenuItemTypeMenu type.
 */
+ (instancetype)itemForMenuTypeWithTitle:(NSString *)title sections:(NSArray *)sections selectionBlock:(MenuItemSelectedBlock)block;

/** Creates an item with MenuItemTypeMultipleOptions type.
 */
+ (instancetype)itemForOptionsWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID options:(NSArray *)options readableOptions:(NSArray *)readableOptions changeBlock:(MenuValueChangeBlock)block;

/** Creates an item with MenuItemTypeText type.
 */
+ (instancetype)itemForTextWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID changeBlock:(MenuValueChangeBlock)block editEndBlock:(MenuItemEditEndBlock)editEndBlock;

/** Creates an item with MenuItemTypeToggle type.
 */
+ (instancetype)itemForToggleWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID changeBlock:(MenuValueChangeBlock)block;

/** Creates an item with MenuItemTypeButton type.
 */
+ (instancetype)itemForButtonWithTitle:(NSString *)title selectionBlock:(MenuItemSelectedBlock)block;

/** Creates an item with MenuItemTypeCustomView type.
 */
+ (instancetype)itemForCustomViewWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID view:(DisclosureView *)view;

/** Creates a slider item.
 */
+ (instancetype)itemForSliderWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID minValue:(float)min maxValue:(float)max changeBlock:(MenuValueChangeBlock)block;

+ (instancetype)itemForColorWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID changeBlock:(MenuValueChangeBlock)block;

/** Returns the item having a given ID;
 */
+ (instancetype)itemWithID:(NSString *)uniqueID;

@end

@protocol MenuItemDelegate <NSObject>

- (void)refreshItem:(MenuItem *)item;

@end
