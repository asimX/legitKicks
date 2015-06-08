//
//  ReviewListViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 02/04/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "ReviewListViewController.h"
#import "ReviewListTableViewCell.h"

@interface ReviewListViewController ()
{
    NSMutableArray *reviewListArray;
    
    BOOL loadNextReviewListData;
    NSInteger totalReviewListPageCount;
    NSInteger ReviewListOffset;
    NSInteger dataLimit;
    BOOL isLoadingData;
}
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation ReviewListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Reviews";
    
    self.offscreenCells = [NSMutableDictionary dictionary];
    
    [self setBackButtonToNavigationBar];
    
    reviewListArray = [NSMutableArray array];
    
    loadNextReviewListData = YES;
    
    [self loadReviewListFromWebserver];
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


-(void)loadReviewListFromWebserver
{
    if(isLoadingData || !loadNextReviewListData)
        return;
    
    isLoadingData = YES;
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"getuserreview",
                                 @"userid" : _userDict[@"userid"],
                                 @"Page" : @(ReviewListOffset)};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:GET_REVIEW_LIST_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [reviewListArray addObjectsFromArray:responseObject[@"alldata"]];
                
                [reviewTable reloadData];
                
                ReviewListOffset = ReviewListOffset + 1;
                
                totalReviewListPageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || ReviewListOffset >= totalReviewListPageCount)
                {
                    loadNextReviewListData = NO;
                }
                else
                {
                    loadNextReviewListData = YES;
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
    return [reviewListArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ReviewListTableViewCell *cell = [self.offscreenCells objectForKey:@"ReviewListCell"];
    if (!cell && cell.tag!=-1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewListCell"];
        cell.tag = -1;
        [self.offscreenCells setObject:cell forKey:@"ReviewListCell"];
    }
    
    
    cell.usernameLbl.text = [reviewListArray objectAtIndex:indexPath.row][@"buyername"];
    cell.reviewDescLbl.text = [reviewListArray objectAtIndex:indexPath.row][@"review"];
    cell.reviewDateLbl.text = [reviewListArray objectAtIndex:indexPath.row][@"date"];
    cell.reviewDescLbl.preferredMaxLayoutWidth = self.view.bounds.size.width - cell.reviewDescLbl.frame.origin.x - cell.reviewDescLbl.frame.origin.x;
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    //height += 1;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(!isLoadingData && indexPath.row==[reviewListArray count]-1 && loadNextReviewListData)
    {
        [self loadReviewListFromWebserver];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    
    NSDate *date = [formatter dateFromString:[reviewListArray objectAtIndex:indexPath.row][@"date"]];
    
    [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    
    
    ReviewListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewListCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.usernameLbl.text = [reviewListArray objectAtIndex:indexPath.row][@"buyername"];
    cell.reviewDescLbl.text = [reviewListArray objectAtIndex:indexPath.row][@"review"];
    cell.reviewDateLbl.text = [formatter stringFromDate:date];
    
    cell.ratingView.rating = [[reviewListArray objectAtIndex:indexPath.row][@"rate"] floatValue];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
