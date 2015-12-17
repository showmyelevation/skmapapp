//
//  Routes.m
//  FrameworkIOSDemo
//
//  Created by john on 11/12/2015.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "Routes.h"

@implementation Routes

@synthesize map_id;
@synthesize map_desc;

-(id)initWithMapid:(NSString *)mapid mapdesc:(NSString *)mapdesc{
    if ((self = [super init])) {
        map_id = mapid;
        map_desc = mapdesc;
    }
    return self;
}

@end
