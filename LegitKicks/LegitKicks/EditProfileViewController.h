//
//  EditProfileViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 21/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UIView *photoBackView;
    IBOutlet UIImageView *photoImageView;
    IBOutlet UIButton *addPhotoBtn;
    IBOutlet UITextField *firstnameTxt;
    IBOutlet UITextField *lastnameTxt;
    IBOutlet UITextField *streetAddressTxt;
    IBOutlet UITextField *cityTxt;
    IBOutlet UITextField *stateTxt;
    IBOutlet UITextField *zipTxt;
    IBOutlet UIButton *updateBtn;
}
@property(nonatomic, retain)NSDictionary *userDict;

@end
