//
//  SettingsValuesViewController.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsValuesViewControllerDelegate;

@interface SettingsValuesViewController : UITableViewController

@property (nonatomic, weak) id<SettingsValuesViewControllerDelegate> delegate;

@property (nonatomic, assign) NSUInteger tag;

- (id)initWithTitle:(NSString *)title datasource:(NSArray *)datasource selectedIndex:(int)selectedIndex;

@end

@protocol SettingsValuesViewControllerDelegate <NSObject>

- (void)settingsValuesViewController:(SettingsValuesViewController *)vc didSelectIndexPath:(NSIndexPath *)path;

@end
