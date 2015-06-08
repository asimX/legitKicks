//
//  SearchResultsViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 09/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "SearchResultsViewController.h"
//#import "UIImageView+AFNetworking.h"
#import "SneakerDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface SearchResultsViewController ()
{
    CGFloat collectionViewWidth;
    CGFloat collectionViewHeight;
    
    BOOL loadNextResultData;
    NSInteger totalPageCount;
    NSInteger resutltOffset;
    NSInteger dataLimit;
    BOOL isLoadingData;
    
}

@end

@implementation SearchResultsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.title = NSLocalizedString(@"search_reults", nil);
    
    //self.navigationController.navigationBarHidden = NO;
    
    
    loadNextResultData = YES;
    
    resutltOffset = 0;
    
    dataLimit = 20;
    
    [sneakerArray removeAllObjects];
    [sneakerCollectionView reloadData];
    
    [self fetchSearchResultsFromWebserver];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applySearchFilter) name:POST_APPLY_FILTER_NOTIFICATION object:nil];
    
    [self setBackButtonToNavigationBar];
    [self setFilterButtonToNavigationBar];
    
    self.navigationItem.titleView = searchbar;
    
    noSneakerFoundLbl.hidden = YES;
    
    collectionViewWidth = 151.0;
    collectionViewHeight = 120.0;
    
    CGFloat defaultResolutionWidth = 320.0;
    
    CGFloat currentResolutionWidth = self.view.frame.size.width;
    
    collectionViewWidth = currentResolutionWidth*collectionViewWidth/defaultResolutionWidth;
    
    sneakerArray = [[NSMutableArray alloc] init];
    
    if(self.searchString!=nil)
    {
        searchbar.text = self.searchString;
    }
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@{@"brandid" : @"", @"brandname" : @""} forKey:@"brand"];
    [dict setObject:[NSArray array] forKey:@"size"];
    [dict setObject:[NSArray array] forKey:@"condition"];
    [dict setObject:@"" forKey:@"minPrice"];
    [dict setObject:@"" forKey:@"maxPrice"];
    [dict setObject:@"0" forKey:@"searchType"];
    [dict setObject:@"date" forKey:@"orderby"];
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"searchFilterDict"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:POST_APPLY_FILTER_NOTIFICATION object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Set Filter button to Navigationbar

-(void)setFilterButtonToNavigationBar
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.frame = CGRectMake(0, 0, 50, 44);;
    [filterButton addTarget:self action:@selector(filterBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [filterButton setTitle:NSLocalizedString(@"filter", nil) forState:UIControlStateNormal];
    filterButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightItem, nil]];
    
}

-(void)filterBtnClicked
{
    [self performSegueWithIdentifier:@"SearchResultVcToFilterVc" sender:nil];
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


#pragma mark - SearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    LKLog(@"searchBar text = %@", searchBar.text);
    
    [self fetchSearchResultsFromWebserver];
    
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}


-(void)applySearchFilter
{
    [self fetchSearchResultsFromWebserver];
}


#pragma mark Load sneakers list for sale

-(void)fetchSearchResultsFromWebserver
{
    if(isLoadingData || !loadNextResultData)
        return;
    
    //[sneakerArray removeAllObjects];
    //[sneakerCollectionView reloadData];
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        /*NSDictionary *params = @{@"method" : @"SneakerList",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"fortrade" : @"0",
                                 @"forsale" : @"1",
                                 @"Page" : @(resutltOffset)};*/
        
        NSDictionary *params;
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"searchFilterDict"]!=nil)
        {
            NSDictionary *filterDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchFilterDict"];
            
            
            NSArray *sizeAr = filterDict[@"size"];
            NSString *sizeStr = @"";
            
            for(int i=0; i<[sizeAr count]; i++)
            {
                if([sizeStr length]>0)
                {
                    sizeStr = [sizeStr stringByAppendingFormat:@",%@",[sizeAr objectAtIndex:i]];
                }
                else
                {
                    sizeStr = [sizeStr stringByAppendingFormat:@"%@",[sizeAr objectAtIndex:i]];
                }
            }
            
            
            NSArray *conditionAr = filterDict[@"condition"];
            NSString *conditionStr = @"";
            
            for(int i=0; i<[conditionAr count]; i++)
            {
                
                if([conditionStr length]>0)
                {
                    conditionStr = [conditionStr stringByAppendingFormat:@", %@",[conditionAr objectAtIndex:i]];
                }
                else
                {
                    conditionStr = [conditionStr stringByAppendingFormat:@"%@",[conditionAr objectAtIndex:i]];
                }
            }
            
            
            params = @{@"method" : @"searchbykeyword",
                       @"keyword" : searchbar.text,
                       @"brand_id" : [NSString stringWithFormat:@"%@",filterDict[@"brand"][@"brandid"]],
                       @"size" : sizeStr,
                       @"condition" : conditionStr,
                       @"min_price" : filterDict[@"minPrice"],
                       @"max_price" : filterDict[@"maxPrice"],
                       @"business_type" : filterDict[@"searchType"],
                       @"orderby" : filterDict[@"orderby"],
                       @"Page":@(resutltOffset)};
        }
        else
        {
            params = @{@"keyword" : searchbar.text};
        }
        
        LKLog(@"params = %@",params);
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:SEARCH_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [sneakerArray addObjectsFromArray:responseObject[@"alldata"]];
                
                [sneakerCollectionView reloadData];
                
                resutltOffset = resutltOffset + 1;
                
                totalPageCount = [responseObject[@"totalpage"] integerValue];
                
                if([responseObject[@"alldata"] count]==0 || resutltOffset >= totalPageCount)
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
            
            [self displayNoSneakerFoundMsgIfNeeded];
            
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
    
    
    if(!isLoadingData && indexPath.row==[sneakerArray count]-1 && loadNextResultData)
    {
        [self fetchSearchResultsFromWebserver];
    }
    
    
    //[cell.projectImageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"no_image"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"SearchResultVcToSneakerDetailVc" sender:[sneakerArray objectAtIndex:indexPath.row]];
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
    
    if([segue.identifier isEqualToString:@"SearchResultVcToSneakerDetailVc"])
    {
        SneakerDetailViewController *sneakerDetailVc = (SneakerDetailViewController *)segue.destinationViewController;
        sneakerDetailVc.sneakerInfoDict = [[NSDictionary alloc] initWithDictionary:sender];
    }
}


@end
