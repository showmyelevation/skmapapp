//
//  MapXMLViewController.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDKTools/SKTDownloadManager/Helper/SKTDownloadObjectHelper.h>
#import <SDKTools/SKTMaps/SKTPackages/SKTPackage.h>

@interface MapXMLViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mapRegion:(SKTPackage*)mapRegion;

@end
