//
//  EditPayPalInfoViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 20/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPayPalInfoViewController : UIViewController
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UILabel *descLbl;
    IBOutlet UITextField *paypalIdTxt;
    IBOutlet UITextField *confirmPaypalIdTxt;
    IBOutlet UIButton *updateBtn;
}

@end
