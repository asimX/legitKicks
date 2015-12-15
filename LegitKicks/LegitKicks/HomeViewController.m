//
//  HomeViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 16/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "HomeViewController.h"
#import "MFSideMenu.h"
//#import "UIImageView+AFNetworking.h"
#import "SneakerDetailViewController.h"
#import "SearchResultsViewController.h"
#import "UIImageView+WebCache.h"

#import "MXSegmentedPager.h"
#import "HomeSneakerListingViewController.h"

@interface HomeViewController () <MXSegmentedPagerDelegate, MXSegmentedPagerDataSource, HomeSneakerListingVcDelegate>
{
    HomeSneakerListingViewController *forTradeVc;
    HomeSneakerListingViewController *forSaleVc;
}
@property (nonatomic, strong) MXSegmentedPager  * segmentedPager;

@end

@implementation HomeViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [forTradeVc loadViewFromStart];
    [forSaleVc loadViewFromStart];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    forTradeVc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeSneakerListingVc"];
    forTradeVc.delegate = self;
    forTradeVc.isListingForTrade = YES;
    
    forSaleVc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeSneakerListingVc"];
    forSaleVc.delegate = self;
    forSaleVc.isListingForTrade = NO;
    
    [self setMenuButtonToNavigationBar];
    [self setRightBarButtonToNavigationBar];
    
    self.navigationItem.titleView = searchbar;
    
    [self.view addSubview:self.segmentedPager];
    
    self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedPager.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:210.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
    self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedPager.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor]};
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

#pragma mark Set Search button to Navigationbar

-(void)setRightBarButtonToNavigationBar
{
    /*UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    UIView *rightBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];

    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(0, 0, 44, 44);;
    [searchButton addTarget:self action:@selector(searchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setImage:[UIImage imageNamed:@"nav_search_btn"] forState:UIControlStateNormal];
    [rightBarView addSubview:searchButton];
    
    UIButton *addShoesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addShoesButton.frame = CGRectMake(38, 0, 44, 44);
    [addShoesButton addTarget:self action:@selector(addSneakerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [addShoesButton setImage:[UIImage imageNamed:@"nav_plus_btn"] forState:UIControlStateNormal];
    [rightBarView addSubview:addShoesButton];
    
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarView];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, negativeSpacer, rightItem, nil]];*/
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    UIButton *addShoesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addShoesButton.frame = CGRectMake(38, 0, 44, 44);
    [addShoesButton addTarget:self action:@selector(addSneakerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [addShoesButton setImage:[UIImage imageNamed:@"nav_plus_btn"] forState:UIControlStateNormal];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:addShoesButton];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightItem, nil]];
    
}

-(void)searchButtonPressed
{
    [self performSegueWithIdentifier:@"HomeVcToSearchFilterVc" sender:nil];
}

-(void)addSneakerButtonPressed
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FromSideMenu"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:@"HomeVcToAddSneakerVc" sender:nil];
}

- (void)viewWillLayoutSubviews {
    self.segmentedPager.frame = (CGRect){
        .origin.x       = 0.f,
        .origin.y       = 0.f,
        .size.width     = self.view.frame.size.width,
        .size.height    = self.view.frame.size.height
    };
    [super viewWillLayoutSubviews];
}

#pragma -mark Properties

- (MXSegmentedPager *)segmentedPager {
    if (!_segmentedPager) {
        
        // Set a segmented pager
        _segmentedPager = [[MXSegmentedPager alloc] init];
        _segmentedPager.delegate    = self;
        _segmentedPager.dataSource  = self;
    }
    return _segmentedPager;
}

#pragma -mark <MXSegmentedPagerDelegate>

- (void)segmentedPager:(MXSegmentedPager *)segmentedPager didSelectViewWithTitle:(NSString *)title
{
    NSLog(@"%@ page selected.", title);
}

- (CGFloat) heightForSegmentedControlInSegmentedPager:(MXSegmentedPager*)segmentedPager
{
    return 40.0;
}

#pragma -mark <MXSegmentedPagerDataSource>

- (NSInteger)numberOfPagesInSegmentedPager:(MXSegmentedPager *)segmentedPager
{
    return 2;
}

- (NSString *)segmentedPager:(MXSegmentedPager *)segmentedPager titleForSectionAtIndex:(NSInteger)index
{
    
    if(index==0)
    {
        return NSLocalizedString(@"for_trade", nil);
    }
    else
    {
        return NSLocalizedString(@"for_sale", nil);
    }
    
}

- (UIView *)segmentedPager:(MXSegmentedPager *)segmentedPager viewForPageAtIndex:(NSInteger)index
{
    if(index==0)
    {
        return forTradeVc.view;
    }
    else
    {
        return forSaleVc.view;
    }
}


#pragma mark - SearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    LKLog(@"searchBar text = %@", searchBar.text);
    
    [searchBar resignFirstResponder];
    [self performSegueWithIdentifier:@"HomeVcToSearchResultsVc" sender:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}


-(void)sneakerSelectedWithDict:(NSDictionary *)dict viewController:(HomeSneakerListingViewController *)viewController
{
    [self performSegueWithIdentifier:@"HomeVcToSneakerDetailVc" sender:dict];
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
    
    if([segue.identifier isEqualToString:@"HomeVcToSneakerDetailVc"])
    {
        SneakerDetailViewController *sneakerDetailVc = (SneakerDetailViewController *)segue.destinationViewController;
        sneakerDetailVc.sneakerInfoDict = [[NSDictionary alloc] initWithDictionary:sender];
    }
    else if([segue.identifier isEqualToString:@"HomeVcToSearchResultsVc"])
    {
        SearchResultsViewController *searchResultVc = (SearchResultsViewController *)segue.destinationViewController;
        searchResultVc.searchString = sender;
    }
    
}


@end
