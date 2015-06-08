//
//  ViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 28/10/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "MFSideMenuContainerViewController.h"
#import "HomeViewController.h"

@interface LoginViewController () <GPPSignInDelegate>
{
    UITextField *lastTextfield;
    NSMutableArray *declinedPermissions;
}

@end

@implementation LoginViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    titleLbl.text = NSLocalizedString(@"sign_in", nil);
    [loginBtn setTitle:NSLocalizedString(@"sign_in", nil) forState:UIControlStateNormal];
    [forgotPasswordBtn setTitle:NSLocalizedString(@"forgot_password", nil) forState:UIControlStateNormal];
    
    
    if([[LKKeyChain objectForKey:@"isLKUserLogin"] boolValue])
    {
        [self goToHomeViewControllerScreen];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    emailTxt.leftView = paddingView;
    emailTxt.leftViewMode = UITextFieldViewModeAlways;
    emailTxt.rightView = paddingView;
    emailTxt.rightViewMode = UITextFieldViewModeAlways;
    
    
    paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    passwordTxt.leftView = paddingView;
    passwordTxt.leftViewMode = UITextFieldViewModeAlways;
    passwordTxt.rightView = paddingView;
    passwordTxt.rightViewMode = UITextFieldViewModeAlways;
    
    emailTxt.layer.cornerRadius = 4.0;
    passwordTxt.layer.cornerRadius = 4.0;
    loginBtn.layer.cornerRadius = 4.0;
    
}


-(IBAction)forgotPasswordBtnClicked:(id)sender
{
    [lastTextfield resignFirstResponder];
}

-(IBAction)loginBtnClicked:(id)sender
{
    [lastTextfield resignFirstResponder];
    
    if(![AppDelegate isLocationServiceEnable])
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"location_service_enabling_alert", nil)];
    }
    else if([emailTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_email_address_alert", nil)];
    }
    else if([passwordTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_password_alert", nil)];
    }
    else
    {
        if([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSDictionary *params = @{@"method" : @"Login",
                                     @"email" : emailTxt.text,
                                     @"password" : passwordTxt.text,
                                     @"device_token" : [[NSUserDefaults standardUserDefaults] objectForKey:@"appDeviceToken"]};
            LKLog(@"params = %@",params);
            
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
            
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            
            MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view.window];
            [self.view.window addSubview:loading];
            [loading show:YES];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager.operationQueue cancelAllOperations];
            
            [manager POST:BASE_API parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 LKLog(@"JSON: %@", responseObject);
                 
                 [loading hide:YES];
                 
                 if([responseObject[@"success"] integerValue] == 1)
                 {
                     [LKKeyChain setObject:responseObject[@"email"] forKey:@"email"];
                     //[LKKeyChain setObject:responseObject[@"firstname"] forKey:@"firstname"];
                     //[LKKeyChain setObject:responseObject[@"lastname"] forKey:@"lastname"];
                     [LKKeyChain setObject:responseObject[@"image"] forKey:@"profile_image"];
                     //[LKKeyChain setObject:responseObject[@"location"] forKey:@"location"];
                     //[LKKeyChain setObject:responseObject[@"noofcloset"] forKey:@"noofcloset"];
                     //[LKKeyChain setObject:responseObject[@"nooftradesneaker"] forKey:@"nooftradesneaker"];
                     //[LKKeyChain setObject:responseObject[@"noofsalesneaker"] forKey:@"noofsalesneaker"];
                     [LKKeyChain setObject:responseObject[@"online"] forKey:@"online"];
                     //[LKKeyChain setObject:responseObject[@"userdescription"] forKey:@"userdescription"];
                     [LKKeyChain setObject:responseObject[@"userid"] forKey:@"userid"];
                     //[LKKeyChain setObject:responseObject[@"city"] forKey:@"city"];
                     //[LKKeyChain setObject:responseObject[@"state"] forKey:@"state"];
                     //[LKKeyChain setObject:responseObject[@"street_address"] forKey:@"street_address"];
                     //[LKKeyChain setObject:responseObject[@"zip"] forKey:@"zip"];
                     //[LKKeyChain setObject:responseObject[@"paypal_id"] forKey:@"paypal_id"];
                     [LKKeyChain setObject:responseObject[@"username"] forKey:@"username"];
                     
                     [LKKeyChain setObject:responseObject forKey:@"userObject"];
                     
                     [LKKeyChain setObject:@YES forKey:@"isLKUserLogin"];
                     
                     [self goToHomeViewControllerScreen];
                     
                     emailTxt.text = @"";
                     passwordTxt.text = @"";
                 }
                 else
                 {
                     [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"login_failed_alert", nil)];
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [loading hide:YES];
                 
                 LKLog(@"failed response string = %@",operation.responseString);
                 [Utility displayHttpFailureError:error];
             }];
        }
        else
        {
            [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
        }
    }
}


-(IBAction)facebookLoginBtnClicked:(id)sender
{
    [lastTextfield resignFirstResponder];
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    __block FBSessionStateHandler runOnceHandler = ^(FBSession *session,
                                                     FBSessionState state,
                                                     NSError *error)
    {
        [FBSession setActiveSession:session];
        
        [self sessionStateChanged:session state:state error:error];
    };
    
    facebookLoginBtn.enabled = NO;
    
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         /*[FBSession setActiveSession:session];
          
          [self sessionStateChanged:session state:state error:error];*/
         
         
         if (runOnceHandler)
         {
             runOnceHandler(session, state, error);
             runOnceHandler = nil;
         }
         
         
         return;
     }];
}

-(IBAction)googlePlusLoginBtnClicked:(id)sender
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    
    signIn.scopes = [NSArray arrayWithObjects: kGTLAuthScopePlusLogin, kGTLAuthScopePlusMe, nil];
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    
    [signIn authenticate];
}


- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth error: (NSError *) error
{
    LKLog(@"Received error %@",error);
    if(error==nil)
    {
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:loading];
        [loading show:YES];
        
        
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error)
        {
                    
                    [loading hide:YES];
                    
                    if (error)
                    {
                        GTMLoggerError(@"Error: %@", error);
                        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"googleSignInFailed", nil)];
                    }
                    else
                    {
                        NSLog(@"detail = %@",[person description]);
                        
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                        [dict setObject:person.identifier forKey:@"id"];
                        [dict setObject:person.displayName forKey:@"display_name"];
                        [dict setObject:auth.userEmail forKey:@"email"];
                        [dict setObject:[person.image.url stringByReplacingOccurrencesOfString:@"50" withString:@"100"] forKey:@"imageURL"];
                        [dict setObject:person.name.givenName forKey:@"first_name"];
                        [dict setObject:person.name.familyName forKey:@"last_name"];
                        [dict setObject:@"" forKey:@"user_name"];
                        
                        [self doGooglePlusLoginWithUserDict:dict];
                    }
                }];
    }
    else
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"googleSignInFailed", nil)];
    }
}


-(void)doGooglePlusLoginWithUserDict:(NSDictionary *)userDict
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"Registration",
                                 @"userid" : @"0",
                                 @"FacebookID" : @"0",
                                 @"GooglePlusID" : userDict[@"id"],
                                 @"firstname" : userDict[@"first_name"],
                                 @"lastname" : userDict[@"last_name"]?userDict[@"last_name"]:@"",
                                 @"email" : userDict[@"email"]?userDict[@"email"]:@"",
                                 @"username" : @"",
                                 @"password" : @"",
                                 @"imageURL" : userDict[@"imageURL"]?userDict[@"imageURL"]:@"",
                                 @"userdescription" : @"",
                                 @"location" : @"",
                                 @"device_token" : [[NSUserDefaults standardUserDefaults] objectForKey:@"appDeviceToken"]};
        LKLog(@"params = %@",params);
        
        googlePlusLoginBtn.enabled = NO;
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        [manager POST:BASE_API parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             LKLog(@"JSON: %@", responseObject);
             [loading hide:YES];
             googlePlusLoginBtn.enabled = YES;
             if([responseObject[@"success"] integerValue] == 1)
             {
                 
                 if([responseObject[@"status"] integerValue]==2)
                 {
                     LKLog(@"Already Exist!!");
                 }
                 else if([responseObject[@"status"] integerValue]==1)
                 {
                     LKLog(@"Not Exist!!");
                 }
                 
                 [LKKeyChain setObject:responseObject[@"email"] forKey:@"email"];
                 [LKKeyChain setObject:responseObject[@"firstname"] forKey:@"firstname"];
                 [LKKeyChain setObject:responseObject[@"lastname"] forKey:@"lastname"];
                 [LKKeyChain setObject:responseObject[@"image"] forKey:@"profile_image"];
                 [LKKeyChain setObject:responseObject[@"location"] forKey:@"location"];
                 
                 if(responseObject[@"noofcloset"])
                 {
                     [LKKeyChain setObject:responseObject[@"noofcloset"] forKey:@"noofcloset"];
                 }
                 
                 if(responseObject[@"nooftradesneaker"])
                 {
                     [LKKeyChain setObject:responseObject[@"nooftradesneaker"] forKey:@"nooftradesneaker"];
                 }
                 
                 if(responseObject[@"noofsalesneaker"])
                 {
                     [LKKeyChain setObject:responseObject[@"noofsalesneaker"] forKey:@"noofsalesneaker"];
                 }
                 [LKKeyChain setObject:responseObject[@"online"] forKey:@"online"];
                 [LKKeyChain setObject:responseObject[@"userdescription"] forKey:@"userdescription"];
                 [LKKeyChain setObject:responseObject[@"userid"] forKey:@"userid"];
                 
                 [LKKeyChain setObject:responseObject[@"city"] forKey:@"city"];
                 [LKKeyChain setObject:responseObject[@"state"] forKey:@"state"];
                 [LKKeyChain setObject:responseObject[@"street_address"] forKey:@"street_address"];
                 [LKKeyChain setObject:responseObject[@"zip"] forKey:@"zip"];
                 //[LKKeyChain setObject:responseObject[@"paypal_id"] forKey:@"paypal_id"];
                 //[LKKeyChain setObject:responseObject[@"username"] forKey:@"username"];
                 
                 [LKKeyChain setObject:responseObject forKey:@"userObject"];
                 
                 [LKKeyChain setObject:@YES forKey:@"isLKUserLogin"];
                 
                 [self goToHomeViewControllerScreen];
             }
             else
             {
                 [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"login_failed_alert", nil)];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [loading hide:YES];
             googlePlusLoginBtn.enabled = YES;
             LKLog(@"failed response string = %@",operation.responseString);
             [Utility displayHttpFailureError:error];
         }];
    }
    else
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
        googlePlusLoginBtn.enabled = YES;
    }
}



// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && (state == FBSessionStateOpen || state == FBSessionStateOpenTokenExtended))
    {
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        facebookLoginBtn.enabled = NO;
        
        [FBRequestConnection startWithGraphPath:@"/me/permissions" completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
         {
             if (!error)
             {
                 LKLog(@"permission = %@",result);
                 NSArray *permissionsAr = (NSArray *)[result data];
                 
                 BOOL publicProfilePermitted = NO;
                 BOOL userEmailPermitted = NO;
                 
                 for(NSDictionary *dict in permissionsAr)
                 {
                     if([[dict objectForKey:@"permission"] isEqualToString:@"public_profile"] && [[dict objectForKey:@"status"] isEqualToString:@"granted"])
                     {
                         publicProfilePermitted = YES;
                     }
                     else if([[dict objectForKey:@"permission"] isEqualToString:@"email"] && [[dict objectForKey:@"status"] isEqualToString:@"granted"])
                     {
                         userEmailPermitted = YES;
                     }
                 }
                 
                 if (publicProfilePermitted && userEmailPermitted)
                 {
                     [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                      {
                          facebookLoginBtn.enabled = YES;
                          
                          if (!error)
                          {
                              // Success! Include your code to handle the results here
                              LKLog(@"user info: %@", result);
                              
                              [self doFacebookLoginWithUserDict:result];
                              
                          }
                          else
                          {
                              // An error occurred, we need to handle the error
                              // See: https://developers.facebook.com/docs/ios/errors
                          }
                      }];
                 }
                 else
                 {
                     declinedPermissions = [[NSMutableArray alloc] init];
                     
                     if(!publicProfilePermitted)
                     {
                         [declinedPermissions addObject:@"public_profile"];
                     }
                     if(!userEmailPermitted)
                     {
                         [declinedPermissions addObject:@"email"];
                     }
                     
                     [self displayPermissionAlertDialog];
                     
                     facebookLoginBtn.enabled = YES;
                 }
                 
             }
             else
             {
                 facebookLoginBtn.enabled = YES;
                 
                 // There was an error, handle it
                 // See https://developers.facebook.com/docs/ios/errors/
             }
         }];
        
        
        return;
    }
    
    facebookLoginBtn.enabled = YES;
    
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed)
    {
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
    }
    
    // Handle errors
    if (error)
    {
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
        {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [Utility displayAlertWithTitle:alertText andMessage:alertTitle];
        }
        else
        {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
            {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            }
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
            {
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                //[self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            }
            else
            {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                //[self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
    }
}

-(void)displayPermissionAlertDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"ask_for_missing_permission", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"yes", nil), NSLocalizedString(@"no", nil), nil];
    alert.tag=200;
    [alert show];
}


#pragma mark UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==200 && buttonIndex==0)
    {
        facebookLoginBtn.enabled = NO;
        [[FBSession activeSession] requestNewReadPermissions:declinedPermissions completionHandler:^(FBSession *session, NSError *error) {
            
            [FBSession setActiveSession:session];
            
            [self sessionStateChanged:session state:session.state error:error];
        }];
    }
}


-(void)doFacebookLoginWithUserDict:(NSDictionary *)fbUserDict
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        
        NSString *emailStr = @"";
        if(fbUserDict[@"email"] && [fbUserDict[@"email"] isKindOfClass:[NSArray class]])
        {
            emailStr = [fbUserDict[@"email"] objectAtIndex:0];
        }
        else if(fbUserDict[@"email"] && [fbUserDict[@"email"] isKindOfClass:[NSString class]])
        {
            emailStr = fbUserDict[@"email"];
        }
        
        
        NSDictionary *params = @{@"method" : @"Registration",
                                 @"userid" : @"0",
                                 @"FacebookID" : fbUserDict[@"id"],
                                 @"GooglePlusID" : @"0",
                                 @"firstname" : fbUserDict[@"first_name"],
                                 @"lastname" : fbUserDict[@"last_name"]?fbUserDict[@"last_name"]:@"",
                                 @"email" : emailStr,
                                 @"username" : @"",
                                 @"password" : @"",
                                 @"imageURL" : [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",fbUserDict[@"id"]],
                                 @"userdescription" : @"",
                                 @"location" : @"",
                                 @"device_token" : [[NSUserDefaults standardUserDefaults] objectForKey:@"appDeviceToken"]};
        LKLog(@"params = %@",params);
        
        facebookLoginBtn.enabled = NO;
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        [manager POST:BASE_API parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             LKLog(@"JSON: %@", responseObject);
             [loading hide:YES];
             facebookLoginBtn.enabled = YES;
             if([responseObject[@"success"] integerValue] == 1)
             {
                 
                 if([responseObject[@"status"] integerValue]==2)
                 {
                     LKLog(@"Already Exist!!");
                 }
                 else if([responseObject[@"status"] integerValue]==1)
                 {
                     LKLog(@"Not Exist!!");
                 }
                 
                 [LKKeyChain setObject:responseObject[@"email"] forKey:@"email"];
                 [LKKeyChain setObject:responseObject[@"firstname"] forKey:@"firstname"];
                 [LKKeyChain setObject:responseObject[@"lastname"] forKey:@"lastname"];
                 [LKKeyChain setObject:responseObject[@"image"] forKey:@"profile_image"];
                 [LKKeyChain setObject:responseObject[@"location"] forKey:@"location"];
                 if(responseObject[@"noofcloset"])
                 {
                     [LKKeyChain setObject:responseObject[@"noofcloset"] forKey:@"noofcloset"];
                 }
                 
                 if(responseObject[@"nooftradesneaker"])
                 {
                     [LKKeyChain setObject:responseObject[@"nooftradesneaker"] forKey:@"nooftradesneaker"];
                 }
                 
                 if(responseObject[@"noofsalesneaker"])
                 {
                     [LKKeyChain setObject:responseObject[@"noofsalesneaker"] forKey:@"noofsalesneaker"];
                 }
                 [LKKeyChain setObject:responseObject[@"online"] forKey:@"online"];
                 [LKKeyChain setObject:responseObject[@"userdescription"] forKey:@"userdescription"];
                 [LKKeyChain setObject:responseObject[@"userid"] forKey:@"userid"];
                 
                 [LKKeyChain setObject:responseObject[@"city"] forKey:@"city"];
                 [LKKeyChain setObject:responseObject[@"state"] forKey:@"state"];
                 [LKKeyChain setObject:responseObject[@"street_address"] forKey:@"street_address"];
                 [LKKeyChain setObject:responseObject[@"zip"] forKey:@"zip"];
                 //[LKKeyChain setObject:responseObject[@"paypal_id"] forKey:@"paypal_id"];
                 //[LKKeyChain setObject:responseObject[@"username"] forKey:@"username"];
                 
                 [LKKeyChain setObject:responseObject forKey:@"userObject"];
                 
                 [LKKeyChain setObject:@YES forKey:@"isLKUserLogin"];
                 
                 [self goToHomeViewControllerScreen];
             }
             else
             {
                 [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"login_failed_alert", nil)];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [loading hide:YES];
             facebookLoginBtn.enabled = YES;
             LKLog(@"failed response string = %@",operation.responseString);
             [Utility displayHttpFailureError:error];
         }];
    }
    else
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
        facebookLoginBtn.enabled = YES;
    }
}



-(void)goToHomeViewControllerScreen
{
    MFSideMenuContainerViewController *container = [self.storyboard instantiateViewControllerWithIdentifier:@"mfSideMenuContainerVc"];
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"navigationController"];
    UIViewController *leftSideMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
    
    [container setLeftMenuViewController:leftSideMenuViewController];
    [container setCenterViewController:navigationController];
    
    
    HomeViewController *homeVc = [self.storyboard instantiateViewControllerWithIdentifier:@"homeVc"];
    
    NSArray *controllers = [NSArray arrayWithObject:homeVc];
    navigationController.viewControllers = controllers;
    
    
    [self.navigationController pushViewController:container animated:YES];
    
    [[AppDelegate sharedAppDelegate] checkForRatingRemainFromWebserver];
}



#pragma mark Keyboard Notifications

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note
{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // commit animations
    [UIView commitAnimations];
    
    
    CGFloat keyboardHeight = keyboardBounds.size.height;
    UIEdgeInsets bottomInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    [scroll setContentInset:bottomInset];
    [scroll setScrollIndicatorInsets:bottomInset];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // commit animations
    [UIView commitAnimations];
    
    
    CGFloat keyboardHeight = 0;
    UIEdgeInsets bottomInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    [scroll setContentInset:bottomInset];
    [scroll setScrollIndicatorInsets:bottomInset];
}



#pragma mark TextField delegate method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==emailTxt)
    {
        [passwordTxt becomeFirstResponder];
    }
    else if(textField==passwordTxt)
    {
        [passwordTxt resignFirstResponder];
        [self loginBtnClicked:nil];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    lastTextfield = textField;
    
    /*if((textField.frame.origin.y-scroll.contentOffset.y)>100)
    {
        scroll.contentOffset = CGPointMake(0, textField.frame.origin.y-50); //make room for keyboard
    }*/
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
