//
//  PublicProfileViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 26/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublicProfileViewController : UIViewController
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UIView *photoBackView;
    IBOutlet UIImageView *photoImageView;
    IBOutlet UILabel *nameLbl;
    IBOutlet UILabel *locationLbl;
    
    IBOutlet UIButton *ratingBtn;
    IBOutlet UIButton *closetsBtn;
    
    IBOutlet UILabel *tradedCountLbl;
    IBOutlet UILabel *soldCountLbl;
    IBOutlet UILabel *boughtCountLbl;

    IBOutlet UIButton *flagUserBtn;
}
@property(nonatomic, retain)NSString *userid;

@end
