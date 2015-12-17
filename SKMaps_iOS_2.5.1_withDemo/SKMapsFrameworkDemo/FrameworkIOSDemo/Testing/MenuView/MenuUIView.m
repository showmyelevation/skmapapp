//
//  MenuView.m
//  DemoiOS
//
//  Created by BogdanB on 10/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "MenuUIView.h"
#import "MenuSection.h"
#import "MenuItem.h"
#import "ChoiceMenu.h"
#import "TextDisclosure.h"
#import "SliderCell.h"
#import "UIView+Additions.h"
#import "TextCell.h"
#import "ColorCell.h"

#define kButtonHeight (kDisclosureButtonSize)

@interface MenuUIView() <UITableViewDataSource, UITableViewDelegate, DisclosureViewDelegate, MenuSectionDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGRect expandedFrame;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) NSMutableArray *viewStack;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, strong) NSMutableArray *mutableSections;

@end

@implementation MenuUIView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _expanded = YES;
        _animating = NO;
        
        self.viewStack = [NSMutableArray array];
        self.clipsToBounds = YES;
        self.contentView.scrollEnabled = NO;

        [self addTable];
        self.mutableSections = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addTable {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor grayColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Public properties

- (void)setSections:(NSArray *)sections {
    for (MenuSection *section in _mutableSections) {
        section.refreshDelegate = nil;
    }
    _mutableSections = [NSMutableArray arrayWithArray:sections];
    
    for (MenuSection *section in _mutableSections) {
        section.refreshDelegate = self;
    }
    
    [_tableView reloadData];
}

- (NSArray *)sections {
    return _mutableSections;
}

- (void)setType:(MenuType)type {
    _type = type;
    if (_type == MenuTypeRoot) {
        [self.closeButton setTitle:@"≡" forState:UIControlStateNormal];
        
        CGRect frame = self.closeButton.frame;
        self.closeButton.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.titleLabel.frame = CGRectMake(kButtonHeight, 0.0, self.topView.frame.size.width, kButtonHeight);
        self.backgroundColor = [UIColor clearColor];
        [self.closeButton removeFromSuperview];
        [self addSubview:self.closeButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }
}

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    
    return hitView;
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
    self.animating = YES;
    if (self.type == MenuTypeRoot) {
        if (expanded) {
            self.topView.autoresizingMask = UIViewAutoresizingNone;
            self.contentView.autoresizingMask = UIViewAutoresizingNone;
            [UIView animateWithDuration:0.3 animations:^{
                self.contentView.hidden = YES;
                self.topView.hidden = YES;
            } completion:^(BOOL finished) {
                self.animating = NO;
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                self.contentView.hidden = NO;
                self.topView.hidden = NO;
            } completion:^(BOOL finished) {
                self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                self.animating = NO;
            }];
        }
    } else {
        
    }
}

#pragma mark - Private methods

- (NSString *)reusableIdForItem:(MenuItem *)item {
    switch (item.type) {
        case MenuItemTypeButton:
            return @"buttonID";
            break;
            
        case MenuItemTypeCustomView:
            return @"customViewID";
            break;
            
        case MenuItemTypeMenu:
            return @"menuID";
            break;
            
        case MenuItemTypeMultipleOptions:
            return @"multipleOptionsID";
            break;
            
        case MenuItemTypeText:
            return @"textID";
            break;
            
        case MenuItemTypeToggle:
            return @"toggleID";
            break;
            
        case MenuItemTypeColor:
            return @"colorID";
            
        default:
            return @"defaultID";
            break;
    }
}

- (UITableViewCell *)cellForItem:(MenuItem *)item {
    UITableViewCell *cell = nil;
    
    switch (item.type) {
        case MenuItemTypeButton:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reusableIdForItem:item]];
            break;
            
        case MenuItemTypeToggle:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reusableIdForItem:item]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
            
        case MenuItemTypeMultipleOptions:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[self reusableIdForItem:item]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case MenuItemTypeMenu:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reusableIdForItem:item]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case MenuItemTypeText:
            cell = [[TextCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[self reusableIdForItem:item]];
            cell.detailTextLabel.hidden = YES;
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case MenuItemTypeSlider:
            cell = [[SliderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[self reusableIdForItem:item]];
            break;
            
        case MenuItemTypeCustomView:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reusableIdForItem:item]];
            break;
            
        case MenuItemTypeColor:
            cell = [[ColorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reusableIdForItem:item]];
            cell.textLabel.backgroundColor = [UIColor blueColor];
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:10.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0];
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    cell.textLabel.numberOfLines = item.numberOfLines;

    return cell;
}

- (void)fillCell:(UITableViewCell *)cell forItem:(MenuItem *)item {
    cell.textLabel.text = item.title;
    [cell.textLabel sizeToFit];
    cell.accessoryView = nil;
    
    if (item.backgroundColor) {
        cell.backgroundColor = item.backgroundColor;
    } else {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    
    switch (item.type) {
        case MenuItemTypeButton:
            if (item.image) {
                cell.imageView.image = item.image;
            } else {
                cell.imageView.image = item.image;
            }
            break;
            
        case MenuItemTypeCustomView:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case MenuItemTypeMenu:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case MenuItemTypeMultipleOptions:
            if (item.readableOptions && item.value) {
                cell.detailTextLabel.text = item.readableOptions[[item.itemOptions indexOfObject:item.value]];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", item.value];
            }
            break;
            
        case MenuItemTypeText:
        {
            TextCell *textCell = (TextCell *)cell;
            textCell.textLabel.text = item.title;
            textCell.field.text = [NSString stringWithFormat:@"%@", item.value];
            textCell.item = item;
            break;
        }
            
        case MenuItemTypeToggle:
            {
                BOOL on = NO;
                if ([item.value isKindOfClass:[NSNumber class]]) {
                    on = ((NSNumber *)item.value).boolValue;
                } else {
                    [[NSException exceptionWithName:@"Invalid value" reason:@"Toggle items support only bool values as NSNumber" userInfo:nil] raise];
                }
                
                if (on) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            break;
            
        case MenuItemTypeSlider:
            {
                SliderCell *sliderCell = (SliderCell*)cell;
                sliderCell.slider.minimumValue = item.minValue;
                sliderCell.slider.maximumValue = item.maxValue;
                sliderCell.slider.value = ((NSNumber*)item.value).floatValue;
                sliderCell.slider.continuous = item.continuous;
                sliderCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", item.value];
                sliderCell.item = item;
            }
            break;
            
        case MenuItemTypeColor:
            {
                ColorCell *colorCell = (ColorCell *)cell;
                colorCell.titleLabel.text = item.title;
                colorCell.textLabel.text = @"";
                colorCell.color = item.colorValue;
                colorCell.item = item;
            }
            return;
            
        default:
            break;
    }
}

- (void)showCustomViewForItem:(MenuItem *)item {
    if (self.type == MenuTypeRoot) {
        item.customView.item = item;
        [self showDisclosureView:item.customView];
    } else {
        [self.rootMenu showDisclosureView:item.customView];
    }
}

- (void)showMenuForItem:(MenuItem *)item {
    MenuUIView *menu = [MenuUIView menuWithSections:item.sections frame:self.tableView.frame];
    menu.titleLabel.text = item.title;
    
    if (self.type == MenuTypeRoot) {
        [self showDisclosureView:menu];
        menu.rootMenu = self;
    } else {
        [self.rootMenu showDisclosureView:menu];
        menu.rootMenu = self.rootMenu;
    }
}

- (void)showMultipleOptionsForItem:(MenuItem *)item {
    ChoiceMenu *menu = [ChoiceMenu menuForItem:item frame:CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    menu.item = item;
    if (self.type == MenuTypeMenu) {
        [self.rootMenu showDisclosureView:menu];
    } else {
        [self showDisclosureView:menu];
    }
}

- (void)showTextForItem:(MenuItem *)item {
    TextDisclosure *disclosure = [TextDisclosure textDisclosureWithItem:item frame:CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    disclosure.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    if (self.type == MenuTypeMenu) {
        [self.rootMenu showDisclosureView:disclosure];
    } else {
        [self showDisclosureView:disclosure];
    }
}

- (void)showDisclosureView:(DisclosureView *)view {
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.delegate = self;
    view.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    UIView *prevView = [self.viewStack lastObject];
    [self.viewStack addObject:view];
    if (!prevView) {
        prevView = self.tableView;
    }
    
    view.frame = CGRectMake(self.contentView.frame.size.width, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self.contentView addSubview:view];
    [UIView animateWithDuration:0.3 animations:^{
        prevView.frame = CGRectMake(-self.contentView.frame.size.width / 3.0, 0.0, prevView.frame.size.width, prevView.frame.size.height);
        view.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height - kButtonHeight);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MenuSection *menuSection = self.sections[section];
    return menuSection.items.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ((MenuSection *)self.sections[section]).title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    MenuSection *section = self.sections[indexPath.section];
    MenuItem *item = section.items[indexPath.row];
    NSString *cellID = [self reusableIdForItem:item];
    cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [self cellForItem:item];
    }
    
    [self fillCell:cell forItem:item];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuSection *section = self.sections[indexPath.section];
    MenuItem *item = section.items[indexPath.row];
    
    switch (item.type) {
        case MenuItemTypeSlider:
            return 70.0;
            break;
            
        case MenuItemTypeText:
            return 70.0;
            break;
            
        case MenuItemTypeButton:
            return 55.0;
            break;
            
        case MenuItemTypeColor:
            return 230.0;
            break;
            
        default:
            return 44.0;
            break;
    }
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuSection *section = self.sections[indexPath.section];
    MenuItem *item = section.items[indexPath.row];
    
    //call selection block
    if (item.itemSelectedBlock) {
        item.itemSelectedBlock(item);
    }
    
    //do actions based on item type
    switch (item.type) {
        case MenuItemTypeButton:
            break;
            
        case MenuItemTypeCustomView:
            [self showCustomViewForItem:item];
            break;
            
        case MenuItemTypeMenu:
            [self showMenuForItem:item];
            break;
            
        case MenuItemTypeMultipleOptions:
            [self showMultipleOptionsForItem:item];
            break;
            
        case MenuItemTypeText:
//            [self showTextForItem:item];
            break;
            
        case MenuItemTypeToggle:
            {
                BOOL on = NO;
                if ([item.value isKindOfClass:[NSNumber class]]) {
                    on = ((NSNumber *)item.value).boolValue;
                } else {
                    [[NSException exceptionWithName:@"Invalid value" reason:@"Toggle items support only bool values as NSNumber" userInfo:nil] raise];
                }
                item.value = @(!on);
            }
            break;
            
        case MenuItemTypeSlider:
            break;
            
        default:
            break;
    }
}

#pragma mark - Actions

- (void)closeClicked {
    [super closeClicked];
    self.expanded = !self.expanded;
}

#pragma mark - DisclosureViewDelegate methods

- (void)disclosureViewDidClose:(DisclosureView *)view {
    [self.viewStack removeObject:view];
    UIView *prevView = [self.viewStack lastObject];
    if (!prevView) {
        prevView = self.tableView;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        prevView.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        prevView.alpha = 1.0;
        view.frame = CGRectMake(self.contentView.frame.size.width, 0.0, view.frame.size.width, view.frame.size.height);
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

#pragma mark - MenuSectionDelegate methods

- (void)refreshSection:(MenuSection *)section {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.sections indexOfObject:section]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)refreshItem:(MenuItem *)item inSection:(MenuSection *)section {
    NSInteger sectionIndex = [self.sections indexOfObject:section];
    NSInteger row = [section.items indexOfObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sectionIndex];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)addItemAtIndex:(NSInteger)index inSection:(MenuSection *)section {
    NSInteger sectionIndex = [self.sections indexOfObject:section];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:sectionIndex];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)removeItemAtIndex:(NSInteger)index inSection:(MenuSection *)section {
    NSInteger sectionIndex = [self.sections indexOfObject:section];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:sectionIndex];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)addSection:(MenuSection *)section {
    NSInteger sectionIndex = self.sections.count;
    [_mutableSections addObject:section];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)removeSection:(MenuSection *)section {
    NSInteger sectionIndex = [self.sections indexOfObject:section];
    [_mutableSections removeObject:section];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
}

+ (instancetype)rootMenuWithSections:(NSArray *)sections frame:(CGRect)frame {
    MenuUIView *menu = [[MenuUIView alloc] initWithFrame:frame];
    menu.type = MenuTypeRoot;
    menu.sections = sections;
    
    return menu;
}

+ (instancetype)menuWithSections:(NSArray *)sections frame:(CGRect)frame {
    MenuUIView *menu = [[MenuUIView alloc] initWithFrame:frame];
    menu.type = MenuTypeMenu;
    menu.sections = sections;
    
    return menu;
}

#pragma mark - Notifications

- (void)keyboardWillShowNotification:(NSNotification *)notif {
    CGRect keyRect = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.originalFrame = self.frame;
    CGRect targetFrame = self.originalFrame;
    if (self.frame.size.height + self.frame.origin.y > keyRect.origin.y) {
        targetFrame.size.height -= self.frame.size.height + self.frame.origin.y - keyRect.origin.y;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = targetFrame;
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notif {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = self.originalFrame;
    }];
}

@end
