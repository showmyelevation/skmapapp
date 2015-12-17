//
//  MultiStepSearchViewController.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKMaps/SKMaps.h"

@interface MultiStepSearchViewController : UITableViewController<SKSearchServiceDelegate>

@property(nonatomic,strong) NSArray *dataSource;
@property(nonatomic,strong) SKMultiStepSearchSettings *multiStepObject;

@end
