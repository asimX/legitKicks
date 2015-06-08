//
//  PublicProfileViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 26/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "PublicProfileViewController.h"
#import "MFSideMenu.h"
//#import "UIImageView+AFNetworking.h"
#import "FlagUserViewController.h"
#import "ClosetDetailViewController.h"
#import "ReviewListViewController.h"
#import "UIImageView+WebCache.h"


#define EMAIL_TAG               100
#define CHANGE_PASS_TAG         101
#define PAYPAL_TAG              102
#define STREET_ADDRESS_TAG      103
#define CITY_TAG                104
#define STATE_TAG               105
#define ZIP_TAG                 106


@interface PublicProfileViewController ()
{
    NSDictionary *userInfoDict;
    NSMutableArray *userInfoArray;
}

@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation PublicProfileViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"profile", nil);
    [flagUserBtn setTitle:NSLocalizedString(@"flag_this_user", nil) forState:UIControlStateNormal];
    
    self.navigationController.navigationBarHidden = NO;
    
    [self loadProfileDataFromWebserver];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.offscreenCells = [NSMutableDictionary dictionary];
    
    [self setBackButtonToNavigationBar];
    
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
    
    flagUserBtn.layer.cornerRadius = 4.0;
}

-(void)viewWillLayoutSubviews
{
    
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


#pragma mark Load profile data

-(void)loadProfileDataFromWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"PublicProfile",
                                 @"userid" : self.userid};
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
    
    nameLbl.text = userInfoDict[@"username"];
    
    if([userInfoDict[@"city"] length]>0 && [userInfoDict[@"state"] length]>0)
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
    }
    
    
    [ratingBtn setTitle:[NSString stringWithFormat:@"Rating (%@)", userInfoDict[@"AvgRating"]] forState:UIControlStateNormal];
    [closetsBtn setTitle:[NSString stringWithFormat:@"Closets (%@)", userInfoDict[@"closetCount"]] forState:UIControlStateNormal];
    
    tradedCountLbl.text = [NSString stringWithFormat:@"%@", userInfoDict[@"tradedCount"]];
    soldCountLbl.text = [NSString stringWithFormat:@"%@", userInfoDict[@"soldCount"]];
    boughtCountLbl.text = [NSString stringWithFormat:@"%@", userInfoDict[@"boughtCount"]];
    
}


-(IBAction)editProfileBtnClicked:(id)sender
{
    //[Utility displayAlertWithTitle:@"Edit Profile" andMessage:@"Under Construction!!"];
}

-(IBAction)ratingBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"ProfileVcToReviewListVc" sender:nil];
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
    
    UITableViewCell *cell = [self.offscreenCells objectForKey:@"userInfoCell"];
    if (!cell && cell.tag!=-1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"userInfoCell"];
        cell.tag = -1;
        [self.offscreenCells setObject:cell forKey:@"userInfoCell"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    if([segue.identifier isEqualToString:@"PublicProfileVcToFlagUserVc"])
    {
        FlagUserViewController *flagUserVc = (FlagUserViewController *)segue.destinationViewController;
        flagUserVc.userDict = [[NSDictionary alloc] initWithDictionary:userInfoDict];
    }
    else if([segue.identifier isEqualToString:@"PublicProfileVcToClosetDetailVc"])
    {
        ClosetDetailViewController *closetDetailVc = (ClosetDetailViewController *)segue.destinationViewController;
        closetDetailVc.closetid = [NSString stringWithFormat:@"%@", userInfoDict[@"closetid"]];
    }
    else if([segue.identifier isEqualToString:@"ProfileVcToReviewListVc"])
    {
        ReviewListViewController *reviewListVc = (ReviewListViewController *)segue.destinationViewController;
        reviewListVc.userDict = userInfoDict;
    }
}


@end
