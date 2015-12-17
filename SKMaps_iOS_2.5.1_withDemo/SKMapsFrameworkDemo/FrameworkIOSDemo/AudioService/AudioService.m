//
//  AudioService.m
//  SKMapsFrameworkDevelopment
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "AudioService.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioService () <AVAudioPlayerDelegate>
@property(nonatomic, strong) AVAudioPlayer *audioPlayer;
@property(nonatomic, strong) NSMutableArray *audioFilesArray;
@end

static AudioService *sharedInstance;

@implementation AudioService

@synthesize audioPlayer;
@synthesize audioFilesArray;

#pragma mark - Lifecycle

+(AudioService *)sharedInstance
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AudioService alloc] init];
    });
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        self.audioPlayer = nil;
        self.audioFilesArray = [NSMutableArray array];
        self.audioFilesFolderPath=@"";
    }
    return self;
}

-(void)dealloc
{
    self.audioPlayer.delegate = nil;
}

#pragma mark - Public methods

-(void)play:(NSArray *)audioFiles
{
    @synchronized(self)
    {
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSBundle* advisorResourcesBundle = [NSBundle bundleWithPath:[mainBundlePath stringByAppendingPathComponent:@"SKAdvisorResources.bundle"]];
        if(!advisorResourcesBundle)
        {
            NSLog(@"Advisor resources not found.");
            return;
        }
        
        if (audioFiles.count == 0)
        {
            NSLog(@"No audio files to play.");
            return;
        }
        
        [self.audioFilesArray addObjectsFromArray:audioFiles];
        
        if ((self.audioFilesArray.count > 0) && (self.audioPlayer == nil))
        {
            NSString *audioFileName = [self.audioFilesArray objectAtIndex:0];
            [self playAudioFile:audioFileName];
            [self.audioFilesArray removeObjectAtIndex:0];
        }
    }
}

-(void)playAudioFile:(NSString *)audioFileName
{
    NSString *soundFilePath = [self.audioFilesFolderPath stringByAppendingPathComponent:audioFileName];
    soundFilePath = [soundFilePath stringByAppendingPathExtension:@"mp3"];
    
    if( ![[NSFileManager defaultManager] fileExistsAtPath:soundFilePath])
    {
        return;
    }
    else
    {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundFilePath] error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer play];
    }
}

-(void)cancel
{
    [self.audioPlayer stop];
    self.audioPlayer.delegate = nil;
    self.audioPlayer = nil;
    
    [self.audioFilesArray removeAllObjects];
}

-(float)volume {
    return self.audioPlayer.volume;
}

-(void)setVolume:(float)volume {
    self.audioPlayer.volume = volume;
}

#pragma mark - AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.audioFilesArray.count > 0)
    {
        NSString *audioFileName = [self.audioFilesArray objectAtIndex:0];
        [self playAudioFile:audioFileName];
        [self.audioFilesArray removeObjectAtIndex:0];
    }
    else
    {
        [self cancel];
    }
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    
}

@end
