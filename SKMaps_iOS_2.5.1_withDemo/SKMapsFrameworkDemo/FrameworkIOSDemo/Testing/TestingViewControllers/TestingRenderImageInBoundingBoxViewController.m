//
//  RenderImageInBoundingBoxViewController.m
//  FrameworkIOSDemo
//
//  Created by Csongor Korosi on 24/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingRenderImageInBoundingBoxViewController.h"
#import "UIView+Additions.h"

@interface TestingRenderImageInBoundingBoxViewController()<SKMapViewDelegate>

@property(nonatomic, assign) double topLeftCoordinateLatitude;
@property(nonatomic, assign) double topLeftCoordinateLongitude;
@property(nonatomic, assign) double bottomRightCoordinateLatitude;
@property(nonatomic, assign) double bottomRightCoordinateLongitude;

@property(nonatomic, assign) CGFloat imageSizeWidth;
@property(nonatomic, assign) CGFloat imageSizeHeight;

@property(nonatomic) MenuItem *topLeftCoordinateLatitudeItem;
@property(nonatomic) MenuItem *topLeftCoordinateLongitudeItem;
@property(nonatomic) MenuItem *bottomRightCoordinateLatitudeItem;
@property(nonatomic) MenuItem *bottomRightCoordinateLongitudeItem;

@property(nonatomic, assign) CGFloat paddingWidth;
@property(nonatomic, assign) CGFloat paddingHeight;

@end

@implementation TestingRenderImageInBoundingBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    [self.mapView centerOnCurrentPosition];
    SKBoundingBox *boundingBox = [SKBoundingBox boundingBoxForRegion:self.mapView.visibleRegion inMapViewWithSize:self.mapView.frame.size];
    self.topLeftCoordinateLatitude = boundingBox.topLeftCoordinate.latitude;
    self.topLeftCoordinateLongitude = boundingBox.topLeftCoordinate.longitude;
    self.bottomRightCoordinateLatitude = boundingBox.bottomRightCoordinate.latitude;
    self.bottomRightCoordinateLongitude = boundingBox.bottomRightCoordinate.longitude;
    
    [self configureMenuView];
}

- (void)configureMenuView {
    MenuSection *menuSectionRenderImageInBoundingBox = [self menuSectionForRenderImageInBoundingBox];
    MenuSection *menuSectionFitBoundingBox = [self menuSectionFitBoundingBox];
    self.menuView.sections = @[menuSectionRenderImageInBoundingBox, menuSectionFitBoundingBox];
}

- (MenuSection *)menuSectionForRenderImageInBoundingBox {
    __weak TestingRenderImageInBoundingBoxViewController *weakSelf = self;
    
    self.topLeftCoordinateLatitudeItem = [MenuItem itemForTextWithTitle:@"Top left latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.topLeftCoordinateLatitude = [item floatValue];
    } editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {}];
    self.topLeftCoordinateLatitudeItem.defaultValue = [NSString stringWithFormat:@"%f", self.topLeftCoordinateLatitude];
    
    self.topLeftCoordinateLongitudeItem = [MenuItem itemForTextWithTitle:@"Top left longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.topLeftCoordinateLongitude = [item floatValue];
    } editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {}];
    self.topLeftCoordinateLongitudeItem.defaultValue = [NSString stringWithFormat:@"%f", self.topLeftCoordinateLongitude];
    
    self.bottomRightCoordinateLatitudeItem = [MenuItem itemForTextWithTitle:@"Bottom right latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.bottomRightCoordinateLatitude = [item floatValue];
    } editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {}];
    self.bottomRightCoordinateLatitudeItem.defaultValue = [NSString stringWithFormat:@"%f", self.bottomRightCoordinateLatitude];
    
    self.bottomRightCoordinateLongitudeItem = [MenuItem itemForTextWithTitle:@"Bottom right longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.bottomRightCoordinateLongitude = [item floatValue];
    } editEndBlock:^(MenuItem *item, NSObject<NSCoding> *value) {}];
    self.bottomRightCoordinateLongitudeItem.defaultValue = [NSString stringWithFormat:@"%f", self.bottomRightCoordinateLongitude];
    
    MenuItem *imageSizeWidthItem = [MenuItem itemForSliderWithTitle:@"Image size width" uniqueID:nil minValue:0.0f maxValue:self.view.frame.size.width changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.imageSizeWidth = [item floatValue];
    }];
    imageSizeWidthItem.floatValue = self.view.frame.size.width;
    
    MenuItem *imageSizeHeightItem = [MenuItem itemForSliderWithTitle:@"Image size height" uniqueID:nil minValue:0.0f maxValue:self.view.frame.size.height changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.imageSizeHeight = [item floatValue];
    }];
    imageSizeHeightItem.floatValue = self.view.frame.size.height;
    
    MenuItem *buttonItem = [MenuItem itemForButtonWithTitle:@"Render" selectionBlock:^(MenuItem *item) {
        SKBoundingBox *boundingBox = [[SKBoundingBox alloc] init];
        boundingBox.topLeftCoordinate = CLLocationCoordinate2DMake(self.topLeftCoordinateLatitude, self.topLeftCoordinateLongitude);
        boundingBox.bottomRightCoordinate = CLLocationCoordinate2DMake(self.bottomRightCoordinateLatitude, self.bottomRightCoordinateLongitude);
        
        NSMutableString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"MapImage%f_%f_%f_%f.png", boundingBox.topLeftCoordinate.latitude, boundingBox.topLeftCoordinate.longitude, boundingBox.bottomRightCoordinate.latitude, boundingBox.bottomRightCoordinate.longitude]];
        
        [weakSelf.mapView renderMapImageInBoundingBox:boundingBox toPath:filePath withSize:CGSizeMake(self.imageSizeWidth, self.imageSizeHeight)];
    }];
    
    MenuSection *settingsSection = [MenuSection sectionWithTitle:@"Settings" items:@[self.topLeftCoordinateLatitudeItem, self.topLeftCoordinateLongitudeItem, self.bottomRightCoordinateLatitudeItem, self.bottomRightCoordinateLongitudeItem, imageSizeWidthItem, imageSizeHeightItem, buttonItem]];
    
    return settingsSection;
}

- (MenuSection *)menuSectionFitBoundingBox {
    __weak TestingRenderImageInBoundingBoxViewController *weakSelf = self;
    
    MenuItem *paddingWidthMenuItem = [MenuItem itemForSliderWithTitle:@"Padding width" uniqueID:nil minValue:0.0f maxValue:self.view.frameWidth changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.paddingWidth = item.intValue;
    }];
    paddingWidthMenuItem.defaultValue = @(self.view.frameWidth);
    
    MenuItem *paddingHeightMenuItem = [MenuItem itemForSliderWithTitle:@"Padding height" uniqueID:nil minValue:0.0f maxValue:self.view.frameHeight changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.paddingHeight = item.intValue;
    }];
    paddingHeightMenuItem.defaultValue = @(self.view.frameHeight);
    
    MenuItem *buttonItem = [MenuItem itemForButtonWithTitle:@"Fit bounding box with padding" selectionBlock:^(MenuItem *item) {
        SKBoundingBox *boundingBox = [[SKBoundingBox alloc] init];
        boundingBox.topLeftCoordinate = CLLocationCoordinate2DMake(self.topLeftCoordinateLatitude, self.topLeftCoordinateLongitude);
        boundingBox.bottomRightCoordinate = CLLocationCoordinate2DMake(self.bottomRightCoordinateLatitude, self.bottomRightCoordinateLongitude);
        
        [weakSelf.mapView fitBounds:boundingBox withPadding:CGSizeMake(weakSelf.paddingWidth, weakSelf.paddingHeight)];
    }];
    
    MenuSection *menuSectionFitBoundingBox = [MenuSection sectionWithTitle:@"Fit bounding box" items:@[paddingWidthMenuItem, paddingHeightMenuItem, buttonItem]];
    
    return menuSectionFitBoundingBox;
}

#pragma mark - SKMapViewDelegate

- (void)mapView:(SKMapView *)mapView didEndRegionChangeToRegion:(SKCoordinateRegion)region {
    SKBoundingBox *boundingBox = [SKBoundingBox boundingBoxForRegion:self.mapView.visibleRegion inMapViewWithSize:self.mapView.frame.size];
    self.topLeftCoordinateLatitude = boundingBox.topLeftCoordinate.latitude;
    self.topLeftCoordinateLongitude = boundingBox.topLeftCoordinate.longitude;
    self.bottomRightCoordinateLatitude = boundingBox.bottomRightCoordinate.latitude;
    self.bottomRightCoordinateLongitude = boundingBox.bottomRightCoordinate.longitude;

    self.topLeftCoordinateLatitudeItem.stringValue = [NSString stringWithFormat:@"%f",boundingBox.topLeftCoordinate.latitude];
    self.topLeftCoordinateLongitudeItem.stringValue = [NSString stringWithFormat:@"%f",boundingBox.topLeftCoordinate.longitude];
    self.bottomRightCoordinateLatitudeItem.stringValue = [NSString stringWithFormat:@"%f",boundingBox.bottomRightCoordinate.latitude];
    self.bottomRightCoordinateLongitudeItem.stringValue = [NSString stringWithFormat:@"%f",boundingBox.bottomRightCoordinate.longitude];
    [self.topLeftCoordinateLongitudeItem fireRefresh];
    [self.topLeftCoordinateLatitudeItem fireRefresh];
    [self.bottomRightCoordinateLatitudeItem fireRefresh];
    [self.bottomRightCoordinateLongitudeItem fireRefresh];
}

- (void)mapViewDidFinishRenderingImageInBoundingBox:(SKMapView *)mapView {

}

@end
