//
//  ViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 28/10/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UILabel *titleLbl;
    IBOutlet UITextField *emailTxt;
    IBOutlet UITextField *passwordTxt;
    IBOutlet UIButton *forgotPasswordBtn;
    IBOutlet UIButton *loginBtn;
    IBOutlet UIButton *facebookLoginBtn;
    IBOutlet UIButton *googlePlusLoginBtn;
    IBOutlet UIButton *signupBtn;
}


@end

