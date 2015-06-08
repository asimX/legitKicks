//
//  SneakerDetailViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 11/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating/EDStarRating.h"

@interface SneakerDetailViewController : UIViewController
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UICollectionView *sneakerImageCollectionView;
    IBOutlet UIImageView *profileImageView;
    IBOutlet UILabel *usernameLbl;
    IBOutlet EDStarRating *avgRatingView;
    IBOutlet UILabel *brandValueLbl;
    IBOutlet UILabel *conditionValueLbl;
    IBOutlet UILabel *sizeValueLbl;
    IBOutlet UILabel *descriptionValueLbl;
    IBOutlet UILabel *priceValueLbl;
    IBOutlet UIView *bottomActionView;
    IBOutlet UIButton *requestForTradeBtn;
    IBOutlet UIButton *requestForSaleBtn;
    IBOutlet UIButton *requestForBtn;
    IBOutlet NSLayoutConstraint *actionViewBottomSpaceConstraint;
}
@property(nonatomic, retain)NSDictionary *sneakerInfoDict;
@property(nonatomic, assign)BOOL disableAction;

@end
