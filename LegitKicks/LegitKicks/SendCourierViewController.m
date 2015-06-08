//
//  SendCourierViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 09/02/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "SendCourierViewController.h"

@interface SendCourierViewController ()
{
    NSDictionary *userDetails;
    UITextField *lastTextfield;
}

@end

@implementation SendCourierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Send Courier";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    
    [scroll layoutIfNeeded];
    
    [self setBackButtonToNavigationBar];
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    courierNameTxt.leftView = paddingView;
    courierNameTxt.leftViewMode = UITextFieldViewModeAlways;
    courierNameTxt.rightView = paddingView;
    courierNameTxt.rightViewMode = UITextFieldViewModeAlways;
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    courierNumberTxt.leftView = paddingView;
    courierNumberTxt.leftViewMode = UITextFieldViewModeAlways;
    courierNumberTxt.rightView = paddingView;
    courierNumberTxt.rightViewMode = UITextFieldViewModeAlways;
    
    if(_sendCourierForTrade)
    {
        [self getUserAddressDetailFromWebserver];
    }
    else
    {
        [self getUserSellAddressDetailFromWebserver];
    }
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

-(void)getUserAddressDetailFromWebserver
{
    NSDictionary *params = @{@"method" : @"getaddressdetailforuser",
                             @"userid" : [LKKeyChain objectForKey:@"userid"],
                             @"tradeid" : _tradeDict[@"tradeid"]};
    LKLog(@"params = %@",params);
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loading];
    [loading show:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.operationQueue cancelAllOperations];
    
    [manager POST:GET_ADDRESS_FOR_USER_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        LKLog(@"JSON: %@", responseObject);
        
        [loading hide:YES];
        
        if([responseObject[@"success"] integerValue] == 1)
        {
            userDetails = [[NSDictionary alloc] initWithDictionary:responseObject];
            [self displayUserInformation];
        }
        else
        {
            [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"failed to get shiping address information, please try again."];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [loading hide:YES];
        
        LKLog(@"failed response string = %@",operation.responseString);
        [Utility displayHttpFailureError:error];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


-(void)getUserSellAddressDetailFromWebserver
{
    NSDictionary *params = @{@"method" : @"getselladdressdetailforuser",
                             @"sellid" : _saleDict[@"sellid"]};
    LKLog(@"params = %@",params);
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loading];
    [loading show:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.operationQueue cancelAllOperations];
    
    [manager POST:GET_SELL_ADDRESS_FOR_USER_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        LKLog(@"JSON: %@", responseObject);
        
        [loading hide:YES];
        
        if([responseObject[@"success"] integerValue] == 1)
        {
            userDetails = [[NSDictionary alloc] initWithDictionary:responseObject];
            [self displayUserInformation];
        }
        else
        {
            [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"failed to get shiping address information, please try again."];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [loading hide:YES];
        
        LKLog(@"failed response string = %@",operation.responseString);
        [Utility displayHttpFailureError:error];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

-(void)displayUserInformation
{
    usernameValueLbl.text = [NSString stringWithFormat:@"%@ %@", userDetails[@"fname"], userDetails[@"lname"]];
    addressValueLbl.text = userDetails[@"streetaddress"];
    cityValueLbl.text = userDetails[@"city"];
    stateValueLbl.text = userDetails[@"state"];
    zipValueLbl.text = userDetails[@"zip"];
    
    [scroll layoutIfNeeded];
}

-(IBAction)sendCourierBtnClicked:(id)sender
{
    [lastTextfield resignFirstResponder];
    
    if([courierNameTxt.text length]==0)
    {
        [self.view makeToast:@"Please enter courier name."];
    }
    else if([courierNumberTxt.text length]==0)
    {
        [self.view makeToast:@"Please enter courier number."];
    }
    else
    {
        if(_sendCourierForTrade)
        {
            [self sendCourierDetailForTradeRequestToWebserver];
        }
        else
        {
            [self sendCourierDetailForSaleRequestToWebserver];
        }
    }
}


-(void)sendCourierDetailForTradeRequestToWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"sendcourierdetail",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"tradeid" : _tradeDict[@"tradeid"],
                                 @"couriername" : courierNameTxt.text,
                                 @"courierNo" : courierNumberTxt.text};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:SEND_COURIER_DETAIL_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [self.navigationController.view.window makeToast:@"Courier details sent successfully."];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to send courier details, please try again."];
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


-(void)sendCourierDetailForSaleRequestToWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"sendcourierdetail",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"sellid" : _saleDict[@"sellid"],
                                 @"couriername" : courierNameTxt.text,
                                 @"courierNo" : courierNumberTxt.text};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:SEND_COURIER_DETAILFOR_SALE_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [self.navigationController.view.window makeToast:@"Courier details sent successfully."];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to send courier details, please try again."];
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
    if(textField==courierNameTxt)
    {
        [courierNumberTxt becomeFirstResponder];
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
