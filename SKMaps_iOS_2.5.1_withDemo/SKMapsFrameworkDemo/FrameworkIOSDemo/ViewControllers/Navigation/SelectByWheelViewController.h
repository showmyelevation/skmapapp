//
//  SelectByWheelViewController.h
//  FrameworkIOSDemo
//
//  Created by john on 16/11/2015.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <SKMaps/SKMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SelectByWheelViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,NSFetchedResultsControllerDelegate,CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@property (strong, nonatomic) IBOutlet UILabel *lblDestination;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIButton *btnOk;

@property (nonatomic, strong) UIButton *centerButton;
@property CLLocation *userLocation;

@end
