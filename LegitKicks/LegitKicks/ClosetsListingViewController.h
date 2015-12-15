//
//  ClosetsListingViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 10/08/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClosetsListingViewController;

@protocol ClosetsListingVcDelegate <NSObject>

-(void)closetSelectedWithDict:(NSDictionary *)dict viewController:(ClosetsListingViewController *)viewController;

@end

@interface ClosetsListingViewController : UIViewController
{
    IBOutlet UISegmentedControl *closetTypeSegmentControl;
    IBOutlet UITableView *closetTableview;
    
    NSMutableArray *closetArray;
    NSMutableArray *randomClosetArray;
    NSMutableArray *recentClosetArray;
    NSMutableArray *popularClosetArray;
    NSMutableArray *followingClosetArray;
}
@property(assign)BOOL isRandomClosets;
@property(assign)BOOL isRecentClosets;
@property(assign)BOOL isPopularClosets;
@property(assign)BOOL isFollowingClosets;
@property(nonatomic, weak)id <ClosetsListingVcDelegate> delegate;

-(void)loadViewFromStart;

@end
