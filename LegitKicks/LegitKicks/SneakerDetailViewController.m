//
//  SneakerDetailViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 11/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "SneakerDetailViewController.h"
//#import "UIImageView+AFNetworking.h"
#import "PublicProfileViewController.h"
#import "RequestForSaleViewController.h"
#import "RequestForTradeViewController.h"
#import "EditProfileViewController.h"
#import "UIImageView+WebCache.h"

@interface SneakerDetailViewController ()
{
    NSArray *sneakerImageArray;
}

@end

@implementation SneakerDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setBackButtonToNavigationBar];
    [self setAddToWatchlistButtonToNavigationBar];
    
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2.0;
    profileImageView.layer.borderWidth = 2.0;
    profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    profileImageView.layer.masksToBounds = YES;
    
    requestForTradeBtn.layer.cornerRadius = 5.0;
    requestForSaleBtn.layer.cornerRadius = 5.0;
    requestForBtn.layer.cornerRadius = 5.0;
    
    //requestForTradeBtn.enabled = NO;
    //requestForSaleBtn.enabled = NO;
    
    avgRatingView.starImage = [UIImage imageNamed:@"unrated_sneaker_ic20x20"];
    avgRatingView.starHighlightedImage = [UIImage imageNamed:@"rated_sneaker_ic20x20"];
    avgRatingView.maxRating = 5.0;
    avgRatingView.horizontalMargin = 0;
    avgRatingView.editable=NO;
    avgRatingView.rating= 0.0;
    avgRatingView.displayMode=EDStarRatingDisplayAccurate;
    
    
    if(!_disableAction && _sneakerInfoDict[@"status"])
    {
        NSInteger sneakerStatus = [_sneakerInfoDict[@"status"] integerValue];
        
        if(sneakerStatus == SNEAKER_STATUS_IN_SALE || sneakerStatus == SNEAKER_STATUS_IN_TRADE || sneakerStatus == SNEAKER_STATUS_SOLD || sneakerStatus == SNEAKER_STATUS_TRADED)
        {
            _disableAction = YES;
        }
    }
    
    
    [self getUerAverageRatingFromWebserver];
    [self displaySneakerDetails];
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


#pragma mark Set add to watchlist button to Navigationbar
- (void)setAddToWatchlistButtonToNavigationBar
{
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(0, 0, 44, 44);;
    [editButton addTarget:self action:@selector(addToWatchlistBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editButton setImage:[UIImage imageNamed:@"ic_heart_white_unfilled"] forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"ic_heart_white_filled"] forState:UIControlStateSelected];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightItem, nil]];
    
}

-(IBAction)addToWatchlistBtnClicked:(id)sender
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"Watchlist",
                                 @"sneakerid" : [NSString stringWithFormat:@"%@", self.sneakerInfoDict[@"sneakerid"]],
                                 @"userid" : [LKKeyChain objectForKey:@"userid"]};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:BASE_API parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            UIBarButtonItem *rightItem = (UIBarButtonItem *)[self.navigationItem.rightBarButtonItems objectAtIndex:1];
            
            UIButton *addToWatchlistBtn = (UIButton *)rightItem.customView;
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                if(addToWatchlistBtn.selected)
                {
                    addToWatchlistBtn.selected = NO;
                    [self.view makeToast:NSLocalizedString(@"sneaker_removed_from_watchlist_alert", nil)];
                }
                else
                {
                    addToWatchlistBtn.selected = YES;
                    [self.view makeToast:NSLocalizedString(@"sneaker_added_to_watchlist_alert", nil)];
                }
            }
            else
            {
                
                if(addToWatchlistBtn.selected)
                {
                    [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"unable_to_remove_sneaker_from_watchlist_alert", nil)];
                }
                else
                {
                    [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"unable_to_add_sneaker_to_watchlist_alert", nil)];
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


#pragma mark getUerAverageRatingFromWebserver

-(void)getUerAverageRatingFromWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"getUserRatingByUserID",
                                 @"userid" : [NSString stringWithFormat:@"%@", self.sneakerInfoDict[@"userid"]]};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:GET_USER_AVG_RATING parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                avgRatingView.rating= [responseObject[@"AvgRating"] floatValue];
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


-(void)displaySneakerDetails
{
    UIBarButtonItem *rightItem = (UIBarButtonItem *)[self.navigationItem.rightBarButtonItems objectAtIndex:1];
    
    UIButton *addToWatchlistBtn = (UIButton *)rightItem.customView;
    
    if([self.sneakerInfoDict[@"watchlist"] integerValue]==1)
    {
        addToWatchlistBtn.selected = YES;
    }
    else
    {
        addToWatchlistBtn.selected = NO;
    }
    
    actionViewBottomSpaceConstraint.constant = 0;
    
    if(self.disableAction || [self.sneakerInfoDict[@"userid"] isEqualToString:[LKKeyChain objectForKey:@"userid"]])
    {
        requestForSaleBtn.hidden = NO;
        requestForTradeBtn.hidden = NO;
        requestForBtn.hidden = YES;
        
        requestForTradeBtn.enabled = NO;
        requestForSaleBtn.enabled = NO;
        
        actionViewBottomSpaceConstraint.constant = -(bottomActionView.frame.size.height);
    }
    else if([self.sneakerInfoDict[@"forsale"] integerValue]==1 && [self.sneakerInfoDict[@"fortrade"] integerValue]==1)
    {
        requestForSaleBtn.hidden = NO;
        requestForTradeBtn.hidden = NO;
        requestForBtn.hidden = YES;
    }
    else
    {
        requestForSaleBtn.hidden = YES;
        requestForTradeBtn.hidden = YES;
        requestForBtn.hidden = NO;
        if([self.sneakerInfoDict[@"forsale"] integerValue]==1)
        {
            [requestForBtn setTitle:@"Request For Sale" forState:UIControlStateNormal];
        }
        if([self.sneakerInfoDict[@"fortrade"] integerValue]==1)
        {
            [requestForBtn setTitle:@"Request For Trade" forState:UIControlStateNormal];
        }
    }
    
    __block UIImageView *blockThumbImage = profileImageView;
    
    /*[profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.sneakerInfoDict[@"userimage"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         blockThumbImage.image = image;
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];*/
    
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:self.sneakerInfoDict[@"userimage"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        blockThumbImage.image = image;
    }];
    
    usernameLbl.text = self.sneakerInfoDict[@"username"];
    self.title = [NSString stringWithFormat:@"%@", self.sneakerInfoDict[@"sneakername"]];
    
    sneakerImageArray = [[NSArray alloc] initWithArray:self.sneakerInfoDict[@"picture"]];
    
    brandValueLbl.text = [NSString stringWithFormat:@"%@", self.sneakerInfoDict[@"brandname"]];
    conditionValueLbl.text = [NSString stringWithFormat:@"%@", self.sneakerInfoDict[@"condition"]];
    sizeValueLbl.text = [NSString stringWithFormat:@"%@", self.sneakerInfoDict[@"size"]];
    descriptionValueLbl.text = [NSString stringWithFormat:@"%@", self.sneakerInfoDict[@"description"]];
    priceValueLbl.text = [NSString stringWithFormat:@"%@", self.sneakerInfoDict[@"value"]];
    
    [scroll layoutIfNeeded];
    
    [sneakerImageCollectionView reloadData];[sneakerImageCollectionView reloadData];
}


-(IBAction)requestForBtnClicked:(id)sender
{
    if([self.sneakerInfoDict[@"forsale"] integerValue]==1)
    {
        [self requestForSaleBtnClicked:nil];
    }
    if([self.sneakerInfoDict[@"fortrade"] integerValue]==1)
    {
        [self requestForTradeBtnClicked:nil];
    }
}

-(IBAction)requestForTradeBtnClicked:(id)sender
{
    NSDictionary *userDict = [LKKeyChain objectForKey:@"userObject"];
    
    BOOL isAddressDetailIncomplete = NO;
    
    if(!userDict[@"zip"] || [userDict[@"zip"] length] == 0)
    {
        isAddressDetailIncomplete = YES;
    }
    
    if(!userDict[@"city"] || [userDict[@"city"] length] == 0)
    {
        isAddressDetailIncomplete = YES;
    }
    
    if(!userDict[@"state"] || [userDict[@"state"] length] == 0)
    {
        isAddressDetailIncomplete = YES;
    }
    
    if(!userDict[@"street_address"] || [userDict[@"street_address"] length] == 0)
    {
        isAddressDetailIncomplete = YES;
    }
    
    
    
    if(!isAddressDetailIncomplete)
    {
        
        if([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSDictionary *params = @{@"method" : @"check_trade_status",
                                     @"sneakerid" : [NSString stringWithFormat:@"%@", self.sneakerInfoDict[@"sneakerid"]],
                                     @"buyerid" : [LKKeyChain objectForKey:@"userid"],
                                     @"zip" : userDict[@"zip"]};
            LKLog(@"params = %@",params);
            
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
            
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            
            MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:loading];
            [loading show:YES];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager.operationQueue cancelAllOperations];
            
            [manager POST:CHECK_TRADE_ALLOW_STATUS_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                LKLog(@"JSON: %@", responseObject);
                
                [loading hide:YES];
                
                if([responseObject[@"success"] integerValue] == 1)
                {
                    if([responseObject[@"allow_trade"] integerValue] == 1)
                    {
                        [self performSegueWithIdentifier:@"SneakerDetailVcToRequestForTradeVc" sender:nil];
                    }
                    else
                    {
                        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"You have to complete atleast 3 local trade to trade sneaker outside of 50 miles."];
                    }
                }
                else
                {
                    
                    [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Unable to process for trade with you address or update profile address details and try again."];
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
    else
    {
        //[Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Please update your profile with complete shipping address details to continue trade."];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:@"Please update your profile with complete shipping address details to continue trade." delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"update", nil), nil];
        [alert show];
    }
}

-(IBAction)requestForSaleBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"SneakerDetailVcToRequestForSaleVc" sender:nil];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        EditProfileViewController *editProfileVc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileVc"];
        [self.navigationController pushViewController:editProfileVc animated:YES];
    }
}



#pragma mark - CollectionView Datasource/Delegate Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.bounds.size.width, sneakerImageCollectionView.frame.size.height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [sneakerImageArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"sneakerImageCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UIImageView *sneakerImageView = (UIImageView *)[cell.contentView viewWithTag:10];
    
    __block UIImageView *blockThumbImage = sneakerImageView;
    
    /*[sneakerImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[sneakerImageArray objectAtIndex:indexPath.row][@"picture"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         blockThumbImage.image = image;
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];*/
    
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:[sneakerImageArray objectAtIndex:indexPath.row][@"picture"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        blockThumbImage.image = image;
    }];
    
    
    //[cell.projectImageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"no_image"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    
    if([segue.identifier isEqualToString:@"SneakerDetailVcToPublicProfileVc"])
    {
        PublicProfileViewController *publicProfileVc = (PublicProfileViewController *)segue.destinationViewController;
        publicProfileVc.userid = [NSString stringWithFormat:@"%@", self.sneakerInfoDict[@"userid"]];
    }
    else if([segue.identifier isEqualToString:@"SneakerDetailVcToRequestForTradeVc"])
    {
        RequestForTradeViewController *tradeVc = (RequestForTradeViewController *)segue.destinationViewController;
        tradeVc.sneakerDict = [[NSDictionary alloc] initWithDictionary:self.sneakerInfoDict];
    }
    else if([segue.identifier isEqualToString:@"SneakerDetailVcToRequestForSaleVc"])
    {
        RequestForSaleViewController *saleVc = (RequestForSaleViewController *)segue.destinationViewController;
        saleVc.sneakerDict = [[NSDictionary alloc] initWithDictionary:self.sneakerInfoDict];
    }
}


@end
