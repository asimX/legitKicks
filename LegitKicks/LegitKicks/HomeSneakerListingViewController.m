//
//  HomeSneakerListingViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 08/08/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "HomeSneakerListingViewController.h"
#import "UIImageView+WebCache.h"

@interface HomeSneakerListingViewController ()
{
    CGFloat collectionViewWidth;
    CGFloat collectionViewHeight;
    
    BOOL loadNextSneakerForSaleData;
    BOOL loadNextSneakerForTradeData;
    
    
    NSInteger totalForTradePageCount;
    NSInteger totalForSalePageCount;
    
    NSInteger sneakerForTradeOffset;
    NSInteger sneakerForSaleOffset;
    NSInteger dataLimit;
    
    BOOL isLoadingData;
}

@end

@implementation HomeSneakerListingViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*if (_isListingForTrade)
    {
        [self loadSneakerForTradeDataFromWebserver];
    }
    else
    {
        [self loadSneakerForSaleDataFromWebserver];
    }*/
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    noSneakerFoundLbl.hidden = YES;
    
    collectionViewWidth = 151.0;
    collectionViewHeight = 120.0;
    
    CGFloat defaultResolutionWidth = 320.0;
    
    CGFloat currentResolutionWidth = self.view.frame.size.width;
    
    collectionViewWidth = currentResolutionWidth*collectionViewWidth/defaultResolutionWidth;
    
    sneakerForSaleArray = [[NSMutableArray alloc] init];
    sneakerForTradeArray = [[NSMutableArray alloc] init];
    
    /*if(_isListingForTrade)
    {
        sneakerArray = [[NSMutableArray alloc] initWithArray:sneakerForTradeArray];
        
        [sneakerCollectionView setContentOffset:CGPointMake(0, 0)];
        
        [sneakerCollectionView reloadData];
        
        noSneakerFoundLbl.text = @"No sneakers found for trade.";
        [self displayNoSneakerFoundMsgIfNeeded];
        
        if([sneakerArray count]==0)
        {
            [self loadSneakerForTradeDataFromWebserver];
        }
    }
    else
    {
        sneakerArray = [[NSMutableArray alloc] initWithArray:sneakerForSaleArray];
        
        [sneakerCollectionView setContentOffset:CGPointMake(0, 0)];
        
        [sneakerCollectionView reloadData];
        
        noSneakerFoundLbl.text = @"No sneakers found for sale.";
        [self displayNoSneakerFoundMsgIfNeeded];
        
        if([sneakerArray count]==0)
        {
            [self loadSneakerForSaleDataFromWebserver];
        }
    }*/
}

-(void)loadViewFromStart
{
    loadNextSneakerForSaleData = YES;
    loadNextSneakerForTradeData = YES;
    
    sneakerForSaleOffset = 0;
    sneakerForTradeOffset = 0;
    
    dataLimit = 20;
    
    [sneakerForSaleArray removeAllObjects];
    [sneakerForTradeArray removeAllObjects];
    
    
    if(_isListingForTrade)
    {
        sneakerArray = [[NSMutableArray alloc] initWithArray:sneakerForTradeArray];
        
        [sneakerCollectionView setContentOffset:CGPointMake(0, 0)];
        
        [sneakerCollectionView reloadData];
        
        noSneakerFoundLbl.text = @"No sneakers found for trade.";
        [self displayNoSneakerFoundMsgIfNeeded];
        
        if([sneakerArray count]==0)
        {
            [self loadSneakerForTradeDataFromWebserver];
        }
    }
    else
    {
        sneakerArray = [[NSMutableArray alloc] initWithArray:sneakerForSaleArray];
        
        [sneakerCollectionView setContentOffset:CGPointMake(0, 0)];
        
        [sneakerCollectionView reloadData];
        
        noSneakerFoundLbl.text = @"No sneakers found for sale.";
        [self displayNoSneakerFoundMsgIfNeeded];
        
        if([sneakerArray count]==0)
        {
            [self loadSneakerForSaleDataFromWebserver];
        }
    }
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

#pragma mark Load sneakers list for trade

-(void)loadSneakerForTradeDataFromWebserver
{
    if(isLoadingData || !loadNextSneakerForTradeData)
        return;
    
    isLoadingData = YES;
    
    //[sneakerArray removeAllObjects];
    //[sneakerCollectionView reloadData];
    
    //if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"SneakerList",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"fortrade" : @"1",
                                 @"forsale" : @"0",
                                 @"Page" : @(sneakerForTradeOffset)};
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
                [sneakerForTradeArray addObjectsFromArray:responseObject[@"alldata"]];
                
                sneakerArray = [[NSMutableArray alloc] initWithArray:sneakerForTradeArray];
                
                [sneakerCollectionView reloadData];
                
                sneakerForTradeOffset = sneakerForTradeOffset + 1;
                
                totalForTradePageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || sneakerForTradeOffset >= totalForTradePageCount)
                {
                    loadNextSneakerForTradeData = NO;
                }
                else
                {
                    loadNextSneakerForTradeData = YES;
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
    /*else
     {
     [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
     }*/
}

#pragma mark Load sneakers list for sale

-(void)loadSneakerForSaleDataFromWebserver
{
    if(isLoadingData || !loadNextSneakerForSaleData)
        return;
    
    //[sneakerArray removeAllObjects];
    //[sneakerCollectionView reloadData];
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"SneakerList",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"fortrade" : @"0",
                                 @"forsale" : @"1",
                                 @"Page" : @(sneakerForSaleOffset)};
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
                [sneakerForSaleArray addObjectsFromArray:responseObject[@"alldata"]];
                
                sneakerArray = [[NSMutableArray alloc] initWithArray:sneakerForSaleArray];
                
                [sneakerCollectionView reloadData];
                
                sneakerForSaleOffset = sneakerForSaleOffset + 1;
                
                totalForSalePageCount = [responseObject[@"totalpage"] integerValue];
                
                if([responseObject[@"alldata"] count]==0 || sneakerForSaleOffset >= totalForSalePageCount)
                {
                    loadNextSneakerForSaleData = NO;
                }
                else
                {
                    loadNextSneakerForSaleData = YES;
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
    
    
    if(!isLoadingData && indexPath.row==[sneakerArray count]-1)
    {
        if(!_isListingForTrade && loadNextSneakerForSaleData)
        {
            [self loadSneakerForSaleDataFromWebserver];
        }
        else if(_isListingForTrade && loadNextSneakerForTradeData)
        {
            [self loadSneakerForTradeDataFromWebserver];
        }
    }
    
    
    //[cell.projectImageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"no_image"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"HomeVcToSneakerDetailVc" sender:[sneakerArray objectAtIndex:indexPath.row]];
    
    if(_delegate && [_delegate respondsToSelector:@selector(sneakerSelectedWithDict:viewController:)])
    {
        [_delegate sneakerSelectedWithDict:[sneakerArray objectAtIndex:indexPath.row] viewController:self];
    }
    
    /*if(forTradeTabBtn.selected)
     {
     [Utility displayAlertWithTitle:@"For Trade" andMessage:@"You have selected Sneaker for Trade"];
     }
     else
     {
     [Utility displayAlertWithTitle:@"For Sale" andMessage:@"You have selected Sneaker for Sale"];
     }*/
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
