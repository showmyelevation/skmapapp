//
//  GPSFilesViewController.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, GPSFileElementType)
{
  GPSFileElementCollection,
  GPSFileElementSubcollection,
  GPSFileElementPoints
};

@interface GPSFilesViewController : UIViewController<NSFetchedResultsControllerDelegate>

- (id)initWithFileName:(NSString*)fileName;
- (id)initWithType:(GPSFileElementType)type andDatasource:(NSArray*)datasource;



@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end