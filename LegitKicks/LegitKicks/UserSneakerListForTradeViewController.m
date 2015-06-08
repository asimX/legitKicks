//
//  RequestForTradeViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 17/01/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "UserSneakerListForTradeViewController.h"
//#import "UIImageView+AFNetworking.h"
#import "SneakerDetailViewController.h"
#import "UIImageView+WebCache.h"

#import "BraintreeTransactionService.h"
#import "Braintree.h"

@interface UserSneakerListForTradeViewController () <BTPaymentMethodCreationDelegate, BTDropInViewControllerDelegate>
{
    CGFloat collectionViewWidth;
    CGFloat collectionViewHeight;
    
    BOOL loadNextResultData;
    NSInteger totalPageCount;
    NSInteger sneakerListOffset;
    NSInteger dataLimit;
    BOOL isLoadingData;
    
    NSMutableArray *selectedSneakerArray;
    
    BOOL fromPresentedVc;
}

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) BTPaymentProvider *paymentProvider;
@property (nonatomic, copy) NSString *nonce;

@end

@implementation UserSneakerListForTradeViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.title = NSLocalizedString(@"search_reults", nil);
    
    //self.navigationController.navigationBarHidden = NO;
    
    if(fromPresentedVc)
    {
        fromPresentedVc = NO;
        return;
    }
    
    
    loadNextResultData = YES;
    
    sneakerListOffset = 0;
    
    dataLimit = 20;
    
    [sneakerArray removeAllObjects];
    [sneakerCollectionView reloadData];
    
    [self fetchSneakerListFromWebserver];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setBackButtonToNavigationBar];
    [self setTradeButtonToNavigationBar];
    
    self.title = @"Select Sneaker";
    
    noSneakerFoundLbl.hidden = YES;
    
    collectionViewWidth = 151.0;
    collectionViewHeight = 120.0;
    
    CGFloat defaultResolutionWidth = 320.0;
    
    CGFloat currentResolutionWidth = self.view.frame.size.width;
    
    collectionViewWidth = currentResolutionWidth*collectionViewWidth/defaultResolutionWidth;
    
    sneakerArray = [[NSMutableArray alloc] init];
    selectedSneakerArray = [[NSMutableArray alloc] init];
    
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

#pragma mark Set trade button to Navigationbar

-(void)setTradeButtonToNavigationBar
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    UIButton *myClosetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myClosetButton.frame = CGRectMake(0, 0, 60, 44);;
    [myClosetButton addTarget:self action:@selector(tradeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [myClosetButton setTitle:NSLocalizedString(@"trade", nil) forState:UIControlStateNormal];
    myClosetButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:myClosetButton];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightItem, nil]];
    
}

-(void)tradeBtnClicked
{
    if([selectedSneakerArray count]>0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Trade" message:@"Are you sure to exchange sneaker with your selected sneakers?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 100;
        [alert show];
    }
    else
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Please select at least one sneaker with which you want to process for trade."];
    }
    //[Utility displayAlertWithTitle:@"Trade" andMessage:@"Under Construction!!"];
    //[self performSegueWithIdentifier:@"SneakerListVcToTradeVc" sender:nil];
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
        [self presentViewController:navigationController animated:YES completion:^{
            fromPresentedVc = YES;
        }];
        
    }];
}

- (void)userDidCancelPayment
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod
{
    self.nonce = paymentMethod.nonce;
    
    [self addTradeRequestWithWebserver];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)displayNoSneakerFoundMsgIfNeeded
{
    if([sneakerArray count]==0)
    {
        noSneakerFoundLbl.hidden = NO;
    }
    else
    {
        noSneakerFoundLbl.hidden = YES;
    }
}


#pragma mark Load sneakers list for sale

-(void)fetchSneakerListFromWebserver
{
    if(isLoadingData || !loadNextResultData)
        return;
    
    //[sneakerArray removeAllObjects];
    //[sneakerCollectionView reloadData];
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"sneakerlistbyuser",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 //@"closetid" : @"1",
                                 @"Page" : @(sneakerListOffset)};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:GET_SNEAKER_FOR_TRADE_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [sneakerArray addObjectsFromArray:responseObject[@"alldata"]];
                
                [sneakerCollectionView reloadData];
                
                sneakerListOffset = sneakerListOffset + 1;
                
                totalPageCount = [responseObject[@"totalpage"] integerValue];
                
                if([responseObject[@"alldata"] count]==0 || sneakerListOffset >= totalPageCount)
                {
                    loadNextResultData = NO;
                }
                else
                {
                    loadNextResultData = YES;
                }
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"unable_load_data_alert", nil)];
            }
            
            [self displayNoSneakerFoundMsgIfNeeded];
            
            isLoadingData = NO;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [loading hide:YES];
            
            LKLog(@"failed response string = %@",operation.responseString);
            [Utility displayHttpFailureError:error];
            
            isLoadingData = NO;
        }];
    }
    else
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
    }
}



#pragma mark - CollectionView Datasource/Delegate Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionViewWidth, collectionViewHeight);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [sneakerArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"sneakerCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UIImageView *sneakerThumbImageView = (UIImageView *)[cell.contentView viewWithTag:10];
    UILabel *sneakerPriceLbl = (UILabel *)[cell.contentView viewWithTag:11];
    
    /*sneakerThumbImageView.layer.borderWidth = 1.0;
     sneakerThumbImageView.layer.borderColor = [UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0].CGColor;*/
    sneakerThumbImageView.image = nil;
    
    
    NSDictionary *dict = [sneakerArray objectAtIndex:indexPath.row];
    
    if([selectedSneakerArray containsObject:dict])
    {
        sneakerThumbImageView.layer.borderWidth = 3.0;
        sneakerThumbImageView.layer.borderColor = [UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0].CGColor;
    }
    else
    {
        sneakerThumbImageView.layer.borderWidth = 0.0;
        sneakerThumbImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    sneakerPriceLbl.text = [NSString stringWithFormat:@"%@",dict[@"value"]];
    
    
    __block UIImageView *blockThumbImage = sneakerThumbImageView;
    
    NSString *urlStr = @"";
    if(dict[@"picture"] && [dict[@"picture"] count]>0)
    {
        urlStr = [dict[@"picture"] objectAtIndex:0][@"picture"];
    }
    
    /*[sneakerThumbImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         blockThumbImage.image = image;
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];*/
    
    [sneakerThumbImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        blockThumbImage.image = image;
    }];
    
    
    if(!isLoadingData && indexPath.row==[sneakerArray count]-1 && loadNextResultData)
    {
        [self fetchSneakerListFromWebserver];
    }
    
    
    //[cell.projectImageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"no_image"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"SearchResultVcToSneakerDetailVc" sender:[sneakerArray objectAtIndex:indexPath.row]];
    
    NSDictionary *dict = [sneakerArray objectAtIndex:indexPath.row];
    
    if([selectedSneakerArray containsObject:dict])
    {
        [selectedSneakerArray removeObject:dict];
    }
    else
    {
        [selectedSneakerArray addObject:dict];
    }
    
    [sneakerCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Trade" message:@"Are you sure to exchange sneaker with your selected sneaker?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 100;
    [alert show];*/
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100 && buttonIndex==1)
    {
        //[Utility displayAlertWithTitle:@"Request Trade" andMessage:@"Under Construction!!"];
        //[self.navigationController popToRootViewControllerAnimated:YES];
        
        [self loadBraintreePaymentGateway];
    }
}

-(void)addTradeRequestWithWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *userDict = [LKKeyChain objectForKey:@"userObject"];
        
        NSDictionary *params = @{@"method" : @"addtradeinfo",
                                 @"zip" : userDict[@"zip"],
                                 @"buyerid" : [LKKeyChain objectForKey:@"userid"],
                                 @"buyersneakerid" : [[selectedSneakerArray valueForKey:@"sneakerid"] componentsJoinedByString:@","],
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
        
        [manager POST:ADD_TRADE_INFO_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [self.navigationController.view.window makeToast:@"Your trade request sent successfully."];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to send trade request, please try again."];
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
    
    [self addTradeRequestWithWebserver];
    
    //[Utility displayAlertWithTitle:@"PayPal Payment" andMessage:[NSString stringWithFormat:@"Your PayPal payment method created successfully with nonce : %@",self.nonce]];
    
    
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error
{
    LKLog(@"didFailWithError = %@ ---- %@", sender, error);
    
    [Utility displayAlertWithTitle:@"PayPal Payment Error" andMessage:[NSString stringWithFormat:@"Failed to process payment, please try again."]];
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
    
    if([segue.identifier isEqualToString:@"RequestForTradeVcToSneakerDetailVc"])
    {
        SneakerDetailViewController *sneakerDetailVc = (SneakerDetailViewController *)segue.destinationViewController;
        sneakerDetailVc.sneakerInfoDict = [[NSDictionary alloc] initWithDictionary:sender];
    }
}

@end
