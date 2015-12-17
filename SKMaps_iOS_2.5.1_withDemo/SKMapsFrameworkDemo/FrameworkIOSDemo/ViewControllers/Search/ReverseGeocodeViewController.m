//
//  ReverseGeocodeViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "ReverseGeocodeViewController.h"
#import "SKMaps/SKMaps.h"

@interface ReverseGeocodeViewController ()<UITextFieldDelegate>
@property(nonatomic,strong) IBOutlet UITextField *latitudeTextField;
@property(nonatomic,strong) IBOutlet UITextField *longitudeTextField;
@property(nonatomic,strong) IBOutlet UILabel *resultLabel;
@end

@implementation ReverseGeocodeViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Reverse geocoding";
    CLLocationCoordinate2D currentCoordinate = [[SKPositionerService sharedInstance]currentCoordinate];
    self.latitudeTextField.text = [NSString stringWithFormat:@"%f",currentCoordinate.latitude];
    self.longitudeTextField.text = [NSString stringWithFormat:@"%f",currentCoordinate.longitude];
}


#pragma mark - Private methods

-(IBAction)reverseButtonCliked:(id)sender
{
    double lonX = [self.longitudeTextField.text doubleValue];
    double latY = [self.latitudeTextField.text doubleValue];
    SKSearchResult *searchObject =  [[SKReverseGeocoderService sharedInstance] reverseGeocodeLocation:CLLocationCoordinate2DMake(latY, lonX)];
    
    NSString *name = [searchObject name];
    if ([name isEqualToString:@""])
    {
        self.resultLabel.text = @"Reverse geocoding failed. Map tiles from the selected coordinate are not downloaded.";
        return;
    }
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"%@",name];
    for (int i = 0; i < [searchObject.parentSearchResults count];i++)
    {
        SKSearchResultParent *parent = (SKSearchResultParent*)[searchObject.parentSearchResults objectAtIndex:i];
        [result appendFormat:@", %@",parent.name];
    }
    
    self.resultLabel.text = result;
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
