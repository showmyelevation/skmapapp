//
//  SearchResultsViewController.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SKMaps/SKSearch.h>

typedef enum
{
    SearchTypeAddress = 0,
    SearchTypeNearby = 1,
    SearchTypeWikiTravel = 2,
}SearchType;

@interface SearchResultsViewController : UIViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil searchResults:(NSArray*)searchResults searchType:(SearchType)type;
@end
