//
//  ClosetsListingViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 10/08/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "ClosetsListingViewController.h"
#import "UIImageView+WebCache.h"

@interface ClosetsListingViewController ()
{
    BOOL loadNextRandomClosetsList;
    BOOL loadNextRecentClosetsList;
    BOOL loadNextPopularClosetsList;
    BOOL loadNextFollowingClosetsList;
    
    
    NSInteger totalRandomClosetsPageCount;
    NSInteger totalRecentClosetsPageCount;
    NSInteger totalPopularClosetsPageCount;
    NSInteger totalFollowingClosetsPageCount;
    
    NSInteger randomClosetsOffset;
    NSInteger recentClosetsOffset;
    NSInteger popularClosetsOffset;
    NSInteger followingClosetsOffset;
    NSInteger dataLimit;
    
    BOOL isLoadingData;
    
    NSInteger randomClosetApiCount;
}

@end

@implementation ClosetsListingViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"closets", nil);
    
    /*[closetTypeSegmentControl setTitle:NSLocalizedString(@"recent", nil) forSegmentAtIndex:0];
    [closetTypeSegmentControl setTitle:NSLocalizedString(@"popular", nil) forSegmentAtIndex:1];
    [closetTypeSegmentControl setTitle:NSLocalizedString(@"following", nil) forSegmentAtIndex:2];
    [closetTypeSegmentControl setTitle:NSLocalizedString(@"random", nil) forSegmentAtIndex:3];
    
    self.navigationController.navigationBarHidden = NO;*/
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    randomClosetArray = [[NSMutableArray alloc] init];
    recentClosetArray = [[NSMutableArray alloc] init];
    popularClosetArray = [[NSMutableArray alloc] init];
    followingClosetArray = [[NSMutableArray alloc] init];
}


-(void)loadViewFromStart
{
    loadNextRandomClosetsList = YES;
    loadNextRecentClosetsList = YES;
    loadNextPopularClosetsList = YES;
    loadNextFollowingClosetsList = YES;
    
    randomClosetsOffset = 0;
    recentClosetsOffset = 0;
    popularClosetsOffset = 0;
    followingClosetsOffset = 0;
    randomClosetApiCount = 0;
    
    dataLimit = 20;
    
    [randomClosetArray removeAllObjects];
    [recentClosetArray removeAllObjects];
    [popularClosetArray removeAllObjects];
    [followingClosetArray removeAllObjects];
    
    [self closetTypeSegmentControlValueChanged:nil];
}


-(IBAction)closetTypeSegmentControlValueChanged:(id)sender
{
    if(_isRandomClosets)
    {
        randomClosetsOffset = 0;
        
        //[randomClosetArray removeAllObjects];
        
        closetArray = [[NSMutableArray alloc] initWithArray:randomClosetArray];
        
        [closetTableview setContentOffset:CGPointMake(0, 0)];
        
        [closetTableview reloadData];
        
        //if([closetArray count]==0)
        {
            [self loadRandomClosetsListFromWebserver];
        }
    }
    else if(_isRecentClosets)
    {
        closetArray = [[NSMutableArray alloc] initWithArray:recentClosetArray];
        
        [closetTableview setContentOffset:CGPointMake(0, 0)];
        
        [closetTableview reloadData];
        
        if([closetArray count]==0)
        {
            [self loadRecentClosetsListFromWebserver];
        }
    }
    else if(_isPopularClosets)
    {
        closetArray = [[NSMutableArray alloc] initWithArray:popularClosetArray];
        
        [closetTableview setContentOffset:CGPointMake(0, 0)];
        
        [closetTableview reloadData];
        
        if([closetArray count]==0)
        {
            [self loadPopularClosetsListFromWebserver];
        }
    }
    else if(_isFollowingClosets)
    {
        closetArray = [[NSMutableArray alloc] initWithArray:followingClosetArray];
        
        [closetTableview setContentOffset:CGPointMake(0, 0)];
        
        [closetTableview reloadData];
        
        if([closetArray count]==0)
        {
            [self loadFollowingClosetsListFromWebserver];
        }
    }
}


-(void)loadRandomClosetsListFromWebserver
{
    if(isLoadingData /*|| !loadNextRandomClosetsList*/)
        return;
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"RandomCloset",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"Page" : @(randomClosetsOffset)};
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
                [randomClosetArray removeAllObjects];
                [randomClosetArray addObjectsFromArray:responseObject[@"alldata"]];
                
                closetArray = [[NSMutableArray alloc] initWithArray:randomClosetArray];
                
                [closetTableview reloadData];
                
                randomClosetsOffset = randomClosetsOffset + 1;
                
                totalRandomClosetsPageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || randomClosetsOffset >= totalRandomClosetsPageCount)
                {
                    if(randomClosetApiCount<4)
                    {
                        randomClosetApiCount = randomClosetApiCount + 1;
                        [self loadRandomClosetsListFromWebserver];
                    }
                    
                    loadNextRandomClosetsList = NO;
                }
                else
                {
                    randomClosetApiCount = 0;
                    loadNextRandomClosetsList = YES;
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


-(void)loadRecentClosetsListFromWebserver
{
    if(isLoadingData || !loadNextRecentClosetsList)
        return;
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"RecentUpdateCloset",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"Page" : @(recentClosetsOffset)};
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
                [recentClosetArray addObjectsFromArray:responseObject[@"alldata"]];
                
                closetArray = [[NSMutableArray alloc] initWithArray:recentClosetArray];
                
                [closetTableview reloadData];
                
                recentClosetsOffset = recentClosetsOffset + 1;
                
                totalRecentClosetsPageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || recentClosetsOffset >= totalRecentClosetsPageCount)
                {
                    loadNextRecentClosetsList = NO;
                }
                else
                {
                    loadNextRecentClosetsList = YES;
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

-(void)loadPopularClosetsListFromWebserver
{
    if(isLoadingData || !loadNextPopularClosetsList)
        return;
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"MostPopularCloset",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"Page" : @(popularClosetsOffset)};
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
                [popularClosetArray addObjectsFromArray:responseObject[@"alldata"]];
                
                closetArray = [[NSMutableArray alloc] initWithArray:popularClosetArray];
                
                [closetTableview reloadData];
                
                popularClosetsOffset = popularClosetsOffset + 1;
                
                totalPopularClosetsPageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || popularClosetsOffset >= totalPopularClosetsPageCount)
                {
                    loadNextPopularClosetsList = NO;
                }
                else
                {
                    loadNextPopularClosetsList = YES;
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


-(void)loadFollowingClosetsListFromWebserver
{
    if(isLoadingData || !loadNextFollowingClosetsList)
        return;
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"FollowingClosetList",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"Page" : @(followingClosetsOffset)};
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
                [followingClosetArray addObjectsFromArray:responseObject[@"alldata"]];
                
                closetArray = [[NSMutableArray alloc] initWithArray:followingClosetArray];
                
                [closetTableview reloadData];
                
                followingClosetsOffset = followingClosetsOffset + 1;
                
                totalFollowingClosetsPageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || followingClosetsOffset >= totalFollowingClosetsPageCount)
                {
                    loadNextFollowingClosetsList = NO;
                }
                else
                {
                    loadNextFollowingClosetsList = YES;
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



#pragma mark Tableview delegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [closetArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"closetCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UIImageView *profileImageView = (UIImageView *)[cell.contentView viewWithTag:10];
    UILabel *closetNameLbl = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *usernameLbl = (UILabel *)[cell.contentView viewWithTag:12];
    UIImageView *heartImageView = (UIImageView *)[cell.contentView viewWithTag:13];
    UILabel *followingCountLbl = (UILabel *)[cell.contentView viewWithTag:14];
    
    
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2.0;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.image = nil;
    
    NSDictionary *dict = [closetArray objectAtIndex:indexPath.row];
    
    
    __block UIImageView *blockThumbImage = profileImageView;
    
    /*[profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dict[@"closetprofileimage"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
     blockThumbImage.image = image;
     
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
     
     }];*/
    
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"closetprofileimage"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        blockThumbImage.image = image;
    }];
    
    
    closetNameLbl.text = dict[@"closetname"];
    usernameLbl.text = dict[@"username"];
    followingCountLbl.text = [NSString stringWithFormat:@"%@", dict[@"followers"]];
    
    if([dict[@"isfollow"] integerValue]==1 || closetTypeSegmentControl.selectedSegmentIndex==2)
    {
        heartImageView.highlighted = YES;
    }
    else
    {
        heartImageView.highlighted = NO;
    }
    
    
    if(!isLoadingData && indexPath.row==[closetArray count]-1)
    {
        /*if(forSaleTabBtn.selected && loadNextSneakerForSaleData)
         {
         [self loadSneakerForSaleDataFromWebserver];
         }
         else if(forTradeTabBtn.selected && loadNextSneakerForTradeData)
         {
         [self loadSneakerForTradeDataFromWebserver];
         }*/
        
        if(_isRandomClosets)
        {
            
        }
        else if(_isRecentClosets)
        {
            
            [self loadRecentClosetsListFromWebserver];
        }
        else if(_isPopularClosets)
        {
            [self loadPopularClosetsListFromWebserver];
        }
        else if(_isFollowingClosets)
        {
            [self loadFollowingClosetsListFromWebserver];
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_delegate && [_delegate respondsToSelector:@selector(closetSelectedWithDict:viewController:)])
    {
        [_delegate closetSelectedWithDict:[closetArray objectAtIndex:indexPath.row] viewController:self];
    }
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
