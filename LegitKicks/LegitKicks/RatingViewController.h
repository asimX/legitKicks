//
//  RatingViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 25/04/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface RatingViewController : UIViewController
{
    IBOutlet UIView *ratingPopupView;
    IBOutlet UIScrollView *ratingPopupScroll;
    IBOutlet UIView *ratingView;
    IBOutlet UILabel *ratingTitleLbl;
    IBOutlet EDStarRating *sneakerRatingView;
    IBOutlet UITextView *reviewTxt;
    IBOutlet UIButton *ratingPopupDoneBtn;
    
    IBOutlet UIScrollView *scroll;
    IBOutlet UIImageView *profileImageView;
    IBOutlet UITableView *sneakerTable;
    IBOutlet NSLayoutConstraint *sneakerTableHeightConstraint;
}
@property(nonatomic, retain)NSDictionary *sellTradeInfoDict;
@property(assign)BOOL forTrade;
@property(assign)BOOL fromCheckingRemainRating;

@end
