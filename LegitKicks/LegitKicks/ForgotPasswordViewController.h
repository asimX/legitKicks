//
//  ForgotPasswordViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 15/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UILabel *descLbl;
    IBOutlet UITextField *emailTxt;
    IBOutlet UIButton *submitBtn;
}

@end
