//
//  SignupViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 12/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "SignupViewController.h"
#import "UIImage+ProportionalFill.h"

@interface SignupViewController ()
{
    UITextField *lastTextfield;
    BOOL isProfileImageSelected;
    UIImageView *tempImage;
}

@end

@implementation SignupViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"register", nil);
    usernameTxt.placeholder = NSLocalizedString(@"user_name", nil);
    emailTxt.placeholder = NSLocalizedString(@"email_address", nil);
    passwordTxt.placeholder = NSLocalizedString(@"password", nil);
    confirmPasswordTxt.placeholder = NSLocalizedString(@"confirm_password", nil);
    [registerBtn setTitle:NSLocalizedString(@"register", nil) forState:UIControlStateNormal];
    
    self.navigationController.navigationBarHidden = NO;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setBackButtonToNavigationBar];
    
    tempImage = [[UIImageView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    
    [scroll layoutIfNeeded];
    
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    usernameTxt.leftView = paddingView;
    usernameTxt.leftViewMode = UITextFieldViewModeAlways;
    usernameTxt.rightView = paddingView;
    usernameTxt.rightViewMode = UITextFieldViewModeAlways;
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    emailTxt.leftView = paddingView;
    emailTxt.leftViewMode = UITextFieldViewModeAlways;
    emailTxt.rightView = paddingView;
    emailTxt.rightViewMode = UITextFieldViewModeAlways;
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    passwordTxt.leftView = paddingView;
    passwordTxt.leftViewMode = UITextFieldViewModeAlways;
    passwordTxt.rightView = paddingView;
    passwordTxt.rightViewMode = UITextFieldViewModeAlways;
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    confirmPasswordTxt.leftView = paddingView;
    confirmPasswordTxt.leftViewMode = UITextFieldViewModeAlways;
    confirmPasswordTxt.rightView = paddingView;
    confirmPasswordTxt.rightViewMode = UITextFieldViewModeAlways;
    
    usernameTxt.layer.cornerRadius = 4.0;
    emailTxt.layer.cornerRadius = 4.0;
    passwordTxt.layer.cornerRadius = 4.0;
    confirmPasswordTxt.layer.cornerRadius = 4.0;
    registerBtn.layer.cornerRadius = 4.0;
    
    
    photoBackView.layer.cornerRadius = photoBackView.frame.size.width/2.0;
    photoBackView.layer.borderColor = [UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0].CGColor;
    photoBackView.layer.borderWidth =1.0;
    
    photoImageView.layer.cornerRadius = photoImageView.frame.size.width/2.0;
    photoImageView.layer.borderWidth = 3.0;
    photoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
}


#pragma mark Set custom Back button to Navigationbar
- (void)setBackButtonToNavigationBar
{
    UIImage *backButtonImage = [UIImage imageNamed:@"back_btn"];
    CGRect buttonFrame = CGRectMake(0, 0, 44, 44);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = buttonFrame;
    [button addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:backButtonImage forState:UIControlStateNormal];
    
    
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, settingItem, nil]];
    
}

-(IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



-(IBAction)addPhotoBtnClicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"select_photo", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"take_a_photo", nil), NSLocalizedString(@"choose_existing", nil), NSLocalizedString(@"cancel", nil), nil];
    alert.tag = 100;
    [alert show];
}


-(IBAction)registerBtnClicked:(id)sender
{
    [lastTextfield resignFirstResponder];
    
    /*if(![AppDelegate isLocationServiceEnable])
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"location_service_enabling_alert", nil)];
    }
    else */if(!isProfileImageSelected)
    {
        [self.view makeToast:NSLocalizedString(@"select_profile_picture_alert", nil)];
    }
    else if([usernameTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_user_name_alert", nil)];
    }
    else if([emailTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_email_address_alert", nil)];
    }
    else if(![self validateEmail:emailTxt.text])
    {
        [self.view makeToast:NSLocalizedString(@"enter_valid_email_address_alert", nil)];
    }
    else if([passwordTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_password_alert", nil)];
    }
    else if([confirmPasswordTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_confirm_password_alert", nil)];
    }
    else if(![passwordTxt.text isEqualToString:confirmPasswordTxt.text])
    {
        [self.view makeToast:NSLocalizedString(@"confirm_password_does_not_match_alert", nil)];
    }
    else
    {
        if([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSDictionary *params = @{@"method" : @"Registration",
                                     @"userid" : @"0",
                                     @"FacebookID" : @"0",
                                     @"GooglePlusID" : @"0",
                                     @"firstname" : @"",
                                     @"lastname" : @"",
                                     @"email" : emailTxt.text,
                                     @"username" : usernameTxt.text,
                                     @"password" : passwordTxt.text,
                                     @"imageURL" : @"",
                                     @"userdescription" : @"",
                                     @"location" : @"",
                                     @"device_token" : @""};
            LKLog(@"params = %@",params);
            
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
            
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            
            MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view.window];
            [self.view.window addSubview:loading];
            [loading show:YES];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager.operationQueue cancelAllOperations];
            
            [manager POST:BASE_API parameters:@{@"data" : jsonString} constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
            {
                [formData appendPartWithFileData:UIImageJPEGRepresentation(tempImage.image, 1.0) name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                 LKLog(@"JSON: %@", responseObject);
                
                 [loading hide:YES];

                 if([responseObject[@"success"] integerValue] == 1)
                 {
                     if([responseObject[@"status"] integerValue]==2)
                     {
                         [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"already_registered_alert", nil)];
                     }
                     else if([responseObject[@"status"] integerValue]==1)
                     {
                         [self.navigationController.view.window makeToast:NSLocalizedString(@"signup_successfully_done_alert", nil)];
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                 }
                 else
                 {
                     [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"signup_failed_alert", nil)];
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [loading hide:YES];
                 
                 LKLog(@"failed response string = %@",operation.responseString);
                 [Utility displayHttpFailureError:error];
             }];
        }
        else
        {
            [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
        }
    }
}


- (BOOL)validateEmail:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}


#pragma mark UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100 && buttonIndex==0)
    {
        [self loadCameraCaptureView];
    }
    else if(alertView.tag==100 && buttonIndex==1)
    {
        [self loadPhotoGalleryView];
    }
}


#pragma mark Load camera capture view
-(void)loadCameraCaptureView
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        mediaUI.allowsEditing = YES;
        
        mediaUI.delegate = self;
        
        mediaUI.showsCameraControls = YES;
        
        [self presentViewController:mediaUI animated:YES completion:nil];
    }
    else
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"camera_not_available", nil)];
    }
}

#pragma mark Load photo gallery view
-(void)loadPhotoGalleryView
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        // Displays saved pictures and movies, if both are available, from the
        // Camera Roll album.
        mediaUI.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypePhotoLibrary];
        
        mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        mediaUI.allowsEditing = YES;
        
        mediaUI.delegate = self;
        
        [self presentViewController:mediaUI animated:YES completion:nil];
    }
    else
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"gallery_not_available", nil)];
    }
}

#pragma mark ImagePickerViewController delegate method
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    isProfileImageSelected = YES;
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo)
    {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        
        tempImage.image = imageToUse;
        
        [photoImageView setImage:[imageToUse imageCroppedToFitSize:photoImageView.frame.size]];
        photoImageView.layer.borderWidth = 3.0;
        photoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Keyboard Notifications

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note
{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // commit animations
    [UIView commitAnimations];
    
    
    CGFloat keyboardHeight = keyboardBounds.size.height;
    UIEdgeInsets bottomInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    [scroll setContentInset:bottomInset];
    [scroll setScrollIndicatorInsets:bottomInset];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // commit animations
    [UIView commitAnimations];
    
    
    CGFloat keyboardHeight = 0;
    UIEdgeInsets bottomInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    [scroll setContentInset:bottomInset];
    [scroll setScrollIndicatorInsets:bottomInset];
}



#pragma mark - TextField delegate method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==usernameTxt)
    {
        [emailTxt becomeFirstResponder];
    }
    else if(textField==emailTxt)
    {
        [passwordTxt becomeFirstResponder];
    }
    else if(textField==passwordTxt)
    {
        [confirmPasswordTxt becomeFirstResponder];
    }
    else if(textField==confirmPasswordTxt)
    {
        [confirmPasswordTxt resignFirstResponder];
        [self registerBtnClicked:nil];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    lastTextfield = textField;
    
    if((textField.frame.origin.y-scroll.contentOffset.y)>100)
    {
        scroll.contentOffset = CGPointMake(0, textField.frame.origin.y-50); //make room for keyboard
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
