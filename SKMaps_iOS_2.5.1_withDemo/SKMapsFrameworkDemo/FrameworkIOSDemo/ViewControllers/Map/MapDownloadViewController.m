//
//  MapDownloadViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "MapDownloadViewController.h"
#import "XMLParser.h"
#import "AppDelegate.h"
#import <SKMaps/SKMaps.h>


NSString *const kMapDownloadFinished = @"Download finished";

@interface MapDownloadViewController () <SKTDownloadManagerDelegate, SKTDownloadManagerDataSource>

@property (nonatomic, strong) IBOutlet UIButton *startButton;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UILabel *percentLabel;

@end

@implementation MapDownloadViewController

#pragma mark - Init

- (void)viewDidLoad {
	[super viewDidLoad];
    
	self.startButton.hidden = YES;
	self.progressView.hidden = YES;
	self.percentLabel.hidden = YES;
    
	if (![XMLParser sharedInstance].isParsingFinished) {
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showDownloadUI) name:kParsingFinishedNotificationName object:nil];
	}
	else {
		[self showDownloadUI];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)showDownloadUI {
	[self.startButton setTitle:[NSString stringWithFormat:@"Download: %@", [self.regionToDownload nameForLanguageCode:@"en"]] forState:UIControlStateNormal];
	self.startButton.layer.cornerRadius = 15;
	self.startButton.layer.borderWidth = 1;
    //    self.startButton.layer.borderColor = [UIColor redColor].CGColor;
    
	self.startButton.hidden = NO;
	self.progressView.hidden = NO;
	self.percentLabel.hidden = NO;
}

- (IBAction)startDownloading:(id)sender {
    SKTDownloadObjectHelper *region = [SKTDownloadObjectHelper downloadObjectHelperWithSKTPackage:self.regionToDownload];
    
    [[SKTDownloadManager sharedInstance] requestDownloads:@[region] startAutomatically:YES withDelegate:self withDataSource:self];
	//[self startDownload];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - SKTDownloadManagerDelegate

- (void)downloadManager:(SKTDownloadManager *)downloadManager saveDownloadHelperToDatabase:(SKTDownloadObjectHelper *)downloadHelper {
    NSString *path = [[SKTDownloadManager libraryDirectory] stringByAppendingPathComponent:[downloadHelper getCode]];
    
    NSString *code = [downloadHelper getCode];
    [[SKMapsService sharedInstance].packagesManager addOfflineMapPackageNamed:code inContainingFolderPath:path];
    NSError *error;
    NSFileManager *fman = [NSFileManager new];
    [fman removeItemAtPath:path error:&error];
}

- (void)notEnoughDiskSpace {
    NSLog(@"not enough space");
}

- (void)didCancelDownload {
    [self.startButton setEnabled:YES];
}

- (void)downloadManager:(SKTDownloadManager *)downloadManager didPauseDownloadForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    NSLog(@"didPauseDownloadForDownloadHelper");
    [self.startButton setEnabled:YES];

}

- (void)downloadManager:(SKTDownloadManager *)downloadManager didResumeDownloadForDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    NSLog(@"didResumeDownloadForDownloadHelper");
    [self.startButton setEnabled:NO];
}

- (void)downloadManager:(SKTDownloadManager *)downloadManager internetAvailabilityChanged:(BOOL)isAvailable {

}

- (void)downloadManagerSwitchedWifiToCellularNetwork:(SKTDownloadManager *)downloadManager {

}

- (void)downloadManager:(SKTDownloadManager *)downloadManager didUpdateDownloadSpeed:(NSString *)speed andRemainingTime:(NSString *)remainingTime {

}

- (void)downloadManager:(SKTDownloadManager *)downloadManager didUpdateCurrentDownloadProgress:(NSString *)currentPorgressString currentDownloadPercentage:(float)currentPercentage overallDownloadProgress:(NSString *)overallProgressString overallDownloadPercentage:(float)overallPercentage forDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    self.progressView.progress = overallPercentage / 100;
    self.percentLabel.text = overallProgressString;
}

- (void)downloadManager:(SKTDownloadManager *)downloadManager didUpdateUnzipProgress:(NSString *)progressString percentage:(float)percentage forDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper {
    self.progressView.progress = percentage / 100;
    self.percentLabel.text = progressString;
}

- (void)downloadManager:(SKTDownloadManager *)downloadManager didDownloadDownloadHelper:(SKTDownloadObjectHelper *)downloadHelper withSuccess:(BOOL)success {
    [self.startButton setEnabled:NO];
    
    self.progressView.progress = 1;
    self.percentLabel.text = @"Download finished";
}

- (void)operationsCancelledByOSDownloadManager:(SKTDownloadManager *)downloadManager {

}

#pragma mark - SKTDownloadManagerDataSource

- (BOOL)isOnBoardMode {
    return NO;
}

@end
