//
//  FilterMultiSelectionViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 08/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SIZE_FILTER_TYPE        1
#define CONDITION_FILTER_TYPE   2

@interface FilterMultiSelectionViewController : UIViewController
{
    IBOutlet UITableView *listTableView;
}
@property(nonatomic, retain)NSMutableArray *selectedListArray;
@property(nonatomic, assign)NSInteger filterType;

@end
