//
//  LeftMenuViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 15/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *menuTableview;
    
    NSMutableArray *menuArray;
}

@end
