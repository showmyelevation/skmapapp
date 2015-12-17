//
//  InputStartEndViewController.h
//  FrameworkIOSDemo
//
//  Created by john on 27/10/2015.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SKMaps/SKMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface InputStartEndViewController  : UIViewController<SKSearchServiceDelegate,NSFetchedResultsControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@property (nonatomic, strong) UITextField *txtNickName;
@property (nonatomic, strong) UITextField *txtAddr;
@property (nonatomic, strong) UITextField *txtCountry;
@property (nonatomic, strong) UITextField *txtState;
@property (nonatomic, strong) UITextField *txtCity;
@property (nonatomic, strong) UITextField *txtStreet;
@property (nonatomic, strong) UITextField *txtNumber;
@property (nonatomic, strong) UIButton *btnSave;

@property (weak, nonatomic) IBOutlet UIButton *btnSet;
@property (weak, nonatomic) IBOutlet UITextField *txtDestAddr;
@property (weak, nonatomic) IBOutlet UITextField *txtStartAddr;
//@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIButton *btnStartNav;

@property CLLocation *userLocation;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
