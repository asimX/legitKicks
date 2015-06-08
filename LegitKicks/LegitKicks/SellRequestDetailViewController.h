//
//  SellRequestDetailViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 13/03/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface SellRequestDetailViewController : UIViewController
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UITableView *sneakerTable;
    IBOutlet NSLayoutConstraint *sneakerTableHeightConstraint;
    IBOutlet UIView *makeCounterOfferView;
    IBOutlet UITextField *counterOfferTxt;
    IBOutlet UIButton *counterOfferBtn;
    IBOutlet UIView *actionView;
    IBOutlet UIButton *acceptBtn;
    IBOutlet UIButton *rejectBtn;
    IBOutlet UIButton *sendBtn;
    IBOutlet NSLayoutConstraint *actionViewBottomSpaceConstraint;
    IBOutlet NSLayoutConstraint *makeCounterOffersViewBottomSpaceConstraint;
    
    
    IBOutlet UIView *offerRequestedView;
    IBOutlet UILabel *offerRequestedValueLbl;
    IBOutlet UIView *counterOfferRequestedView;
    IBOutlet UILabel *counterOfferRequestedValueLbl;
    IBOutlet UIView *offerAcceptedRejectedTimeView;
    IBOutlet UILabel *offerAcceptedRejectedTimeTitleLbl;
    IBOutlet UILabel *offerAcceptedRejectedTimeValueLbl;
    IBOutlet UIView *paidTimeView;
    IBOutlet UILabel *paidTimeValueLbl;
    IBOutlet UIView *sentTimeView;
    IBOutlet UILabel *sentTimeValueLbl;
    IBOutlet UIView *receivedTimeView;
    IBOutlet UILabel *receivedTimeValueLbl;
    
    IBOutlet NSLayoutConstraint *offerRequestedViewBottomSpaceConstraint;
    IBOutlet NSLayoutConstraint *counterOfferRequestedViewBottomSpaceConstraint;
    IBOutlet NSLayoutConstraint *offerAcceptedRejectedTimeViewBottomSpaceConstraint;
    IBOutlet NSLayoutConstraint *paidTimeViewBottomSpaceConstraint;
    IBOutlet NSLayoutConstraint *sentTimeViewBottomSpaceConstraint;
    IBOutlet NSLayoutConstraint *receivedTimeViewBottomSpaceConstraint;
    
    
    IBOutlet UIView *ratingPopupView;
    IBOutlet UIScrollView *ratingPopupScroll;
    IBOutlet UIView *ratingView;
    IBOutlet UILabel *ratingTitleLbl;
    IBOutlet EDStarRating *sneakerRatingView;
    IBOutlet UITextView *reviewTxt;
    IBOutlet UIButton *ratingPopupDoneBtn;
}

@property(nonatomic, retain)NSDictionary *saleDict;
@end
