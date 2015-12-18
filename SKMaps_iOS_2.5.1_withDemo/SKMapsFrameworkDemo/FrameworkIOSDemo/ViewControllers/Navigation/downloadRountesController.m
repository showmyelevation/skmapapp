//
//  downloadRountesController.m
//  FrameworkIOSDemo
//
//  Created by john on 11/12/2015.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "downloadRountesController.h"

@interface downloadRountesController (){
    NSXMLParser *parser;
    NSMutableArray *mapRoutes;
    NSMutableDictionary *mapRoute;
    NSMutableString *map_id;
    NSMutableString *map_desc;
    NSString *element;
}

@property (nonatomic, retain)NSMutableArray *arrMap_id;
@property (nonatomic, retain)NSMutableArray *arrMap_desc;
@property (nonatomic, retain)NSMutableArray *arrfullPath;
@property NSString *downloadedXMLPath;
@property NSString *currentElementValue;

@end


@implementation downloadRountesController

@synthesize arrMap_id;
@synthesize arrMap_desc;
@synthesize arrfullPath;
@synthesize currentElementValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrMap_desc = [[NSMutableArray alloc] init];
    arrMap_id = [[NSMutableArray alloc] init];
    
    [self downloadRoutesWithURL:@"http://myspeedshow.com/user_maps.xml" saveToFile:@"userMaps.xml" doXMLParsing:YES refreshTableview:YES];
    // Do any additional setup after loading the view from its nib.
    
    mapRoutes = [[NSMutableArray alloc] init];
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrMap_desc count] ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *routesViewTableIdentifier = @"routesTableview";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:routesViewTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:routesViewTableIdentifier];
        
    }
    cell.textLabel.text = [arrMap_desc objectAtIndex:indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *map_id_str = [arrMap_id objectAtIndex:[indexPath row]];
    NSString *map_id_fn = [NSString stringWithFormat:@"%@.gpx",map_id_str];
    [self downloadRoutesWithURL:[NSString stringWithFormat:@"http://myspeedshow.com/gpx/gpxGenerate.php?map_id=%@",map_id_str] saveToFile:@"dummy" doXMLParsing:NO refreshTableview:NO];
    NSLog(@"didSelected download gpx");
    [self downloadRoutesWithURL:[NSString stringWithFormat:@"http://myspeedshow.com/gpx/routes/%@.gpx",map_id_str] saveToFile:map_id_fn doXMLParsing:YES refreshTableview:NO];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)parseXMLFile:(NSString *)pathToFile andRefresh:(BOOL)refresh{
    BOOL success;
    NSXMLParser *routeParser;
    //arrMap_desc = [[NSMutableArray alloc] init];
    //arrMap_id = [[NSMutableArray alloc] init];
    
    
    NSURL *xmlURL = [NSURL fileURLWithPath:pathToFile];
    routeParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    routeParser.delegate = self;
    
    [routeParser setShouldProcessNamespaces:NO];
    [routeParser setShouldReportNamespacePrefixes:NO];
    [routeParser setShouldResolveExternalEntities:NO];
    
    [routeParser setDelegate:self];
    [routeParser setShouldResolveExternalEntities:YES];
    success = [routeParser parse];
    NSLog(@"parseXMLFile success parse = %d",success);
    
    if (success) {
        NSLog(@"parseXMLFile finished number ok");
    }
    if (refresh) {
       [self.tblViewRoutes reloadData];
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    if ([elementName isEqualToString:@"map_id"]) {
        
    }else if([elementName isEqualToString:@"map_description"]){
        
    }
    
    NSLog(@"elementName=%@",elementName);
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    NSLog(@"xml %@=",string);
    currentElementValue = string;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"map_id"]) {
        [arrMap_id addObject:currentElementValue];
    }else if([elementName isEqualToString:@"map_desc"]){
        [arrMap_desc addObject:currentElementValue];
    }
    
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"Error in downloadRoutesCtl");
    NSLog(@"%@",parseError.description);
}

//-(void)downloadRoutes{
-(void)downloadRoutesWithURL:(NSString *)remoteUrl saveToFile:(NSString *)fn doXMLParsing:(BOOL)doParsing refreshTableview:(BOOL)refresh{
    
    //NSURL *url = [NSURL URLWithString:@"http://myspeedshow.com/user_maps.xml"];
    NSURL *url = [NSURL URLWithString:remoteUrl];
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
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                
                NSString *path = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%@",fn]];
                [rspData writeToFile:path atomically:YES];
                self.downloadedXMLPath = path;
                //&&&&&&&&parse through the xml file
                NSLog(@"downloadRoutesWithURL safe file to %@",path);
                if (doParsing) {
                   [self parseXMLFile:path andRefresh:refresh];
                   //&&&&&&&&parse through the xml file
                }
            };
        });
    });
    
}

-(BOOL)clearDB{
    NSError *error;
    AppDelegate *sharedDelegate = [AppDelegate appDelegate];
    NSManagedObjectContext *context = [sharedDelegate managedObjectContext];
    NSFetchRequest *fetchRequests = [[NSFetchRequest alloc] init];
    fetchRequests.entity = [NSEntityDescription entityForName:@"GpxFiles" inManagedObjectContext:context];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequests error:&error];
    for (NSManagedObject *gpxFs in fetchedObjects) {
        [context deleteObject:gpxFs];
    }
    
    if (![context save:&error]) {
        return false;
    }else {
        return true;
    }
}

////////////////////////Coredata////////////
-(BOOL)insertDBWithMapId:(NSString *)mapid fullPath:(NSString *)fulpath routeName:(NSString *)routenam {
    NSError *error;

    AppDelegate *sharedDelegate = [AppDelegate appDelegate];

    NSManagedObjectContext *context = [sharedDelegate managedObjectContext];
    
    NSManagedObject *gpxFilesEntity = [NSEntityDescription insertNewObjectForEntityForName:@"GpxFiles" inManagedObjectContext:context];

    [gpxFilesEntity setValue:fulpath forKey:@"fullpath"];
    [gpxFilesEntity setValue:routenam forKey:@"routename"];
    [gpxFilesEntity setValue:mapid forKey:@"map_id"];
    
    if(![context save:&error]) {
        NSLog(@"failed save : %@",[error localizedDescription]);
        return false;
    }else{
        NSLog(@"saved successfully");
        return true;
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
