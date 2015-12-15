//
//  ClosetsViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 21/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "ClosetsViewController.h"
#import "MFSideMenu.h"
//#import "UIImageView+AFNetworking.h"
#import "ClosetDetailViewController.h"

#import "MXSegmentedPager.h"
#import "ClosetsListingViewController.h"

@interface ClosetsViewController () <MXSegmentedPagerDelegate, MXSegmentedPagerDataSource, ClosetsListingVcDelegate>
{
    ClosetsListingViewController *randomClosetsVc;
    ClosetsListingViewController *popularClosetsVc;
    ClosetsListingViewController *followingClosetsVc;
}
@property (nonatomic, strong) MXSegmentedPager  * segmentedPager;

@end

@implementation ClosetsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"closets", nil);
    
    self.navigationController.navigationBarHidden = NO;
    
    [randomClosetsVc loadViewFromStart];
    [popularClosetsVc loadViewFromStart];
    [followingClosetsVc loadViewFromStart];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    randomClosetsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"ClosetsListingVc"];
    randomClosetsVc.delegate = self;
    randomClosetsVc.isRandomClosets = YES;
    
    popularClosetsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"ClosetsListingVc"];
    popularClosetsVc.delegate = self;
    popularClosetsVc.isPopularClosets = YES;
    
    followingClosetsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"ClosetsListingVc"];
    followingClosetsVc.delegate = self;
    followingClosetsVc.isFollowingClosets = YES;
    
    
    [self setMenuButtonToNavigationBar];
    [self setMyClosetButtonToNavigationBar];
    
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


#pragma mark Set My Closet button to Navigationbar

-(void)setMyClosetButtonToNavigationBar
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    UIButton *myClosetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myClosetButton.frame = CGRectMake(0, 0, 80, 44);;
    [myClosetButton addTarget:self action:@selector(myClosetBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [myClosetButton setTitle:NSLocalizedString(@"my_closets", nil) forState:UIControlStateNormal];
    myClosetButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:myClosetButton];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightItem, nil]];
    
}

-(void)myClosetBtnClicked
{
    //[Utility displayAlertWithTitle:@"My Closets" andMessage:@"Under Construction!!"];
    [self performSegueWithIdentifier:@"ClosetsVcToMyClosetVc" sender:nil];
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
    return 3;
}

- (NSString *)segmentedPager:(MXSegmentedPager *)segmentedPager titleForSectionAtIndex:(NSInteger)index
{
    
    if(index==0)
    {
        return NSLocalizedString(@"random", nil);
    }
    else if(index==1)
    {
        return NSLocalizedString(@"popular", nil);
    }
    else
    {
        return NSLocalizedString(@"following", nil);
    }
    
}

- (UIView *)segmentedPager:(MXSegmentedPager *)segmentedPager viewForPageAtIndex:(NSInteger)index
{
    if(index==0)
    {
        return randomClosetsVc.view;
    }
    else if(index==1)
    {
        return popularClosetsVc.view;
    }
    else
    {
        return followingClosetsVc.view;
    }
}

-(void)closetSelectedWithDict:(NSDictionary *)dict viewController:(ClosetsListingViewController *)viewController
{
    id closetId = dict[@"closetid"];
    [self performSegueWithIdentifier:@"ClosetsVcToClosetDetailVc" sender:closetId];
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
    
    if([segue.identifier isEqualToString:@"ClosetsVcToClosetDetailVc"])
    {
        ClosetDetailViewController *closetDetailVc = (ClosetDetailViewController *)segue.destinationViewController;
        closetDetailVc.closetid = [NSString stringWithFormat:@"%@", sender];
    }
    
}


@end
