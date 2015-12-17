//
//  AudioService.h
//  SKMapsFrameworkDevelopment
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioService : NSObject

@property(nonatomic, strong) NSString*  audioFilesFolderPath;

-(void)play:(NSArray *)audioFiles;
-(void)cancel;
-(float)volume;
-(void)setVolume:(float)volume;

+(AudioService *)sharedInstance;

@end
