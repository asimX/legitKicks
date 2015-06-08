//
//  TradeRequestDetailViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 08/02/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "TradeRequestDetailViewController.h"
#import "MFSideMenu.h"
//#import "UIImageView+AFNetworking.h"
#import "SneakerDetailViewController.h"
#import "SendCourierViewController.h"

#import "BraintreeTransactionService.h"
#import "Braintree.h"

#import "RatingViewController.h"
#import "UIImageView+WebCache.h"

@interface TradeRequestDetailViewController () <EDStarRatingProtocol, BTPaymentMethodCreationDelegate, BTDropInViewControllerDelegate>
{
    NSDictionary *tradeRequestDetailDict;
    NSMutableArray *sellerSneakerArray;
    NSMutableArray *buyerSneakerArray;
    
    BOOL isReceivedBtnShown;
    
    UIWindow *tempWindow;
    UIToolbar *keyboardToolbar;
}

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) BTPaymentProvider *paymentProvider;
@property (nonatomic, copy) NSString *nonce;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation TradeRequestDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    self.title = @"Request Details";
    reviewTxt.text = @"Write review...";
    reviewTxt.textColor = [UIColor lightGrayColor];
    
    [self setBackButtonToNavigationBar];
    
    self.offscreenCells = [NSMutableDictionary dictionary];
    
    
    keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,44)];
    keyboardToolbar.barStyle = UIBarStyleBlack;
    keyboardToolbar.tintColor = [UIColor whiteColor];
    //keyboardToolbar.barTintColor = [UIColor colorWithRed:253.0/255.0 green:202.0/255.0 blue:15.0/255.0 alpha:1.0];
    //keyboardToolbar.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:202.0/255.0 blue:15.0/255.0 alpha:1.0];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(keyboardToolbarDoneClicked:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *items = [[NSArray alloc] initWithObjects:flex, barButtonItem, nil];
    [keyboardToolbar setItems:items];
    reviewTxt.inputAccessoryView = keyboardToolbar;
    
    
    
    [self.view layoutIfNeeded];
    
    sendBtn.hidden = YES;
    acceptTradeBtn.hidden = YES;
    rejectTradeBtn.hidden = YES;
    actionView.hidden = YES;
    
    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;
    
    
    ratingView.layer.cornerRadius = 5.0;
    ratingView.layer.masksToBounds = YES;
    
    
    sneakerRatingView.starImage = [UIImage imageNamed:@"unrated_sneaker_ic"];
    sneakerRatingView.starHighlightedImage = [UIImage imageNamed:@"rated_sneaker_ic"];
    sneakerRatingView.maxRating = 5.0;
    sneakerRatingView.delegate = self;
    sneakerRatingView.horizontalMargin = 0;
    sneakerRatingView.editable=YES;
    sneakerRatingView.rating= 5.0;
    sneakerRatingView.displayMode=EDStarRatingDisplayFull;
    
    
    
    [self loadTradeRequestDetailFromWebserver];
    
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
    [reviewTxt resignFirstResponder];
}


-(void)loadBraintreePaymentGateway
{
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
        
        // Create and retain a `Braintree` instance with the client token
        self.braintree = [Braintree braintreeWithClientToken:clientToken];
        
        
        /*self.paymentProvider = [[BTPaymentProvider alloc] initWithClient:self.braintree.client];
        self.paymentProvider.delegate = self;
        
        [self.paymentProvider createPaymentMethod:BTPaymentProviderTypePayPal];*/
        
        // Create a BTDropInViewController
        BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
        // This is where you might want to customize your Drop in. (See below.)
        dropInViewController.theme = [BTUI braintreeTheme];
        dropInViewController.summaryTitle = @"Trade Fees";
        dropInViewController.summaryDescription = @"$5 will be collected for trade fees.";
        dropInViewController.displayAmount = @"$5";
        dropInViewController.callToActionText = @"Pay";
        
        
        // The way you present your BTDropInViewController instance is up to you.
        // In this example, we wrap it in a new, modally presented navigation controller:
        dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                              target:self
                                                                                                              action:@selector(userDidCancelPayment)];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
        
    }];
}

- (void)userDidCancelPayment
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod
{
    self.nonce = paymentMethod.nonce;
    
    [self callAcceptRejectWebserviceWithAccept:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Load profile data

-(void)loadTradeRequestDetailFromWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"gettraderequestdetail",
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
        
        [manager POST:GET_TRADE_REQUEST_DETAIL_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                tradeRequestDetailDict = [[NSDictionary alloc] initWithDictionary:responseObject];
                
                [self displaySneakerDetailInformation];
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"unable_load_data_alert", nil)];
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


-(void)displaySneakerDetailInformation
{
    
    buyerSneakerArray = [[NSMutableArray alloc] initWithArray:tradeRequestDetailDict[@"buyersneakerdetail"]];
    sellerSneakerArray = [[NSMutableArray alloc] initWithArray:tradeRequestDetailDict[@"sellersneakerdetail"]];
    [sneakerTable reloadData];
    
    isReceivedBtnShown = NO;
    
    switch ([_tradeDict[@"status"] integerValue])
    {
        case 1:
        {
            if([[NSString stringWithFormat:@"%@", _tradeDict[@"buyerid"]] isEqualToString:[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]]])
            {
                acceptTradeBtn.hidden = YES;
                rejectTradeBtn.hidden = YES;
                sendBtn.hidden = YES;
                actionView.hidden = YES;
                actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;
            }
            else
            {
                acceptTradeBtn.hidden = NO;
                rejectTradeBtn.hidden = NO;
                sendBtn.hidden = YES;
                actionView.hidden = NO;
                actionViewBottomSpaceConstraint.constant = 0;
            }
            
            break;
        }
        case 2:
        {
            
            if([[NSString stringWithFormat:@"%@", _tradeDict[@"buyerid"]] isEqualToString:[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]]])
            {
                if(([_tradeDict[@"sellerresponseptime"] length] > 0 && ![_tradeDict[@"sellerresponseptime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([_tradeDict[@"buyersendtime"] length] == 0 || [_tradeDict[@"buyersendtime"] isEqualToString:@"0000-00-00 00:00:00"]))
                {
                    acceptTradeBtn.hidden = YES;
                    rejectTradeBtn.hidden = YES;
                    sendBtn.hidden = NO;
                    actionView.hidden = NO;
                    actionViewBottomSpaceConstraint.constant = 0;
                    
                    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
                }
                else if(([_tradeDict[@"buyersendtime"] length] > 0 && ![_tradeDict[@"buyersendtime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([_tradeDict[@"sellersendtime"] length] > 0 && ![_tradeDict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([_tradeDict[@"buyerreceivedtime"] length] == 0 || [_tradeDict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"]))
                {
                    acceptTradeBtn.hidden = YES;
                    rejectTradeBtn.hidden = YES;
                    sendBtn.hidden = NO;
                    actionView.hidden = NO;
                    actionViewBottomSpaceConstraint.constant = 0;
                    
                    [sendBtn setTitle:@"Received" forState:UIControlStateNormal];
                    
                    isReceivedBtnShown = YES;
                }
                else if([_tradeDict[@"buyerreceivedtime"] length] > 0 && ![_tradeDict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
                {
                    acceptTradeBtn.hidden = YES;
                    rejectTradeBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;
                }
                else
                {
                    acceptTradeBtn.hidden = YES;
                    rejectTradeBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;
                }
                
            }
            else
            {
                
                if(([_tradeDict[@"sellerresponseptime"] length] > 0 && ![_tradeDict[@"sellerresponseptime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([_tradeDict[@"sellersendtime"] length] == 0 || [_tradeDict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"]))
                {
                    acceptTradeBtn.hidden = YES;
                    rejectTradeBtn.hidden = YES;
                    sendBtn.hidden = NO;
                    actionView.hidden = NO;
                    actionViewBottomSpaceConstraint.constant = 0;
                    
                    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
                }
                else if(([_tradeDict[@"sellersendtime"] length] > 0 && ![_tradeDict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([_tradeDict[@"buyersendtime"] length] > 0 && ![_tradeDict[@"buyersendtime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([_tradeDict[@"sellerreceivedtime"] length] == 0 || [_tradeDict[@"sellerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"]))
                {
                    acceptTradeBtn.hidden = YES;
                    rejectTradeBtn.hidden = YES;
                    sendBtn.hidden = NO;
                    actionView.hidden = NO;
                    actionViewBottomSpaceConstraint.constant = 0;
                    
                    [sendBtn setTitle:@"Received" forState:UIControlStateNormal];
                    
                    isReceivedBtnShown = YES;
                }
                else if([_tradeDict[@"sellerreceivedtime"] length] > 0 && ![_tradeDict[@"sellerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
                {
                    acceptTradeBtn.hidden = YES;
                    rejectTradeBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;
                }
                else
                {
                    acceptTradeBtn.hidden = YES;
                    rejectTradeBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;
                }
            }
            
            break;
        }
        case 3:
        {
            acceptTradeBtn.hidden = YES;
            rejectTradeBtn.hidden = YES;
            sendBtn.hidden = YES;
            actionView.hidden = YES;
            actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;
            
            break;
        }
        case 4:
        {
            acceptTradeBtn.hidden = YES;
            rejectTradeBtn.hidden = YES;
            sendBtn.hidden = YES;
            actionView.hidden = YES;
            actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;
            
            break;
        }
            
        default:
        {
            acceptTradeBtn.hidden = YES;
            rejectTradeBtn.hidden = YES;
            sendBtn.hidden = YES;
            actionView.hidden = YES;
            actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;
            
            break;
        }
    }
}


-(IBAction)acceptTradeBtnClicked:(id)sender
{
    [self loadBraintreePaymentGateway];
}

-(IBAction)rejectTradeBtnClicked:(id)sender
{
    [self callAcceptRejectWebserviceWithAccept:NO];
}


-(void)callAcceptRejectWebserviceWithAccept:(BOOL)accept
{
    //NSDictionary *userDict = [LKKeyChain objectForKey:@"userObject"];
    
    NSDictionary *params = @{@"method" : @"acceptrejecttraderequest",
                             @"userid" : [LKKeyChain objectForKey:@"userid"],
                             @"tradeid" : _tradeDict[@"tradeid"],
                             @"flag" : accept?@"1":@"0",
                             @"sellernonce" : self.nonce};
    LKLog(@"params = %@",params);
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loading];
    [loading show:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.operationQueue cancelAllOperations];
    
    [manager POST:ACCEPT_REJECT_TRADE_REQUEST_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        LKLog(@"JSON: %@", responseObject);
        
        [loading hide:YES];
        
        if([responseObject[@"success"] integerValue] == 1)
        {
            self.tradeDict = [[NSDictionary alloc] initWithDictionary:responseObject];
            [self displaySneakerDetailInformation];
        }
        else
        {
            if(accept)
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to accept trade request, please try again."];
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to reject trade request, please try again."];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [loading hide:YES];
        
        LKLog(@"failed response string = %@",operation.responseString);
        [Utility displayHttpFailureError:error];
    }];
}


-(IBAction)sendBtnClicked:(id)sender
{
    if(isReceivedBtnShown)
    {
        NSDictionary *params = @{@"method" : @"sneajerreceivefortrade",
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
        
        [manager POST:SNEAKER_RECEIVED_FOR_TRADE_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                self.tradeDict = [[NSDictionary alloc] initWithDictionary:responseObject];
                [self displaySneakerDetailInformation];
                
                //[self displayPopupview:ratingPopupView];
                
                RatingViewController *ratingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RatingVC"];
                ratingVC.forTrade = YES;
                ratingVC.sellTradeInfoDict = _tradeDict;
                [self.navigationController pushViewController:ratingVC animated:YES];
                
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to submit receving status, please try again."];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [loading hide:YES];
            
            LKLog(@"failed response string = %@",operation.responseString);
            [Utility displayHttpFailureError:error];
        }];
    }
    else
    {
        [self performSegueWithIdentifier:@"TradeRequestDetailVcToSendCourierVc" sender:nil];
    }
}


-(void)displayPopupview:(UIView *)tempView
{
    tempView.frame = [[UIScreen mainScreen] bounds];
    
    [tempView layoutIfNeeded];
    
    tempWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    tempWindow.windowLevel = UIWindowLevelAlert;
    tempWindow.opaque = NO;
    
    [tempWindow addSubview:tempView];
    
    // window has to be un-hidden on the main thread
    [tempWindow makeKeyAndVisible];
    
    
    [tempWindow addConstraint:[NSLayoutConstraint constraintWithItem:tempView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:tempWindow
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    [tempWindow addConstraint:[NSLayoutConstraint constraintWithItem:tempView
                                                           attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:tempWindow
                                                           attribute:NSLayoutAttributeLeading
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    [tempWindow addConstraint:[NSLayoutConstraint constraintWithItem:tempView
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:tempWindow
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    [tempWindow addConstraint:[NSLayoutConstraint constraintWithItem:tempView
                                                           attribute:NSLayoutAttributeTrailing
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:tempWindow
                                                           attribute:NSLayoutAttributeTrailing
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    
    [tempWindow layoutIfNeeded];
}


-(IBAction)ratingPopupDoneBtnClicked:(id)sender
{
    if([reviewTxt.text length]==0)
    {
        [tempWindow makeToast:NSLocalizedString(@"enter_comment_alert", nil)];
    }
    else
    {
        
        NSString *toUserIdStr = _tradeDict[@"buyerid"];
        
        if([[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]] isEqualToString:[NSString stringWithFormat:@"%@", _tradeDict[@"buyerid"]]])
        {
            toUserIdStr = _tradeDict[@"sellerid"];
        }
        
        NSDictionary *params = @{@"method" : @"addratereview",
                                 @"by_userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"trade_sell_id" : _tradeDict[@"tradeid"],
                                 @"to_userid" : toUserIdStr,
                                 @"rate" : @(sneakerRatingView.rating),
                                 @"review" : reviewTxt.text,
                                @"status" : @"0"};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:tempWindow];
        loading.removeFromSuperViewOnHide = YES;
        [tempWindow addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:ADD_RATE_REVIEW_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [ratingPopupView removeFromSuperview];
                tempWindow = nil;
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to submit review, please try again."];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [loading hide:YES];
            
            LKLog(@"failed response string = %@",operation.responseString);
            [Utility displayHttpFailureError:error];
        }];
    }
}



-(NSAttributedString *)getCommonLabelAttributedStringForName:(NSString *)nameStr andValue:(NSString *)valueStr
{
    NSString *tempStr = [NSString stringWithFormat:@"%@ : %@",nameStr, valueStr];
    
    NSInteger nameStrLength = [nameStr length];
    NSMutableAttributedString * finalStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
    [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,nameStrLength)];
    [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange((nameStrLength+1),[tempStr length]-(nameStrLength+1))];
    return finalStr;
    
}


#pragma mark - UITableView Datasource/Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([sellerSneakerArray count]>0 && [buyerSneakerArray count]>0)
    {
        return 2;
    }
    else if([sellerSneakerArray count]>0 || [buyerSneakerArray count]>0)
    {
        return 1;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"sectionHeader";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *headerLabel = (UILabel *)[headerView viewWithTag:10];
    
    if(section==0)
    {
        headerLabel.text = @"Sneaker details";
    }
    else
    {
        headerLabel.text = @"Buyer sneaker details";
    }
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return [sellerSneakerArray count];
    }
    else
    {
        return [buyerSneakerArray count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = nil;
    
    if(indexPath.section == 0)
    {
        dict = [sellerSneakerArray objectAtIndex:indexPath.row];
    }
    else
    {
        dict = [buyerSneakerArray objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *cell = [self.offscreenCells objectForKey:@"sneakerInfoCell"];
    if (!cell && cell.tag!=-1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"sneakerInfoCell"];
        cell.tag = -1;
        [self.offscreenCells setObject:cell forKey:@"sneakerInfoCell"];
    }
    
    UILabel *sneakerNameLbl = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *conditionLbl = (UILabel *)[cell.contentView viewWithTag:12];
    UILabel *brandNameLbl = (UILabel *)[cell.contentView viewWithTag:13];
    UILabel *sizeLbl = (UILabel *)[cell.contentView viewWithTag:14];
    
    sneakerNameLbl.text = dict[@"sneakername"];
    brandNameLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Brand" andValue:dict[@"sneakerbrand"]];
    conditionLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Condition" andValue:dict[@"sneakercondition"]];
    sizeLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Size" andValue:dict[@"sneakersize"]];
    
    //fieldValueLbl.text = dict[@"value"];
    
    sneakerNameLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (sneakerNameLbl.frame.origin.x + 8.0);
    brandNameLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (brandNameLbl.frame.origin.x + 8.0);
    conditionLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (conditionLbl.frame.origin.x + 8.0);
    
    
    //[cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    
    return height;
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = nil;
    
    if(indexPath.section == 0)
    {
        dict = [sellerSneakerArray objectAtIndex:indexPath.row];
    }
    else
    {
        dict = [buyerSneakerArray objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sneakerInfoCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UIImageView *sneakerThumbImageView = (UIImageView *)[cell.contentView viewWithTag:10];
    UILabel *sneakerNameLbl = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *conditionLbl = (UILabel *)[cell.contentView viewWithTag:12];
    UILabel *brandNameLbl = (UILabel *)[cell.contentView viewWithTag:13];
    UILabel *sizeLbl = (UILabel *)[cell.contentView viewWithTag:14];
     
    sneakerNameLbl.text = dict[@"sneakername"];
    brandNameLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Brand" andValue:dict[@"sneakerbrand"]];
    conditionLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Condition" andValue:dict[@"sneakercondition"]];
    sizeLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Size" andValue:dict[@"sneakersize"]];
    
    sneakerNameLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (sneakerNameLbl.frame.origin.x + 8.0);
    brandNameLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (brandNameLbl.frame.origin.x + 8.0);
    conditionLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (conditionLbl.frame.origin.x + 8.0);
    
    
    __block UIImageView *blockThumbImage = sneakerThumbImageView;
    
    NSString *urlStr = dict[@"sneakerimg"];
    /*if(dict[@"sneakerimg"] && [dict[@"sneakerimg"] count]>0)
     {
     urlStr = [dict[@"picture"] objectAtIndex:0][@"picture"];
     }*/
    
    /*[sneakerThumbImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         blockThumbImage.image = image;
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         LKLog(@"error - %@",error);
     }];*/
    
    [sneakerThumbImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        blockThumbImage.image = image;
    }];
    
    
    [cell layoutIfNeeded];
    
    return cell;
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = nil;
    if(indexPath.section == 0)
    {
        dict = [sellerSneakerArray objectAtIndex:indexPath.row];
    }
    else
    {
        dict = [buyerSneakerArray objectAtIndex:indexPath.row];
    }
    
    //[self performSegueWithIdentifier:@"ReqestDetailVcToSneakerDetailVc" sender:dict];
    
    [self getAndDisplaySneakerDetailForSneakerId:dict[@"sneakerid"]];
}


-(void)getAndDisplaySneakerDetailForSneakerId:(id)sneakerId
{
    NSDictionary *params = @{@"method" : @"getsneakerdetail",
                             @"userid" : [LKKeyChain objectForKey:@"userid"],
                             @"sneakerid" : sneakerId};
    LKLog(@"params = %@",params);
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    loading.removeFromSuperViewOnHide = YES;
    [self.navigationController.view addSubview:loading];
    [loading show:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.operationQueue cancelAllOperations];
    
    [manager POST:GET_SNEAKER_DETAIL_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        LKLog(@"JSON: %@", responseObject);
        
        [loading hide:YES];
        
        if([responseObject[@"success"] integerValue] == 1 && responseObject[@"sneakerdetail"])
        {
            [self performSegueWithIdentifier:@"ReqestDetailVcToSneakerDetailVc" sender:responseObject[@"sneakerdetail"]];
        }
        else
        {
            [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to get sneaker detail, please try again."];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [loading hide:YES];
        
        LKLog(@"failed response string = %@",operation.responseString);
        [Utility displayHttpFailureError:error];
    }];
}


#pragma mark - BTPaymentMethodCreationDelegate methods

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
    
    [self callAcceptRejectWebserviceWithAccept:YES];
    
    //[Utility displayAlertWithTitle:@"PayPal Payment" andMessage:[NSString stringWithFormat:@"Your PayPal payment method created successfully with nonce : %@",self.nonce]];
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error
{
    LKLog(@"didFailWithError = %@ ---- %@", sender, error);
    
    [Utility displayAlertWithTitle:@"PayPal Payment Error" andMessage:[NSString stringWithFormat:@"Failed to process payment, please try again."]];
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
    
    
    if([reviewTxt isFirstResponder])
    {
        [ratingPopupScroll setContentInset:bottomInset];
        [ratingPopupScroll setScrollIndicatorInsets:bottomInset];
        
        
        
        CGRect textFieldRect = [ratingView convertRect:reviewTxt.bounds fromView:reviewTxt];
        textFieldRect = CGRectMake(textFieldRect.origin.x, ratingView.frame.origin.y+textFieldRect.origin.y, textFieldRect.size.width, textFieldRect.size.height);
        
        CGRect rect = self.view.frame;
        rect.size.height -= keyboardHeight;
        /*if (!CGRectContainsPoint(rect, reviewTxt.frame.origin)) {
            CGPoint point = CGPointMake(0, reviewTxt.frame.origin.y - keyboardHeight);
            [ratingPopupScroll setContentOffset:point animated:YES];
        }*/
        
        if (!CGRectContainsPoint(rect, textFieldRect.origin))
        {
            [ratingPopupScroll scrollRectToVisible:textFieldRect animated:YES];
        }
    }
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
    
    [ratingPopupScroll setContentInset:bottomInset];
    [ratingPopupScroll setScrollIndicatorInsets:bottomInset];
}


#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.textColor = [UIColor blackColor];
    
    if([textView.text isEqualToString:@"Write review..."])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([textView.text length]==0)
    {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = @"Write review...";
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text length]==0)
        return YES;
    
    NSString *textStr = [textView.text stringByAppendingString:text];
    
    if([textStr length]>1000)
        return NO;
    
    
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
    
    if([segue.identifier isEqualToString:@"ReqestDetailVcToSneakerDetailVc"])
    {
        SneakerDetailViewController *sneakerDetailVc = (SneakerDetailViewController *)segue.destinationViewController;
        sneakerDetailVc.sneakerInfoDict = [[NSDictionary alloc] initWithDictionary:sender];
        sneakerDetailVc.disableAction = YES;
    }
    else if([segue.identifier isEqualToString:@"TradeRequestDetailVcToSendCourierVc"])
    {
        SendCourierViewController *sendCourierVc = (SendCourierViewController *)segue.destinationViewController;
        sendCourierVc.tradeDict = [[NSDictionary alloc] initWithDictionary:self.tradeDict];
        sendCourierVc.sendCourierForTrade = YES;
    }
    
}


@end
