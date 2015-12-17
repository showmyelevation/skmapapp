/*
//
//  AppDelegate.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@class SKTMapsObject;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RootViewController *rootViewController;

@property(nonatomic,strong) NSMutableArray *cachedMapRegions;
@property (nonatomic, strong) SKTMapsObject *skMapsObject;

@end
*/
//
//  AppDelegate.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "NavigationUIViewController.h"
#import <CoreData/CoreData.h>

@class SKTMapsObject;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RootViewController *rootViewController;

@property(nonatomic,strong) NSMutableArray *cachedMapRegions;
@property (nonatomic, strong) SKTMapsObject *skMapsObject;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(NSURL *)applicationDocumentsDirectory;
+(AppDelegate *)appDelegate;

@end
