//
//  ClosetsViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 21/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClosetsViewController : UIViewController
{
    IBOutlet UISegmentedControl *closetTypeSegmentControl;
    IBOutlet UITableView *closetTableview;
    
    NSMutableArray *closetArray;
    NSMutableArray *randomClosetArray;
    NSMutableArray *recentClosetArray;
    NSMutableArray *popularClosetArray;
    NSMutableArray *followingClosetArray;
}

@end
