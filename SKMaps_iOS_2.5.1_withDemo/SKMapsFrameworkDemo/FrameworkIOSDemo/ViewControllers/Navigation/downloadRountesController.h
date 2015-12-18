//
//  downloadRountesController.h
//  FrameworkIOSDemo
//
//  Created by john on 11/12/2015.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface downloadRountesController : UIViewController<NSXMLParserDelegate,UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tblViewRoutes;
-(void)parseXMLFile:(NSString *)pathToFile;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
