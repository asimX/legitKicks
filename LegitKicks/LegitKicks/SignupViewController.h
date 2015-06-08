//
//  SignupViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 12/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UIView *photoBackView;
    IBOutlet UIImageView *photoImageView;
    IBOutlet UIButton *addPhotoBtn;
    IBOutlet UITextField *usernameTxt;
    IBOutlet UITextField *emailTxt;
    IBOutlet UITextField *passwordTxt;
    IBOutlet UITextField *confirmPasswordTxt;
    IBOutlet UILabel *agreementDescLbl;
    IBOutlet UIButton *termsConditionBtn;
    IBOutlet UIButton *privacyPolicyBtn;
    IBOutlet UIButton *registerBtn;
}

@end
