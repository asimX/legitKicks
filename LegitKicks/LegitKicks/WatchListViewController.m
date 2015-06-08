//
//  WishListViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 20/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "WatchListViewController.h"
#import "MFSideMenu.h"
//#import "UIImageView+AFNetworking.h"
#import "SneakerDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface WatchListViewController ()
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

@implementation WatchListViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"legit_kicks", nil);
    
    self.navigationController.navigationBarHidden = NO;
    
    
    loadNextResultData = YES;
    
    resutltOffset = 0;
    
    dataLimit = 20;
    
    [sneakerArray removeAllObjects];
    
    [self fetchWatchListsFromWebserver];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMenuButtonToNavigationBar];
    
    noSneakerFoundLbl.hidden = YES;
    
    collectionViewWidth = 151.0;
    collectionViewHeight = 120.0;
    
    CGFloat defaultResolutionWidth = 320.0;
    
    CGFloat currentResolutionWidth = self.view.frame.size.width;
    
    collectionViewWidth = currentResolutionWidth*collectionViewWidth/defaultResolutionWidth;
    
    sneakerArray = [[NSMutableArray alloc] init];
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

-(void)fetchWatchListsFromWebserver
{
    if(isLoadingData || !loadNextResultData)
        return;
    
    //[sneakerArray removeAllObjects];
    //[sneakerCollectionView reloadData];
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        isLoadingData = YES;
        
        NSDictionary *params = @{@"method" : @"GetWatchlist",
                                 @"userid" : [LKKeyChain objectForKey:@"userid"],
                                 @"Page" : @(resutltOffset)};
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
                
                [sneakerCollectionView reloadData];
                
                loadNextResultData = NO;
                
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
        [self fetchWatchListsFromWebserver];
    }
    
    
    //[cell.projectImageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"no_image"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"WatchlistVcToSneakerDetailVc" sender:[sneakerArray objectAtIndex:indexPath.row]];
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
    
    if([segue.identifier isEqualToString:@"WatchlistVcToSneakerDetailVc"])
    {
        SneakerDetailViewController *sneakerDetailVc = (SneakerDetailViewController *)segue.destinationViewController;
        sneakerDetailVc.sneakerInfoDict = [[NSDictionary alloc] initWithDictionary:sender];
    }
}


@end
