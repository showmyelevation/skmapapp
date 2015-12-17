
//
//  AppDelegate.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <SKMaps/SKMaps.h>
#import "XMLParser.h"

#import <SKTDownloadAPI.h>

@interface AppDelegate ()<SKMapVersioningDelegate>

@end

@implementation AppDelegate

@synthesize  managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString* const API_KEY = @"c9c454188f9b384d94313c4d92fab04653ccdd94ecab10de8fd209fc57e6d2c5";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    SKMapsInitSettings* initSettings = [[SKMapsInitSettings alloc]init];
    initSettings.mapDetailLevel = SKMapDetailLevelFull; //Use Full version of maps.
    //Can be set to a light version.
    
    [[SKMapsService sharedInstance]initializeSKMapsWithAPIKey:API_KEY settings:initSettings];
    [[SKPositionerService sharedInstance]startLocationUpdate];
    [SKMapsService sharedInstance].mapsVersioningManager.delegate= self;
    
    [SKTDownloadManager sharedInstance];
    
    NavigationUIViewController *navUIViewController = [[NavigationUIViewController alloc] init];
    navUIViewController.managedObjectContext = self.managedObjectContext;
    
    
    self.rootViewController = [[RootViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:self.rootViewController];
    navigationController.navigationBar.translucent = NO;
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    self.cachedMapRegions = [NSMutableArray array];
    
    return YES;
}



- (void)mapsVersioningManager:(SKMapsVersioningManager *)versioningManager loadedWithMapVersion:(NSString *)currentMapVersion
{
    NSLog(@"Map version file download finished.\n");
    //needs to be updated for a new map version
    [[XMLParser sharedInstance] downloadAndParseJSON];
}

- (void)mapsVersioningManager:(SKMapsVersioningManager *)versioningManager loadedWithOfflinePackages:(NSArray *)packages updatablePackages:(NSArray *)updatablePackages
{
    NSLog(@"%lu updatable packages",(unsigned long)updatablePackages.count);
    for (SKMapPackage *package in updatablePackages)
    {
        NSLog(@"%@",package.name);
    }
}

- (void)mapsVersioningManager:(SKMapsVersioningManager *)versioningManager detectedNewAvailableMapVersion:(NSString *)latestMapVersion currentMapVersion:(NSString *)currentMapVersion
{
    NSLog(@"Current map version: %@ \n Latest map version: %@",currentMapVersion, latestMapVersion);
    
    NSString* message = [NSString stringWithFormat:@"A new map version is available on the server: %@ \n Current map version: %@",latestMapVersion,currentMapVersion];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New map version available" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
        [alert show];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSArray *availableVersions = [[SKMapsService sharedInstance].mapsVersioningManager availableMapVersions];
        SKVersionInformation *latestVersion = availableVersions[0];
        [[SKMapsService sharedInstance].mapsVersioningManager updateToVersion:latestVersion.version];
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        //[NSManagedObjectContext setPersistentStoreCoordinator:coordinator];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"addressMapping" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"addressMapping.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

+(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end


