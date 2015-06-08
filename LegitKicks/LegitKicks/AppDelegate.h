//
//  AppDelegate.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 28/10/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate *)sharedAppDelegate;
- (UIStoryboard *)currentStoryboard;
- (void)initializeSlideMenu;
+(BOOL)isLocationServiceEnable;
-(void)logoutFromApplication;
-(void)checkForRatingRemainFromWebserver;


@end

