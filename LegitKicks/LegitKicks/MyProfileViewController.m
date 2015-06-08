//
//  MyProfileViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 19/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "MyProfileViewController.h"
#import "MFSideMenu.h"
//#import "UIImageView+AFNetworking.h"
#import "EditProfileViewController.h"
#import "ReviewListViewController.h"
#import "UIImageView+WebCache.h"


#define EMAIL_TAG               100
#define CHANGE_PASS_TAG         101
#define PAYPAL_TAG              102
#define STREET_ADDRESS_TAG      103
#define CITY_TAG                104
#define STATE_TAG               105
#define ZIP_TAG                 106


@interface MyProfileViewController ()
{
    NSDictionary *userInfoDict;
    NSMutableArray *userInfoArray;
}

@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation MyProfileViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"my_profile", nil);
    
    self.navigationController.navigationBarHidden = NO;
    
    
    userInfoDict = [[NSDictionary alloc] initWithDictionary:[LKKeyChain objectForKey:@"userObject"]];
    
    [self generateUserInfoArray];
    
    [self displayProfileInformation];
    
    [self loadUserActivitySummaryFromWebserver];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.offscreenCells = [NSMutableDictionary dictionary];
    
    [self setMenuButtonToNavigationBar];
    [self setEditButtonToNavigationBar];
    
    [scroll layoutIfNeeded];
    
    photoBackView.layer.cornerRadius = photoBackView.frame.size.width/2.0;
    photoBackView.layer.borderColor = [UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0].CGColor;
    photoBackView.layer.borderWidth =1.0;
    
    photoImageView.layer.cornerRadius = photoImageView.frame.size.width/2.0;
    photoImageView.layer.borderWidth = 3.0;
    photoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    
    
    ratingBtn.layer.cornerRadius = ratingBtn.frame.size.height/2.0;
    ratingBtn.layer.borderWidth = 1.0;
    ratingBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    
    closetsBtn.layer.cornerRadius = closetsBtn.frame.size.height/2.0;
    closetsBtn.layer.borderWidth = 1.0;
    closetsBtn.layer.borderColor = [UIColor whiteColor].CGColor;
}

-(void)viewWillLayoutSubviews
{
    userInfoTableHeightConstraint.constant = [userInfoTable contentSize].height;
}


#pragma mark Set Menu button to Navigationbar
- (void)setMenuButtonToNavigationBar
{
    UIImage *backButtonImage = [UIImage imageNamed:@"menu_btn"];
    CGRect buttonFrame = CGRectMake(0, 0, 44, 44);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = buttonFrame;
    [button addTarget:self action:@selector(menuBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:backButtonImage forState:UIControlStateNormal];
    
    
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, settingItem, nil]];
    
}

-(IBAction)menuBtnClicked:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

#pragma mark Set Edit button to Navigationbar

-(void)setEditButtonToNavigationBar
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(0, 0, 44, 44);;
    [editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [editButton setImage:[UIImage imageNamed:@"edit_white_btn"] forState:UIControlStateNormal];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightItem, nil]];
    
}

-(void)editButtonPressed
{
    [self performSegueWithIdentifier:@"MyProfileVcToEditProfileVc" sender:nil];
}


#pragma mark Load profile data

-(void)loadProfileDataFromWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"GetProfileDetailByUsedID",
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
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                
                [LKKeyChain setObject:responseObject[@"email"] forKey:@"email"];
                [LKKeyChain setObject:responseObject[@"firstname"] forKey:@"firstname"];
                [LKKeyChain setObject:responseObject[@"lastname"] forKey:@"lastname"];
                [LKKeyChain setObject:responseObject[@"image"] forKey:@"profile_image"];
                [LKKeyChain setObject:responseObject[@"noofcloset"] forKey:@"noofcloset"];
                [LKKeyChain setObject:responseObject[@"nooftradesneaker"] forKey:@"nooftradesneaker"];
                [LKKeyChain setObject:responseObject[@"noofsalesneaker"] forKey:@"noofsalesneaker"];
                [LKKeyChain setObject:responseObject[@"online"] forKey:@"online"];
                [LKKeyChain setObject:responseObject[@"userdescription"] forKey:@"userdescription"];
                [LKKeyChain setObject:responseObject[@"userid"] forKey:@"userid"];
                
                userInfoDict = [[NSDictionary alloc] initWithDictionary:responseObject];
                
                [self displayProfileInformation];
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

#pragma mark Load User Activity Summary

-(void)loadUserActivitySummaryFromWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"UserActivitySummary",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"]};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        /*MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];*/
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:BASE_API parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            //[loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [ratingBtn setTitle:[NSString stringWithFormat:@"Rating (%@)", responseObject[@"Avgrating"]] forState:UIControlStateNormal];
                [closetsBtn setTitle:[NSString stringWithFormat:@"Closets (%@)", responseObject[@"closetCount"]] forState:UIControlStateNormal];
                
                tradedCountLbl.text = [NSString stringWithFormat:@"%@", responseObject[@"tradeCount"]];
                soldCountLbl.text = [NSString stringWithFormat:@"%@", responseObject[@"soldCount"]];
                boughtCountLbl.text = [NSString stringWithFormat:@"%@", responseObject[@"boughtCount"]];
                tradingCountLbl.text = [NSString stringWithFormat:@"%@", responseObject[@"tradingCount"]];
                sellingCountLbl.text = [NSString stringWithFormat:@"%@", responseObject[@"sellingCount"]];
                buyingCountLbl.text = [NSString stringWithFormat:@"%@", responseObject[@"buyingCount"]];
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"unable_load_data_alert", nil)];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //[loading hide:YES];
            
            LKLog(@"failed response string = %@",operation.responseString);
            [Utility displayHttpFailureError:error];
        }];
    }
    else
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
    }
}


-(void)displayProfileInformation
{
     __block UIImageView *blockThumbImage = photoImageView;
    
    /*[photoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:userInfoDict[@"image"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         blockThumbImage.image = image;
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];*/
    
    [photoImageView sd_setImageWithURL:[NSURL URLWithString:userInfoDict[@"image"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        blockThumbImage.image = image;
    }];
    
    nameLbl.text = [NSString stringWithFormat:@"%@", userInfoDict[@"username"]];
    
    /*if([userInfoDict[@"city"] length]>0 && [userInfoDict[@"state"] length]>0)
    {
        locationLbl.text = [NSString stringWithFormat:@"%@, %@", userInfoDict[@"city"], userInfoDict[@"state"]];
    }
    else if([userInfoDict[@"city"] length]>0)
    {
        locationLbl.text = userInfoDict[@"city"];
    }
    else if([userInfoDict[@"state"] length]>0)
    {
        locationLbl.text = userInfoDict[@"state"];
    }
    else
    {
        locationLbl.text = @"";
    }*/
    
    /*tradesCountLbl.text = [NSString stringWithFormat:@"%@",userInfoDict[@"nooftradesneaker"]];
    salesCountLbl.text = [NSString stringWithFormat:@"%@",userInfoDict[@"noofsalesneaker"]];
    myClosetsCountLbl.text = [NSString stringWithFormat:@"%@",userInfoDict[@"noofcloset"]];*/
    
    
    [self generateUserInfoArray];
}


#pragma mark Generate user info array

-(void)generateUserInfoArray
{
    userInfoArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    
    NSString *nameStr = [NSString stringWithFormat:@"%@ %@", userInfoDict[@"firstname"], userInfoDict[@"lastname"]];
    NSDictionary *tempDict = @{@"field_name" : NSLocalizedString(@"name", nil),
                               @"value" : nameStr,
                               @"field_tag" : @(EMAIL_TAG)};
    [tempArray addObject:tempDict];
    
    
    tempDict = @{@"field_name" : NSLocalizedString(@"email_address", nil),
                               @"value" : userInfoDict[@"email"]?userInfoDict[@"email"]:NSLocalizedString(@"not_available", nil),
                               @"field_tag" : @(EMAIL_TAG)};
    [tempArray addObject:tempDict];
    
    tempDict = @{@"field_name" : NSLocalizedString(@"change_password", nil),
                 @"value" : NSLocalizedString(@"change_your_account_password", nil),
                 @"field_tag" : @(CHANGE_PASS_TAG)};
    [tempArray addObject:tempDict];
    
    
    [userInfoArray addObject:@{@"section_name" : NSLocalizedString(@"user_information", nil),
                               @"section_info" : tempArray}];

    
    
    
    tempArray = [[NSMutableArray alloc] init];
    
    tempDict = @{@"field_name" : NSLocalizedString(@"street_address", nil),
                 @"value" : [userInfoDict[@"street_address"] length]>0?userInfoDict[@"street_address"]:NSLocalizedString(@"not_available", nil),
                               @"field_tag" : @(STREET_ADDRESS_TAG)};
    [tempArray addObject:tempDict];
    
    tempDict = @{@"field_name" : NSLocalizedString(@"city", nil),
                 @"value" : [userInfoDict[@"city"] length]>0?userInfoDict[@"city"]:NSLocalizedString(@"not_available", nil),
                 @"field_tag" : @(CITY_TAG)};
    [tempArray addObject:tempDict];
    
    tempDict = @{@"field_name" : NSLocalizedString(@"state", nil),
                 @"value" : [userInfoDict[@"state"] length]>0?userInfoDict[@"state"]:NSLocalizedString(@"not_available", nil),
                 @"field_tag" : @(STATE_TAG)};
    [tempArray addObject:tempDict];
    
    tempDict = @{@"field_name" : NSLocalizedString(@"zip", nil),
                 @"value" : [userInfoDict[@"zip"] length]>0?userInfoDict[@"zip"]:NSLocalizedString(@"not_available", nil),
                 @"field_tag" : @(ZIP_TAG)};
    [tempArray addObject:tempDict];
    
    
    [userInfoArray addObject:@{@"section_name" : NSLocalizedString(@"shipping_address", nil),
                               @"section_info" : tempArray}];
    
    
    
    /*tempArray = [[NSMutableArray alloc] init];
    
    tempDict = @{@"field_name" : @"paypal_logo",
                 @"value" : [userInfoDict[@"paypal_id"] length]>0?[NSString stringWithFormat:@"%@\nPayPal ID: %@", NSLocalizedString(@"send_receive_money_with_paypal", nil), userInfoDict[@"paypal_id"]]:NSLocalizedString(@"send_receive_money_with_paypal", nil),
                 @"field_tag" : @(PAYPAL_TAG)};
    [tempArray addObject:tempDict];*/
    
    /*tempDict = @{@"field_name" : @"Venmo",
                 @"value" : @"Send and receive money with Venmo",
                 @"field_tag" : @(CHANGE_PASS_TAG)};
    [tempArray addObject:tempDict];*/
    
    
    /*[userInfoArray addObject:@{@"section_name" : NSLocalizedString(@"payment_options", nil),
                               @"section_info" : tempArray}];*/

    [userInfoTable reloadData];
    
    [scroll layoutIfNeeded];
}


-(IBAction)editProfileBtnClicked:(id)sender
{
    //[Utility displayAlertWithTitle:@"Edit Profile" andMessage:@"Under Construction!!"];
}

-(IBAction)ratingBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"MyProfileVcToReviewListVc" sender:nil];
}

-(IBAction)closetsBtnClicked:(id)sender
{
    //[Utility displayAlertWithTitle:@"My Closets" andMessage:@"Under Construction!!"];
}

-(IBAction)tradedBtnClicked:(id)sender
{
    //[Utility displayAlertWithTitle:@"Traded" andMessage:@"Under Construction!!"];
}

-(IBAction)soldBtnClicked:(id)sender
{
    //[Utility displayAlertWithTitle:@"Sold" andMessage:@"Under Construction!!"];
}

-(IBAction)boughtBtnClicked:(id)sender
{
    //[Utility displayAlertWithTitle:@"Bought" andMessage:@"Under Construction!!"];
}

-(IBAction)tradingBtnClicked:(id)sender
{
    //[Utility displayAlertWithTitle:@"Trading" andMessage:@"Under Construction!!"];
}

-(IBAction)sellingBtnClicked:(id)sender
{
    //[Utility displayAlertWithTitle:@"Selling" andMessage:@"Under Construction!!"];
}

-(IBAction)buyingBtnClicked:(id)sender
{
    //[Utility displayAlertWithTitle:@"Buying" andMessage:@"Under Construction!!"];
}



#pragma mark - UITableView Datasource/Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [userInfoArray count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"sectionHeader";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *headerLabel = (UILabel *)[headerView viewWithTag:10];
    
    headerLabel.text = [userInfoArray objectAtIndex:section][@"section_name"];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *dict = [[userInfoArray objectAtIndex:indexPath.section][@"section_info"] objectAtIndex:indexPath.row];
    
    UITableViewCell *cell;
    
    if([dict[@"field_tag"] integerValue] == PAYPAL_TAG)
    {
        cell = [self.offscreenCells objectForKey:@"paymentInfoCell"];
        if (!cell && cell.tag!=-1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"paymentInfoCell"];
            cell.tag = -1;
            [self.offscreenCells setObject:cell forKey:@"paymentInfoCell"];
        }
    }
    else
    {
        cell = [self.offscreenCells objectForKey:@"userInfoCell"];
        if (!cell && cell.tag!=-1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"userInfoCell"];
            cell.tag = -1;
            [self.offscreenCells setObject:cell forKey:@"userInfoCell"];
        }
    }
    
    
    UILabel *fieldValueLbl = (UILabel *)[cell.contentView viewWithTag:11];
    
    fieldValueLbl.text = dict[@"value"];
    
    
    //[cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    
    return height;
    
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[userInfoArray objectAtIndex:section][@"section_info"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [[userInfoArray objectAtIndex:indexPath.section][@"section_info"] objectAtIndex:indexPath.row];
    
    if([dict[@"field_tag"] integerValue] == PAYPAL_TAG)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"paymentInfoCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView *fieldLogoImage = (UIImageView *)[cell.contentView viewWithTag:10];
        UILabel *fieldValueLbl = (UILabel *)[cell.contentView viewWithTag:11];
        
        fieldLogoImage.image = [UIImage imageNamed:dict[@"field_name"]];
        fieldValueLbl.text = dict[@"value"];
        
        [cell layoutIfNeeded];
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userInfoCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if([dict[@"field_tag"] integerValue] == CHANGE_PASS_TAG)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        UILabel *fieldLbl = (UILabel *)[cell.contentView viewWithTag:10];
        UILabel *fieldValueLbl = (UILabel *)[cell.contentView viewWithTag:11];
        
        fieldLbl.text = dict[@"field_name"];
        fieldValueLbl.text = dict[@"value"];
        
        [cell layoutIfNeeded];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [[userInfoArray objectAtIndex:indexPath.section][@"section_info"] objectAtIndex:indexPath.row];
    
    if([dict[@"field_tag"] integerValue] == PAYPAL_TAG)
    {
        //[Utility displayAlertWithTitle:@"PayPal" andMessage:@"Under Construction!!"];
        
        [self performSegueWithIdentifier:@"MyProfileVcToEditPaypalVc" sender:nil];
    }
    else if([dict[@"field_tag"] integerValue] == CHANGE_PASS_TAG)
    {
        //[Utility displayAlertWithTitle:@"Change Pasword" andMessage:@"Under Construction!!"];
        
        [self performSegueWithIdentifier:@"MyProfileVcToChangePasswordVc" sender:nil];
    }
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
    
    if([segue.identifier isEqualToString:@"MyProfileVcToEditProfileVc"])
    {
        EditProfileViewController *editProfileVc = (EditProfileViewController *)segue.destinationViewController;
        editProfileVc.userDict = [[NSDictionary alloc] initWithDictionary:userInfoDict];
    }
    else if([segue.identifier isEqualToString:@"MyProfileVcToReviewListVc"])
    {
        ReviewListViewController *reviewListVc = (ReviewListViewController *)segue.destinationViewController;
        reviewListVc.userDict = userInfoDict;
    }
}


@end
