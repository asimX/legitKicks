//
//  AppDelegate.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 28/10/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Braintree.h"
#import "BraintreeTransactionService.h"
#import "RatingViewController.h"



@implementation UINavigationController (nav_rotate)

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

@end


@interface AppDelegate ()
{
    RatingViewController *ratingVc;
    BOOL isCheckingForRatingRemain;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Fabric with:@[CrashlyticsKit]];
    
    [Braintree setReturnURLScheme:@"com.app.legitkicks.payments"];
    
    BraintreeDemoTransactionServiceEnvironment environment;
    //environment = BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant;
    environment = BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant;
    [self switchToEnvironment:environment];
    

    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         LKLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
         
         if(status != AFNetworkReachabilityStatusNotReachable)
         {
             [self checkForRatingRemainFromWebserver];
         }
         
     }];
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"appUniqueID"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[self uniqueIDForDevice] forKey:@"appUniqueID"];
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        [LKKeyChain removeObjectForKey:@"email"];
        [LKKeyChain removeObjectForKey:@"firstname"];
        [LKKeyChain removeObjectForKey:@"lastname"];
        [LKKeyChain removeObjectForKey:@"first_name"];
        [LKKeyChain removeObjectForKey:@"profile_image"];
        [LKKeyChain removeObjectForKey:@"location"];
        [LKKeyChain removeObjectForKey:@"noofcloset"];
        [LKKeyChain removeObjectForKey:@"nooftradesneaker"];
        [LKKeyChain removeObjectForKey:@"noofsalesneaker"];
        [LKKeyChain removeObjectForKey:@"online"];
        [LKKeyChain removeObjectForKey:@"userdescription"];
        [LKKeyChain removeObjectForKey:@"userid"];
        [LKKeyChain removeObjectForKey:@"isLKUserLogin"];
    }
    
    
    NSArray *conditionArray = @[@{@"id":@"1", @"condition":@"Deadstock(DS - 10/10) - Never worn/Brand New"}, @{@"id":@"2", @"condition":@"VeryNear Deadstock (VNDS - 9+/10) - Minor Flaws/Wears"}, @{@"id":@"3", @"condition":@"GoodCondition (9/10) - Some Flaws/Wears"}, @{@"id":@"4", @"condition":@"SemiBeat (8/10) - Multiple Flaws/Wears"}, @{@"id":@"5", @"condition":@"Beat(7/10 or less) - Heavy Flaws/Wears"}];
    [[NSUserDefaults standardUserDefaults] setObject:conditionArray forKey:@"SneakerConditionArray"];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"deviceLatitude"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0.0" forKey:@"deviceLatitude"];
    }
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"deviceLongitude"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0.0" forKey:@"deviceLongitude"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"appDeviceToken"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"appDeviceToken"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    
    
    return YES;
}

- (void)switchToEnvironment:(BraintreeDemoTransactionServiceEnvironment)environment
{
    NSString *environmentName;
    
    switch (environment) {
        case BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant:
            environmentName = @"Sandbox";
            break;
        case BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant:
            environmentName = @"Production";
    }
    
    [[BraintreeTransactionService sharedService] setEnvironment:environment];
}

#pragma mark --
#pragma mark RegisterPush.
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *StrdeviceToken=[[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    //NSLog(@"deviceToken:%@",deviceToken);
    [[NSUserDefaults standardUserDefaults] setValue:StrdeviceToken forKey:@"appDeviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //[Utility displayAlertWithTitle:@"Token" andMessage:StrdeviceToken];
    
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    ////NSLog(@"Failed to get token, error: %@", error);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}


+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (UIStoryboard *)currentStoryboard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

- (void)initializeSlideMenu
{
    
}


#pragma mark - Location Manager Delegate Methods

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    LKLog(@"location error = %@",error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [locationManager stopUpdatingLocation];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[formatter stringFromDate:[NSDate date]] forKey:@"lastLocationRefreshDate"];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"refreshLocationInformation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //TTLog(@"getting location");
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude] forKey:@"deviceLatitude"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude] forKey:@"deviceLongitude"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    NSString *StrURL = [url description];
    
    if([StrURL rangeOfString:@"legitkickspassword"].length !=0) {
        
        /*ResetPasswordViewController *viewController = [[ResetPasswordViewController alloc] initWithNibName:@"ResetPasswordViewController" bundle:nil];
        viewController.isFromChangePassword = FALSE;
        viewController.strURL = [url description];
        [self.navigationController pushViewController:viewController animated:YES];*/
        return YES;
    }
    else if([FBAppCall handleOpenURL:url sourceApplication:sourceApplication])
    {
        return YES;
    }
    else if([GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation])
    {
        return YES;
    }
    else if([Braintree handleOpenURL:url sourceApplication:sourceApplication])
    {
        return YES;
    }
        
    return NO;
}


-(NSString*)uniqueIDForDevice
{
    NSString* uniqueIdentifier = nil;
    if( [UIDevice instancesRespondToSelector:@selector(identifierForVendor)] )
    {
        // >=iOS 7
        uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    else
    {  //<=iOS6, Use UDID of Device
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        //uniqueIdentifier = ( NSString*)CFUUIDCreateString(NULL, uuid);- for non- ARC
        uniqueIdentifier = ( NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));// for ARC
        CFRelease(uuid);
    }
    return uniqueIdentifier;
}

+(BOOL)isLocationServiceEnable
{
    BOOL locationOn = NO;
    
    if([CLLocationManager locationServicesEnabled])
    {
        
        if(IS_IOS8)
        {
            if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse)
            {
                locationOn = YES;
            }
        }
        else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorized)
        {
            locationOn = YES;
        }
    }
    else
    {
        locationOn = NO;
    }
    
    return locationOn;
}

-(void)logoutFromApplication
{
    [LKKeyChain removeObjectForKey:@"email"];
    [LKKeyChain removeObjectForKey:@"firstname"];
    [LKKeyChain removeObjectForKey:@"lastname"];
    [LKKeyChain removeObjectForKey:@"first_name"];
    [LKKeyChain removeObjectForKey:@"profile_image"];
    [LKKeyChain removeObjectForKey:@"location"];
    [LKKeyChain removeObjectForKey:@"noofcloset"];
    [LKKeyChain removeObjectForKey:@"nooftradesneaker"];
    [LKKeyChain removeObjectForKey:@"noofsalesneaker"];
    [LKKeyChain removeObjectForKey:@"online"];
    [LKKeyChain removeObjectForKey:@"userdescription"];
    [LKKeyChain removeObjectForKey:@"userid"];
    [LKKeyChain removeObjectForKey:@"city"];
    [LKKeyChain removeObjectForKey:@"state"];
    [LKKeyChain removeObjectForKey:@"street_address"];
    [LKKeyChain removeObjectForKey:@"zip"];
    [LKKeyChain removeObjectForKey:@"paypal_id"];
    [LKKeyChain removeObjectForKey:@"username"];
    [LKKeyChain removeObjectForKey:@"userObject"];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [LKKeyChain setObject:@NO forKey:@"isLKUserLogin"];
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[GPPSignIn sharedInstance] signOut];
    
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    [nav popToRootViewControllerAnimated:YES];
}

-(void)refreshLocationInformation
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"lastLocationRefreshDate"] isEqualToString:[formatter stringFromDate:[NSDate date]]])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshLocationInformation"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"refreshLocationInformation"])
    {
        [locationManager startUpdatingLocation];
    }
}


-(void)checkForRatingRemainFromWebserver
{
    
    
    if(isCheckingForRatingRemain || ![[LKKeyChain objectForKey:@"isLKUserLogin"] boolValue])
    {
        return;
    }
    
    isCheckingForRatingRemain = YES;
    
    
    NSDictionary *params = @{@"method" : @"CheckReviewRemain",
                             @"userid" : [LKKeyChain objectForKey:@"userid"]};
    LKLog(@"params = %@",params);
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager.operationQueue cancelAllOperations];
    
    [manager POST:CHECK_REMAIN_RATE_REVIEW_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        LKLog(@"JSON: %@", responseObject);
        
        /*{
            IsReviewPending = 1;
            buyerid = 176;
            flag = sell;
            sellerid = 162;
            sellid = 42;
        }*/
        
        if(responseObject[@"IsReviewPending"] && [responseObject[@"IsReviewPending"] integerValue] !=0)
        {
            if(ratingVc)
            {
                [ratingVc dismissViewControllerAnimated:NO completion:nil];
                ratingVc = nil;
            }
            
            ratingVc = [[self currentStoryboard] instantiateViewControllerWithIdentifier:@"RatingVC"];
            ratingVc.sellTradeInfoDict = responseObject;
            if([responseObject[@"flag"] isEqualToString:@"sell"])
            {
                ratingVc.forTrade = NO;
            }
            else
            {
                ratingVc.forTrade = YES;
            }
            ratingVc.fromCheckingRemainRating = YES;
            
            [self.window.rootViewController presentViewController:ratingVc animated:YES completion:nil];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        LKLog(@"failed response string = %@",operation.responseString);
        //[Utility displayHttpFailureError:error];
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [self refreshLocationInformation];
    [self checkForRatingRemainFromWebserver];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
