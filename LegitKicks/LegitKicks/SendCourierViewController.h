//
//  SendCourierViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 09/02/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendCourierViewController : UIViewController
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UILabel *usernameValueLbl;
    IBOutlet UILabel *addressValueLbl;
    IBOutlet UILabel *cityValueLbl;
    IBOutlet UILabel *stateValueLbl;
    IBOutlet UILabel *zipValueLbl;
    IBOutlet UITextField *courierNameTxt;
    IBOutlet UITextField *courierNumberTxt;
    IBOutlet UIButton *sendBtn;
    
}
@property(assign)BOOL sendCourierForTrade;
@property(nonatomic, retain)NSDictionary *tradeDict;
@property(nonatomic, retain)NSDictionary *saleDict;

@end
