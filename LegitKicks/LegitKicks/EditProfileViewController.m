//
//  EditProfileViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 21/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "EditProfileViewController.h"
#import "UIImage+ProportionalFill.h"
//#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"

@interface EditProfileViewController ()
{
    UITextField *lastTextfield;
    BOOL isProfileImageSelected;
    UIImageView *tempImage;
}

@end

@implementation EditProfileViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"edit_profile", nil);
    firstnameTxt.placeholder = NSLocalizedString(@"first_name", nil);
    lastnameTxt.placeholder = NSLocalizedString(@"last_name", nil);
    streetAddressTxt.placeholder = NSLocalizedString(@"street_address", nil);
    cityTxt.placeholder = NSLocalizedString(@"city", nil);
    stateTxt.placeholder = NSLocalizedString(@"state", nil);
    zipTxt.placeholder = NSLocalizedString(@"zip", nil);
    [updateBtn setTitle:NSLocalizedString(@"update", nil) forState:UIControlStateNormal];
    
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
    firstnameTxt.leftView = paddingView;
    firstnameTxt.leftViewMode = UITextFieldViewModeAlways;
    firstnameTxt.rightView = paddingView;
    firstnameTxt.rightViewMode = UITextFieldViewModeAlways;
    
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    lastnameTxt.leftView = paddingView;
    lastnameTxt.leftViewMode = UITextFieldViewModeAlways;
    lastnameTxt.rightView = paddingView;
    lastnameTxt.rightViewMode = UITextFieldViewModeAlways;
    
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    streetAddressTxt.leftView = paddingView;
    streetAddressTxt.leftViewMode = UITextFieldViewModeAlways;
    streetAddressTxt.rightView = paddingView;
    streetAddressTxt.rightViewMode = UITextFieldViewModeAlways;
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    cityTxt.leftView = paddingView;
    cityTxt.leftViewMode = UITextFieldViewModeAlways;
    cityTxt.rightView = paddingView;
    cityTxt.rightViewMode = UITextFieldViewModeAlways;
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    stateTxt.leftView = paddingView;
    stateTxt.leftViewMode = UITextFieldViewModeAlways;
    stateTxt.rightView = paddingView;
    stateTxt.rightViewMode = UITextFieldViewModeAlways;
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    zipTxt.leftView = paddingView;
    zipTxt.leftViewMode = UITextFieldViewModeAlways;
    zipTxt.rightView = paddingView;
    zipTxt.rightViewMode = UITextFieldViewModeAlways;
    
    firstnameTxt.layer.cornerRadius = 4.0;
    lastnameTxt.layer.cornerRadius = 4.0;
    streetAddressTxt.layer.cornerRadius = 4.0;
    cityTxt.layer.cornerRadius = 4.0;
    stateTxt.layer.cornerRadius = 4.0;
    zipTxt.layer.cornerRadius = 4.0;
    updateBtn.layer.cornerRadius = 4.0;
    
    
    photoBackView.layer.cornerRadius = photoBackView.frame.size.width/2.0;
    photoBackView.layer.borderColor = [UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0].CGColor;
    photoBackView.layer.borderWidth =1.0;
    
    photoImageView.layer.cornerRadius = photoImageView.frame.size.width/2.0;
    photoImageView.layer.borderWidth = 3.0;
    photoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    
    if(self.userDict == nil)
    {
        NSDictionary *dict = [LKKeyChain objectForKey:@"userObject"];
        self.userDict = [[NSDictionary alloc] initWithDictionary:dict];
    }
    
    
    firstnameTxt.text = self.userDict[@"firstname"];
    lastnameTxt.text = self.userDict[@"lastname"];
    streetAddressTxt.text = self.userDict[@"street_address"];
    cityTxt.text = self.userDict[@"city"];
    stateTxt.text = self.userDict[@"state"];
    zipTxt.text = self.userDict[@"zip"];
    
    __block UIImageView *blockThumbImage = photoImageView;
    
    /*[photoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.userDict[@"image"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         blockThumbImage.image = image;
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];*/
    
    [photoImageView sd_setImageWithURL:[NSURL URLWithString:self.userDict[@"image"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        blockThumbImage.image = image;
    }];
    
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



-(IBAction)editPhotoBtnClicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"select_photo", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"take_a_photo", nil), NSLocalizedString(@"choose_existing", nil), NSLocalizedString(@"cancel", nil), nil];
    alert.tag = 100;
    [alert show];
}


-(IBAction)updateBtnClicked:(id)sender
{
    [lastTextfield resignFirstResponder];
    
    
    //[Utility displayAlertWithTitle:@"Update Profile" andMessage:@"Under Construction!!"];
    
    //return;
    
    if([firstnameTxt.text length]==0)
     {
         [self.view makeToast:NSLocalizedString(@"enter_first_name_alert", nil)];
     }
     else if([lastnameTxt.text length]==0)
     {
         [self.view makeToast:NSLocalizedString(@"enter_last_name_alert", nil)];
     }
     /*else if([streetAddressTxt.text length]==0)
     {
         [self.view makeToast:NSLocalizedString(@"enter_email_address_alert", nil)];
     }
     else if([cityTxt.text length]==0)
     {
         [self.view makeToast:NSLocalizedString(@"enter_password_alert", nil)];
     }
     else if([stateTxt.text length]==0)
     {
         [self.view makeToast:NSLocalizedString(@"enter_confirm_password_alert", nil)];
     }
     else if([zipTxt.text length]==0)
     {
         [self.view makeToast:NSLocalizedString(@"enter_confirm_password_alert", nil)];
     }*/
     else
     {
         if([[AFNetworkReachabilityManager sharedManager] isReachable])
         {
             NSDictionary *params = @{@"method" : @"EditProfile",
                                      @"userid" : self.userDict[@"userid"],
                                      @"firstname" : firstnameTxt.text,
                                      @"lastname" : lastnameTxt.text,
                                      @"street_address" : streetAddressTxt.text,
                                      @"city" : cityTxt.text,
                                      @"state" : stateTxt.text,
                                      @"zip" : zipTxt.text};
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
                  if(isProfileImageSelected)
                  {
                      [formData appendPartWithFileData:UIImageJPEGRepresentation(tempImage.image, 1.0) name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                  }
              } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  LKLog(@"JSON: %@", responseObject);
                  
                  [loading hide:YES];
                  
                  if([responseObject[@"success"] integerValue] == 1)
                  {
                      
                      [LKKeyChain setObject:responseObject forKey:@"userObject"];
                      
                      [self.navigationController.view.window makeToast:NSLocalizedString(@"profile_update_successfully_done_alert", nil)];
                      [self.navigationController popViewControllerAnimated:YES];
                  }
                  else
                  {
                      [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"profile_update_failed_alert", nil)];
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
    if(textField==firstnameTxt)
    {
        [lastnameTxt becomeFirstResponder];
    }
    else if(textField==lastnameTxt)
    {
        [streetAddressTxt becomeFirstResponder];
    }
    else if(textField==streetAddressTxt)
    {
        [cityTxt becomeFirstResponder];
    }
    else if(textField==cityTxt)
    {
        [stateTxt becomeFirstResponder];
    }
    else if(textField==stateTxt)
    {
        [zipTxt becomeFirstResponder];
    }
    else if(textField==zipTxt)
    {
        [zipTxt resignFirstResponder];
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
