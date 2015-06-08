//
//  RequestForSaleViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 16/01/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "RequestForSaleViewController.h"
#import "BraintreeTransactionService.h"
#import "AskQuestionViewController.h"
#import "Braintree.h"

@interface RequestForSaleViewController () <BTPaymentMethodCreationDelegate, BTDropInViewControllerDelegate>
{
    UIToolbar *keyboardToolbar;
    BOOL isOfferMaking;
}
@property (nonatomic, strong) BTPaymentProvider *paymentProvider;
@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, copy) NSString *nonce;

@end

@implementation RequestForSaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Request For Sale";
    
    [self setBackButtonToNavigationBar];
    
    
    keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,44)];
    keyboardToolbar.barStyle = UIBarStyleBlack;
    keyboardToolbar.tintColor = [UIColor whiteColor];
    //keyboardToolbar.barTintColor = [UIColor colorWithRed:47.0/255.0 green:190.0/255.0 blue:182.0/255.0 alpha:1.0];
    //keyboardToolbar.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:190.0/255.0 blue:182.0/255.0 alpha:1.0];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(keyboardToolbarDoneClicked:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *items = [[NSArray alloc] initWithObjects:flex, barButtonItem, nil];
    [keyboardToolbar setItems:items];
    
    offerTxt.inputAccessoryView = keyboardToolbar;
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    offerTxt.leftView = paddingView;
    offerTxt.leftViewMode = UITextFieldViewModeAlways;
    offerTxt.rightView = paddingView;
    offerTxt.rightViewMode = UITextFieldViewModeAlways;
    
    
    offerTxt.layer.cornerRadius = 4.0;
    purchaseNowBtn.layer.cornerRadius = 4.0;
    makeOfferBtn.layer.cornerRadius = 4.0;
    askQuestionBtn.layer.cornerRadius = 4.0;
    
    offerTxt.layer.borderColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
    offerTxt.layer.borderWidth = 1.0;
    
    
    self.braintree = nil;
    self.nonce = nil;
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

-(IBAction)keyboardToolbarDoneClicked:(id)sender
{
    [offerTxt resignFirstResponder];
}


-(IBAction)purchaseNowBtnClicked:(id)sender
{
    isOfferMaking = NO;
    
    [self openPaymentMethods];
}

-(void)openPaymentMethods
{
    [offerTxt resignFirstResponder];
    
    NSDictionary *params = @{@"method" : @"getclienttoken",
                             @"userid" : [LKKeyChain objectForKey:@"userid"]};
    LKLog(@"params = %@",params);
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    loading.removeFromSuperViewOnHide = YES;
    [self.navigationController.view addSubview:loading];
    [loading show:YES];
    
    [[BraintreeTransactionService sharedService] createCustomerAndFetchClientTokenWithParameters:@{@"data" : jsonString} withCompletion:^(NSString *clientToken, NSError *error, BOOL success){
        
        [loading hide:YES];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (error)
        {
            NSLog(@"error = %@",error);
            
            [Utility displayHttpFailureError:error];
            
            return;
        }
        else if(!success)
        {
            [Utility displayAlertWithTitle:@"Error" andMessage:@"Unable to process for payment, please try again."];
        }
        
        //Braintree *braintree = [Braintree braintreeWithClientToken:clientToken];
        
        
        // Create and retain a `Braintree` instance with the client token
        self.braintree = [Braintree braintreeWithClientToken:clientToken];
        
        
        /*self.paymentProvider = [[BTPaymentProvider alloc] initWithClient:self.braintree.client];
         self.paymentProvider.delegate = self;
         
         [self.paymentProvider createPaymentMethod:BTPaymentProviderTypePayPal];*/
        
        
        //btn = [braintree paymentButtonWithDelegate:self];
        //btn.delegate = self;
        
        /*NSOrderedSet *types = [NSOrderedSet orderedSetWithObjects:@(BTPaymentProviderTypePayPal), @(BTPaymentProviderTypeVenmo), nil];
         // Instantiate BTPaymentButton
         //BTPaymentButton *button = [braintree paymentButtonWithDelegate:self];
         BTPaymentButton *button = [braintree paymentButtonWithDelegate:self paymentProviderTypes:types];
         [button setFrame:CGRectMake(0,0,320,120)];
         [self.view addSubview:button];
         
         return;*/
        
        
        
        // Create a BTDropInViewController
        BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
        // This is where you might want to customize your Drop in. (See below.)
        dropInViewController.theme = [BTUI braintreeTheme];
        dropInViewController.summaryTitle = self.sneakerDict[@"sneakername"];
        
        if(isOfferMaking)
        {
            dropInViewController.displayAmount = [NSString stringWithFormat:@"%@", offerTxt.text];
        }
        else
        {
            dropInViewController.displayAmount = [NSString stringWithFormat:@"%@", self.sneakerDict[@"value"]];
        }
        dropInViewController.summaryDescription = [NSString stringWithFormat:@"Brand: %@\nCondition: %@\nSize: %@", self.sneakerDict[@"brandname"], self.sneakerDict[@"condition"], self.sneakerDict[@"size"]];
        
        dropInViewController.callToActionText = @"Pay";
        
        
        // The way you present your BTDropInViewController instance is up to you.
        // In this example, we wrap it in a new, modally presented navigation controller:
        dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                              target:self
                                                                                                              action:@selector(userDidCancelPayment)];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
        
        
        
        /*[[BraintreeDemoTransactionService sharedService] fetchMerchantConfigWithCompletion:^(NSString *merchantId, NSError *error){
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         if (error) {
         NSLog(@"error = %@",error);
         return;
         }
         
         [self resetWithBraintree:braintree merchantId:merchantId];
         }];*/
    }];
}


- (void)userDidCancelPayment
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod
{
    self.nonce = paymentMethod.nonce;
    
    if(isOfferMaking)
    {
        [self makeOfferRequestToWebserver];
    }
    else
    {
        [self addSaleRequestWithWebserver];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)makeOfferBtnClicked:(id)sender
{
    isOfferMaking = YES;
    
    if([offerTxt.text length] == 0)
    {
        [Utility displayAlertWithTitle:@"Error" andMessage:@"Please enter offer amount."];
    }
    else if([offerTxt.text floatValue] == 0.0f)
    {
        [Utility displayAlertWithTitle:@"Error" andMessage:@"Offer amount should be more than $0."];
    }
    else
    {
        //[self openPaymentMethods];
        [self makeOfferRequestToWebserver];
    }
}

-(IBAction)askQuestionBtnClicked:(id)sender
{
    
}


-(void)addSaleRequestWithWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *userDict = [LKKeyChain objectForKey:@"userObject"];
        
        NSDictionary *params = @{@"method" : @"addsellinfo",
                                 @"zip" : userDict[@"zip"],
                                 @"buyerid" : [LKKeyChain objectForKey:@"userid"],
                                 @"sellerid" : [NSString stringWithFormat:@"%@", self.sneakerDict[@"userid"]],
                                 @"sellersneakerid" : [NSString stringWithFormat:@"%@", self.sneakerDict[@"sneakerid"]],
                                 @"buyernonce" : self.nonce};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:ADD_SALE_INFO_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [self.navigationController.view.window makeToast:@"Your sale request sent successfully."];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to send sale request, please try again."];
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


-(void)makeOfferRequestToWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *userDict = [LKKeyChain objectForKey:@"userObject"];
        
        NSDictionary *params = @{@"method" : @"makeofferforsell",
                                 @"zip" : userDict[@"zip"],
                                 @"buyerid" : [LKKeyChain objectForKey:@"userid"],
                                 @"sellerid" : [NSString stringWithFormat:@"%@", self.sneakerDict[@"userid"]],
                                 @"sellersneakerid" : [NSString stringWithFormat:@"%@", self.sneakerDict[@"sneakerid"]],
                                 /*@"buyernonce" : self.nonce,*/
                                 @"offer_amt" : offerTxt.text};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:MAKE_SELL_OFFER_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [self.navigationController.view.window makeToast:@"Your offer request sent successfully."];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to send offer request, please try again."];
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


- (void)paymentMethodCreator:(id)sender requestsPresentationOfViewController:(UIViewController *)viewController
{
    LKLog(@"requestsPresentationOfViewController = %@", sender);
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentMethodCreator:(id)sender requestsDismissalOfViewController:(UIViewController *)viewController
{
    LKLog(@"requestsDismissalOfViewController = %@", sender);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentMethodCreatorWillPerformAppSwitch:(id)sender
{
    LKLog(@"paymentMethodCreatorWillPerformAppSwitch = %@", sender);
}

- (void)paymentMethodCreatorWillProcess:(id)sender
{
    LKLog(@"paymentMethodCreatorWillProcess = %@", sender);
}

- (void)paymentMethodCreatorDidCancel:(id)sender
{
    LKLog(@"paymentMethodCreatorDidCancel = %@", sender);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentMethodCreator:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod
{
    self.nonce = paymentMethod.nonce;
    
    LKLog(@"didCreatePaymentMethod = %@ ----- %@", sender, paymentMethod);
    
    [Utility displayAlertWithTitle:@"PayPal Payment" andMessage:[NSString stringWithFormat:@"Your PayPal payment method created successfully with nonce : %@",self.nonce]];
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error
{
    LKLog(@"didFailWithError = %@ ---- %@", sender, error);
    
    [Utility displayAlertWithTitle:@"PayPal Payment Error" andMessage:[NSString stringWithFormat:@"Failed to create PayPal payment method, please try again."]];
}


#pragma mark - TextField delegate method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ReqForSellVcToAskQuestionVc"])
    {
        AskQuestionViewController *askQuestionVc = segue.destinationViewController;
        askQuestionVc.sneakerDict = [[NSDictionary alloc] initWithDictionary:_sneakerDict];
    }
}


@end
