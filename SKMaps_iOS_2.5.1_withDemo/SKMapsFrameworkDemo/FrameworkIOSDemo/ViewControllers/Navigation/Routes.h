//
//  Routes.h
//  FrameworkIOSDemo
//
//  Created by john on 11/12/2015.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Routes : NSObject{
    NSString *_map_id;
    NSString *_map_desc;
}

@property (nonatomic) NSString *map_id;
@property (nonatomic) NSString *map_desc;

-(id)initWithMapid:(NSString *)map_id mapdesc:(NSString *)map_desc;

@end
