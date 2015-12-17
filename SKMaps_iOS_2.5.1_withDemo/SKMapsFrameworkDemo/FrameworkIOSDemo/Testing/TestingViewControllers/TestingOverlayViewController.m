//
//  TestingOverlayViewController.m
//  FrameworkIOSDemo
//
//  Created by Cristian Chertes on 15/05/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TestingOverlayViewController.h"
#import "UIView+Additions.h"

typedef NS_ENUM(NSInteger, OverlayLocationType)
{
    OverlayLocationTypeCoordinate,
    OverlayLocationTypeCenter,
    OverlayLocationTypeLongTap
};

@interface TestingOverlayViewController ()

//Circle settings
@property (nonatomic, assign) NSInteger     circleIdentifier;
@property (nonatomic, assign) CGFloat       circleLatitude;
@property (nonatomic, assign) CGFloat       circleLongitude;
@property (nonatomic, assign) NSInteger     circleBorderDotsSize;
@property (nonatomic, assign) NSInteger     circleBorderDotsSpacingSize;
@property (nonatomic, strong) UIColor       *circleFillColor;
@property (nonatomic, strong) UIColor       *circleStrokeColor;
@property (nonatomic, assign) CGFloat       circleRadius;
@property (nonatomic, assign) NSInteger     circleBorderWidth;
@property (nonatomic, assign) BOOL          circleIsMask;
@property (nonatomic, assign) CGFloat       circleMaskedObjectScale;
@property (nonatomic, assign) NSInteger     circleNumberOfPoints;

//Polygon settings
@property (nonatomic, assign) NSInteger         polygonIdentifier;
@property (nonatomic, strong) NSMutableArray    *polygonCoordinates;
@property (nonatomic, assign) CGFloat           polygonLatitude;
@property (nonatomic, assign) CGFloat           polygonLongitude;
@property (nonatomic, assign) NSInteger         polygonBorderDotsSize;
@property (nonatomic, assign) NSInteger         polygonBorderDotsSpacingSize;
@property (nonatomic, strong) UIColor           *polygonFillColor;
@property (nonatomic, strong) UIColor           *polygonStrokeColor;
@property (nonatomic, assign) NSInteger         polygonBorderWidth;
@property (nonatomic, assign) BOOL              polygonIsMask;
@property (nonatomic, assign) CGFloat           polygonMaskedObjectScale;

//Polyline settings
@property (nonatomic, assign) NSInteger         polylineIdentifier;
@property (nonatomic, strong) NSMutableArray    *polylineCoordinates;
@property (nonatomic, assign) CGFloat           polylineLatitude;
@property (nonatomic, assign) CGFloat           polylineLongitude;
@property (nonatomic, assign) NSInteger         polylineBorderDotsSize;
@property (nonatomic, assign) NSInteger         polylineBorderDotsSpacingSize;
@property (nonatomic, strong) UIColor           *polylineFillColor;
@property (nonatomic, assign) NSInteger         polylineLineWidth;
@property (nonatomic, assign) NSInteger         polylineBackgroundLineWidth;

@property (nonatomic, assign) NSInteger                 searchOverlayId;
@property (nonatomic, strong) NSMutableArray            *overlaysArray;
@property (nonatomic, assign) BOOL                      shouldAddLocationToPolygon;
@property (nonatomic, assign) BOOL                      shouldAddLocationToPolyline;
@property (nonatomic, assign) CLLocationCoordinate2D    longTapCoordinate;
@property (nonatomic, strong) UIView                    *centerView;
@property (nonatomic, strong) UILabel                   *tapLabel;
@property (nonatomic, strong) MenuItem                  *polygonLatitudeItem;
@property (nonatomic, strong) MenuItem                  *polygonLongitudeItem;
@property (nonatomic, strong) MenuItem                  *polylineLatitudeItem;
@property (nonatomic, strong) MenuItem                  *polylineLongitudeItem;

@end

@implementation TestingOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.longTapCoordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    self.overlaysArray = [NSMutableArray  array];
    self.polygonCoordinates = [NSMutableArray array];
    self.polylineCoordinates = [NSMutableArray  array];
    
    [self addTapLabel];
    [self addCenterView];
    [self configureMenuView];
}

#pragma mark - Actions

- (void)addCircleToLocationType:(OverlayLocationType)type {
    __weak TestingOverlayViewController *weakSelf = self;
    SKCircle *circle = [weakSelf getCircle];
    
    if (type == OverlayLocationTypeCenter) {
        circle.centerCoordinate = weakSelf.mapView.visibleRegion.center;
    } else if (type == OverlayLocationTypeLongTap) {
        circle.centerCoordinate = weakSelf.longTapCoordinate;
    }
    
    [weakSelf.mapView addCircle:circle];
    [weakSelf.overlaysArray addObject:circle];
    [weakSelf changeMapRegionToLocation:circle.centerCoordinate];
}

- (void)addPolygon {
    __weak TestingOverlayViewController *weakSelf = self;
    
    SKPolygon *polygon = [weakSelf getPolygon];
    
    [weakSelf.mapView addPolygon:polygon];
    [weakSelf.overlaysArray addObject:polygon];
    if (polygon.coordinates.count > 0) {
        CLLocation *location = polygon.coordinates[0];
        [weakSelf changeMapRegionToLocation:location.coordinate];
    }
}

- (void)addPolyline {
    __weak TestingOverlayViewController *weakSelf = self;
    
    SKPolyline *polyline = [weakSelf getPolyline];
    
    [weakSelf.mapView addPolyline:polyline];
    [weakSelf.overlaysArray addObject:polyline];
    if (polyline.coordinates.count > 0) {
        CLLocation *location = polyline.coordinates[0];
        [weakSelf changeMapRegionToLocation:location.coordinate];
    }
}

- (void)deleteLastPolygonLocation {
    __weak TestingOverlayViewController *weakSelf = self;
    
    [weakSelf.polygonCoordinates removeLastObject];
}

- (void)deleteLastPolylineLocation {
    __weak TestingOverlayViewController *weakSelf = self;
    
    [weakSelf.polylineCoordinates removeLastObject];
}

- (void)addLocationToPolygon {
    if (self.shouldAddLocationToPolygon) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.longTapCoordinate.latitude longitude:self.longTapCoordinate.longitude];
        
        [self.polygonCoordinates addObject:location];
        self.shouldAddLocationToPolygon = NO;
        
        self.polygonLatitudeItem.stringValue = [NSString stringWithFormat:@"%f",self.longTapCoordinate.latitude];
        self.polygonLongitudeItem.stringValue = [NSString stringWithFormat:@"%f",self.longTapCoordinate.longitude];
        [self.polygonLatitudeItem fireRefresh];
        [self.polygonLongitudeItem fireRefresh];
    }
}

- (void)addLocationToPolyline {
    if (self.shouldAddLocationToPolyline) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.longTapCoordinate.latitude longitude:self.longTapCoordinate.longitude];
        
        [self.polylineCoordinates addObject:location];
        self.shouldAddLocationToPolyline = NO;
        
        self.polylineLatitudeItem.stringValue = [NSString stringWithFormat:@"%f",self.longTapCoordinate.latitude];
        self.polylineLongitudeItem.stringValue = [NSString stringWithFormat:@"%f",self.longTapCoordinate.longitude];
        [self.polylineLatitudeItem fireRefresh];
        [self.polylineLongitudeItem fireRefresh];
    }
}

- (void)changeMapRegionToLocation:(CLLocationCoordinate2D)location {
    __weak TestingOverlayViewController *weakSelf = self;
    
    SKCoordinateRegion region;
    region.center = location;
    region.zoomLevel = weakSelf.mapView.visibleRegion.zoomLevel;
    weakSelf.mapView.visibleRegion = region;
}

- (void)clearOverlays {
    __weak TestingOverlayViewController *weakSelf = self;
    
    [weakSelf.mapView clearAllOverlays];
}

- (void)searchForOverlayWithId:(int)identifier {
    __weak TestingOverlayViewController *weakSelf = self;

    for (SKOverlay *overlay in weakSelf.overlaysArray) {
        if (overlay.identifier == identifier) {
            CLLocationCoordinate2D location;
            if ([overlay isMemberOfClass:[SKCircle class]]) {
                SKCircle *circle = (SKCircle *)overlay;
                location = circle.centerCoordinate;
            }
            
            if ([overlay isMemberOfClass:[SKPolyline class]]) {
                SKPolyline *polyline = (SKPolyline *)overlay;
                CLLocation *loc = polyline.coordinates[0];
                location = loc.coordinate;
            }
            
            if ([overlay isMemberOfClass:[SKPolygon class]]) {
                SKPolygon *polygon = (SKPolygon *)overlay;
                CLLocation *loc = polygon.coordinates[0];
                location = loc.coordinate;
            }
            
            [weakSelf changeMapRegionToLocation:location];
        }
    }
}

- (void)pushNewVcInstance {
    __weak TestingOverlayViewController *weakSelf = self;
    
    TestingOverlayViewController *vc = [[TestingOverlayViewController alloc] init];
    [weakSelf.navigationController pushViewController:vc animated:YES];
}

- (void)hideTapLabel {
    self.tapLabel.hidden = YES;
}

#pragma mark - Private methods

- (SKCircle *)getCircle {
    __weak TestingOverlayViewController *weakSelf = self;
    
    SKCircle *circle = [SKCircle circle];
    circle.identifier = weakSelf.circleIdentifier;
    circle.centerCoordinate = CLLocationCoordinate2DMake(weakSelf.circleLatitude, weakSelf.circleLongitude);
    circle.borderDotsSize = weakSelf.circleBorderDotsSize;
    circle.borderDotsSpacingSize = weakSelf.circleBorderDotsSpacingSize;
    circle.fillColor = weakSelf.circleFillColor;
    circle.strokeColor = weakSelf.circleStrokeColor;
    circle.radius = weakSelf.circleRadius;
    circle.borderWidth = weakSelf.circleBorderWidth;
    circle.isMask = weakSelf.circleIsMask;
    circle.maskedObjectScale = weakSelf.circleMaskedObjectScale;
    circle.numberOfPoints = weakSelf.circleNumberOfPoints;
    
    return circle;
}

- (SKPolygon *)getPolygon {
    __weak TestingOverlayViewController *weakSelf = self;
    
    SKPolygon *polygon = [SKPolygon polygon];
    polygon.identifier = weakSelf.polygonIdentifier;
    polygon.coordinates = weakSelf.polygonCoordinates;
    polygon.borderDotsSize = weakSelf.polygonBorderDotsSize;
    polygon.borderDotsSpacingSize = weakSelf.polygonBorderDotsSpacingSize;
    polygon.fillColor = weakSelf.polygonFillColor;
    polygon.strokeColor = weakSelf.polygonStrokeColor;
    polygon.borderWidth = weakSelf.polygonBorderWidth;
    polygon.isMask = weakSelf.polygonIsMask;
    polygon.maskedObjectScale = weakSelf.polygonMaskedObjectScale;
    
    return polygon;
}

- (SKPolyline *)getPolyline {
    __weak TestingOverlayViewController *weakSelf = self;
    
    SKPolyline *polyline = [SKPolyline polyline];
    polyline.identifier = weakSelf.polylineIdentifier;
    polyline.coordinates = weakSelf.polylineCoordinates;
    polyline.borderDotsSize = weakSelf.polylineBorderDotsSize;
    polyline.borderDotsSpacingSize = weakSelf.polylineBorderDotsSpacingSize;
    polyline.fillColor = weakSelf.polylineFillColor;
    polyline.lineWidth = weakSelf.polylineLineWidth;
    polyline.backgroundLineWidth = weakSelf.polylineBackgroundLineWidth;
    
    return polyline;
}

- (UIColor *)colorForIndex:(int)index {
    UIColor *color = [UIColor blackColor];
    switch (index) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1:
            color = [UIColor blueColor];
            break;
        case 2:
            color = [UIColor greenColor];
            break;
        case 3:
            color = [UIColor yellowColor];
            break;
        case 4:
            color = [UIColor blackColor];
            break;
            
        default:
            break;
    }
    
    return color;
}

- (void)configureMenuView {
    MenuSection *addOverlaySection = [self addOverlaySection];
    MenuSection *deleteOverlaySection = [self deleteOverlaySection];
    MenuSection *searchSection = [self searchSection];
    MenuSection *newInstanceSection = [self newInstanceSection];
    
    self.menuView.sections = @[addOverlaySection, deleteOverlaySection, searchSection, newInstanceSection];
}

- (MenuSection*)addOverlaySection {
    MenuItem *circleItem = [MenuItem itemForMenuTypeWithTitle:@"Circle" sections:[self circleSection] selectionBlock:nil];
    MenuItem *polyognItem = [MenuItem itemForMenuTypeWithTitle:@"Polygon" sections:[self polygonSection] selectionBlock:nil];
    MenuItem *polylineItem = [MenuItem itemForMenuTypeWithTitle:@"Polyline" sections:[self polylineSection] selectionBlock:nil];
    
    MenuSection *section = [MenuSection sectionWithTitle:@"Add Overlays" items:@[circleItem, polyognItem, polylineItem]];
    
    return section;
}

- (MenuSection *)deleteOverlaySection {
    __weak TestingOverlayViewController *weakSelf = self;
    
    MenuItem *deleteOverlaysItem = [MenuItem itemForButtonWithTitle:@"Clear All Overlays" selectionBlock:^(MenuItem *item) {
        [weakSelf.mapView clearAllOverlays];
    }];
    
    MenuSection *deleteOverlaysSection = [MenuSection sectionWithTitle:@"Delete Overlays" items:@[deleteOverlaysItem]];
    
    return deleteOverlaysSection;
}

- (MenuSection *)searchSection {
    __weak TestingOverlayViewController *weakSelf = self;
    
    MenuItem *searchIdItem = [MenuItem itemForTextWithTitle:@"Identifier" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.searchOverlayId = item.intValue;
    } editEndBlock:nil];
    searchIdItem.intValue = 0;
    
    MenuItem *searchOverlaysItem = [MenuItem itemForButtonWithTitle:@"Search" selectionBlock:^(MenuItem *item) {
        [weakSelf searchForOverlayWithId:weakSelf.searchOverlayId];
    }];
    
    MenuSection *searchOverlaysSection = [MenuSection sectionWithTitle:@"Search Overlays" items:@[searchIdItem, searchOverlaysItem]];
    
    return searchOverlaysSection;
}

- (MenuSection *)newInstanceSection {
    __weak TestingOverlayViewController *weakSelf = self;
    
    MenuItem *searchOverlaysItem = [MenuItem itemForButtonWithTitle:@"Push" selectionBlock:^(MenuItem *item) {
        [weakSelf pushNewVcInstance];
    }];
    
    MenuSection *searchOverlaysSection = [MenuSection sectionWithTitle:@"New Instance" items:@[searchOverlaysItem]];
    
    return searchOverlaysSection;
}

- (NSArray *)circleSection {
    __weak TestingOverlayViewController *weakSelf = self;
    
    MenuItem *circleIdentifierItem = [MenuItem itemForTextWithTitle:@"Identifier" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleIdentifier = item.intValue;
    } editEndBlock:nil];
    circleIdentifierItem.intValue = 1;
    
    MenuItem *circleBorderDotsSizeItem = [MenuItem itemForSliderWithTitle:@"Border Dots Size" uniqueID:nil minValue:0.0 maxValue:30.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleBorderDotsSize = item.intValue;
    }];
    circleBorderDotsSizeItem.intValue = 2;
    
    MenuItem *circleBorderDotsSpacingSizeItem = [MenuItem itemForSliderWithTitle:@"Border Dots Spacing Size" uniqueID:nil minValue:0.0 maxValue:30.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleBorderDotsSpacingSize = item.intValue;
    }];
    circleBorderDotsSpacingSizeItem.intValue = 1;
    
    NSArray *colorOptions = @[@(0),@(1),@(2),@(3),@(4)];
    NSArray *colorStrings = @[@"Red", @"Blue", @"Green", @"Yellow", @"Black"];
    MenuItem *strokeColorItem = [MenuItem itemForOptionsWithTitle:@"Stroke Color" uniqueID:nil options:colorOptions readableOptions:colorStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleStrokeColor = [self colorForIndex:item.intValue];
    }];
    strokeColorItem.defaultValue = @(0);
    
    MenuItem *fillColorItem = [MenuItem itemForOptionsWithTitle:@"Fill Color" uniqueID:nil options:colorOptions readableOptions:colorStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleFillColor = [self colorForIndex:item.intValue];
    }];
    fillColorItem.defaultValue = @(1);
    
    MenuItem *circleLatitudeItem = [MenuItem itemForTextWithTitle:@"Latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleLatitude = item.floatValue;
    } editEndBlock:nil];
    circleLatitudeItem.floatValue = 0.0;
    
    MenuItem *circleLongitudeItem = [MenuItem itemForTextWithTitle:@"Longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleLongitude = item.floatValue;
    } editEndBlock:nil];
    circleLongitudeItem.floatValue = 0.0;
    
    MenuItem *circleRadiusItem = [MenuItem itemForTextWithTitle:@"Radius" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleRadius = item.floatValue;
    } editEndBlock:nil];
    circleRadiusItem.floatValue = 350.0;
    
    MenuItem *circleBorderWidthItem = [MenuItem itemForSliderWithTitle:@"Border Width" uniqueID:nil minValue:1.0 maxValue:10.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleBorderWidth = item.intValue;
    }];
    circleBorderWidthItem.intValue = 1;
    
    MenuItem *circleIsMaskItem = [MenuItem itemForToggleWithTitle:@"Is Mask" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleIsMask = item.boolValue;
    }];
    circleIsMaskItem.boolValue = NO;
    
    MenuItem *circleMaskedObjectScaleItem = [MenuItem itemForSliderWithTitle:@"Masked Object Scale" uniqueID:nil minValue:0.0 maxValue:30.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleMaskedObjectScale = item.floatValue;
    }];
    circleMaskedObjectScaleItem.floatValue = 1.0;
    
    MenuItem *circleNumberOfPointsItem = [MenuItem itemForSliderWithTitle:@"Number Of Points" uniqueID:nil minValue:0.0 maxValue:30.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.circleNumberOfPoints = item.intValue;
    }];
    circleNumberOfPointsItem.intValue = 6.0;
    
    MenuItem *addCircleItem = [MenuItem itemForButtonWithTitle:@"Add" selectionBlock:^(MenuItem *item) {
        [weakSelf addCircleToLocationType:OverlayLocationTypeCoordinate];
    }];
    
    MenuItem *addCircleToCenterItem = [MenuItem itemForButtonWithTitle:@"Add To Center" selectionBlock:^(MenuItem *item) {
        [weakSelf addCircleToLocationType:OverlayLocationTypeCenter];
    }];
    
    MenuItem *addCircleToMapItem = [MenuItem itemForButtonWithTitle:@"Add To Long Tap Coord." selectionBlock:^(MenuItem *item) {
        [weakSelf addCircleToLocationType:OverlayLocationTypeLongTap];
    }];
    
    MenuSection *circleSection = [MenuSection sectionWithTitle:@"Circle" items:@[circleIdentifierItem, circleBorderDotsSizeItem, circleBorderDotsSpacingSizeItem, strokeColorItem, fillColorItem, circleLatitudeItem, circleLongitudeItem, circleRadiusItem, circleBorderWidthItem, circleIsMaskItem, circleMaskedObjectScaleItem, circleNumberOfPointsItem, addCircleItem, addCircleToCenterItem, addCircleToMapItem]];
    
    return @[circleSection];
}

- (NSArray *)polygonSection {
    __weak TestingOverlayViewController *weakSelf = self;
    
    MenuItem *polygonIdentifierItem = [MenuItem itemForTextWithTitle:@"Identifier" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polygonIdentifier = item.intValue;
    } editEndBlock:nil];
    polygonIdentifierItem.intValue = 2;
    
    MenuItem *polygonBorderDotsSizeItem = [MenuItem itemForSliderWithTitle:@"Border Dots Size" uniqueID:nil minValue:0.0 maxValue:30.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polygonBorderDotsSize = item.intValue;
    }];
    polygonBorderDotsSizeItem.intValue = 2;
    
    MenuItem *polygonBorderDotsSpacingSizeItem = [MenuItem itemForSliderWithTitle:@"Border Dots Spacing Size" uniqueID:nil minValue:0.0 maxValue:30.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polygonBorderDotsSpacingSize = item.intValue;
    }];
    polygonBorderDotsSpacingSizeItem.intValue = 2;
    
    NSArray *colorOptions = @[@(0),@(1),@(2),@(3),@(4)];
    NSArray *colorStrings = @[@"Red", @"Blue", @"Green", @"Yellow", @"Black"];
    MenuItem *polygonStrokeColorItem = [MenuItem itemForOptionsWithTitle:@"Stroke Color" uniqueID:nil options:colorOptions readableOptions:colorStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polygonStrokeColor = [self colorForIndex:item.intValue];
    }];
    polygonStrokeColorItem.defaultValue = @(0);
    
    MenuItem *polygonFillColorItem = [MenuItem itemForOptionsWithTitle:@"Fill Color" uniqueID:nil options:colorOptions readableOptions:colorStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polygonFillColor = [self colorForIndex:item.intValue];
    }];
    polygonFillColorItem.defaultValue = @(1);
    
    self.polygonLatitudeItem = [MenuItem itemForTextWithTitle:@"Latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polygonLatitude = item.floatValue;
    } editEndBlock:nil];
    self.polygonLatitudeItem.floatValue = 0.0;
    
    self.polygonLongitudeItem = [MenuItem itemForTextWithTitle:@"Longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polygonLongitude = item.floatValue;
    } editEndBlock:nil];
    self.polygonLongitudeItem.floatValue = 0.0;
    
    MenuItem *addLocationItem = [MenuItem itemForButtonWithTitle:@"Add Location" selectionBlock:^(MenuItem *item) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:weakSelf.polygonLatitude longitude:weakSelf.polygonLongitude];
        [weakSelf.polygonCoordinates addObject:location];
    }];
    
    MenuItem *addLocationFromLongTapItem = [MenuItem itemForButtonWithTitle:@"Add Long Tap Location" selectionBlock:^(MenuItem *item) {
        weakSelf.shouldAddLocationToPolygon = YES;
    }];
    
    MenuItem *polygonBorderWidthItem = [MenuItem itemForSliderWithTitle:@"Border Width" uniqueID:nil minValue:1.0 maxValue:10.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polygonBorderWidth = item.intValue;
    }];
    polygonBorderWidthItem.intValue = 2;
    
    MenuItem *polygonIsMaskItem = [MenuItem itemForToggleWithTitle:@"Is Mask" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polygonIsMask = item.boolValue;
    }];
    polygonIsMaskItem.boolValue = NO;
    
    MenuItem *polygonMaskedObjectScaleItem = [MenuItem itemForSliderWithTitle:@"Masked Object Scale" uniqueID:nil minValue:0.0 maxValue:30.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polygonMaskedObjectScale = item.floatValue;
    }];
    polygonMaskedObjectScaleItem.floatValue = 1.0;
    
    MenuItem *deleteLastPolygonLocationItem = [MenuItem itemForButtonWithTitle:@"Remove Last Location" selectionBlock:^(MenuItem *item) {
        [weakSelf deleteLastPolygonLocation];
    }];
    
    MenuItem *addPolygonItem = [MenuItem itemForButtonWithTitle:@"Add" selectionBlock:^(MenuItem *item) {
        [weakSelf addPolygon];
    }];
    
    MenuSection *polygonSection = [MenuSection sectionWithTitle:@"Polygon" items:@[polygonIdentifierItem, polygonBorderDotsSizeItem, polygonBorderDotsSpacingSizeItem, polygonStrokeColorItem, polygonFillColorItem, self.polygonLatitudeItem, self.polygonLongitudeItem, addLocationItem, addLocationFromLongTapItem,polygonBorderWidthItem, polygonIsMaskItem, polygonMaskedObjectScaleItem, deleteLastPolygonLocationItem, addPolygonItem]];
    
    return @[polygonSection];
}

- (NSArray *)polylineSection {
    __weak TestingOverlayViewController *weakSelf = self;
    
    MenuItem *polylineIdentifierItem = [MenuItem itemForTextWithTitle:@"Identifier" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polylineIdentifier = item.intValue;
    } editEndBlock:nil];
    polylineIdentifierItem.intValue = 3;
    
    MenuItem *polylineBorderDotsSizeItem = [MenuItem itemForSliderWithTitle:@"Border Dots Size" uniqueID:nil minValue:0.0 maxValue:30.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polylineBorderDotsSize = item.intValue;
    }];
    polylineBorderDotsSizeItem.intValue = 1;
    
    MenuItem *polylineBorderDotsSpacingSizeItem = [MenuItem itemForSliderWithTitle:@"Border Dots Spacing Size" uniqueID:nil minValue:0.0 maxValue:30.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polylineBorderDotsSpacingSize = item.intValue;
    }];
    polylineBorderDotsSpacingSizeItem.intValue = 1;
    
    NSArray *colorOptions = @[@(0),@(1),@(2),@(3),@(4)];
    NSArray *colorStrings = @[@"Red", @"Blue", @"Green", @"Yellow", @"Black"];
    MenuItem *polylineFillColorItem = [MenuItem itemForOptionsWithTitle:@"Fill Color" uniqueID:nil options:colorOptions readableOptions:colorStrings changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polylineFillColor = [self colorForIndex:item.intValue];
    }];
    polylineFillColorItem.defaultValue = @(0);
    
    self.polylineLatitudeItem = [MenuItem itemForTextWithTitle:@"Latitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polylineLatitude = item.floatValue;
    } editEndBlock:nil];
    self.polylineLatitudeItem.floatValue = 0.0;
    
    self.polylineLongitudeItem = [MenuItem itemForTextWithTitle:@"Longitude" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polylineLongitude = item.floatValue;
    } editEndBlock:nil];
    self.polylineLongitudeItem.floatValue = 0.0;
    
    MenuItem *addLocationItem = [MenuItem itemForButtonWithTitle:@"Add Location" selectionBlock:^(MenuItem *item) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:weakSelf.polylineLatitude longitude:weakSelf.polylineLongitude];
        [weakSelf.polylineCoordinates addObject:location];
    }];
    
    MenuItem *addLocationFromLongTapItem = [MenuItem itemForButtonWithTitle:@"Add Long Tap Location" selectionBlock:^(MenuItem *item) {
        weakSelf.shouldAddLocationToPolyline = YES;
    }];
    
    MenuItem *polylineWidthItem = [MenuItem itemForSliderWithTitle:@"Border Width" uniqueID:nil minValue:1.0 maxValue:10.0 changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polylineLineWidth = item.intValue;
    }];
    polylineWidthItem.intValue = 1;
    
    MenuItem *polylineBackgroundLineWidthItem = [MenuItem itemForToggleWithTitle:@"Is Mask" uniqueID:nil changeBlock:^(MenuItem *item, NSObject<NSCoding> *newValue, NSObject<NSCoding> *oldValue) {
        weakSelf.polylineBackgroundLineWidth = item.intValue;
    }];
    polylineBackgroundLineWidthItem.intValue = 1;
    
    MenuItem *deleteLastPolylineLocationItem = [MenuItem itemForButtonWithTitle:@"Remove Last Location" selectionBlock:^(MenuItem *item) {
        [weakSelf deleteLastPolylineLocation];
    }];
    
    MenuItem *addPollineItem = [MenuItem itemForButtonWithTitle:@"Add" selectionBlock:^(MenuItem *item) {
        [weakSelf addPolyline];
    }];
    
    MenuSection *polylineSection = [MenuSection sectionWithTitle:@"Polyline" items:@[polylineIdentifierItem, polylineBorderDotsSizeItem, polylineBorderDotsSpacingSizeItem, polylineFillColorItem, self.polylineLatitudeItem, self.polylineLongitudeItem, addLocationItem, addLocationFromLongTapItem, polylineWidthItem,polylineBackgroundLineWidthItem, deleteLastPolylineLocationItem, addPollineItem]];
    
    return @[polylineSection];
}

- (void)addCenterView {
    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 5.0, 5.0)];
    self.centerView.centerX = self.mapView.frameWidth / 2.0;
    self.centerView.centerY = self.mapView.frameHeight / 2.0;
    self.centerView.backgroundColor = [UIColor redColor];
    self.centerView.alpha = 0.5;
    self.centerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.mapView addSubview:self.centerView];
}

- (void)addTapLabel {
    self.tapLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 20.0)];
    self.tapLabel.backgroundColor = [UIColor clearColor];
    self.tapLabel.center = self.view.center;
    self.tapLabel.text = @"Overlay With ID:- Tapped";
    self.tapLabel.textAlignment = NSTextAlignmentCenter;
    self.tapLabel.backgroundColor = [UIColor whiteColor];
    self.tapLabel.hidden = YES;
    self.tapLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:self.tapLabel];
}

#pragma mark - SKMapViewDelegate methods

- (void)mapView:(SKMapView *)mapView didLongTapAtCoordinate:(CLLocationCoordinate2D)coordinate  {
    self.longTapCoordinate = coordinate;
    
    [self addLocationToPolygon];
    [self addLocationToPolyline];
}

- (void)mapView:(SKMapView *)mapView didSelectOverlayWithId:(int)overlayId atLocation:(CLLocationCoordinate2D)location {
    self.tapLabel.text = [NSString stringWithFormat:@"Overlay With ID:%d Tapped",overlayId];
    self.tapLabel.hidden = NO;
    
    [self performSelector:@selector(hideTapLabel) withObject:nil afterDelay:3.0];
}

@end
