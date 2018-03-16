//
//  DataListTableViewController.h
//  officialDemoLoc
//
//  Created by Hutong on 04/09/2017.
//  Copyright © 2017 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataListTableViewController : UITableViewController

@property (nonatomic, strong) NSString *fileName;

-(id)initWithFileName:(NSString *)fileName;

@end
