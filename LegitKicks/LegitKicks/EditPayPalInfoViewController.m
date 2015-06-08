//
//  EditPayPalInfoViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 20/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "EditPayPalInfoViewController.h"

@interface EditPayPalInfoViewController ()

@end

@implementation EditPayPalInfoViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"paypal", nil);
    descLbl.text = NSLocalizedString(@"forgot_pass_desc_text", nil);
    paypalIdTxt.placeholder = NSLocalizedString(@"paypal_id", nil);
    confirmPaypalIdTxt.placeholder = NSLocalizedString(@"confirm_paypal_id", nil);
    [updateBtn setTitle:NSLocalizedString(@"update", nil) forState:UIControlStateNormal];
    
    self.navigationController.navigationBarHidden = NO;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setBackButtonToNavigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    paypalIdTxt.leftView = paddingView;
    paypalIdTxt.leftViewMode = UITextFieldViewModeAlways;
    paypalIdTxt.rightView = paddingView;
    paypalIdTxt.rightViewMode = UITextFieldViewModeAlways;
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    confirmPaypalIdTxt.leftView = paddingView;
    confirmPaypalIdTxt.leftViewMode = UITextFieldViewModeAlways;
    confirmPaypalIdTxt.rightView = paddingView;
    confirmPaypalIdTxt.rightViewMode = UITextFieldViewModeAlways;
    
    paypalIdTxt.layer.cornerRadius = 4.0;
    confirmPaypalIdTxt.layer.cornerRadius = 4.0;
    updateBtn.layer.cornerRadius = 4.0;
    
    paypalIdTxt.layer.borderColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
    paypalIdTxt.layer.borderWidth = 1.0;
    
    confirmPaypalIdTxt.layer.borderColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
    confirmPaypalIdTxt.layer.borderWidth = 1.0;
    
    [paypalIdTxt becomeFirstResponder];
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

- (BOOL)validateEmail:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

-(IBAction)updateBtnClicked:(id)sender
{
    [paypalIdTxt resignFirstResponder];
    [confirmPaypalIdTxt resignFirstResponder];
    
    //[Utility displayAlertWithTitle:@"Update PaPal Info" andMessage:@"Under Construction!!"];
    
    return;
    
    
    if([paypalIdTxt.text length]==0)
    {
        //[Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"enter_email_alert", nil)];
        [self.view makeToast:NSLocalizedString(@"enter_paypal_id_alert", nil)];
    }
    else if(![self validateEmail:paypalIdTxt.text])
    {
        //[Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"enter_valid_email_alert", nil)];
        [self.view makeToast:NSLocalizedString(@"enter_valid_paypal_id_alert", nil)];
    }
    else if([confirmPaypalIdTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_confirm_paypal_id_alert", nil)];
    }
    else if([paypalIdTxt.text length]!=[confirmPaypalIdTxt.text length] || ![paypalIdTxt.text isEqualToString:confirmPaypalIdTxt.text])
    {
        [self.view makeToast:NSLocalizedString(@"confirm_paypal_id_does_not_match_alert", nil)];
    }
    else
    {
        /*if([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSDictionary *params = @{@"method" : @"Forgotpassword",
                                     @"email" : emailTxt.text};
            LKLog(@"params = %@",params);
            
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
            
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            
            MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view.window];
            [self.view.window addSubview:loading];
            [loading show:YES];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager.operationQueue cancelAllOperations];
            
            [manager POST:BASE_API parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                LKLog(@"JSON: %@", responseObject);
                
                [loading hide:YES];
                
                if([responseObject[@"success"] integerValue] == 1)
                {
                    [Utility displayAlertWithTitle:NSLocalizedString(@"legit_kicks", nil) andMessage:NSLocalizedString(@"paypal_update_successfully_done_alert", nil)];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"paypal_update_failed_alert", nil)];
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
        }*/
    }
}


#pragma mark Keyboard Notifications

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



#pragma mark TextField delegate method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==paypalIdTxt)
    {
        [confirmPaypalIdTxt becomeFirstResponder];
    }
    else if(textField==confirmPaypalIdTxt)
    {
        [confirmPaypalIdTxt resignFirstResponder];
        [self updateBtnClicked:nil];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
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
