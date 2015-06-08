//
//  SellRequestDetailViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 13/03/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "SellRequestDetailViewController.h"
#import "SneakerDetailViewController.h"
#import "SendCourierViewController.h"

#import "MFSideMenu.h"
//#import "UIImageView+AFNetworking.h"

#import "BraintreeTransactionService.h"
#import "Braintree.h"

#import "RatingViewController.h"
#import "UIImageView+WebCache.h"

@interface SellRequestDetailViewController () <EDStarRatingProtocol, BTPaymentMethodCreationDelegate, BTDropInViewControllerDelegate>
{
    NSDictionary *saleRequestDetailDict;
    NSMutableArray *sellerSneakerArray;
    NSMutableArray *buyerSneakerArray;
    
    BOOL isReceivedBtnShown;
    
    UIWindow *tempWindow;
    UIToolbar *keyboardToolbar;
    
    BOOL isCounterOfferRequest;
    BOOL isOfferPay;
    
    CGRect originalFrame;
}

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) BTPaymentProvider *paymentProvider;
@property (nonatomic, copy) NSString *nonce;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation SellRequestDetailViewController


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    originalFrame = self.view.frame;
}


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
    
    counterOfferTxt.inputAccessoryView = keyboardToolbar;
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    counterOfferTxt.leftView = paddingView;
    counterOfferTxt.leftViewMode = UITextFieldViewModeAlways;
    counterOfferTxt.rightView = paddingView;
    counterOfferTxt.rightViewMode = UITextFieldViewModeAlways;
    
    
    counterOfferTxt.layer.cornerRadius = 4.0;
    counterOfferBtn.layer.cornerRadius = 4.0;
    
    counterOfferTxt.layer.borderColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
    counterOfferTxt.layer.borderWidth = 1.0;
    
    
    [self.view layoutIfNeeded];
    
    sendBtn.hidden = YES;
    acceptBtn.hidden = YES;
    rejectBtn.hidden = YES;
    actionView.hidden = YES;
    offerRequestedView.hidden = YES;
    counterOfferRequestedView.hidden = YES;
    makeCounterOfferView.hidden = YES;
    
    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;
    
    [self hideAllActionsAndStatus];
    
    
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
    
    
    
    [self loadSellRequestDetailFromWebserver];
    
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
    [counterOfferTxt resignFirstResponder];
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
        dropInViewController.summaryTitle = _saleDict[@"sellersneakername"];
        dropInViewController.summaryDescription = @"";
        if(isOfferPay)
        {
            dropInViewController.displayAmount = [NSString stringWithFormat:@"%@", _saleDict[@"total_final_amt"]];
        }
        else if(isCounterOfferRequest)
        {
            dropInViewController.displayAmount = [NSString stringWithFormat:@"%@", _saleDict[@"counter_offer_amt"]];
        }
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
    
    if(isOfferPay)
    {
        [self paySellOffer];
    }
    else if(isCounterOfferRequest)
    {
        [self callAcceptRejectCounterOfferWebserviceWithAccept:YES];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Load profile data

-(void)loadSellRequestDetailFromWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"getsellrequestdetail",
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
        
        [manager POST:GET_SALE_REQUEST_DETAIL_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                saleRequestDetailDict = [[NSDictionary alloc] initWithDictionary:responseObject];
                
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


-(void)hideAllActionsAndStatus
{
    acceptBtn.hidden = YES;
    rejectBtn.hidden = YES;
    sendBtn.hidden = YES;
    actionView.hidden = YES;
    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;
    
    
    offerRequestedView.hidden = YES;
    offerRequestedViewBottomSpaceConstraint.constant = -offerRequestedView.frame.size.height;
    
    counterOfferRequestedView.hidden = YES;
    counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
    
    makeCounterOfferView.hidden = YES;
    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;
    
    
    offerAcceptedRejectedTimeView.hidden = YES;
    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
    
    paidTimeView.hidden = YES;
    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
    
    sentTimeView.hidden = YES;
    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
    
    receivedTimeView.hidden = YES;
    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
}


-(void)displaySneakerDetailInformation
{
    
    buyerSneakerArray = [[NSMutableArray alloc] initWithArray:saleRequestDetailDict[@"buyersneakerdetail"]];
    sellerSneakerArray = [[NSMutableArray alloc] initWithArray:saleRequestDetailDict[@"sellersneakerdetail"]];
    [sneakerTable reloadData];
    sneakerTableHeightConstraint.constant = sneakerTable.contentSize.height;
    
    [acceptBtn setTitle:@"Accept" forState:UIControlStateNormal];
    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    isReceivedBtnShown = NO;
    isCounterOfferRequest = NO;
    isOfferPay = NO;
    
    [self hideAllActionsAndStatus];
    
    
    switch ([_saleDict[@"status"] integerValue])
    {
        case 1:
        {
            if([[NSString stringWithFormat:@"%@", _saleDict[@"buyerid"]] isEqualToString:[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]]])
            {
                if([_saleDict[@"buyerreceivedtime"] length] > 0 && ![_saleDict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
                {
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                    
                    /*offerRequestedView.hidden = YES;
                    offerRequestedViewBottomSpaceConstraint.constant = -offerRequestedView.frame.size.height;
                    
                    counterOfferRequestedView.hidden = YES;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                    
                    [self displayReceivedTime];
                    [self displaySentTime];
                    [self displayPaidTime];
                }
                else if([_saleDict[@"sellersendtime"] length] > 0 && ![_saleDict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
                {
                    [sendBtn setTitle:@"Received" forState:UIControlStateNormal];
                    isReceivedBtnShown = YES;
                    
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;*/
                    sendBtn.hidden = NO;
                    actionView.hidden = NO;
                    actionViewBottomSpaceConstraint.constant = 0;
                    
                    /*offerRequestedView.hidden = YES;
                    offerRequestedViewBottomSpaceConstraint.constant = -offerRequestedView.frame.size.height;
                    
                    counterOfferRequestedView.hidden = YES;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                    
                    [self displaySentTime];
                    [self displayPaidTime];
                }
                else
                {
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                    
                    /*offerRequestedView.hidden = YES;
                    offerRequestedViewBottomSpaceConstraint.constant = -offerRequestedView.frame.size.height;
                    
                    counterOfferRequestedView.hidden = YES;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                }
            }
            else
            {
                if([_saleDict[@"buyerreceivedtime"] length] > 0 && ![_saleDict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
                {
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                    
                    /*offerRequestedView.hidden = YES;
                    offerRequestedViewBottomSpaceConstraint.constant = -offerRequestedView.frame.size.height;
                    
                    counterOfferRequestedView.hidden = YES;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                    
                    
                    [self displayReceivedTime];
                    [self displaySentTime];
                    [self displayPaidTime];
                }
                else if([_saleDict[@"sellersendtime"] length] > 0 && ![_saleDict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
                {
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                    
                    /*offerRequestedView.hidden = YES;
                    offerRequestedViewBottomSpaceConstraint.constant = -offerRequestedView.frame.size.height;
                    
                    counterOfferRequestedView.hidden = YES;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                    
                    
                    [self displaySentTime];
                    [self displayPaidTime];
                    
                }
                else
                {
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;*/
                    sendBtn.hidden = NO;
                    actionView.hidden = NO;
                    actionViewBottomSpaceConstraint.constant = 0;
                    
                    /*offerRequestedView.hidden = YES;
                    offerRequestedViewBottomSpaceConstraint.constant = -offerRequestedView.frame.size.height;
                    
                    counterOfferRequestedView.hidden = YES;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                }
            }
            
            break;
        }
        case 11:
        {
            if([[NSString stringWithFormat:@"%@", _saleDict[@"buyerid"]] isEqualToString:[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]]])
            {
                if([_saleDict[@"accept_reject_status"] integerValue] == 1)
                {
                    /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];*/
                    
                    if([_saleDict[@"buyerreceivedtime"] length] > 0 && ![_saleDict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;
                        sendBtn.hidden = YES;
                        actionView.hidden = YES;
                        actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = YES;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                        [self displayReceivedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                    else if([_saleDict[@"paidtime"] length] > 0 && ![_saleDict[@"paidtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                    else
                    {
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;
                        sendBtn.hidden = YES;
                        actionView.hidden = YES;
                        actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = YES;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                        [self displaySentTime];
                    }
                }
                else if([_saleDict[@"accept_reject_status"] integerValue] == 2)
                {
                    /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];*/
                    
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                    
                    /*offerRequestedView.hidden = NO;
                    offerRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    counterOfferRequestedView.hidden = YES;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                    
                    [self displayOfferRequestedValueTime];
                    [self displayOfferRejectedTime];
                }
                else
                {
                    /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];*/
                    
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                    
                    /*offerRequestedView.hidden = NO;
                    offerRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    counterOfferRequestedView.hidden = YES;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                    
                    [self displayOfferRequestedValueTime];
                }
            }
            else
            {
                if([_saleDict[@"accept_reject_status"] integerValue] == 1)
                {
                    /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];*/
                    
                    if([_saleDict[@"buyerreceivedtime"] length] > 0 && ![_saleDict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;
                        sendBtn.hidden = YES;
                        actionView.hidden = YES;
                        actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = YES;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                        [self displayReceivedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                    else if([_saleDict[@"paidtime"] length] > 0 && ![_saleDict[@"paidtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                    else
                    {
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;*/
                        sendBtn.hidden = NO;
                        actionView.hidden = NO;
                        actionViewBottomSpaceConstraint.constant = 0;
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = YES;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                        [self displaySentTime];
                    }
                }
                else if([_saleDict[@"accept_reject_status"] integerValue] == 2)
                {
                    offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];
                    
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                    
                    /*offerRequestedView.hidden = NO;
                    offerRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    counterOfferRequestedView.hidden = YES;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                    
                    
                    
                    [self displayOfferRequestedValueTime];
                    [self displayOfferRejectedTime];
                }
                else
                {
                    offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];
                    
                    acceptBtn.hidden = NO;
                    rejectBtn.hidden = NO;
                    /*sendBtn.hidden = YES;*/
                    actionView.hidden = NO;
                    actionViewBottomSpaceConstraint.constant = 0;
                    
                    /*offerRequestedView.hidden = NO;
                    offerRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    counterOfferRequestedView.hidden = YES;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;*/
                    
                    makeCounterOfferView.hidden = NO;
                    makeCounterOffersViewBottomSpaceConstraint.constant = 1;
                    
                    
                    
                    [self displayOfferRequestedValueTime];
                }
            }
            
            break;
        }
        case 12:
        {
            isCounterOfferRequest = YES;
            if([[NSString stringWithFormat:@"%@", _saleDict[@"buyerid"]] isEqualToString:[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]]])
            {
                /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];
                counterOfferRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"counter_offer_amt"]];*/
                
                if([_saleDict[@"accept_reject_status"] integerValue] == 3)
                {
                    if([_saleDict[@"buyerreceivedtime"] length] > 0 && ![_saleDict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;
                        sendBtn.hidden = YES;
                        actionView.hidden = YES;
                        actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = NO;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayCounterOfferRequestedValueTime];
                        [self displayCounterOfferAcceptedTime];
                        [self displayReceivedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                    else
                    {
                        [sendBtn setTitle:@"Pay" forState:UIControlStateNormal];
                        
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;*/
                         sendBtn.hidden = NO;
                         actionView.hidden = NO;
                         actionViewBottomSpaceConstraint.constant = 0;
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = NO;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayCounterOfferRequestedValueTime];
                        [self displayCounterOfferAcceptedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                }
                else if([_saleDict[@"accept_reject_status"] integerValue] == 4)
                {
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                    
                    /*offerRequestedView.hidden = NO;
                    offerRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    counterOfferRequestedView.hidden = NO;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                    
                    
                    
                    [self displayOfferRequestedValueTime];
                    [self displayCounterOfferRequestedValueTime];
                    [self displayCounterOfferRejectedTime];
                }
                else
                {
                    [acceptBtn setTitle:@"Pay" forState:UIControlStateNormal];
                    
                    acceptBtn.hidden = NO;
                    rejectBtn.hidden = NO;
                    /*sendBtn.hidden = YES;*/
                    actionView.hidden = NO;
                    actionViewBottomSpaceConstraint.constant = 0;
                    
                    /*offerRequestedView.hidden = NO;
                    offerRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    counterOfferRequestedView.hidden = NO;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                    
                    
                    
                    [self displayOfferRequestedValueTime];
                    [self displayCounterOfferRequestedValueTime];
                }
            }
            else
            {
                /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];
                counterOfferRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"counter_offer_amt"]];*/
                
                if([_saleDict[@"accept_reject_status"] integerValue] == 3)
                {
                    if([_saleDict[@"buyerreceivedtime"] length] > 0 && ![_saleDict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;
                        sendBtn.hidden = YES;
                        actionView.hidden = YES;
                        actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = NO;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayCounterOfferRequestedValueTime];
                        [self displayCounterOfferAcceptedTime];
                        [self displayReceivedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                    else
                    {
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;*/
                        sendBtn.hidden = NO;
                        actionView.hidden = NO;
                        actionViewBottomSpaceConstraint.constant = 0;
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = NO;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayCounterOfferRequestedValueTime];
                        [self displayCounterOfferAcceptedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                }
                else if([_saleDict[@"accept_reject_status"] integerValue] == 4)
                {
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                    
                    /*offerRequestedView.hidden = NO;
                    offerRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    counterOfferRequestedView.hidden = NO;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                    
                    
                    
                    [self displayOfferRequestedValueTime];
                    [self displayCounterOfferRequestedValueTime];
                    [self displayCounterOfferRejectedTime];
                }
                else
                {
                    /*acceptBtn.hidden = YES;
                    rejectBtn.hidden = YES;
                    sendBtn.hidden = YES;
                    actionView.hidden = YES;
                    actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                    
                    /*offerRequestedView.hidden = NO;
                    offerRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    counterOfferRequestedView.hidden = NO;
                    counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                    
                    offerAcceptedRejectedTimeView.hidden = YES;
                    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                    
                    paidTimeView.hidden = YES;
                    paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                    
                    sentTimeView.hidden = YES;
                    sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                    
                    receivedTimeView.hidden = YES;
                    receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                    
                    makeCounterOfferView.hidden = YES;
                    makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                    
                    
                    
                    [self displayOfferRequestedValueTime];
                    [self displayCounterOfferRequestedValueTime];
                }
            }
            
            break;
        }
        case 2:
        {
            if([[NSString stringWithFormat:@"%@", _saleDict[@"buyerid"]] isEqualToString:[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]]])
            {
                if([_saleDict[@"accept_reject_status"] integerValue] == 1)
                {
                    /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];*/
                    
                    
                    if([_saleDict[@"sellersendtime"] length] > 0 && ![_saleDict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        [sendBtn setTitle:@"Received" forState:UIControlStateNormal];
                        isReceivedBtnShown = YES;
                        
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;*/
                        sendBtn.hidden = NO;
                        actionView.hidden = NO;
                        actionViewBottomSpaceConstraint.constant = 0;
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = YES;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                    else if([_saleDict[@"paidtime"] length] > 0 && ![_saleDict[@"paidtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                        [self displayPaidTime];
                    }
                    else
                    {
                        isOfferPay = YES;
                        [sendBtn setTitle:@"Pay" forState:UIControlStateNormal];
                        
                        /*acceptBtn.hidden = YES;
                         rejectBtn.hidden = YES;*/
                        sendBtn.hidden = NO;
                        actionView.hidden = NO;
                        actionViewBottomSpaceConstraint.constant = 0;
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = YES;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                    }
                }
                else if([_saleDict[@"accept_reject_status"] integerValue] == 3)
                {
                    /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];
                    counterOfferRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"counter_offer_amt"]];*/
                    
                    if([_saleDict[@"sellersendtime"] length] > 0 && ![_saleDict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        [sendBtn setTitle:@"Received" forState:UIControlStateNormal];
                        isReceivedBtnShown = YES;
                        
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;*/
                        sendBtn.hidden = NO;
                        actionView.hidden = NO;
                        actionViewBottomSpaceConstraint.constant = 0;
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = NO;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayCounterOfferRequestedValueTime];
                        [self displayCounterOfferAcceptedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                    else
                    {
                        /*cceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;
                        sendBtn.hidden = YES;
                        actionView.hidden = YES;
                        actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = NO;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayCounterOfferRequestedValueTime];
                        [self displayCounterOfferAcceptedTime];
                        [self displayPaidTime];
                    }
                }
            }
            else
            {
                if([_saleDict[@"accept_reject_status"] integerValue] == 1)
                {
                    /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];*/
                    
                    
                    if([_saleDict[@"sellersendtime"] length] > 0 && ![_saleDict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;
                        sendBtn.hidden = YES;
                        actionView.hidden = YES;
                        actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = YES;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                    else if([_saleDict[@"paidtime"] length] > 0 && ![_saleDict[@"paidtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        sendBtn.hidden = NO;
                        actionView.hidden = NO;
                        actionViewBottomSpaceConstraint.constant = 0;
                        
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                        [self displayPaidTime];
                    }
                    else
                    {
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;
                        sendBtn.hidden = NO;
                        actionView.hidden = NO;
                        actionViewBottomSpaceConstraint.constant = 0;*/
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = YES;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayOfferAcceptedTime];
                    }
                }
                else if([_saleDict[@"accept_reject_status"] integerValue] == 3)
                {
                    /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];
                    counterOfferRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"counter_offer_amt"]];*/
                    
                    
                    if([_saleDict[@"sellersendtime"] length] > 0 && ![_saleDict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
                    {
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;
                        sendBtn.hidden = YES;
                        actionView.hidden = YES;
                        actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = NO;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayCounterOfferRequestedValueTime];
                        [self displayCounterOfferAcceptedTime];
                        [self displaySentTime];
                        [self displayPaidTime];
                    }
                    else
                    {
                        /*acceptBtn.hidden = YES;
                        rejectBtn.hidden = YES;*/
                        sendBtn.hidden = NO;
                        actionView.hidden = NO;
                        actionViewBottomSpaceConstraint.constant = 0;
                        
                        /*offerRequestedView.hidden = NO;
                        offerRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        counterOfferRequestedView.hidden = NO;
                        counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                        
                        offerAcceptedRejectedTimeView.hidden = YES;
                        offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                        
                        paidTimeView.hidden = YES;
                        paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                        
                        sentTimeView.hidden = YES;
                        sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                        
                        receivedTimeView.hidden = YES;
                        receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                        
                        makeCounterOfferView.hidden = YES;
                        makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                        
                        
                        
                        [self displayOfferRequestedValueTime];
                        [self displayCounterOfferRequestedValueTime];
                        [self displayCounterOfferAcceptedTime];
                        [self displayPaidTime];
                    }
                }
            }
            break;
        }
        case 3:
        {
            if([_saleDict[@"accept_reject_status"] integerValue] == 2)
            {
                /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];*/
                
                /*acceptBtn.hidden = YES;
                rejectBtn.hidden = YES;
                sendBtn.hidden = YES;
                actionView.hidden = YES;
                actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                
                /*offerRequestedView.hidden = NO;
                offerRequestedViewBottomSpaceConstraint.constant = 1;
                
                counterOfferRequestedView.hidden = YES;
                counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                
                offerAcceptedRejectedTimeView.hidden = YES;
                offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                
                paidTimeView.hidden = YES;
                paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                
                sentTimeView.hidden = YES;
                sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                
                receivedTimeView.hidden = YES;
                receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                
                makeCounterOfferView.hidden = YES;
                makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                
                
                
                [self displayOfferRequestedValueTime];
                [self displayOfferRejectedTime];
            }
            else if([_saleDict[@"accept_reject_status"] integerValue] == 4)
            {
                /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];
                counterOfferRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"counter_offer_amt"]];*/
                
                /*acceptBtn.hidden = YES;
                rejectBtn.hidden = YES;
                sendBtn.hidden = YES;
                actionView.hidden = YES;
                actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                
                /*offerRequestedView.hidden = NO;
                offerRequestedViewBottomSpaceConstraint.constant = 1;
                
                counterOfferRequestedView.hidden = NO;
                counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                
                offerAcceptedRejectedTimeView.hidden = YES;
                offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                
                paidTimeView.hidden = YES;
                paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                
                sentTimeView.hidden = YES;
                sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                
                receivedTimeView.hidden = YES;
                receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                
                makeCounterOfferView.hidden = YES;
                makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                
                
                
                [self displayOfferRequestedValueTime];
                [self displayCounterOfferRequestedValueTime];
                [self displayCounterOfferRejectedTime];
            }
            else
            {
                /*acceptBtn.hidden = YES;
                rejectBtn.hidden = YES;
                sendBtn.hidden = YES;
                actionView.hidden = YES;
                actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                
                /*offerRequestedView.hidden = YES;
                offerRequestedViewBottomSpaceConstraint.constant = -offerRequestedView.frame.size.height;
                
                counterOfferRequestedView.hidden = YES;
                counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                
                offerAcceptedRejectedTimeView.hidden = YES;
                offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                
                paidTimeView.hidden = YES;
                paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                
                sentTimeView.hidden = YES;
                sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                
                receivedTimeView.hidden = YES;
                receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                
                makeCounterOfferView.hidden = YES;
                makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
            }
            
            break;
        }
        case 4:
        {
            
            if([_saleDict[@"accept_reject_status"] integerValue] == 1)
            {
                /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];*/
                
                /*acceptBtn.hidden = YES;
                rejectBtn.hidden = YES;
                sendBtn.hidden = YES;
                actionView.hidden = YES;
                actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                
                /*offerRequestedView.hidden = NO;
                offerRequestedViewBottomSpaceConstraint.constant = 1;
                
                counterOfferRequestedView.hidden = YES;
                counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                
                offerAcceptedRejectedTimeView.hidden = YES;
                offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                
                paidTimeView.hidden = YES;
                paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                
                sentTimeView.hidden = YES;
                sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                
                receivedTimeView.hidden = YES;
                receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                
                makeCounterOfferView.hidden = YES;
                makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                
                
                
                [self displayOfferRequestedValueTime];
                [self displayOfferAcceptedTime];
                [self displayReceivedTime];
                [self displaySentTime];
                [self displayPaidTime];
            }
            else if([_saleDict[@"accept_reject_status"] integerValue] == 3)
            {
                /*offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"offer_amt"]];
                counterOfferRequestedValueLbl.text = [NSString stringWithFormat:@"%@", _saleDict[@"counter_offer_amt"]];*/
                
                /*acceptBtn.hidden = YES;
                rejectBtn.hidden = YES;
                sendBtn.hidden = YES;
                actionView.hidden = YES;
                actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                
                /*offerRequestedView.hidden = NO;
                offerRequestedViewBottomSpaceConstraint.constant = 1;
                
                counterOfferRequestedView.hidden = NO;
                counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
                
                offerAcceptedRejectedTimeView.hidden = YES;
                offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                
                paidTimeView.hidden = YES;
                paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                
                sentTimeView.hidden = YES;
                sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                
                receivedTimeView.hidden = YES;
                receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                
                makeCounterOfferView.hidden = YES;
                makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
                
                
                
                [self displayOfferRequestedValueTime];
                [self displayCounterOfferRequestedValueTime];
                [self displayCounterOfferAcceptedTime];
                [self displayReceivedTime];
                [self displaySentTime];
                [self displayPaidTime];
            }
            else
            {
                /*acceptBtn.hidden = YES;
                rejectBtn.hidden = YES;
                sendBtn.hidden = YES;
                actionView.hidden = YES;
                actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
                
                /*offerRequestedView.hidden = YES;
                offerRequestedViewBottomSpaceConstraint.constant = -offerRequestedView.frame.size.height;
                
                counterOfferRequestedView.hidden = YES;
                counterOfferRequestedViewBottomSpaceConstraint.constant = -counterOfferRequestedView.frame.size.height;
                
                offerAcceptedRejectedTimeView.hidden = YES;
                offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = -offerAcceptedRejectedTimeView.frame.size.height;
                
                paidTimeView.hidden = YES;
                paidTimeViewBottomSpaceConstraint.constant = -paidTimeView.frame.size.height;
                
                sentTimeView.hidden = YES;
                sentTimeViewBottomSpaceConstraint.constant = -sentTimeView.frame.size.height;
                
                receivedTimeView.hidden = YES;
                receivedTimeViewBottomSpaceConstraint.constant = -receivedTimeView.frame.size.height;
                
                makeCounterOfferView.hidden = YES;
                makeCounterOffersViewBottomSpaceConstraint.constant = -makeCounterOfferView.frame.size.height;*/
            }
            
            break;
        }
            
        default:
        {
            /*acceptBtn.hidden = YES;
            rejectBtn.hidden = YES;
            sendBtn.hidden = YES;
            actionView.hidden = YES;
            actionViewBottomSpaceConstraint.constant = -actionView.frame.size.height;*/
            
            break;
        }
    }
}


-(NSString *)getFormattedDateForString:(NSString *)dateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    
    NSDate *date = [formatter dateFromString:dateStr];
    
    [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}

-(void)displayOfferRequestedValueTime
{
    offerRequestedValueLbl.text = [NSString stringWithFormat:@"%@ on %@", _saleDict[@"offer_amt"], [self getFormattedDateForString:_saleDict[@"offerrequesttime"]]];
    
    offerRequestedView.hidden = NO;
    offerRequestedViewBottomSpaceConstraint.constant = 1;
}

-(void)displayCounterOfferRequestedValueTime
{
    counterOfferRequestedValueLbl.text = [NSString stringWithFormat:@"%@ on %@", _saleDict[@"counter_offer_amt"], [self getFormattedDateForString:_saleDict[@"counterofferrequesttime"]]];
    
    counterOfferRequestedView.hidden = NO;
    counterOfferRequestedViewBottomSpaceConstraint.constant = 1;
}

-(void)displayOfferAcceptedTime
{
    offerAcceptedRejectedTimeTitleLbl.text = @"Offer accepted on :";
    offerAcceptedRejectedTimeValueLbl.text = [NSString stringWithFormat:@"%@", [self getFormattedDateForString:_saleDict[@"offeractiontime"]]];
    
    offerAcceptedRejectedTimeView.hidden = NO;
    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = 1;
}

-(void)displayOfferRejectedTime
{
    offerAcceptedRejectedTimeTitleLbl.text = @"Offer rejected on :";
    offerAcceptedRejectedTimeValueLbl.text = [NSString stringWithFormat:@"%@", [self getFormattedDateForString:_saleDict[@"offeractiontime"]]];
    
    offerAcceptedRejectedTimeView.hidden = NO;
    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = 1;
}

-(void)displayCounterOfferAcceptedTime
{
    offerAcceptedRejectedTimeTitleLbl.text = @"Counter offer accepted on :";
    offerAcceptedRejectedTimeValueLbl.text = [NSString stringWithFormat:@"%@", [self getFormattedDateForString:_saleDict[@"counterofferactiontime"]]];
    
    offerAcceptedRejectedTimeView.hidden = NO;
    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = 1;
}

-(void)displayCounterOfferRejectedTime
{
    offerAcceptedRejectedTimeTitleLbl.text = @"Counter offer rejected on :";
    offerAcceptedRejectedTimeValueLbl.text = [NSString stringWithFormat:@"%@", [self getFormattedDateForString:_saleDict[@"counterofferactiontime"]]];
    
    offerAcceptedRejectedTimeView.hidden = NO;
    offerAcceptedRejectedTimeViewBottomSpaceConstraint.constant = 1;
}

-(void)displayPaidTime
{
    paidTimeValueLbl.text = [NSString stringWithFormat:@"%@", [self getFormattedDateForString:_saleDict[@"paidtime"]]];
    
    paidTimeView.hidden = NO;
    paidTimeViewBottomSpaceConstraint.constant = 1;
}

-(void)displaySentTime
{
    sentTimeValueLbl.text = [NSString stringWithFormat:@"%@", [self getFormattedDateForString:_saleDict[@"sellersendtime"]]];
    
    sentTimeView.hidden = NO;
    sentTimeViewBottomSpaceConstraint.constant = 1;
}

-(void)displayReceivedTime
{
    receivedTimeValueLbl.text = [NSString stringWithFormat:@"%@", [self getFormattedDateForString:_saleDict[@"buyerreceivedtime"]]];
    
    receivedTimeView.hidden = NO;
    receivedTimeViewBottomSpaceConstraint.constant = 1;
}


-(void)paySellOffer
{
    NSDictionary *params = @{@"method" : @"payselloffer",
                             @"userid" : [LKKeyChain objectForKey:@"userid"],
                             @"sellid" : _saleDict[@"sellid"],
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
    
    [manager POST:PAY_SELL_OFFER_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        LKLog(@"JSON: %@", responseObject);
        
        [loading hide:YES];
        
        if([responseObject[@"success"] integerValue] == 1)
        {
            self.saleDict = [[NSDictionary alloc] initWithDictionary:responseObject];
            [self displaySneakerDetailInformation];
        }
        else
        {
            if(accept)
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to accept counter offer request, please try again."];
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to reject counter offer request, please try again."];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [loading hide:YES];
        
        LKLog(@"failed response string = %@",operation.responseString);
        [Utility displayHttpFailureError:error];
    }];
}


-(IBAction)counterOfferBtnClicked:(id)sender
{
    if([counterOfferTxt.text length] == 0)
    {
        [Utility displayAlertWithTitle:@"Error" andMessage:@"Please enter counter offer amount."];
    }
    else if([counterOfferTxt.text floatValue] == 0.0f)
    {
        [Utility displayAlertWithTitle:@"Error" andMessage:@"Counter offer amount should be more than $0."];
    }
    else
    {
        if([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSDictionary *params = @{@"method" : @"counterofferforsell",
                                     @"sellid" : _saleDict[@"sellid"],
                                     @"counter_offer_amt" : counterOfferTxt.text};
            LKLog(@"params = %@",params);
            
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
            
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            
            MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:loading];
            [loading show:YES];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager.operationQueue cancelAllOperations];
            
            [manager POST:MAKE_SELL_COUNTER_OFFER_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                LKLog(@"JSON: %@", responseObject);
                
                [loading hide:YES];
                
                if([responseObject[@"success"] integerValue] == 1)
                {
                    [self.navigationController.view.window makeToast:@"Your counter offer request sent successfully."];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                else
                {
                    
                    [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to send counter offer request, please try again."];
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

-(IBAction)acceptBtnClicked:(id)sender
{
    if(isCounterOfferRequest)
    {
        [self loadBraintreePaymentGateway];
    }
    else
    {
        [self callAcceptRejectOfferWebserviceWithAccept:YES];
    }
}

-(IBAction)rejectBtnClicked:(id)sender
{
    if(isCounterOfferRequest)
    {
        [self callAcceptRejectCounterOfferWebserviceWithAccept:NO];
    }
    else
    {
        [self callAcceptRejectOfferWebserviceWithAccept:NO];
    }
}


-(void)callAcceptRejectOfferWebserviceWithAccept:(BOOL)accept
{
    //NSDictionary *userDict = [LKKeyChain objectForKey:@"userObject"];
    
    NSDictionary *params = @{@"method" : @"acceptrejectmakeofferrequest",
                             @"userid" : [LKKeyChain objectForKey:@"userid"],
                             @"sellid" : _saleDict[@"sellid"],
                             @"flag" : accept?@"1":@"2"};
    LKLog(@"params = %@",params);
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loading];
    [loading show:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.operationQueue cancelAllOperations];
    
    [manager POST:ACCEPT_REJECT_SELL_OFFER_REQUEST_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        LKLog(@"JSON: %@", responseObject);
        
        [loading hide:YES];
        
        if([responseObject[@"success"] integerValue] == 1)
        {
            self.saleDict = [[NSDictionary alloc] initWithDictionary:responseObject];
            [self displaySneakerDetailInformation];
        }
        else
        {
            if(accept)
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to accept offer request, please try again."];
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to reject offer request, please try again."];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [loading hide:YES];
        
        LKLog(@"failed response string = %@",operation.responseString);
        [Utility displayHttpFailureError:error];
    }];
}


-(void)callAcceptRejectCounterOfferWebserviceWithAccept:(BOOL)accept
{
    //NSDictionary *userDict = [LKKeyChain objectForKey:@"userObject"];
    
    NSDictionary *params = @{@"method" : @"acceptrejectcounterofferrequest",
                             @"userid" : [LKKeyChain objectForKey:@"userid"],
                             @"sellid" : _saleDict[@"sellid"],
                             @"flag" : accept?@"3":@"4",
                             @"buyernonce" : accept?self.nonce:@""};
    LKLog(@"params = %@",params);
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:loading];
    [loading show:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.operationQueue cancelAllOperations];
    
    [manager POST:ACCEPT_REJECT_SELL_COUNTER_OFFER_REQUEST_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        LKLog(@"JSON: %@", responseObject);
        
        [loading hide:YES];
        
        if([responseObject[@"success"] integerValue] == 1)
        {
            self.saleDict = [[NSDictionary alloc] initWithDictionary:responseObject];
            [self displaySneakerDetailInformation];
        }
        else
        {
            if(accept)
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to accept counter offer request, please try again."];
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to reject counter offer request, please try again."];
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
    if(isOfferPay)
    {
        [self loadBraintreePaymentGateway];
    }
    else if(isReceivedBtnShown)
    {
        NSDictionary *params = @{@"method" : @"sneakerrecieveforsell",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
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
        
        [manager POST:SNEAKER_RECEIVED_FOR_SELL_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                self.saleDict = [[NSDictionary alloc] initWithDictionary:responseObject];
                [self displaySneakerDetailInformation];
                
                //[self displayPopupview:ratingPopupView];
                RatingViewController *ratingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RatingVC"];
                ratingVC.forTrade = NO;
                ratingVC.sellTradeInfoDict = _saleDict;
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
        [self performSegueWithIdentifier:@"SellRequestDetailVcToSendCourierVc" sender:nil];
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
        NSDictionary *params = @{@"method" : @"addratereview",
                                 @"by_userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"trade_sell_id" : _saleDict[@"sellid"],
                                 @"to_userid" : _saleDict[@"sellerid"],
                                 @"rate" : @(sneakerRatingView.rating),
                                 @"review" : reviewTxt.text,
                                 @"status" : @"1"};
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
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"sectionHeader";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *headerLabel = (UILabel *)[headerView viewWithTag:10];
    headerLabel.text = @"Sneaker details";
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sellerSneakerArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [sellerSneakerArray objectAtIndex:indexPath.row];
    
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
    NSDictionary *dict = [sellerSneakerArray objectAtIndex:indexPath.row];
    
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
    NSDictionary *dict = [sellerSneakerArray objectAtIndex:indexPath.row];
    
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
            [self performSegueWithIdentifier:@"SaleRequestDetailVcToSneakerDetailVc" sender:responseObject[@"sneakerdetail"]];
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
    
    [self callAcceptRejectCounterOfferWebserviceWithAccept:YES];
    
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
    else if([counterOfferTxt isFirstResponder])
    {
        CGRect textFieldRect = [counterOfferRequestedView convertRect:counterOfferTxt.bounds fromView:counterOfferTxt];
        textFieldRect = CGRectMake(textFieldRect.origin.x, counterOfferRequestedView.frame.origin.y+textFieldRect.origin.y, textFieldRect.size.width, textFieldRect.size.height);
        
        CGRect frame = self.view.frame;
        self.view.frame = CGRectMake(frame.origin.x, frame.origin.y - keyboardHeight, frame.size.width, frame.size.height);
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
    
    
    CGRect frame = self.view.frame;
    self.view.frame = originalFrame;
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
    
    if([segue.identifier isEqualToString:@"SaleRequestDetailVcToSneakerDetailVc"])
    {
        SneakerDetailViewController *sneakerDetailVc = (SneakerDetailViewController *)segue.destinationViewController;
        sneakerDetailVc.sneakerInfoDict = [[NSDictionary alloc] initWithDictionary:sender];
        sneakerDetailVc.disableAction = YES;
    }
    else if([segue.identifier isEqualToString:@"SellRequestDetailVcToSendCourierVc"])
    {
        SendCourierViewController *sendCourierVc = (SendCourierViewController *)segue.destinationViewController;
        sendCourierVc.saleDict = [[NSDictionary alloc] initWithDictionary:self.saleDict];
        sendCourierVc.sendCourierForTrade = NO;
    }
}


@end
