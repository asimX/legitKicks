//
//  ActivitiesViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 07/02/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivitiesViewController : UIViewController
{
    IBOutlet UISegmentedControl *activityTypeSegmentControl;
    IBOutlet UITableView *activityTableview;
    
    NSMutableArray *activityArray;
    NSMutableArray *tradeActivityArray;
    NSMutableArray *sellActivityArray;
    NSMutableArray *buyActivityArray;
    NSMutableArray *questionActivityArray;
}

@end
