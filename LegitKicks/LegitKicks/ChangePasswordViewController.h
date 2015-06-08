//
//  ResetPasswordViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 15/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UITextField *oldPasswordTxt;
    IBOutlet UITextField *newPasswordTxt;
    IBOutlet UITextField *confirmPasswordTxt;
    IBOutlet UIButton *submitBtn;
}

@end
