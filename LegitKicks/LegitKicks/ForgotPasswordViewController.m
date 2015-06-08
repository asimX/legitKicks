//
//  ForgotPasswordViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 15/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"forgot_password", nil);
    descLbl.text = NSLocalizedString(@"forgot_pass_desc_text", nil);
    emailTxt.placeholder = NSLocalizedString(@"email_address", nil);
    [submitBtn setTitle:NSLocalizedString(@"submit", nil) forState:UIControlStateNormal];
    
    self.navigationController.navigationBarHidden = NO;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setBackButtonToNavigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    emailTxt.leftView = paddingView;
    emailTxt.leftViewMode = UITextFieldViewModeAlways;
    emailTxt.rightView = paddingView;
    emailTxt.rightViewMode = UITextFieldViewModeAlways;
    
    emailTxt.layer.cornerRadius = 4.0;
    submitBtn.layer.cornerRadius = 4.0;
    
    emailTxt.layer.borderColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
    emailTxt.layer.borderWidth = 1.0;
    
    [emailTxt becomeFirstResponder];
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

-(IBAction)submitBtnClicked:(id)sender
{
    [emailTxt resignFirstResponder];
    
    if([emailTxt.text length]==0)
    {
        //[Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"enter_email_alert", nil)];
        [self.view makeToast:NSLocalizedString(@"enter_email_address_alert", nil)];
    }
    else if(![self validateEmail:emailTxt.text])
    {
        //[Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"enter_valid_email_alert", nil)];
        [self.view makeToast:NSLocalizedString(@"enter_valid_email_address_alert", nil)];
    }
    else
    {
        if([[AFNetworkReachabilityManager sharedManager] isReachable])
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
                    if([responseObject[@"status"] integerValue] == 2)
                    {
                        [Utility displayAlertWithTitle:NSLocalizedString(@"legit_kicks", nil) andMessage:NSLocalizedString(@"reset_password_link_sent", nil)];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"failed_to_submit_forgot_password_request_alert", nil)];
                    }
                }
                else
                {
                    if([responseObject[@"status"] integerValue] == 0)
                    {
                        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"user_not_available_with_given_email_alert", nil)];
                    }
                    else
                    {
                        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"failed_to_submit_forgot_password_request_alert", nil)];
                    }
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
    if(textField==emailTxt)
    {
        [textField becomeFirstResponder];
        [self submitBtnClicked:nil];
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
