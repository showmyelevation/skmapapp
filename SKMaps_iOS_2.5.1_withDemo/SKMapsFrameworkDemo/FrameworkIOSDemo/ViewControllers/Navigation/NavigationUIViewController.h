//
//  NavigationUIViewController.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "InputStartEndViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"


@interface NavigationUIViewController : UIViewController<NSFetchedResultsControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>{
    NSFetchedResultsController *fetcgedResultController;
    NSManagedObjectContext *managedObjectContext;
    UIPickerView *pickerView;
    
}
@property CLLocation *userLocation;
@property NSString *destinationLat;
@property NSString *destinationLng;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UIPickerView *pickerView;

@end
