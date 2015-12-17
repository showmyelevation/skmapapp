//
//  MenuItem.m
//  DemoiOS
//
//  Created by BogdanB on 10/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "MenuItem.h"
#import "DisclosureView.h"

static NSMapTable *items;

@interface MenuItem ()

@property (nonatomic, strong) NSNumberFormatter *formatter;

@end

@implementation MenuItem

@synthesize value = _value;

@synthesize customData;

//@synthesize customValue = _value;

#pragma mark - Public properties


- (id)init {
    self = [super init];
    if (self) {
        if (!items) {
            items = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:1];
        }
        self.formatter = [[NSNumberFormatter alloc] init];
        self.formatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.formatter.locale = [NSLocale currentLocale];
        _numberOfLines = 1;
    }
    
    return self;
}

- (void)dealloc {
    if (self.uniqueID) {
        [items removeObjectForKey:self.uniqueID];
    }
}

- (void)setValue:(NSObject<NSCoding> *)value {
    id oldValue = _value;
    if (self.uniqueID) {
        oldValue = [[NSUserDefaults standardUserDefaults] objectForKey:self.uniqueID];
        if ([oldValue isKindOfClass:[NSData class]]) {
            oldValue = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:oldValue];
        }
        
        if ([value isKindOfClass:[UIColor class]]) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:self.uniqueID];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:value forKey:self.uniqueID];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    _value = value;
    
    if (self.valueChangedBlock) {
        self.valueChangedBlock(self, value, oldValue);
    }
    
    if (self.type != MenuItemTypeText) {
        [self fireRefresh];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self fireRefresh];
}

- (void)setMinValue:(float)minValue {
    _minValue = minValue;
    [self fireRefresh];
}

- (void)setMaxValue:(float)maxValue {
    _maxValue = maxValue;
    [self fireRefresh];
}

- (void)setType:(MenuItemType)type {
    _type = type;
    [self fireRefresh];
}

- (void)setContinuous:(BOOL)continuous {
    _continuous = continuous;
    [self fireRefresh];
}

- (void)setUniqueID:(NSString *)uniqueID {
    //check for duplicate id
    if (uniqueID) {
        id obj = [items objectForKey:uniqueID];
        if (obj && obj != self) {
            [[NSException exceptionWithName:@"Duplicate menu id" reason:[NSString stringWithFormat:@"ID %@ already exists", uniqueID] userInfo:nil] raise];
        }
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (!uniqueID) {
        if (_uniqueID) {
            [userDefaults removeObjectForKey:_uniqueID];
            [items removeObjectForKey:_uniqueID];
        }
    } else {
        if (_uniqueID) {
            //update persistent value
            id obj = [userDefaults objectForKey:_uniqueID];
            [userDefaults removeObjectForKey:_uniqueID];
            if ([_value isKindOfClass:[UIColor class]]) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_value];
                [userDefaults setObject:data forKey:_uniqueID];
            } else {
                [userDefaults setObject:obj forKey:uniqueID];
            }
            
            //update the unique id in the table;
            [items removeObjectForKey:_uniqueID];
            [items setObject:self forKey:uniqueID];
        } else {
            [items setObject:self forKey:uniqueID];
            if (_value) {
                if ([_value isKindOfClass:[UIColor class]]) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_value];
                    [userDefaults setObject:data forKey:_uniqueID];
                } else {
                    [userDefaults setObject:_value forKey:uniqueID];
                }
            }
        }
    }
    
    [userDefaults synchronize];
    [self fireRefresh];
    _uniqueID = uniqueID;
}

- (NSObject<NSCoding> *)value {
    if (self.uniqueID) {
        id value = [[NSUserDefaults standardUserDefaults] valueForKey:self.uniqueID];
        if ([value isKindOfClass:[NSData class]]) {
            _value = [NSKeyedUnarchiver unarchiveObjectWithData:value];
        } else {
            _value = value;
        }
    }
    return _value;
}

- (void)setNumberOfLines:(int)numberOfLines {
    _numberOfLines = numberOfLines;
    [self fireRefresh];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self fireRefresh];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    [self fireRefresh];
}

- (void)setIntValue:(int)intValue {
    self.value = @(intValue);
}

- (int)intValue {
    if ([self.value isKindOfClass:[NSString class]]) {
        return [self.formatter numberFromString:(NSString *)self.value].intValue;
    }
    
    [self ensureNumber];
    return ((NSNumber*)self.value).intValue;
}

- (void)setUintValue:(unsigned int)uintValue {
    self.value = @(uintValue);
}

- (unsigned int)uintValue {
    if ([self.value isKindOfClass:[NSString class]]) {
        return [self.formatter numberFromString:(NSString *)self.value].unsignedIntValue;
    }
    
    [self ensureNumber];
    return ((NSNumber*)self.value).unsignedIntValue;
}


- (void)setLongValue:(long)longValue {
    self.value = @(longValue);
}

- (long)longValue {
    if ([self.value isKindOfClass:[NSString class]]) {
        return [self.formatter numberFromString:(NSString *)self.value].longValue;
    }
    
    [self ensureNumber];
    return ((NSNumber*)self.value).longValue;
}


- (void)setUlongValue:(unsigned long)ulongValue {
    self.value = @(ulongValue);
}

- (unsigned long)ulongValue {
    if ([self.value isKindOfClass:[NSString class]]) {
        return [self.formatter numberFromString:(NSString *)self.value].unsignedLongValue;
    }
    
    [self ensureNumber];
    return ((NSNumber*)self.value).unsignedLongValue;
}

- (void)setLonglongValue:(long long)longlongValue {
    self.value = @(longlongValue);
}

- (unsigned long long)ulonglongValue {
    if ([self.value isKindOfClass:[NSString class]]) {
        return [self.formatter numberFromString:(NSString *)self.value].unsignedLongLongValue;
    }
    
    [self ensureNumber];
    return ((NSNumber*)self.value).unsignedLongLongValue;
}


- (void)setUlonglongValue:(unsigned long long)ulonglongValue {
    self.value = @(ulonglongValue);
}

- (void)setDoubleValue:(double)doubleValue {
    self.value = @(doubleValue);
}

- (double)doubleValue {
    if ([self.value isKindOfClass:[NSString class]]) {
        NSString *separatorType = self.formatter.decimalSeparator;
        NSString *stringValue = (NSString *)self.value;
        if ([separatorType isEqualToString:@","]) {
            stringValue = [stringValue stringByReplacingOccurrencesOfString:@"." withString:@","];
        } else {
            stringValue = [stringValue stringByReplacingOccurrencesOfString:@"," withString:@"."];
        }
        return [self.formatter numberFromString:stringValue].doubleValue;
    }
    
    [self ensureNumber];
    return ((NSNumber*)self.value).doubleValue;
}

- (void)setFloatValue:(float)floatValue {
    self.value = @(floatValue);
}

- (float)floatValue {
    if ([self.value isKindOfClass:[NSString class]]) {
        NSString *separatorType = self.formatter.decimalSeparator;
        NSString *stringValue = (NSString *)self.value;
        if ([separatorType isEqualToString:@","]) {
            stringValue = [stringValue stringByReplacingOccurrencesOfString:@"." withString:@","];
        } else {
            stringValue = [stringValue stringByReplacingOccurrencesOfString:@"," withString:@"."];
        }
        return [self.formatter numberFromString:stringValue].floatValue;
    }
    
    [self ensureNumber];
    return ((NSNumber*)self.value).floatValue;
}

- (void)setBoolValue:(BOOL)boolValue {
    self.value = @(boolValue);
}

- (BOOL)boolValue {
    if ([self.value isKindOfClass:[NSString class]]) {
        return [self.formatter numberFromString:(NSString *)self.value].boolValue;
    }
    
    [self ensureNumber];
    return ((NSNumber*)self.value).boolValue;
}

- (void)setStringValue:(NSString *)stringValue {
    self.value = stringValue;
}

- (NSString *)stringValue {
    return [NSString stringWithFormat:@"%@", self.value];
}

- (void)setColorValue:(UIColor *)colorValue {
    self.value = colorValue;
}

- (UIColor *)colorValue {
    [self ensureColor];
    return (UIColor *)self.value;
}

- (void)setDefaultValue:(NSObject<NSCoding> *)defaultValue {
    _defaultValue = defaultValue;
    if (!self.value) {
        self.value = defaultValue;
    }
}

- (void)ensureNumber {
    if (![self.value isKindOfClass:[NSNumber class]]) {
        [[NSException exceptionWithName:@"Value is not a number" reason:@"not a number" userInfo:nil] raise];
    }
}

- (void)ensureColor {
    if (![self.value isKindOfClass:[UIColor class]]) {
        [[NSException exceptionWithName:@"Value is not a number" reason:@"not a number" userInfo:nil] raise];
    }
}

- (void)fireRefresh {
    if ([self.refreshDelegate respondsToSelector:@selector(refreshItem:)]) {
        [self.refreshDelegate refreshItem:self];
    }
}

+ (instancetype)itemForButtonWithTitle:(NSString *)title selectionBlock:(MenuItemSelectedBlock)block {
    MenuItem *item = [[MenuItem alloc] init];
    item.title = title;
    item.itemSelectedBlock = block;
    item.type = MenuItemTypeButton;
    
    return item;
}

+ (instancetype)itemForMenuTypeWithTitle:(NSString *)title sections:(NSArray *)sections selectionBlock:(MenuItemSelectedBlock)block {
    MenuItem *item = [[MenuItem alloc] init];
    item.type = MenuItemTypeMenu;
    item.title = title;
    item.sections = sections;
    item.itemSelectedBlock = block;
    
    return item;
}

+ (instancetype)itemForOptionsWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID options:(NSArray *)options readableOptions:(NSArray *)readableOptions changeBlock:(MenuValueChangeBlock)block {
    MenuItem *item = [[MenuItem alloc] init];
    item.title = title;
    item.uniqueID = uniqueID;
    item.itemOptions = options;
    item.valueChangedBlock = block;
    item.type = MenuItemTypeMultipleOptions;
    item.readableOptions = readableOptions;
    
    return item;
}

+ (instancetype)itemForTextWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID changeBlock:(MenuValueChangeBlock)block editEndBlock:(MenuItemEditEndBlock)editEndBlock{
    MenuItem *item = [[MenuItem alloc] init];
    item.title = title;
    item.type = MenuItemTypeText;
    item.uniqueID = uniqueID;
    item.valueChangedBlock = block;
    item.editEndBlock = editEndBlock;
    
    return item;
}

+ (instancetype)itemForToggleWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID changeBlock:(MenuValueChangeBlock)block {
    MenuItem *item = [[MenuItem alloc] init];
    item.title = title;
    item.uniqueID = uniqueID;
    if (!item.value) {
        item.value = @(NO);
    }
    item.valueChangedBlock = block;
    item.type = MenuItemTypeToggle;
    
    return item;
}

+ (instancetype)itemForCustomViewWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID view:(DisclosureView *)view {
    MenuItem *item = [[MenuItem alloc] init];
    item.title = title;
    item.uniqueID = uniqueID;
    item.type = MenuItemTypeCustomView;
    item.customView = view;
    
    return item;
}

+ (instancetype)itemForSliderWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID minValue:(float)min maxValue:(float)max changeBlock:(MenuValueChangeBlock)block {
    MenuItem *item = [[MenuItem alloc] init];
    item.title = title;
    item.type = MenuItemTypeSlider;
    item.uniqueID = uniqueID;
    item.minValue = min;
    item.maxValue = max;
    item.continuous = YES;
    item.valueChangedBlock = block;
    
    return item;
}

+ (instancetype)itemForColorWithTitle:(NSString *)title uniqueID:(NSString *)uniqueID changeBlock:(MenuValueChangeBlock)block {
    MenuItem *item = [[MenuItem alloc] init];
    item.title = title;
    item.uniqueID = uniqueID;
    item.type = MenuItemTypeColor;
    item.valueChangedBlock = block;
    
    return item;
}

+ (instancetype)itemWithID:(NSString *)uniqueID {
    return [items objectForKey:uniqueID];
}

@end
