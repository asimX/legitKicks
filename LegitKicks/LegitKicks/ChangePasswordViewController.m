//
//  ResetPasswordViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 15/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()
{
    UITextField *lastTextfield;
}

@end

@implementation ChangePasswordViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"change_password", nil);
    oldPasswordTxt.placeholder = NSLocalizedString(@"old_password", nil);
    newPasswordTxt.placeholder = NSLocalizedString(@"new_password", nil);
    confirmPasswordTxt.placeholder = NSLocalizedString(@"confirm_password", nil);
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
    oldPasswordTxt.leftView = paddingView;
    oldPasswordTxt.leftViewMode = UITextFieldViewModeAlways;
    oldPasswordTxt.rightView = paddingView;
    oldPasswordTxt.rightViewMode = UITextFieldViewModeAlways;
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    newPasswordTxt.leftView = paddingView;
    newPasswordTxt.leftViewMode = UITextFieldViewModeAlways;
    newPasswordTxt.rightView = paddingView;
    newPasswordTxt.rightViewMode = UITextFieldViewModeAlways;
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    confirmPasswordTxt.leftView = paddingView;
    confirmPasswordTxt.leftViewMode = UITextFieldViewModeAlways;
    confirmPasswordTxt.rightView = paddingView;
    confirmPasswordTxt.rightViewMode = UITextFieldViewModeAlways;
    
    oldPasswordTxt.layer.cornerRadius = 4.0;
    newPasswordTxt.layer.cornerRadius = 4.0;
    confirmPasswordTxt.layer.cornerRadius = 4.0;
    submitBtn.layer.cornerRadius = 4.0;
    
    oldPasswordTxt.layer.borderColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
    oldPasswordTxt.layer.borderWidth = 1.0;
    
    newPasswordTxt.layer.borderColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
    newPasswordTxt.layer.borderWidth = 1.0;
    
    confirmPasswordTxt.layer.borderColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
    confirmPasswordTxt.layer.borderWidth = 1.0;
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
    [lastTextfield resignFirstResponder];
    
    if([oldPasswordTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_old_password_alert", nil)];
    }
    else if([newPasswordTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_new_password_alert", nil)];
    }
    else if([confirmPasswordTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_confirm_password_alert", nil)];
    }
    else if([newPasswordTxt.text length]!=[confirmPasswordTxt.text length] || ![newPasswordTxt.text isEqualToString:confirmPasswordTxt.text])
    {
        [self.view makeToast:NSLocalizedString(@"password_not_confirmed_alert", nil)];
    }
    else
    {
        if([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSDictionary *params = @{@"method" : @"Resetpassword",
                                     @"userid" : [LKKeyChain objectForKey:@"userid"],
                                     @"Oldpassword" : oldPasswordTxt.text,
                                     @"password" : newPasswordTxt.text};
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
                    [Utility displayAlertWithTitle:NSLocalizedString(@"legit_kicks", nil) andMessage:NSLocalizedString(@"password_changed_successfully_alert", nil)];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"failed_to_change_password_alert", nil)];
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
    if(textField==oldPasswordTxt)
    {
        [newPasswordTxt becomeFirstResponder];
    }
    else if(textField==newPasswordTxt)
    {
        [confirmPasswordTxt becomeFirstResponder];
    }
    else if(textField==confirmPasswordTxt)
    {
        [confirmPasswordTxt resignFirstResponder];
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
    lastTextfield = textField;
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
