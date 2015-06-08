//
//  ReviewListViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 02/04/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewListViewController : UIViewController
{
    IBOutlet UITableView *reviewTable;
}
@property(nonatomic, retain)NSDictionary *userDict;
@end
