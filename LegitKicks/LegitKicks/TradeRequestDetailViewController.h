//
//  TradeRequestDetailViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 08/02/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface TradeRequestDetailViewController : UIViewController
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UITableView *sneakerTable;
    IBOutlet NSLayoutConstraint *sneakerTableHeightConstraint;
    IBOutlet UIView *actionView;
    IBOutlet UIButton *acceptTradeBtn;
    IBOutlet UIButton *rejectTradeBtn;
    IBOutlet UIButton *sendBtn;
    IBOutlet NSLayoutConstraint *actionViewBottomSpaceConstraint;
    
    IBOutlet UIView *ratingPopupView;
    IBOutlet UIScrollView *ratingPopupScroll;
    IBOutlet UIView *ratingView;
    IBOutlet UILabel *ratingTitleLbl;
    IBOutlet EDStarRating *sneakerRatingView;
    IBOutlet UITextView *reviewTxt;
    IBOutlet UIButton *ratingPopupDoneBtn;
}

@property(nonatomic, retain)NSDictionary *tradeDict;

@end
