//
//  downloadRountesController.h
//  FrameworkIOSDemo
//
//  Created by john on 11/12/2015.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "GDataXMLNode.h"

@interface downloadRountesController : UIViewController<NSXMLParserDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tblViewRoutes;
-(void)parseXMLFile:(NSString *)pathToFile;

@end
