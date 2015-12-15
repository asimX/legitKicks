//
//  LeftMenuViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 15/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "MFSideMenu.h"
//#import "UIImageView+AFNetworking.h"
#import "HomeViewController.h"
#import "MyProfileViewController.h"
#import "PublicProfileViewController.h"
#import "AddSneakerViewController.h"
#import "WatchListViewController.h"
#import "ClosetsViewController.h"
#import "ActivitiesViewController.h"
#import "UIImageView+WebCache.h"

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    menuArray = [[NSMutableArray alloc] init];
    
    NSDictionary *dict = @{@"menu_name" : NSLocalizedString(@"buy_trade_sell", nil),
             @"menu_image" : @"ic_sneaker",
             @"menu_image_selected" : @"ic_sneaker"};
    [menuArray addObject:dict];
    
    
    dict = @{@"menu_name" : NSLocalizedString(@"closets", nil),
             @"menu_image" : @"ic_closets",
             @"menu_image_selected" : @"ic_closets"};
    [menuArray addObject:dict];
    
    
    dict = @{@"menu_name" : NSLocalizedString(@"favorites", nil),
             @"menu_image" : @"ic_watchlist",
             @"menu_image_selected" : @"ic_watchlist"};
    [menuArray addObject:dict];
    
    
    /*dict = @{@"menu_name" : NSLocalizedString(@"watchlist", nil),
             @"menu_image" : @"ic_watchlist",
             @"menu_image_selected" : @"ic_watchlist"};
    [menuArray addObject:dict];*/
    
    
    dict = @{@"menu_name" : NSLocalizedString(@"my_profile", nil),
             @"menu_image" : @"ic_watchlist",
             @"menu_image_selected" : @"ic_watchlist"};
    [menuArray addObject:dict];
    
    
    dict = @{@"menu_name" : NSLocalizedString(@"add_sneaker", nil),
             @"menu_image" : @"nav_plus_btn",
             @"menu_image_selected" : @"nav_plus_btn"};
    [menuArray addObject:dict];
    
    
    /*dict = @{@"menu_name" : NSLocalizedString(@"settings", nil),
             @"menu_image" : @"ic_settings",
             @"menu_image_selected" : @"ic_settings"};
    [menuArray addObject:dict];*/
    
    
    dict = @{@"menu_name" : NSLocalizedString(@"activities", nil),
             @"menu_image" : @"ic_sneaker",
             @"menu_image_selected" : @"ic_sneaker"};
    [menuArray addObject:dict];
    
    
    /*dict = @{@"menu_name" : NSLocalizedString(@"sign_out", nil),
             @"menu_image" : @"ic_signout",
             @"menu_image_selected" : @"ic_signout"};
    [menuArray addObject:dict];*/
    
    
    /*dict = @{@"menu_name" : @"Public Profile",
             @"menu_image" : @"ic_watchlist",
             @"menu_image_selected" : @"ic_watchlist"};
    [menuArray addObject:dict];*/
    
    
    [menuTableview reloadData];
    
}


#pragma mark Tableview delegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    
    
    UIImageView *menuImage = (UIImageView *)[cell.contentView viewWithTag:10];
    UILabel *menuLbl = (UILabel *)[cell.contentView viewWithTag:11];
    
    menuImage.image = nil;
    menuImage.layer.cornerRadius = 0;
    menuImage.image = [UIImage imageNamed:[menuArray objectAtIndex:indexPath.row][@"menu_image"]];
    menuLbl.text = [menuArray objectAtIndex:indexPath.row][@"menu_name"];
    
    if(indexPath.row==3)
    {
        __block UIImageView *blockThumbImage = menuImage;
        
        /*[menuImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[LKKeyChain objectForKey:@"profile_image"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             blockThumbImage.image = image;
             blockThumbImage.layer.cornerRadius = blockThumbImage.frame.size.width/2.0;
             blockThumbImage.layer.masksToBounds = YES;
             
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             
         }];*/
        
        [menuImage sd_setImageWithURL:[NSURL URLWithString:[LKKeyChain objectForKey:@"profile_image"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            blockThumbImage.image = image;
            blockThumbImage.layer.cornerRadius = blockThumbImage.frame.size.width/2.0;
            blockThumbImage.layer.masksToBounds = YES;
        }];
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        HomeViewController *homeVc = [self.storyboard instantiateViewControllerWithIdentifier:@"homeVc"];
        
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:homeVc];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if(indexPath.row==1)
    {        
        ClosetsViewController *closetVc = [self.storyboard instantiateViewControllerWithIdentifier:@"closetsVc"];
        
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:closetVc];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if(indexPath.row==2)
    {
        WatchListViewController *watchListVc = [self.storyboard instantiateViewControllerWithIdentifier:@"watchListVc"];
        
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:watchListVc];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if(indexPath.row==3)
    {
        MyProfileViewController *myProfileVc = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileVc"];
        
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:myProfileVc];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if(indexPath.row==4)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FromSideMenu"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        AddSneakerViewController *addSneakerVc = [self.storyboard instantiateViewControllerWithIdentifier:@"addSneakerVc"];
        
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:addSneakerVc];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if(indexPath.row==5)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FromSideMenu"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        ActivitiesViewController *activitiesVc = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivitiesVc"];
        
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:activitiesVc];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    else if(indexPath.row==6)
    {
        [[AppDelegate sharedAppDelegate] logoutFromApplication];
    }
    /*else if(indexPath.row==6)
    {
        PublicProfileViewController *publicProfileVc = [self.storyboard instantiateViewControllerWithIdentifier:@"publicProfileVc"];
        
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:publicProfileVc];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
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
