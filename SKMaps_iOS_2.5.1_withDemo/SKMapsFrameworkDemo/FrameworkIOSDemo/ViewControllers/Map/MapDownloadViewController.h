//
//  MapDownloadViewController.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDKTools/SKTDownloadManager/Helper/SKTDownloadObjectHelper.h>
#import <SDKTools/SKTDownloadManager/SKTDownloadAPI.h>

@interface MapDownloadViewController : UIViewController

@property(nonatomic,strong) SKTPackage* regionToDownload;

@end
