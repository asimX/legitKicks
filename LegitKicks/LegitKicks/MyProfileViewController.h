//
//  MyProfileViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 19/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyProfileViewController : UIViewController
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UIView *photoBackView;
    IBOutlet UIImageView *photoImageView;
    IBOutlet UILabel *nameLbl;
    
    IBOutlet UIButton *ratingBtn;
    IBOutlet UIButton *closetsBtn;
    
    IBOutlet UILabel *tradedCountLbl;
    IBOutlet UILabel *soldCountLbl;
    IBOutlet UILabel *boughtCountLbl;
    IBOutlet UILabel *tradingCountLbl;
    IBOutlet UILabel *sellingCountLbl;
    IBOutlet UILabel *buyingCountLbl;
    
    IBOutlet UITableView *userInfoTable;
    IBOutlet NSLayoutConstraint *userInfoTableHeightConstraint;
    
    IBOutlet UIButton *logoutBtn;
}

@end
