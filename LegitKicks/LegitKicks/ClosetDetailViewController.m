//
//  ClosetDetailViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 13/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "ClosetDetailViewController.h"
//#import "UIImageView+AFNetworking.h"
#import "SneakerDetailViewController.h"
#import "PublicProfileViewController.h"
#import "UIImageView+WebCache.h"



@interface UIButton (VerticalLayout)

- (void)centerVerticallyWithPadding:(float)padding;
- (void)centerVertically;

@end


@implementation UIButton (VerticalLayout)

- (void)centerVerticallyWithPadding:(float)padding
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    CGFloat totalHeight = (imageSize.height + titleSize.height + padding);
    
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height),
                                            0.0f,
                                            0.0f,
                                            - titleSize.width);
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0f,
                                            - imageSize.width,
                                            - (totalHeight - titleSize.height),
                                            0.0f);
    
}


- (void)centerVertically
{
    const CGFloat kDefaultPadding = 6.0f;
    
    [self centerVerticallyWithPadding:kDefaultPadding];
}  


@end



@interface ClosetDetailViewController ()
{
    NSDictionary *closetInfoDict;
    
    NSMutableArray *sneakerArray;
    NSMutableArray *followingArray;
    
    BOOL loadNextSneakerData;
    BOOL loadNextFollowingData;
    
    NSInteger totalSneakerPageCount;
    NSInteger totalFollowingPageCount;
    
    NSInteger sneakerListOffset;
    NSInteger followingListOffset;
    
    CGFloat collectionViewWidthForSneakerList;
    CGFloat collectionViewHeightForSneakerList;
    CGFloat collectionViewWidthForFollowingList;
    CGFloat collectionViewHeightForFollowingList;
    
    BOOL isLoadingData;
}

@end

@implementation ClosetDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"closet", nil);
    
    self.navigationController.navigationBarHidden = NO;
    
    [self loadClosetDataFromWebserver];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self.view layoutIfNeeded];
    
    [self setBackButtonToNavigationBar];
    
    profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    profileImageView.layer.borderWidth =3.0;
    profileImageView.layer.cornerRadius = 10.0;
    profileImageView.layer.masksToBounds = YES;
    
    
    //[followBtn centerVerticallyWithPadding:0.0];
    [self AlignTextAndImageOfButton:followBtn];
    
    loadNextSneakerData = YES;
    loadNextFollowingData = YES;
    
    sneakerArray = [[NSMutableArray alloc] init];
    followingArray = [[NSMutableArray alloc] init];
    
    
    sneakerTabBtn.selected = YES;
    
    
    CGFloat defaultResolutionWidth = 320.0;
    
    CGFloat currentResolutionWidth = self.view.frame.size.width;
    
    
    collectionViewWidthForSneakerList = 151.0;
    collectionViewHeightForSneakerList = 120.0;
    collectionViewWidthForSneakerList = currentResolutionWidth*collectionViewWidthForSneakerList/defaultResolutionWidth;
    
    
    collectionViewWidthForFollowingList = 98.6;
    collectionViewHeightForFollowingList = 120.0;
    collectionViewWidthForFollowingList = currentResolutionWidth*collectionViewWidthForFollowingList/defaultResolutionWidth;
    
    
    [self loadSneakerListFromWebserver];
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


-(void) AlignTextAndImageOfButton:(UIButton *)button
{
    // the space between the image and text
    CGFloat spacing = 0.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    button.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}


#pragma mark Load profile data

-(void)loadClosetDataFromWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"GetClosetDetailByClosetID",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"closetid" : self.closetid};
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
                closetInfoDict = [[NSDictionary alloc] initWithDictionary:responseObject];
                
                [self displayClosetInformation];
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


-(void)displayClosetInformation
{
    __block UIImageView *blockThumbImage = topBackgroundImageView;
    
    /*[topBackgroundImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:closetInfoDict[@"closetbannerimage"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         blockThumbImage.image = image;
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];*/
    
    [topBackgroundImageView sd_setImageWithURL:[NSURL URLWithString:closetInfoDict[@"closetbannerimage"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        blockThumbImage.image = image;
    }];
    
    
    __block UIImageView *blockThumbImage1 = profileImageView;
    
    /*[profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:closetInfoDict[@"closetprofileimage"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         blockThumbImage1.image = image;
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];*/
    
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:closetInfoDict[@"closetprofileimage"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        blockThumbImage1.image = image;
    }];
    
    
    self.title = closetInfoDict[@"closetname"];
    
    sneakerCountLbl.text = [NSString stringWithFormat:@"%@", closetInfoDict[@"sneakercount"]];
    followingCountLbl.text = [NSString stringWithFormat:@"%@", closetInfoDict[@"followers"]];
    
    if([closetInfoDict[@"is_follow"] integerValue]==1)
    {
        followBtn.selected = YES;
    }
    else
    {
        followBtn.selected = NO;
    }
}


-(IBAction)sneakerTabBtnClicked:(id)sender
{
    if(!sneakerTabBtn.selected)
    {
        selectionImageLeadingConstraint.constant = [sneakerTabBtn superview].frame.origin.x;
        sneakerTabBtn.selected = YES;
        followingTabBtn.selected = NO;
        
        [closetCollectionView setContentOffset:CGPointMake(0, 0)];
        
        [closetCollectionView reloadData];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [tabView layoutIfNeeded];
            
        } completion:^(BOOL finished){
            
            if([sneakerArray count]==0)
            {
                [self loadSneakerListFromWebserver];
            }
            
        }];
    }
}

-(IBAction)followingTabBtnClicked:(id)sender
{
    if(!followingTabBtn.selected)
    {
        selectionImageLeadingConstraint.constant = [followingTabBtn superview].frame.origin.x;
        sneakerTabBtn.selected = NO;
        followingTabBtn.selected = YES;
        
        [closetCollectionView setContentOffset:CGPointMake(0, 0)];
        
        [closetCollectionView reloadData];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [tabView layoutIfNeeded];
            
        } completion:^(BOOL finished){
            
            if([followingArray count]==0)
            {
                [self loadFollowingListFromWebserver];
            }
            
        }];
    }
}


-(IBAction)followBtnClicked:(id)sender
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"AddFollow",
                                 @"closetid" : [NSString stringWithFormat:@"%@", self.closetid],
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
                if(followBtn.selected)
                {
                    followingCountLbl.text = [NSString stringWithFormat:@"%d", [closetInfoDict[@"followers"] intValue] - 1];
                    followBtn.selected = NO;
                    [self.view makeToast:NSLocalizedString(@"closet_unfollowed_successfully_alert", nil)];
                }
                else
                {
                    followingCountLbl.text = [NSString stringWithFormat:@"%d", [closetInfoDict[@"followers"] intValue] + 1];
                    followBtn.selected = YES;
                    [self.view makeToast:NSLocalizedString(@"closet_followed_successfully_alert", nil)];
                }
            }
            else
            {
                
                if(followBtn.selected)
                {
                    [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"failed_to_unfollow_closet_alert", nil)];
                }
                else
                {
                    [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"failed_to_follow_closet_alert", nil)];
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


#pragma mark Load sneakers list

-(void)loadSneakerListFromWebserver
{
    if(isLoadingData || !loadNextSneakerData)
        return;
    
    //[sneakerArray removeAllObjects];
    //[sneakerCollectionView reloadData];
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"GetClosetDetailByClosetID_SneakerList",
                                 //@"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"closetid" : self.closetid,
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
        
        [manager POST:BASE_API parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [sneakerArray addObjectsFromArray:responseObject[@"alldata"]];
                
                [closetCollectionView reloadData];
                
                sneakerListOffset = sneakerListOffset + 1;
                
                totalSneakerPageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || sneakerListOffset >= totalSneakerPageCount)
                {
                    loadNextSneakerData = NO;
                }
                else
                {
                    loadNextSneakerData = YES;
                }
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"unable_load_data_alert", nil)];
            }
            
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

#pragma mark Load following list

-(void)loadFollowingListFromWebserver
{
    if(isLoadingData || !loadNextFollowingData)
        return;
    
    //[sneakerArray removeAllObjects];
    //[sneakerCollectionView reloadData];
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"GetClosetDetailByClosetID_FollowerList",
                                 //@"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"closetid" : self.closetid,
                                 @"Page" : @(followingListOffset)};
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
                [followingArray addObjectsFromArray:responseObject[@"alldata"]];
                
                [closetCollectionView reloadData];
                
                followingListOffset = followingListOffset + 1;
                
                totalFollowingPageCount = [responseObject[@"totalpage"] integerValue];
                
                if([responseObject[@"alldata"] count]==0 || followingListOffset >= totalFollowingPageCount)
                {
                    loadNextFollowingData = NO;
                }
                else
                {
                    loadNextFollowingData = YES;
                }
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"unable_load_data_alert", nil)];
            }
            
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
    if(sneakerTabBtn.selected)
    {
        return CGSizeMake(collectionViewWidthForSneakerList, collectionViewHeightForSneakerList);
    }
    else
    {
        return CGSizeMake(collectionViewWidthForFollowingList, collectionViewHeightForFollowingList);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(sneakerTabBtn.selected)
    {
        return [sneakerArray count];
    }
    else
    {
        return [followingArray count];
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(sneakerTabBtn.selected)
    {
        NSDictionary *dict = [sneakerArray objectAtIndex:indexPath.row];
        
        NSString *CellIdentifier = @"sneakerCell";
        
        if([dict[@"status"] integerValue] != 1)
        {
            CellIdentifier = @"sneakerCell1";
        }
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        
        UIImageView *sneakerThumbImageView = (UIImageView *)[cell.contentView viewWithTag:10];
        UILabel *sneakerPriceLbl = (UILabel *)[cell.contentView viewWithTag:11];
        
        /*sneakerThumbImageView.layer.borderWidth = 1.0;
        sneakerThumbImageView.layer.borderColor = [UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0].CGColor;*/
        sneakerThumbImageView.image = nil;
        
        
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
        
        
        if([dict[@"status"] integerValue] != 1)
        {
            UILabel *sneakerStatusLbl = (UILabel *)[cell.contentView viewWithTag:12];
            
            switch ([dict[@"status"] integerValue])
            {
                case SNEAKER_STATUS_IN_TRADE:
                {
                    sneakerStatusLbl.text = @"In Trade";
                    break;
                }
                case SNEAKER_STATUS_TRADED:
                {
                    sneakerStatusLbl.text = @"Traded";
                    break;
                }
                case SNEAKER_STATUS_IN_SALE:
                {
                    sneakerStatusLbl.text = @"In Sale";
                    break;
                }
                case SNEAKER_STATUS_SOLD:
                {
                    sneakerStatusLbl.text = @"Sold";
                    break;
                }
                    
                default:
                    break;
            }
        }
        
        
        if(!isLoadingData && indexPath.row==[sneakerArray count]-1 && loadNextSneakerData)
        {
            [self loadSneakerListFromWebserver];
        }
        
        
        return cell;
    }
    else
    {
        NSString *CellIdentifier = @"followerUserCell";
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        
        UIImageView *thumbImageView = (UIImageView *)[cell.contentView viewWithTag:10];
        UILabel *usernameLbl = (UILabel *)[cell.contentView viewWithTag:11];
        
        thumbImageView.layer.cornerRadius = thumbImageView.frame.size.width/2.0;
        thumbImageView.layer.masksToBounds = YES;
        thumbImageView.image = nil;
        
        
        NSDictionary *dict = [followingArray objectAtIndex:indexPath.row];
        
        
        usernameLbl.text = dict[@"username"];
        
        
        __block UIImageView *blockThumbImage = thumbImageView;
        
        /*[thumbImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dict[@"image"]]] placeholderImage:[UIImage imageNamed:@"default_user"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             blockThumbImage.image = image;
             
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             
         }];*/
        
        [thumbImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"image"]] placeholderImage:[UIImage imageNamed:@"default_user"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            blockThumbImage.image = image;
        }];
        
        if(!isLoadingData && indexPath.row==[followingArray count]-1 && loadNextFollowingData)
        {
            [self loadFollowingListFromWebserver];
        }
        
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(sneakerTabBtn.selected)
    {
        [self performSegueWithIdentifier:@"ClosetDetailVcToSneakerDetailVc" sender:[sneakerArray objectAtIndex:indexPath.row]];
    }
    else
    {
        [self performSegueWithIdentifier:@"ClosetDetailVcToPublicProfileVc" sender:([followingArray objectAtIndex:indexPath.row][@"userid"])];
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
    
    if([segue.identifier isEqualToString:@"ClosetDetailVcToSneakerDetailVc"])
    {
        SneakerDetailViewController *sneakerDetailVc = (SneakerDetailViewController *)segue.destinationViewController;
        sneakerDetailVc.sneakerInfoDict = [[NSDictionary alloc] initWithDictionary:sender];
    }
    else if([segue.identifier isEqualToString:@"ClosetDetailVcToPublicProfileVc"])
    {
        PublicProfileViewController *publicProfileVc = (PublicProfileViewController *)segue.destinationViewController;
        publicProfileVc.userid = [NSString stringWithFormat:@"%@", sender];
    }
}


@end
