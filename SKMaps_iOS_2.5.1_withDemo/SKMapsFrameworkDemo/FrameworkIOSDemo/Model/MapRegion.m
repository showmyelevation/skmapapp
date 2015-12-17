//
//  MRegion.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "MapRegion.h"

@implementation MapRegion

-(id)init
{
    self = [super init];
    if (self)
    {
        self.childRegions=[NSMutableArray array];
    }
    return self;
}

- (BOOL)isEqual:(id)other
{
    if ([[(MapRegion*)other code]isEqual:[self code]])
    {
        return YES;
    }
    return NO;

}


@end
