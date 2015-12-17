//
//  GPSFilesViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "GPSFilesViewController.h"
#import "GPSElementsDrawingViewController.h"
#import <CoreLocation/CLLocation.h>
#import <SKMaps/SKGPSFileElement.h>
#import <SKMaps/SKGPSFilesService.h>

@interface GPSFilesViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) IBOutlet UITableView *tracksTableView;
//@property(nonatomic,strong) NSArray* datasource;
@property(nonatomic, strong) NSMutableArray *datasource;
@property(nonatomic, strong) NSMutableArray *arrGpxFullPaths;
@property(nonatomic, strong) NSMutableArray *arrRouteNames;
@property(nonatomic,assign) GPSFileElementType type;

@property(nonatomic,strong) NSString *fileName;
@end

@implementation GPSFilesViewController

- (id)initWithType:(GPSFileElementType)type andDatasource:(NSArray*)datasource
{
    NSLog(@"initWithType type=%ld",type);
    self = [super init];
    if (self) {
        self.datasource = datasource;
        self.type = type;
    }
    return self;
}

- (id)initWithFileName:(NSString*)fileName
{
    NSLog(@"initWithFileName = %@",fileName);
    self = [super init];
    if (self) {
        self.fileName = fileName;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    //[self downloadRoutes];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"ViewDidLoad before populateTable");
    self.arrGpxFullPaths = [[NSMutableArray alloc] init];
    self.arrRouteNames = [[NSMutableArray alloc] init];
    //[self populateTable];
    ////////////////////////Coredata////////////
    NSError *error;
    AppDelegate *sharedDelegate = [AppDelegate appDelegate];
    NSManagedObjectContext *context = [sharedDelegate managedObjectContext];
    NSFetchRequest *fetchReuqets = [[NSFetchRequest alloc] init];
    NSEntityDescription *gpxFilesEntity = [NSEntityDescription entityForName:@"GpxFiles" inManagedObjectContext:context];
    [fetchReuqets setEntity:gpxFilesEntity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchReuqets error:&error];
    
    for(NSManagedObject *gpxFs in fetchedObjects){
        [context deleteObject:gpxFs];
        
    }

    NSError *saveEorro = nil;
    [context save:&saveEorro];
    
    [self populateTable];
    NSEntityDescription *gpxaFilesEntity = [NSEntityDescription entityForName:@"GpxFiles" inManagedObjectContext:context];
    [fetchReuqets setEntity:gpxaFilesEntity];
    NSArray *fetchedAObjects = [context executeFetchRequest:fetchReuqets error:&error];
    NSLog(@"ViewDidLoad number of fetchedObjects = %ld",(long)fetchedAObjects.count);
    for(NSManagedObject *gpsF in fetchedAObjects){
    
        NSString *gpxxFileName = [gpsF valueForKey:@"gpxname"];
        NSString *gpxxFullPath = [gpsF valueForKey:@"fullpath"];
        NSString *gpxxRouteName = [gpsF valueForKey:@"routename"];
        [self.arrGpxFullPaths addObject:gpxxFullPath];
        [self.arrRouteNames addObject:gpxxRouteName];
    
        NSLog(@"ViewDidLoad fetched filename :%@ fullpath: %@  routename=%@",gpxxFileName,gpxxFullPath,gpxxRouteName);
        
    }
    
    
    ////////////////////////coredata////////////
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//////======Below is for reading multiple========///////
///*
- (void) populateTable
{
    //*******code for Core data***********
    NSError *error;
    
    AppDelegate *sharedDelegate = [AppDelegate appDelegate];
    NSManagedObjectContext *context = [sharedDelegate managedObjectContext];
    //NSManagedObject *gpxFilesEntity = [NSEntityDescription insertNewObjectForEntityForName:@"GpxFiles" inManagedObjectContext:context];
    
    if (!self.datasource)
    {
        self.datasource = [[NSMutableArray alloc] init];
        
        NSString *pathgpx = [[NSBundle mainBundle] resourcePath];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *directoryAndFileNames = [fm contentsOfDirectoryAtPath:pathgpx error:&error];
        
        NSMutableArray *gpxFiles = [[NSMutableArray alloc] init];
        
        for(NSString *item in directoryAndFileNames){
            if([[item pathExtension] isEqualToString:@"gpx"]) {
                NSManagedObject *gpxFilesEntity = [NSEntityDescription insertNewObjectForEntityForName:@"GpxFiles" inManagedObjectContext:context];
                
                NSLog(@"item = %@",item);
                NSString *strGpxFilePath = [NSString stringWithFormat:@"%@/%@",pathgpx,item];
                [gpxFiles addObject:strGpxFilePath];

                NSLog(@"strGpxFilePath=%@",strGpxFilePath);
                SKGPSFileElement* root = [[SKGPSFilesService sharedInstance] loadFileAtPath:strGpxFilePath error:nil];
                //NSLog(@" in loop root=%@",root);
                NSArray *ds = [[NSArray alloc] init];
                ds = [[SKGPSFilesService sharedInstance] childElementsForElement:root error:nil];
                [gpxFilesEntity setValue:strGpxFilePath forKey:@"fullpath"];
                [gpxFilesEntity setValue:item forKey:@"routename"];
                [gpxFilesEntity setValue:item forKey:@"gpxname"];
                [self.datasource addObjectsFromArray:ds];
                
                if(![context save:&error]) {
                    NSLog(@"failed save : %@",[error localizedDescription]);
                }else{
                    NSLog(@"saved successfully");
                }
                
            }
        }
    }
    
}

///////=========Above is for reading multuple files=============/////


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"tableView arrGpxFullPath.count = %ld",self.arrGpxFullPaths.count);
    
    return self.arrGpxFullPaths.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    cell.accessoryView = nil;
    
    if (self.type != GPSFileElementPoints)
    {
        SKGPSFileElement* gpsElement = self.datasource[indexPath.row];
        cell.textLabel.text = [self.arrRouteNames objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.arrGpxFullPaths objectAtIndex:indexPath.row];
        
        if (gpsElement.type == SKGPSFileElementGPXTrackSegment || gpsElement.type == SKGPSFileElementGPXRoute || gpsElement.type ==SKGPSFileElementGPXTrack)
        {
            UIButton* renderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [renderButton setTitle:@"Draw" forState:UIControlStateNormal];
            [renderButton addTarget:self action:@selector(drawGPSCollection:event:) forControlEvents:UIControlEventTouchUpInside];
            renderButton.frame = CGRectMake(0.0f, 0.0f, 50.0f, 30.0f);;
            cell.accessoryView = renderButton;
        }
    }
    else
    {
        NSLog(@"self.type=GPSFileElementPoints:%ld",self.type);
        CLLocation* point = self.datasource[indexPath.row];
        NSLog(@"ForRowAtIndexPath indexPath.Row = %ld",(long)indexPath.row);
        NSLog(@"self.datasource=%@",self.datasource);
        cell.textLabel.text = [NSString stringWithFormat:@"(%.4f,%.4f)",point.coordinate.latitude, point.coordinate.longitude];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type != GPSFileElementPoints)
    {
        SKGPSFileElement* gpsElement1 = self.datasource[indexPath.row];
        NSLog(@"indexPath has been selected = %@",indexPath);
        NSLog(@"indexPath.row = %ld",(long)indexPath.row);
        NSLog(@"in didSelectRowAtIndex entryName = %@",gpsElement1.name);
        if (self.type == GPSFileElementCollection && gpsElement1.type == SKGPSFileElementGPXTrack)
        {
            NSArray* children = [[SKGPSFilesService sharedInstance] childElementsForElement:gpsElement1 error:nil];
            GPSFilesViewController* subList = [[GPSFilesViewController alloc] initWithType:GPSFileElementSubcollection andDatasource:children];
            NSLog(@"didSelectRowAtIndex gpsElement1.children.name[%ld]=%@,gpsElements.children.fileID[%ld]= %ld",indexPath.row,gpsElement1.name,indexPath.row,gpsElement1.fileIdentifier);
            [self.navigationController pushViewController:subList animated:YES];
        }
        else
        {
            NSArray* points = [[SKGPSFilesService sharedInstance] locationsForElement:gpsElement1];
            GPSFilesViewController* pointsVC = [[GPSFilesViewController alloc] initWithType:GPSFileElementPoints andDatasource:points];
            [self.navigationController pushViewController:pointsVC animated:YES];
        }
        
    }
}

-(IBAction)drawGPSCollection:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tracksTableView];
    NSIndexPath *indexPath = [self.tracksTableView indexPathForRowAtPoint:currentTouchPosition];
    
    SKGPSFileElement* root = [[SKGPSFilesService sharedInstance] loadFileAtPath:[self.arrGpxFullPaths objectAtIndex:indexPath.row] error:nil];
    NSLog(@"drawGPSCollection=%@",root);
    NSArray *ds = [[NSArray alloc] init];
    ds = [[SKGPSFilesService sharedInstance] childElementsForElement:root error:nil];
    
    SKGPSFileElement* gpsElement = [ds objectAtIndex:0];
    GPSElementsDrawingViewController* gpsDrawVC = [[GPSElementsDrawingViewController alloc] initWitGPSElement:gpsElement];
    [self.navigationController pushViewController:gpsDrawVC animated:YES];
}

-(NSString*)stringForType:(SKGPSFileElementType)type
{
    NSString* typeString;
    switch (type) {
        case SKGPSFileElementGPXRoot:{
            typeString = @"Root";
            break;
        }
        case SKGPSFileElementGPXRoute:{
            typeString = @"Route";
            break;
        }
        case SKGPSFileElementGPXRoutePoint:{
            typeString = @"RoutePoint";
            break;
        }
        case SKGPSFileElementGPXTrack:{
            typeString = @"Track";
            break;
        }
        case SKGPSFileElementGPXTrackSegment:{
            typeString = @"TrackSegment";
            break;
        }
        case SKGPSFileElementGPXTrackPoint:{
            typeString = @"TrackPoint";
            break;
        }
        case SKGPSFileElementGPXWaypoint:{
            typeString = @"Waypoint";
            break;
        }
        default:
            break;
    }
    return typeString;
    
}

-(void)downloadRoutes{
    
    NSURL *url = [NSURL URLWithString:@"http://myspeedshow.com/user_maps.xml"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Download queue", NULL);
    dispatch_async(downloadQueue, ^{
        NSError *err = nil;
        NSHTTPURLResponse *rsp = nil;
        NSData *rspData = [NSURLConnection sendSynchronousRequest:request returningResponse:&rsp error:&err];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO ];
            if(rspData == nil || (err != nil && [err code] != noErr)){
                NSLog(@"NO xml file download");
            }else{
                //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *path = [[paths objectAtIndex:0] stringByAppendingString:@"/userMaps.xml"];
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                [rspData writeToFile:path atomically:YES];
                NSLog(@"&&&&&&&&&&&&&&&&&xml has been saved to %@",path);
            }
        });
    });
    
}

@end
