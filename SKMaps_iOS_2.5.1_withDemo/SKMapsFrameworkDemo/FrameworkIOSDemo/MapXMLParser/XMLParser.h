//
//  XMLParser.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kParsingFinishedNotificationName = @"XMLParsingFinishedNotification";

@interface XMLParser : NSObject

@property(nonatomic,assign) BOOL isParsingFinished;
-(void)downloadAndParseXML;
- (void)downloadAndParseJSON;

+(XMLParser*)sharedInstance;

@end
