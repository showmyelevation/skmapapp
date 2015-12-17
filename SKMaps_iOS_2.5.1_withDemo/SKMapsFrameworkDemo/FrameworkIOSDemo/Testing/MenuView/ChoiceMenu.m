//
//  ChoiceMenu.m
//  DemoiOS
//
//  Created by BogdanB on 11/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "ChoiceMenu.h"
#import "UIView+Additions.h"

@interface ChoiceMenu() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ChoiceMenu

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.contentView.frameWidth, self.contentView.frameHeight)];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.tableView];
        self.tableView.backgroundColor = [UIColor grayColor];
        self.contentView.scrollEnabled = NO;
    }
    
    return self;
}

- (void)setItem:(MenuItem *)item {
    [super setItem:item];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.item.itemOptions.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.item.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const cellID = @"choiceID";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:10.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    
    NSObject<NSCoding> *value = self.item.itemOptions[indexPath.row];
    if (self.item.readableOptions) {
        cell.textLabel.text = self.item.readableOptions[indexPath.row];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", value];
    }
    
    if ([value isEqual:self.item.value]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.item.value = self.item.itemOptions[indexPath.row];
    [self.tableView reloadData];
}

+ (instancetype)menuForItem:(MenuItem *)item frame:(CGRect)frame {
    ChoiceMenu *menu = [[ChoiceMenu alloc] initWithFrame:frame];
    menu.item = item;
    
    return menu;
}

@end
