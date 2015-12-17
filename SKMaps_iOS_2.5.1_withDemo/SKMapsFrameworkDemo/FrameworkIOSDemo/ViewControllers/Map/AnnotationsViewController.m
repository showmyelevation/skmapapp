//
//  AnnotationsViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "AnnotationsViewController.h"
#import <SKMaps/SKMaps.h>
#import <SKMaps/SKAnnotationView.h>

@interface AnnotationsViewController ()<SKMapViewDelegate,SKCalloutViewDelegate>
@property(nonatomic,strong) SKMapView *mapView;
@property(nonatomic,strong) SKAnnotation *annotation1;
@property(nonatomic,strong) SKAnnotation *annotation3;

@end

@implementation AnnotationsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //display the map
    self.mapView = [[SKMapView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];

    //set map region
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(52.5233, 13.4127);
    region.zoomLevel = 17.0f;
    [self.mapView setVisibleRegion:region];
    
    [self addAnnotations];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.mapView clearAllAnnotations];
}

#pragma mark - Annotations

-(void)addAnnotations
{
    self.annotation1 = [SKAnnotation annotation];
    self.annotation1.identifier = 10;
    self.annotation1.annotationType = SKAnnotationTypePurple;
    self.annotation1.location = CLLocationCoordinate2DMake(52.5237, 13.4137);
    
    SKAnimationSettings *animationSettings = [SKAnimationSettings animationSettings];
    [self.mapView addAnnotation:self.annotation1 withAnimationSettings:animationSettings];
    
    self.annotation3 = [SKAnnotation annotation];
    self.annotation3.identifier = 13;
    self.annotation3.annotationType = SKAnnotationTypeGreen;
    self.annotation3.location = CLLocationCoordinate2DMake(52.5239, 13.4117);
    [self.mapView addAnnotation:self.annotation3 withAnimationSettings:animationSettings];
    
    self.mapView.calloutView.delegate = self;
    [self.mapView showCalloutForAnnotation:self.annotation3 withOffset:CGPointMake(0, 42.0f) animated:YES];
    
    //Annotation with view
    //create our view
    //the view's size should be power of two
    UIImageView *coloredView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 64.0, 64.0)];
    coloredView.backgroundColor = [UIColor redColor];
    coloredView.image = [UIImage imageNamed:@"picture"];
    coloredView.contentMode = UIViewContentModeTop;
    coloredView.layer.cornerRadius = 10.0;
    
    //add a label to our view
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3.0, coloredView.frame.size.height - 40.0, coloredView.frame.size.width - 6.0, 40.0)];
    label.text = @"Custom view annotation";
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:15.0];
    [coloredView addSubview:label];
    
    //create the SKAnnotationView
    SKAnnotationView *view = [[SKAnnotationView alloc] initWithView:coloredView reuseIdentifier:@"viewID"];
    
    //create the annotation
    SKAnnotation *viewAnnotation = [SKAnnotation annotation];
    //set the custom view
    viewAnnotation.annotationView = view;
    viewAnnotation.identifier = 100;
    viewAnnotation.location = CLLocationCoordinate2DMake(52.5240, 13.4107);
    [self.mapView addAnnotation:viewAnnotation withAnimationSettings:animationSettings];
}

#pragma mark - SKMapDelegate

-(void)mapView:(SKMapView *)mapView didSelectAnnotation:(SKAnnotation *)annotation
{
    [self.mapView showCalloutForAnnotation:annotation withOffset:CGPointMake(0, 42.0f) animated:YES];
}

- (UIView*)mapView:(SKMapView *)mapView calloutViewForAnnotation:(SKAnnotation *)annotation
{
    //Custom callouts.
    if (annotation.identifier == self.annotation1.identifier)
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 50.0f)];
        view.backgroundColor = [UIColor purpleColor];
        view.alpha = 0.5f;
        return view;
    }
    
    return nil;// Default callout view will be used.
}

#pragma mark - SKCalloutViewDelegate

-(void)calloutView:(SKCalloutView *)calloutView didTapLeftButton:(UIButton *)leftButton
{
    SKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(52.5233, 13.4127);
    region.zoomLevel = 17.0f;
    [self.mapView setVisibleRegion:region];
    
    [self addAnnotations];
}

-(void)calloutView:(SKCalloutView *)calloutView didTapRightButton:(UIButton *)rightButton
{
    NSLog(@"Did tap right button on callout view.\n");
}

- (void)mapView:(SKMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [mapView hideCallout];
}

@end
