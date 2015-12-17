//
//  XMLParser.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "XMLParser.h"
#import "MapRegion.h"
#import "TBXML.h"
#import "AppDelegate.h"
#import <SKMaps/SKMaps.h>
#import <SDKTools/SKTMaps/SKTMapsObject.h>

//MapXML keys.
static NSString *const kContinentsParentCode = @"world";
static NSString *const kXmlKeyPackages = @"packages";
static NSString *const kXmlKeyEn = @"en";
static NSString *const kXmlKeyFileURLMap = @"file";
static NSString *const kXmlKeyFileURLNb = @"nbzip";
static NSString *const kXMLKeyType = @"type";
static NSString *const kXMLKeyName = @"name";
static NSString *const kXmlKeyTypeCity = @"city";
static NSString *const kXmlKeyTypeState = @"state";
static NSString *const kXmlKeyTypeCountry = @"country";
static NSString *const kXmlKeyTypeContinent = @"continent";
static NSString *const kXmlKeyTextures = @"textures";
static NSString *const kXmlBBox = @"bbox";

@interface XMLParser()<NSURLConnectionDataDelegate,NSXMLParserDelegate>
@property(nonatomic,strong) NSURLConnection *jsonConnection;
@property(nonatomic,strong) NSURLConnection *xmlConnection;
@property(nonatomic,strong) NSMutableData *xmlData;
@property(nonatomic,strong) NSMutableData *jsonData;
@property(nonatomic,strong) NSMutableDictionary *_parentsDictionary;
@property(nonatomic,strong) NSMutableArray* mapRegions;
@end

@implementation XMLParser

@synthesize xmlData,_parentsDictionary;

static XMLParser* instance = nil;

+(XMLParser*)sharedInstance
{
    if (instance == nil)
    {
        instance = [[XMLParser alloc] init];
        instance.isParsingFinished = NO;
    }
    return instance;
}

#pragma mark - XML download

-(void)downloadAndParseXML
{
    self.xmlData = [NSMutableData data];
    NSString *xmlURLString = [[SKMapsService sharedInstance].packagesManager mapsXMLURLForVersion:nil];
    if (xmlURLString) {
        NSURL *xmlUrl = [[NSURL alloc]initWithString:[[SKMapsService sharedInstance].packagesManager mapsXMLURLForVersion:nil]];
        NSURLRequest *xmlRequest = [NSURLRequest requestWithURL:xmlUrl];
        self.xmlConnection = [[NSURLConnection alloc]initWithRequest:xmlRequest delegate:self];
    }
}

- (void)downloadAndParseJSON
{
    self.jsonData = [NSMutableData data];
    NSString *jsonURLString = [[SKMapsService sharedInstance].packagesManager mapsJSONURLForVersion:nil];
    if (jsonURLString) {
        NSURL *jsonURL = [[NSURL alloc]initWithString:[[SKMapsService sharedInstance].packagesManager mapsJSONURLForVersion:nil]];
        NSURLRequest *jsonRequest = [NSURLRequest requestWithURL:jsonURL];
        self.jsonConnection = [[NSURLConnection alloc]initWithRequest:jsonRequest delegate:self];
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if ([data length] != 0)
    {
        if (connection == self.jsonConnection)
        {
            [self.jsonData appendData:data];
        }
        else
        {
            [self.xmlData appendData:data];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    [self parseXML]; //when the XML is downloaded, start parsing
    [self parseJSON];
}


#pragma mark - XML parsing

-(void)parseXML
{
    TBXML *tbxml =[TBXML newTBXMLWithXMLData:xmlData error:nil];
    _parentsDictionary = [NSMutableDictionary dictionary];
    self.mapRegions = [NSMutableArray array];
    
    TBXMLElement *worldStructureElement = [TBXML childElementNamed:kContinentsParentCode parentElement:tbxml.rootXMLElement];
    if (worldStructureElement)
    {
        [self traverseWorldStructureForElement:worldStructureElement];
    }
    
    TBXMLElement *packages = [TBXML childElementNamed:kXmlKeyPackages parentElement:tbxml.rootXMLElement]; //Tparsing the map regions info
    if (packages)
    {
        [self traversePackagesContentForElement:packages];
    }
    self.isParsingFinished = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:kParsingFinishedNotificationName object:nil];
}

- (void)parseJSON
{
    NSString *jsonString = [[NSString alloc] initWithBytes:[self.jsonData bytes] length:[self.jsonData length] encoding:NSUTF8StringEncoding];
    
    SKTMapsObject *skMaps = [SKTMapsObject convertFromJSON:jsonString];
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate setSkMapsObject:skMaps];
    
    self.isParsingFinished = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:kParsingFinishedNotificationName object:nil];
}

- (void) traverseWorldStructureForElement:(TBXMLElement *)element
{
    TBXMLElement* currentElement = element->firstChild;
    do
    {
        TBXMLElement* parentElement = currentElement->parentElement;
        [_parentsDictionary setObject:[TBXML elementName:parentElement] forKey:[TBXML elementName:currentElement]];
        if(currentElement->firstChild)
        {
            [self traverseWorldStructureForElement:currentElement];
        }
    } while (( currentElement = currentElement->nextSibling));
    
}

- (void)traversePackagesContentForElement:(TBXMLElement *)element
{
    TBXMLElement* currentElement = element->firstChild;
    do
    {
        MapRegion *currentRegion = [[MapRegion alloc] init];
        
        //Element code and Parent code
        if(currentElement)
        {
            currentRegion.code = [TBXML elementName:currentElement];
            NSString* parentCode=[_parentsDictionary objectForKey:[TBXML elementName:currentElement]];
            if(parentCode)
            {
                currentRegion.parentCode = parentCode;
            }
            
            //bbox
            
            TBXMLElement *boundingBoxElement = [TBXML childElementNamed:kXmlBBox parentElement:currentElement];
            if (boundingBoxElement)
            {
                TBXMLElement *longMinElement = [TBXML childElementNamed:@"longMin" parentElement:boundingBoxElement];
                TBXMLElement *longMaxElement = [TBXML childElementNamed:@"longMax" parentElement:boundingBoxElement];
                TBXMLElement *latMinElement = [TBXML childElementNamed:@"latMin" parentElement:boundingBoxElement];
                TBXMLElement *latMaxElement = [TBXML childElementNamed:@"latMax" parentElement:boundingBoxElement];
                float longMin = strtod(longMinElement->text,NULL);
                float longMax = strtod(longMaxElement->text,NULL);
                float latMin = strtod(latMinElement->text,NULL);
                float latMax = strtod(latMaxElement->text,NULL);
                currentRegion.boundingBox = [SKBoundingBox boundingBoxWithTopLeftCoordinate:CLLocationCoordinate2DMake(latMax, longMin) bottomRightCoordinate:CLLocationCoordinate2DMake(latMin, longMax)];
            }
            
            //name
            TBXMLElement *nameElement =[TBXML childElementNamed:kXMLKeyName parentElement:currentElement];
            if(nameElement)
            {
                TBXMLElement *nameCurrentElement =[TBXML childElementNamed:kXmlKeyEn parentElement:nameElement];
                currentRegion.name = [NSString stringWithCString:nameCurrentElement->text encoding:NSUTF8StringEncoding];
            }
            
            //map file Path.
            TBXMLElement *fileElement =[TBXML childElementNamed:kXmlKeyFileURLMap parentElement:currentElement];
            if(fileElement)
            {
                currentRegion.mapURL = [TBXML textForElement:fileElement];
            }
            
            //Downlaod url NB.
            TBXMLElement *fileElementNB =[TBXML childElementNamed:kXmlKeyFileURLNb parentElement:currentElement];
            if(fileElementNB)
            {
                currentRegion.nbURL = [TBXML textForElement:fileElementNB];
            }
            
            //Element's type.
            TBXMLElement *typeElement =[TBXML childElementNamed:kXMLKeyType parentElement:currentElement];
            if(typeElement)
            {
                NSString* type = [TBXML textForElement:typeElement];
                if([type isEqualToString:kXmlKeyTypeCountry])
                {
                    currentRegion.type = kMapRegionTypeCountry;
                }
                else
                    if([type isEqualToString:kXmlKeyTypeCity])
                    {
                        currentRegion.type = kMapRegionTypeCity;
                    }
                    else
                        if([type isEqualToString:kXmlKeyTypeState])
                        {
                            currentRegion.type = kMapRegionTypeState;
                        }
                        else
                            if([type isEqualToString:kXmlKeyTypeContinent])
                            {
                                currentRegion.type = kMapRegionTypeContinent;
                            }
            }
            
            //Textures
            TBXMLElement *texturesElement =[TBXML childElementNamed:kXmlKeyTextures parentElement:currentElement];
            
            if(texturesElement)
            {
                //link to file
                TBXMLElement *fileElementTexture =[TBXML childElementNamed:kXmlKeyFileURLMap parentElement:texturesElement];
                if(fileElementTexture)
                {
                    currentRegion.textureURL = [TBXML textForElement:fileElementTexture];
                }
                
            }
            
        }

        [self.mapRegions addObject:currentRegion];
        
    } while (currentElement && ( currentElement = currentElement->nextSibling));

    [_parentsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        MapRegion* region = [self cachedMapRegionWithID:(NSString *)key];
        MapRegion* parentRegion = [self cachedMapRegionWithID:(NSString *)obj];
        if(parentRegion && region)
        {
            [parentRegion.childRegions addObject:region];
        }
    }];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    for (MapRegion *region in self.mapRegions)
    {
        if(region.type==kMapRegionTypeContinent)
        {
            [appDelegate.cachedMapRegions addObject:region];
        }
    }
    self.mapRegions=nil;
}

-(MapRegion*)cachedMapRegionWithID:(NSString*)mapRegionID
{
    for (MapRegion *region in self.mapRegions)
    {
        if ([region.code isEqualToString:mapRegionID])
        {
            return region;
        }
    }
    return nil;
}

@end
