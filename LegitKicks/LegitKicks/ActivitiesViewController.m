//
//  ActivitiesViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 07/02/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "ActivitiesViewController.h"
#import "MFSideMenu.h"
//#import "UIImageView+AFNetworking.h"
#import "TradeRequestDetailViewController.h"
#import "SellRequestDetailViewController.h"
#import "AskQuestionViewController.h"
#import "UIImageView+WebCache.h"

@interface ActivitiesViewController ()
{
    BOOL loadNextTradeActivitiesList;
    BOOL loadNextSellActivitiesList;
    BOOL loadNextBuyActivitiesList;
    BOOL loadNextQuestionActivitiesList;
    
    
    NSInteger totalTradeActivitiesPageCount;
    NSInteger totalSellActivitiesPageCount;
    NSInteger totalBuyActivitiesPageCount;
    NSInteger totalQuestionActivitiesPageCount;
    
    NSInteger tradeActivitiesOffset;
    NSInteger sellActivitiesOffset;
    NSInteger buyActivitiesOffset;
    NSInteger questionActivitiesOffset;
    NSInteger dataLimit;
    
    BOOL isLoadingData;
}

@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation ActivitiesViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"activities", nil);
    
    [activityTypeSegmentControl setTitle:NSLocalizedString(@"trade", nil) forSegmentAtIndex:0];
    [activityTypeSegmentControl setTitle:NSLocalizedString(@"sell", nil) forSegmentAtIndex:1];
    [activityTypeSegmentControl setTitle:NSLocalizedString(@"buy", nil) forSegmentAtIndex:2];
    [activityTypeSegmentControl setTitle:NSLocalizedString(@"questions", nil) forSegmentAtIndex:3];
    
    self.navigationController.navigationBarHidden = NO;
    
    
    loadNextTradeActivitiesList = YES;
    loadNextSellActivitiesList = YES;
    loadNextBuyActivitiesList = YES;
    loadNextQuestionActivitiesList = YES;
    
    tradeActivitiesOffset = 0;
    sellActivitiesOffset = 0;
    buyActivitiesOffset = 0;
    questionActivitiesOffset = 0;
    
    dataLimit = 20;
    
    [tradeActivityArray removeAllObjects];
    [sellActivityArray removeAllObjects];
    [buyActivityArray removeAllObjects];
    [questionActivityArray removeAllObjects];
    
    [self activityTypeSegmentControlValueChanged:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMenuButtonToNavigationBar];
    [self setRefreshButtonToNavigationBar];
    
    self.offscreenCells = [NSMutableDictionary dictionary];
    
    tradeActivityArray = [[NSMutableArray alloc] init];
    sellActivityArray = [[NSMutableArray alloc] init];
    buyActivityArray = [[NSMutableArray alloc] init];
    questionActivityArray = [[NSMutableArray alloc] init];
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
    
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, menuItem, nil]];
    
}

-(IBAction)menuBtnClicked:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}


#pragma mark Set Edit button to Navigationbar

-(void)setRefreshButtonToNavigationBar
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(0, 0, 44, 44);;
    [editButton addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [editButton setImage:[UIImage imageNamed:@"refresh_icon"] forState:UIControlStateNormal];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightItem, nil]];
    
}

-(void)refreshButtonPressed
{
    if(activityTypeSegmentControl.selectedSegmentIndex == 0)
    {
        [tradeActivityArray removeAllObjects];
        tradeActivitiesOffset = 0;
        loadNextTradeActivitiesList = YES;
        
        activityArray = [[NSMutableArray alloc] initWithArray:tradeActivityArray];
        
        [activityTableview setContentOffset:CGPointMake(0, 0)];
        
        [activityTableview reloadData];
        
        if([activityArray count]==0)
        {
            [self loadTradeActivitiesListFromWebserver];
        }
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 1)
    {
        [sellActivityArray removeAllObjects];
        sellActivitiesOffset = 0;
        loadNextSellActivitiesList = YES;
        
        activityArray = [[NSMutableArray alloc] initWithArray:sellActivityArray];
        
        [activityTableview setContentOffset:CGPointMake(0, 0)];
        
        [activityTableview reloadData];
        
        if([activityArray count]==0)
        {
            [self loadSellActivitiesListFromWebserver];
        }
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 2)
    {
        [buyActivityArray removeAllObjects];
        buyActivitiesOffset = 0;
        loadNextBuyActivitiesList = YES;
        
        activityArray = [[NSMutableArray alloc] initWithArray:sellActivityArray];
        
        [activityTableview setContentOffset:CGPointMake(0, 0)];
        
        [activityTableview reloadData];
        
        if([activityArray count]==0)
        {
            [self loadBuyActivitiesListFromWebserver];
        }
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 3)
    {
        [questionActivityArray removeAllObjects];
        questionActivitiesOffset = 0;
        loadNextQuestionActivitiesList = YES;
        
        activityArray = [[NSMutableArray alloc] initWithArray:questionActivityArray];
        
        [activityTableview setContentOffset:CGPointMake(0, 0)];
        
        [activityTableview reloadData];
        
        if([activityArray count]==0)
        {
            [self loadQuestionActivitiesListFromWebserver];
        }
    }
}



-(IBAction)activityTypeSegmentControlValueChanged:(id)sender
{
    if(activityTypeSegmentControl.selectedSegmentIndex == 0)
    {
        activityArray = [[NSMutableArray alloc] initWithArray:tradeActivityArray];
        
        [activityTableview setContentOffset:CGPointMake(0, 0)];
        
        [activityTableview reloadData];
        
        if([activityArray count]==0)
        {
            [self loadTradeActivitiesListFromWebserver];
        }
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 1)
    {
        activityArray = [[NSMutableArray alloc] initWithArray:sellActivityArray];
        
        [activityTableview setContentOffset:CGPointMake(0, 0)];
        
        [activityTableview reloadData];
        
        if([activityArray count]==0)
        {
            [self loadSellActivitiesListFromWebserver];
        }
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 2)
    {
        activityArray = [[NSMutableArray alloc] initWithArray:buyActivityArray];
        
        [activityTableview setContentOffset:CGPointMake(0, 0)];
        
        [activityTableview reloadData];
        
        if([activityArray count]==0)
        {
            [self loadBuyActivitiesListFromWebserver];
        }
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 3)
    {
        activityArray = [[NSMutableArray alloc] initWithArray:questionActivityArray];
        
        [activityTableview setContentOffset:CGPointMake(0, 0)];
        
        [activityTableview reloadData];
        
        if([activityArray count]==0)
        {
            [self loadQuestionActivitiesListFromWebserver];
        }
    }
}



-(void)loadTradeActivitiesListFromWebserver
{
    if(isLoadingData || !loadNextTradeActivitiesList)
        return;
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"gettraderequest",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"Page" : @(tradeActivitiesOffset)};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:GET_TRADE_REQUEST_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [tradeActivityArray addObjectsFromArray:responseObject[@"alldata"]];
                
                activityArray = [[NSMutableArray alloc] initWithArray:tradeActivityArray];
                
                [activityTableview reloadData];
                
                tradeActivitiesOffset = tradeActivitiesOffset + 1;
                
                totalTradeActivitiesPageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || tradeActivitiesOffset >= totalTradeActivitiesPageCount)
                {
                    loadNextTradeActivitiesList = NO;
                }
                else
                {
                    loadNextTradeActivitiesList = YES;
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

-(void)loadSellActivitiesListFromWebserver
{
    if(isLoadingData || !loadNextSellActivitiesList)
        return;
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"getsellrequest",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"Page" : @(sellActivitiesOffset)};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:GET_SALE_REQUEST_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [sellActivityArray addObjectsFromArray:responseObject[@"alldata"]];
                
                activityArray = [[NSMutableArray alloc] initWithArray:sellActivityArray];
                
                [activityTableview reloadData];
                
                sellActivitiesOffset = sellActivitiesOffset + 1;
                
                totalSellActivitiesPageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || sellActivitiesOffset >= totalSellActivitiesPageCount)
                {
                    loadNextSellActivitiesList = NO;
                }
                else
                {
                    loadNextSellActivitiesList = YES;
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


-(void)loadBuyActivitiesListFromWebserver
{
    if(isLoadingData || !loadNextBuyActivitiesList)
        return;
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"getsellrequest",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"Page" : @(buyActivitiesOffset)};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:GET_BUY_REQUEST_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [buyActivityArray addObjectsFromArray:responseObject[@"alldata"]];
                
                activityArray = [[NSMutableArray alloc] initWithArray:buyActivityArray];
                
                [activityTableview reloadData];
                
                buyActivitiesOffset = buyActivitiesOffset + 1;
                
                totalBuyActivitiesPageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || buyActivitiesOffset >= totalBuyActivitiesPageCount)
                {
                    loadNextBuyActivitiesList = NO;
                }
                else
                {
                    loadNextBuyActivitiesList = YES;
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


-(void)loadQuestionActivitiesListFromWebserver
{
    if(isLoadingData || !loadNextQuestionActivitiesList)
        return;
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"getconversationactivity",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"Page" : @(questionActivitiesOffset)};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:GET_CONVERSATION_ACTIVITY_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [questionActivityArray addObjectsFromArray:responseObject[@"alldata"]];
                
                activityArray = [[NSMutableArray alloc] initWithArray:questionActivityArray];
                
                [activityTableview reloadData];
                
                questionActivitiesOffset = questionActivitiesOffset + 1;
                
                totalQuestionActivitiesPageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || questionActivitiesOffset >= totalQuestionActivitiesPageCount)
                {
                    loadNextQuestionActivitiesList = NO;
                }
                else
                {
                    loadNextQuestionActivitiesList = YES;
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
    return [activityArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(activityTypeSegmentControl.selectedSegmentIndex == 0)
    {
        UITableViewCell *cell = [self.offscreenCells objectForKey:@"sneakerCell"];
        if (!cell && cell.tag!=-1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"sneakerCell"];
            cell.tag = -1;
            [self.offscreenCells setObject:cell forKey:@"sneakerCell"];
        }
        
        
        NSDictionary *dict = [activityArray objectAtIndex:indexPath.row];
        
        UILabel *requestDescLbl = (UILabel *)[cell.contentView viewWithTag:11];
        UILabel *timeLbl = (UILabel *)[cell.contentView viewWithTag:12];
        
        requestDescLbl.attributedText = [self getFormattedStringForTradeRequestFromRequestDict:dict];
        timeLbl.text = dict[@"buyerrequesttime"];
        
        requestDescLbl.preferredMaxLayoutWidth = activityTableview.frame.size.width - 68.0;
        
        //[cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        // Get the actual height required for the cell
        CGFloat height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //height += 1;
        
        if(height<90.0)
        {
            return 90.0;
        }
        
        return height;
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 1 || activityTypeSegmentControl.selectedSegmentIndex == 2)
    {
        UITableViewCell *cell = [self.offscreenCells objectForKey:@"sneakerCell"];
        if (!cell && cell.tag!=-1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"sneakerCell"];
            cell.tag = -1;
            [self.offscreenCells setObject:cell forKey:@"sneakerCell"];
        }
        
        
        NSDictionary *dict = [activityArray objectAtIndex:indexPath.row];
        
        UILabel *requestDescLbl = (UILabel *)[cell.contentView viewWithTag:11];
        UILabel *timeLbl = (UILabel *)[cell.contentView viewWithTag:12];
        
        requestDescLbl.attributedText = [self getFormattedStringForSaleRequestFromRequestDict:dict];
        timeLbl.text = dict[@"buyerrequesttime"];
        
        requestDescLbl.preferredMaxLayoutWidth = activityTableview.frame.size.width - 68.0;
        
        //[cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        // Get the actual height required for the cell
        CGFloat height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //height += 1;
        
        if(height<90.0)
        {
            return 90.0;
        }
        
        return height;
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 3)
    {
        UITableViewCell *cell = [self.offscreenCells objectForKey:@"conversationActivityCell"];
        if (!cell && cell.tag!=-1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"conversationActivityCell"];
            cell.tag = -1;
            [self.offscreenCells setObject:cell forKey:@"conversationActivityCell"];
        }
        
        
        NSDictionary *dict = [activityArray objectAtIndex:indexPath.row];
        
        UILabel *sneakerNameLbl = (UILabel *)[cell.contentView viewWithTag:11];
        UILabel *timeLbl = (UILabel *)[cell.contentView viewWithTag:12];
        UILabel *conversationWithLbl = (UILabel *)[cell.contentView viewWithTag:13];
        UILabel *msgDescLbl = (UILabel *)[cell.contentView viewWithTag:14];
        
        sneakerNameLbl.text = dict[@"sellersneakername"];
        timeLbl.text = dict[@"conversation_time"];
        
        NSString *withUsername = dict[@"sender_uname"];
        if([[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]] isEqualToString:[NSString stringWithFormat:@"%@", dict[@"senderid"]]])
        {
            withUsername = dict[@"reaciever_uname"];
        }
        
        conversationWithLbl.text = [NSString stringWithFormat:@"With: %@", withUsername];
        msgDescLbl.text = dict[@"conversation_desc"];
        
        sneakerNameLbl.preferredMaxLayoutWidth = activityTableview.frame.size.width - (sneakerNameLbl.frame.origin.x+5.0);
        conversationWithLbl.preferredMaxLayoutWidth = activityTableview.frame.size.width - (conversationWithLbl.frame.origin.x+5.0);
        msgDescLbl.preferredMaxLayoutWidth = activityTableview.frame.size.width - (msgDescLbl.frame.origin.x+5.0);
        timeLbl.preferredMaxLayoutWidth = activityTableview.frame.size.width - (timeLbl.frame.origin.x+5.0);
        
        //[cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        // Get the actual height required for the cell
        CGFloat height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //height += 1;
        
        if(height<97.0)
        {
            return 97.0;
        }
        
        return height;
    }
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(!isLoadingData && indexPath.row==[activityArray count]-1)
    {
        if(activityTypeSegmentControl.selectedSegmentIndex == 0)
        {
            [self loadTradeActivitiesListFromWebserver];
        }
        else if(activityTypeSegmentControl.selectedSegmentIndex == 1)
        {
            [self loadSellActivitiesListFromWebserver];
        }
        else if(activityTypeSegmentControl.selectedSegmentIndex == 2)
        {
            [self loadBuyActivitiesListFromWebserver];
        }
        else if(activityTypeSegmentControl.selectedSegmentIndex == 3)
        {
            [self loadQuestionActivitiesListFromWebserver];
        }
    }
    
    
    if(activityTypeSegmentControl.selectedSegmentIndex == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sneakerCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIImageView *profileImageView = (UIImageView *)[cell.contentView viewWithTag:10];
        UILabel *requestDescLbl = (UILabel *)[cell.contentView viewWithTag:11];
        UILabel *timeLbl = (UILabel *)[cell.contentView viewWithTag:12];
        
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2.0;
        profileImageView.layer.masksToBounds = YES;
        profileImageView.image = nil;
        
        NSDictionary *dict = [activityArray objectAtIndex:indexPath.row];
        
        
        __block UIImageView *blockThumbImage = profileImageView;
        
        /*[profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self getBuyerOrSellerProfileImageUrlForTradeRequestFromRequestDict:dict]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             blockThumbImage.image = image;
             
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             
         }];*/
        
        [profileImageView sd_setImageWithURL:[NSURL URLWithString:[self getBuyerOrSellerProfileImageUrlForTradeRequestFromRequestDict:dict]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            blockThumbImage.image = image;
        }];
        
        
        requestDescLbl.attributedText = [self getFormattedStringForTradeRequestFromRequestDict:dict];
        
        timeLbl.text = [self getFormattedDateTimeForTradeProcessFromRequestDict:dict];
        
        return cell;
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 1 || activityTypeSegmentControl.selectedSegmentIndex == 2)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sneakerCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIImageView *profileImageView = (UIImageView *)[cell.contentView viewWithTag:10];
        UILabel *requestDescLbl = (UILabel *)[cell.contentView viewWithTag:11];
        UILabel *timeLbl = (UILabel *)[cell.contentView viewWithTag:12];
        
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2.0;
        profileImageView.layer.masksToBounds = YES;
        profileImageView.image = nil;
        
        NSDictionary *dict = [activityArray objectAtIndex:indexPath.row];
        
        //NSString *porfileImageUrl = [self getBuyerOrSellerProfileImageUrlForSaleRequestFromRequestDict:dict];
        NSString *porfileImageUrl = dict[@"sellersneakerimage"];
        
        __block UIImageView *blockThumbImage = profileImageView;
        
        /*[profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:porfileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             blockThumbImage.image = image;
             
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             
         }];*/
        
        [profileImageView sd_setImageWithURL:[NSURL URLWithString:porfileImageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            blockThumbImage.image = image;
        }];
        
        
        requestDescLbl.attributedText = [self getFormattedStringForSaleRequestFromRequestDict:dict];
        
        timeLbl.text = [self getFormattedDateTimeForSaleProcessFromRequestDict:dict];
        
        return cell;
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 3)
    {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversationActivityCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIImageView *profileImageView = (UIImageView *)[cell.contentView viewWithTag:10];
        UILabel *sneakerNameLbl = (UILabel *)[cell.contentView viewWithTag:11];
        UILabel *timeLbl = (UILabel *)[cell.contentView viewWithTag:12];
        UILabel *conversationWithLbl = (UILabel *)[cell.contentView viewWithTag:13];
        UILabel *msgDescLbl = (UILabel *)[cell.contentView viewWithTag:14];
        
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2.0;
        profileImageView.layer.masksToBounds = YES;
        profileImageView.image = nil;
        
        NSDictionary *dict = [activityArray objectAtIndex:indexPath.row];
        
        
        __block UIImageView *blockThumbImage = profileImageView;
        
        /*[profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dict[@"sellersneakerimg"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             blockThumbImage.image = image;
             
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             
         }];*/
        
        [profileImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"sellersneakerimg"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            blockThumbImage.image = image;
        }];
        
        
        sneakerNameLbl.text = dict[@"sellersneakername"];
        
        NSString *withUsername = dict[@"sender_uname"];
        if([[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]] isEqualToString:[NSString stringWithFormat:@"%@", dict[@"senderid"]]])
        {
            withUsername = dict[@"reaciever_uname"];
        }
        
        conversationWithLbl.text = [NSString stringWithFormat:@"With: %@", withUsername];
        
        msgDescLbl.text = dict[@"conversation_desc"];
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        
        NSDate *date = [formatter dateFromString:dict[@"conversation_time"]];
        
        [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        
        timeLbl.text = [formatter stringFromDate:date];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(activityTypeSegmentControl.selectedSegmentIndex == 0)
    {
        [self performSegueWithIdentifier:@"ActivitiesVcToTradeRequestDetailVc" sender:[activityArray objectAtIndex:indexPath.row]];
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 1 || activityTypeSegmentControl.selectedSegmentIndex == 2)
    {
        [self performSegueWithIdentifier:@"ActivitiesVcToSaleRequestDetailVc" sender:[activityArray objectAtIndex:indexPath.row]];
    }
    else if(activityTypeSegmentControl.selectedSegmentIndex == 3)
    {
        NSDictionary *dict = [activityArray objectAtIndex:indexPath.row];
        
        NSString *userid = dict[@"senderid"];
        NSString *withUsername = dict[@"sender_uname"];
        NSString *userImage = dict[@"sender_uimg"];
        
        if([[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]] isEqualToString:[NSString stringWithFormat:@"%@", dict[@"senderid"]]])
        {
            userid = dict[@"recieverid"];
            withUsername = dict[@"reaciever_uname"];
            userImage = dict[@"reaciever_uimg"];
        }
        
        AskQuestionViewController *askQuestionVc = [self.storyboard instantiateViewControllerWithIdentifier:@"AskQuestionVc"];
        askQuestionVc.sneakerDict = @{@"sneakerid" : dict[@"sellersneakerid"],
                                      @"sneakername" : dict[@"sellersneakername"],
                                      @"picture" : @[dict[@"sellersneakerimg"]],
                                      @"userid" : userid,
                                      @"userimage" : withUsername,
                                      @"username" : userImage};
        
        [self.navigationController pushViewController:askQuestionVc animated:YES];
    }
    //id closetId = [activityArray objectAtIndex:indexPath.row][@"closetid"];
    //[self performSegueWithIdentifier:@"ClosetsVcToClosetDetailVc" sender:closetId];
}



#pragma mark -
#pragma mark - Common methods for Trade Activities

-(id)getFormattedDateTimeForTradeProcessFromRequestDict:(NSDictionary *)dict
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    
    NSString *dateStr =  @"";
    
    //fullStr = [NSString stringWithFormat:@"%@ has requested trade for %@ shoes.",dict[@"buyername"], dict[@"sellersneakername"]];
    
    switch ([dict[@"status"] integerValue])
    {
        case 1:
        {
            NSDate *date = [formatter dateFromString:dict[@"buyerrequesttime"]];
            
            [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
            [formatter setTimeZone:[NSTimeZone localTimeZone]];
            
            dateStr = [formatter stringFromDate:date];
            
            break;
        }
        case 2:
        {
            
            if(([dict[@"buyerreceivedtime"] length] > 0 && ![dict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([dict[@"sellerreceivedtime"] length] > 0 && ![dict[@"sellerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"]))
            {
                NSDate *buyerDate = [formatter dateFromString:dict[@"buyerreceivedtime"]];
                NSDate *sellerDate = [formatter dateFromString:dict[@"sellerreceivedtime"]];
                
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                
                NSComparisonResult result = [buyerDate compare:sellerDate];
                
                switch (result)
                {
                    case NSOrderedAscending:
                    {
                        dateStr = [formatter stringFromDate:sellerDate];
                        //NSLog(@"seller is in future from buyer");
                        break;
                    }
                    case NSOrderedDescending:
                    {
                        dateStr = [formatter stringFromDate:buyerDate];
                        //NSLog(@"seller is in past from buyer");
                        break;
                    }
                    case NSOrderedSame:
                    {
                        dateStr = [formatter stringFromDate:buyerDate];
                        //NSLog(@"seller is the same as buyer");
                        break;
                    }
                    default:
                    {
                        dateStr = [formatter stringFromDate:buyerDate];
                        //NSLog(@"erorr dates seller, buyer");
                        break;
                    }
                }
            }
            else if([dict[@"buyerreceivedtime"] length] > 0 && ![dict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                NSDate *date = [formatter dateFromString:dict[@"buyerreceivedtime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            else if([dict[@"sellerreceivedtime"] length] > 0 && ![dict[@"sellerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                NSDate *date = [formatter dateFromString:dict[@"sellerreceivedtime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            else if(([dict[@"buyersendtime"] length] > 0 && ![dict[@"buyersendtime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"]))
            {
                NSDate *buyerDate = [formatter dateFromString:dict[@"buyersendtime"]];
                NSDate *sellerDate = [formatter dateFromString:dict[@"sellersendtime"]];
                
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                
                NSComparisonResult result = [buyerDate compare:sellerDate];
                
                switch (result)
                {
                    case NSOrderedAscending:
                    {
                        dateStr = [formatter stringFromDate:sellerDate];
                        //NSLog(@"seller is in future from buyer");
                        break;
                    }
                    case NSOrderedDescending:
                    {
                        dateStr = [formatter stringFromDate:buyerDate];
                        //NSLog(@"seller is in past from buyer");
                        break;
                    }
                    case NSOrderedSame:
                    {
                        dateStr = [formatter stringFromDate:buyerDate];
                        //NSLog(@"seller is the same as buyer");
                        break;
                    }
                    default:
                    {
                        dateStr = [formatter stringFromDate:buyerDate];
                        //NSLog(@"erorr dates seller, buyer");
                        break;
                    }
                }
            }
            else if([dict[@"buyersendtime"] length] > 0 && ![dict[@"buyersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                NSDate *date = [formatter dateFromString:dict[@"buyersendtime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            else if([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                NSDate *date = [formatter dateFromString:dict[@"sellersendtime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            else if([dict[@"sellerresponseptime"] length] > 0 && ![dict[@"sellerresponseptime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                NSDate *date = [formatter dateFromString:dict[@"sellerresponseptime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            
            break;
        }
        case 3:
        {
            NSDate *date = [formatter dateFromString:dict[@"sellerresponseptime"]];
            
            [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
            [formatter setTimeZone:[NSTimeZone localTimeZone]];
            
            dateStr = [formatter stringFromDate:date];
            
            break;
        }
        case 4:
        {
            if(([dict[@"buyerreceivedtime"] length] > 0 && ![dict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([dict[@"sellerreceivedtime"] length] > 0 && ![dict[@"sellerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"]))
            {
                NSDate *date1 = [formatter dateFromString:dict[@"buyerreceivedtime"]];
                NSDate *date2 = [formatter dateFromString:dict[@"sellerreceivedtime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                if ([date1 compare:date2] == NSOrderedDescending)
                {
                    dateStr = [formatter stringFromDate:date1];
                    
                    NSLog(@"date1 is later than date2");
                }
                else if ([date1 compare:date2] == NSOrderedAscending)
                {
                    dateStr = [formatter stringFromDate:date2];
                    
                    NSLog(@"date1 is earlier than date2");
                }
                else
                {
                    dateStr = [formatter stringFromDate:date1];
                    
                    NSLog(@"dates are the same");
                }
            }
            
            break;
        }
            
        default:
            break;
    }
    
    return dateStr;
}


-(id)getFormattedStringForTradeRequestFromRequestDict:(NSDictionary *)dict
{
    NSString *fullStr;
    
    //fullStr = [NSString stringWithFormat:@"%@ has requested trade for %@ shoes.",dict[@"buyername"], dict[@"sellersneakername"]];
    
    switch ([dict[@"status"] integerValue])
    {
        case 1:
        {
            //MARK: Request made
            fullStr = [NSString stringWithFormat:@"%@ has requested trade for %@ shoes to %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
            
            break;
        }
        case 2:
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            
            if(([dict[@"buyerreceivedtime"] length] > 0 && ![dict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([dict[@"sellerreceivedtime"] length] > 0 && ![dict[@"sellerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"]))
            {
                NSDate *buyerDate = [formatter dateFromString:dict[@"buyerreceivedtime"]];
                NSDate *sellerDate = [formatter dateFromString:dict[@"sellerreceivedtime"]];
                
                NSComparisonResult result = [buyerDate compare:sellerDate];
                
                switch (result)
                {
                    case NSOrderedAscending:
                    {
                        fullStr = [NSString stringWithFormat:@"%@ has received shoes against %@ shoes from %@.",dict[@"sellername"], dict[@"sellersneakername"],dict[@"buyername"]];
                        //NSLog(@"seller is in future from buyer");
                        break;
                    }
                    case NSOrderedDescending:
                    {
                        fullStr = [NSString stringWithFormat:@"%@ has received shoes %@ shoes from %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
                        //NSLog(@"seller is in past from buyer");
                        break;
                    }
                    case NSOrderedSame:
                    {
                        fullStr = [NSString stringWithFormat:@"%@ has received shoes %@ shoes from %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
                        //NSLog(@"seller is the same as buyer");
                        break;
                    }
                    default:
                    {
                        fullStr = [NSString stringWithFormat:@"%@ has received shoes %@ shoes from %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
                        //NSLog(@"erorr dates seller, buyer");
                        break;
                    }
                }
            }
            else if([dict[@"buyerreceivedtime"] length] > 0 && ![dict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                //MARK: Buyer received shoes from seller
                fullStr = [NSString stringWithFormat:@"%@ has received shoes %@ shoes from %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
            }
            else if([dict[@"sellerreceivedtime"] length] > 0 && ![dict[@"sellerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                //MARK: Seller received shoes from buyer
                fullStr = [NSString stringWithFormat:@"%@ has received shoes against %@ shoes from %@.",dict[@"sellername"], dict[@"sellersneakername"],dict[@"buyername"]];
            }
            else if(([dict[@"buyersendtime"] length] > 0 && ![dict[@"buyersendtime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"]))
            {
                NSDate *buyerDate = [formatter dateFromString:dict[@"buyersendtime"]];
                NSDate *sellerDate = [formatter dateFromString:dict[@"sellersendtime"]];
                
                NSComparisonResult result = [buyerDate compare:sellerDate];
                
                switch (result)
                {
                    case NSOrderedAscending:
                    {
                        fullStr = [NSString stringWithFormat:@"%@ has sent %@ shoes to %@.",dict[@"sellername"], dict[@"sellersneakername"],dict[@"buyername"]];
                        //NSLog(@"seller is in future from buyer");
                        break;
                    }
                    case NSOrderedDescending:
                    {
                        fullStr = [NSString stringWithFormat:@"%@ has Sent shoes against %@ shoes to %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
                        //NSLog(@"seller is in past from buyer");
                        break;
                    }
                    case NSOrderedSame:
                    {
                        fullStr = [NSString stringWithFormat:@"%@ has Sent shoes against %@ shoes to %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
                        //NSLog(@"seller is the same as buyer");
                        break;
                    }
                    default:
                    {
                        fullStr = [NSString stringWithFormat:@"%@ has Sent shoes against %@ shoes to %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
                        //NSLog(@"erorr dates seller, buyer");
                        break;
                    }
                }
            }
            else if([dict[@"buyersendtime"] length] > 0 && ![dict[@"buyersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                //MARK: Buyer has sent shoes to seller
                fullStr = [NSString stringWithFormat:@"%@ has Sent shoes against %@ shoes to %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
            }
            else if([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                //MARK: seller has sent shoes to buyer
                fullStr = [NSString stringWithFormat:@"%@ has sent %@ shoes to %@.",dict[@"sellername"], dict[@"sellersneakername"],dict[@"buyername"]];
            }
            else
            {
                //MARK: Request accepted
                fullStr = [NSString stringWithFormat:@"%@ has accepted trade request for %@ shoes with %@.",dict[@"sellername"], dict[@"sellersneakername"],dict[@"buyername"]];
            }
            
            break;
        }
        case 3:
        {
            //MARK: Request rejected
            fullStr = [NSString stringWithFormat:@"%@ has rejected trade request for %@ shoes with %@.",dict[@"sellername"], dict[@"sellersneakername"],dict[@"buyername"]];
            
            break;
        }
        case 4:
        {
            //MARK: Request completed
            fullStr = [NSString stringWithFormat:@"%@ has successfully completed trade for %@ shoes with %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
            
            break;
        }
            
        default:
            break;
    }
    
    
    //NSString *tempStr = [NSString stringWithFormat:@"%@ has requested trade for %@ shoes.",dict[@"buyername"], dict[@"sellersneakername"]];
    
    NSRange buyerNameRange = [fullStr rangeOfString:dict[@"buyername"]];
    NSRange sneakerNameRange = [fullStr rangeOfString:dict[@"sellersneakername"]];
    NSRange sellerNameRange = [fullStr rangeOfString:dict[@"sellername"]];
    
    NSMutableAttributedString * finalStr = [[NSMutableAttributedString alloc] initWithString:fullStr];
    [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:[fullStr rangeOfString:fullStr]];
    if([dict[@"buyername"] length] > 0)
    {
        [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0] range:buyerNameRange];
    }
    [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0] range:sneakerNameRange];
    
    if([dict[@"sellername"] length] > 0)
    {
        [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0] range:sellerNameRange];
    }
    
    return finalStr;
}



-(id)getBuyerOrSellerProfileImageUrlForTradeRequestFromRequestDict:(NSDictionary *)dict
{
    NSString *urlStr = @"";
    
    //fullStr = [NSString stringWithFormat:@"%@ has requested trade for %@ shoes.",dict[@"buyername"], dict[@"sellersneakername"]];
    
    switch ([dict[@"status"] integerValue])
    {
        case 1:
        {
            //MARK: Request made
            urlStr = dict[@"buyerprofile"];
            
            break;
        }
        case 2:
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            
            if(([dict[@"buyerreceivedtime"] length] > 0 && ![dict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([dict[@"sellerreceivedtime"] length] > 0 && ![dict[@"sellerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"]))
            {
                NSDate *buyerDate = [formatter dateFromString:dict[@"buyerreceivedtime"]];
                NSDate *sellerDate = [formatter dateFromString:dict[@"sellerreceivedtime"]];
                
                NSComparisonResult result = [buyerDate compare:sellerDate];
                
                switch (result)
                {
                    case NSOrderedAscending:
                    {
                        urlStr = dict[@"sellerprofile"];
                        //NSLog(@"seller is in future from buyer");
                        break;
                    }
                    case NSOrderedDescending:
                    {
                        urlStr = dict[@"buyerprofile"];
                        //NSLog(@"seller is in past from buyer");
                        break;
                    }
                    case NSOrderedSame:
                    {
                        urlStr = dict[@"buyerprofile"];
                        //NSLog(@"seller is the same as buyer");
                        break;
                    }
                    default:
                    {
                        urlStr = dict[@"buyerprofile"];
                        //NSLog(@"erorr dates seller, buyer");
                        break;
                    }
                }
            }
            else if([dict[@"buyerreceivedtime"] length] > 0 && ![dict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                //MARK: Buyer received shoes from seller
                urlStr = dict[@"buyerprofile"];
            }
            else if([dict[@"sellerreceivedtime"] length] > 0 && ![dict[@"sellerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                //MARK: Seller received shoes from buyer
                urlStr = dict[@"sellerprofile"];
            }
            else if(([dict[@"buyersendtime"] length] > 0 && ![dict[@"buyersendtime"] isEqualToString:@"0000-00-00 00:00:00"]) && ([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"]))
            {
                NSDate *buyerDate = [formatter dateFromString:dict[@"buyersendtime"]];
                NSDate *sellerDate = [formatter dateFromString:dict[@"sellersendtime"]];
                
                NSComparisonResult result = [buyerDate compare:sellerDate];
                
                switch (result)
                {
                    case NSOrderedAscending:
                    {
                        urlStr = dict[@"sellerprofile"];
                        //NSLog(@"seller is in future from buyer");
                        break;
                    }
                    case NSOrderedDescending:
                    {
                        urlStr = dict[@"buyerprofile"];
                        //NSLog(@"seller is in past from buyer");
                        break;
                    }
                    case NSOrderedSame:
                    {
                        urlStr = dict[@"buyerprofile"];
                        //NSLog(@"seller is the same as buyer");
                        break;
                    }
                    default:
                    {
                        urlStr = dict[@"buyerprofile"];
                        //NSLog(@"erorr dates seller, buyer");
                        break;
                    }
                }
            }
            else if([dict[@"buyersendtime"] length] > 0 && ![dict[@"buyersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                //MARK: Buyer has sent shoes to seller
                urlStr = dict[@"buyerprofile"];
            }
            else if([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                //MARK: seller has sent shoes to buyer
                urlStr = dict[@"sellerprofile"];
            }
            else
            {
                //MARK: Request accepted
                urlStr = dict[@"buyerprofile"];
            }
            
            break;
        }
        case 3:
        {
            //MARK: Request rejected
            urlStr = dict[@"buyerprofile"];
            
            break;
        }
        case 4:
        {
            //MARK: Request completed
            urlStr = dict[@"buyerprofile"];
            
            break;
        }
            
        default:
            break;
    }
    
    return urlStr;
}



#pragma mark -
#pragma mark - Common methods for Sale Activities

-(id)getFormattedStringForSaleRequestFromRequestDict:(NSDictionary *)dict
{
    NSString *fullStr;
    
    //fullStr = [NSString stringWithFormat:@"%@ has requested trade for %@ shoes.",dict[@"buyername"], dict[@"sellersneakername"]];
    
    switch ([dict[@"status"] integerValue])
    {
        case 1:
        {
            if([dict[@"buyerreceivedtime"] length] > 0 && ![dict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                fullStr = [NSString stringWithFormat:@"%@ has received shoes %@ shoes from %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
            }
            else if([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                fullStr = [NSString stringWithFormat:@"%@ has sent %@ shoes to %@.",dict[@"sellername"], dict[@"sellersneakername"],dict[@"buyername"]];
            }
            else
            {
                fullStr = [NSString stringWithFormat:@"%@ has requested sale for %@ shoes to %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
            }
            
            break;
        }
        case 11:
        {
            fullStr = [NSString stringWithFormat:@"%@ has requested offer for %@ shoes to %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
            
            break;
        }
        case 12:
        {
            fullStr = [NSString stringWithFormat:@"%@ has requested counter offer for %@ shoes to %@.",dict[@"sellername"], dict[@"sellersneakername"],dict[@"buyername"]];
            
            break;
        }
        case 2:
        {
            if([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                fullStr = [NSString stringWithFormat:@"%@ has sent %@ shoes to %@.",dict[@"sellername"], dict[@"sellersneakername"],dict[@"buyername"]];
            }
            else if([dict[@"accept_reject_status"] integerValue] == 1)
            {
                fullStr = [NSString stringWithFormat:@"%@ has accepted offer request from %@ for %@ shoes.",dict[@"sellername"], dict[@"buyername"], dict[@"sellersneakername"]];
            }
            else if([dict[@"accept_reject_status"] integerValue] == 3)
            {
                fullStr = [NSString stringWithFormat:@"%@ has accepted counter offer request from %@ for %@ shoes.",dict[@"buyername"], dict[@"sellername"], dict[@"sellersneakername"]];
            }
            break;
        }
        case 3:
        {
            if([dict[@"accept_reject_status"] integerValue] == 2)
            {
                fullStr = [NSString stringWithFormat:@"%@ has rejected offer request from %@ for %@ shoes.", dict[@"sellername"], dict[@"buyername"], dict[@"sellersneakername"]];
            }
            else if([dict[@"accept_reject_status"] integerValue] == 4)
            {
                fullStr = [NSString stringWithFormat:@"%@ has rejected counter offer request from %@ for %@ shoes.", dict[@"buyername"], dict[@"sellername"], dict[@"sellersneakername"]];
            }
            else
            {
                fullStr = [NSString stringWithFormat:@"%@ has rejected sale request for %@ shoes with %@.",dict[@"sellername"], dict[@"sellersneakername"],dict[@"buyername"]];
            }
            
            break;
        }
        case 4:
        {
            //MARK: Request completed
            fullStr = [NSString stringWithFormat:@"%@ has successfully completed sale for %@ shoes with %@.",dict[@"buyername"], dict[@"sellersneakername"],dict[@"sellername"]];
            
            break;
        }
            
        default:
            break;
    }
    
    
    //NSString *tempStr = [NSString stringWithFormat:@"%@ has requested trade for %@ shoes.",dict[@"buyername"], dict[@"sellersneakername"]];
    
    NSRange buyerNameRange = [fullStr rangeOfString:dict[@"buyername"]];
    NSRange sneakerNameRange = [fullStr rangeOfString:dict[@"sellersneakername"]];
    NSRange sellerNameRange = [fullStr rangeOfString:dict[@"sellername"]];
    
    NSMutableAttributedString * finalStr = [[NSMutableAttributedString alloc] initWithString:fullStr];
    [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:[fullStr rangeOfString:fullStr]];
    if([dict[@"buyername"] length] > 0)
    {
        [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0] range:buyerNameRange];
    }
    [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0] range:sneakerNameRange];
    
    if([dict[@"sellername"] length] > 0)
    {
        [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:227.0/255.0 green:104.0/255.0 blue:106.0/255.0 alpha:1.0] range:sellerNameRange];
    }
    
    return finalStr;
}


-(id)getFormattedDateTimeForSaleProcessFromRequestDict:(NSDictionary *)dict
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    
    NSString *dateStr =  @"";
    
    //fullStr = [NSString stringWithFormat:@"%@ has requested trade for %@ shoes.",dict[@"buyername"], dict[@"sellersneakername"]];
    
    switch ([dict[@"status"] integerValue])
    {
        case 1:
        {
            if([dict[@"buyerreceivedtime"] length] > 0 && ![dict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                NSDate *date = [formatter dateFromString:dict[@"buyerreceivedtime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            else if([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                NSDate *date = [formatter dateFromString:dict[@"sellersendtime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            else
            {
                NSDate *date = [formatter dateFromString:dict[@"buyerrequesttime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            
            break;
        }
        case 11:
        {
            NSDate *date = [formatter dateFromString:dict[@"offerrequesttime"]];
            
            [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
            [formatter setTimeZone:[NSTimeZone localTimeZone]];
            
            dateStr = [formatter stringFromDate:date];
            
            break;
        }
        case 12:
        {
            NSDate *date = [formatter dateFromString:dict[@"counterofferrequesttime"]];
            
            [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
            [formatter setTimeZone:[NSTimeZone localTimeZone]];
            
            dateStr = [formatter stringFromDate:date];
            
            break;
        }
        case 2:
        {
            if([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                NSDate *date = [formatter dateFromString:dict[@"sellersendtime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            else if([dict[@"accept_reject_status"] integerValue] == 1)
            {
                NSDate *date = [formatter dateFromString:dict[@"offeractiontime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            else if([dict[@"accept_reject_status"] integerValue] == 3)
            {
                NSDate *date = [formatter dateFromString:dict[@"counterofferactiontime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            break;
        }
        case 3:
        {
            if([dict[@"accept_reject_status"] integerValue] == 2)
            {
                NSDate *date = [formatter dateFromString:dict[@"offeractiontime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            else if([dict[@"accept_reject_status"] integerValue] == 4)
            {
                NSDate *date = [formatter dateFromString:dict[@"counterofferactiontime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            else
            {
                NSDate *date = [formatter dateFromString:dict[@"sellerresponseptime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                dateStr = [formatter stringFromDate:date];
            }
            
            break;
        }
        case 4:
        {
            if([dict[@"buyerreceivedtime"] length] > 0 && ![dict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                NSDate *date = [formatter dateFromString:dict[@"buyerreceivedtime"]];
                
                [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                
                 dateStr = [formatter stringFromDate:date];
            }
            
            break;
        }
            
        default:
            break;
    }
    
    return dateStr;
}


-(id)getBuyerOrSellerProfileImageUrlForSaleRequestFromRequestDict:(NSDictionary *)dict
{
    NSString *urlStr = urlStr = dict[@"buyerprofile"];
    
    //fullStr = [NSString stringWithFormat:@"%@ has requested trade for %@ shoes.",dict[@"buyername"], dict[@"sellersneakername"]];
    
    switch ([dict[@"status"] integerValue])
    {
        case 1:
        {
            if([dict[@"buyerreceivedtime"] length] > 0 && ![dict[@"buyerreceivedtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                urlStr = dict[@"buyerprofile"];
            }
            else if([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                urlStr = dict[@"sellerprofile"];
            }
            else
            {
                urlStr = dict[@"buyerprofile"];
            }
            
            break;
        }
        case 11:
        {
            urlStr = dict[@"buyerprofile"];
            
            break;
        }
        case 12:
        {
            urlStr = dict[@"sellerprofile"];
            
            break;
        }
        case 2:
        {
            if([dict[@"sellersendtime"] length] > 0 && ![dict[@"sellersendtime"] isEqualToString:@"0000-00-00 00:00:00"])
            {
                urlStr = dict[@"sellerprofile"];
            }
            else if([dict[@"accept_reject_status"] integerValue] == 1)
            {
                urlStr = dict[@"sellerprofile"];
            }
            else if([dict[@"accept_reject_status"] integerValue] == 3)
            {
                urlStr = dict[@"buyerprofile"];
            }
            break;
        }
        case 3:
        {
            if([dict[@"accept_reject_status"] integerValue] == 2)
            {
                urlStr = dict[@"sellerprofile"];
            }
            else if([dict[@"accept_reject_status"] integerValue] == 4)
            {
                urlStr = dict[@"buyerprofile"];
            }
            else
            {
                urlStr = dict[@"sellerprofile"];
            }
            
            break;
        }
        case 4:
        {
            urlStr = dict[@"buyerprofile"];
            
            break;
        }
            
        default:
            break;
    }
    
    return urlStr;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ActivitiesVcToTradeRequestDetailVc"])
    {
        TradeRequestDetailViewController *requestDetailVc = (TradeRequestDetailViewController *)segue.destinationViewController;
        requestDetailVc.tradeDict = [[NSDictionary alloc] initWithDictionary:sender];
    }
    else if([segue.identifier isEqualToString:@"ActivitiesVcToSaleRequestDetailVc"])
    {
        SellRequestDetailViewController *requestDetailVc = (SellRequestDetailViewController *)segue.destinationViewController;
        requestDetailVc.saleDict = [[NSDictionary alloc] initWithDictionary:sender];
    }
}


@end
