//
//  RootViewController.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UIViewController<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@end
