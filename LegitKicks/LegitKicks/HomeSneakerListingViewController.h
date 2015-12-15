//
//  HomeSneakerListingViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 08/08/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeSneakerListingViewController;

@protocol HomeSneakerListingVcDelegate <NSObject>

-(void)sneakerSelectedWithDict:(NSDictionary *)dict viewController:(HomeSneakerListingViewController *)viewController;

@end

@interface HomeSneakerListingViewController : UIViewController
{
    IBOutlet UICollectionView *sneakerCollectionView;
    IBOutlet UILabel *noSneakerFoundLbl;
    
    NSMutableArray *sneakerArray;
    NSMutableArray *sneakerForTradeArray;
    NSMutableArray *sneakerForSaleArray;
}
@property(assign)BOOL isListingForTrade;
@property(nonatomic, weak)id <HomeSneakerListingVcDelegate> delegate;
-(void)loadViewFromStart;

@end
