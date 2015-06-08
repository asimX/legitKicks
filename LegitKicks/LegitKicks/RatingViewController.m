//
//  RatingViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 25/04/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "RatingViewController.h"
#import "MFSideMenu.h"
#import "UIImageView+WebCache.h"

@interface RatingViewController () <EDStarRatingProtocol>
{
    UIToolbar *keyboardToolbar;
    
    NSDictionary *requestDetailDict;
    NSMutableArray *buyerSneakerArray;
    NSMutableArray *sellerSneakerArray;
    NSMutableDictionary *offscreenCells;
}

@end

@implementation RatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.hidesBackButton = YES;
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    /*UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    [self.navigationController.navigationBar setTintColor:navigationController.navigationBar.tintColor];
    [self.navigationController.navigationBar setBarTintColor:navigationController.navigationBar.barTintColor];
    [self.navigationController.navigationBar setBackgroundColor:navigationController.navigationBar.backgroundColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    self.title = @"Rate & Review";
    reviewTxt.text = @"Write review...";
    reviewTxt.textColor = [UIColor lightGrayColor];
    keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,44)];
    keyboardToolbar.barStyle = UIBarStyleBlack;
    keyboardToolbar.tintColor = [UIColor whiteColor];
    //keyboardToolbar.barTintColor = [UIColor colorWithRed:253.0/255.0 green:202.0/255.0 blue:15.0/255.0 alpha:1.0];
    //keyboardToolbar.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:202.0/255.0 blue:15.0/255.0 alpha:1.0];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(keyboardToolbarDoneClicked:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *items = [[NSArray alloc] initWithObjects:flex, barButtonItem, nil];
    [keyboardToolbar setItems:items];
    reviewTxt.inputAccessoryView = keyboardToolbar;
    ratingView.layer.cornerRadius = 5.0;
    ratingView.layer.masksToBounds = YES;
    
    
    sneakerRatingView.starImage = [UIImage imageNamed:@"unrated_sneaker_ic"];
    sneakerRatingView.starHighlightedImage = [UIImage imageNamed:@"rated_sneaker_ic"];
    sneakerRatingView.maxRating = 5.0;
    sneakerRatingView.delegate = self;
    sneakerRatingView.horizontalMargin = 0;
    sneakerRatingView.editable=YES;
    sneakerRatingView.rating= 5.0;
    sneakerRatingView.displayMode=EDStarRatingDisplayFull;
    
    offscreenCells = [NSMutableDictionary dictionary];
    
    //[self loadSellRequestDetailFromWebserver];
}

-(IBAction)keyboardToolbarDoneClicked:(id)sender
{
    [reviewTxt resignFirstResponder];
}

-(IBAction)doneBtnClicked:(id)sender
{
    [reviewTxt resignFirstResponder];
    
    if([reviewTxt.text length]==0 || [[reviewTxt.text lowercaseString] isEqualToString:[@"Write review..." lowercaseString]])
    {
        [self.view makeToast:NSLocalizedString(@"enter_comment_alert", nil)];
    }
    else
    {
        NSDictionary *params;
        
        if(_forTrade)
        {
            NSString *toUserIdStr = _sellTradeInfoDict[@"buyerid"];
            
            if([[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]] isEqualToString:[NSString stringWithFormat:@"%@", _sellTradeInfoDict[@"buyerid"]]])
            {
                toUserIdStr = _sellTradeInfoDict[@"sellerid"];
            }
            
            params = @{@"method" : @"addratereview",
                       @"by_userid" : [LKKeyChain objectForKey:@"userid"],
                       @"trade_sell_id" : _sellTradeInfoDict[@"tradeid"],
                       @"to_userid" : toUserIdStr,
                       @"rate" : @(sneakerRatingView.rating),
                       @"review" : reviewTxt.text,
                       @"status" : @"0"};
        }
        else
        {
            params = @{@"method" : @"addratereview",
                       @"by_userid" : [LKKeyChain objectForKey:@"userid"],
                       @"trade_sell_id" : _sellTradeInfoDict[@"sellid"],
                       @"to_userid" : _sellTradeInfoDict[@"sellerid"],
                       @"rate" : @(sneakerRatingView.rating),
                       @"review" : reviewTxt.text,
                       @"status" : @"1"};
        }
        
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        loading.removeFromSuperViewOnHide = YES;
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:ADD_RATE_REVIEW_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
                
                if(_fromCheckingRemainRating)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [[AppDelegate sharedAppDelegate] checkForRatingRemainFromWebserver];
                }
                else
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Failed to submit review, please try again."];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [loading hide:YES];
            
            LKLog(@"failed response string = %@",operation.responseString);
            [Utility displayHttpFailureError:error];
        }];
    }
}


#pragma mark -

#pragma mark Load profile data

-(void)loadTradeRequestDetailFromWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"gettraderequestdetail",
                                 @"tradeid" : _sellTradeInfoDict[@"tradeid"]};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:GET_TRADE_REQUEST_DETAIL_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                requestDetailDict = [[NSDictionary alloc] initWithDictionary:responseObject];
                
                [self displaySneakerDetailInformation];
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"unable_load_data_alert", nil)];
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

-(void)loadSellRequestDetailFromWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"getsellrequestdetail",
                                 @"sellid" : _sellTradeInfoDict[@"sellid"]};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:GET_SALE_REQUEST_DETAIL_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                requestDetailDict = [[NSDictionary alloc] initWithDictionary:responseObject];
                
                [self displaySneakerDetailInformation];
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"unable_load_data_alert", nil)];
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


-(void)displaySneakerDetailInformation
{
    
    buyerSneakerArray = [[NSMutableArray alloc] initWithArray:requestDetailDict[@"buyersneakerdetail"]];
    sellerSneakerArray = [[NSMutableArray alloc] initWithArray:requestDetailDict[@"sellersneakerdetail"]];
    [sneakerTable reloadData];
}


-(NSAttributedString *)getCommonLabelAttributedStringForName:(NSString *)nameStr andValue:(NSString *)valueStr
{
    NSString *tempStr = [NSString stringWithFormat:@"%@ : %@",nameStr, valueStr];
    
    NSInteger nameStrLength = [nameStr length];
    NSMutableAttributedString * finalStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
    [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,nameStrLength)];
    [finalStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange((nameStrLength+1),[tempStr length]-(nameStrLength+1))];
    return finalStr;
    
}

#pragma mark - UITableView Datasource/Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([sellerSneakerArray count]>0 && [buyerSneakerArray count]>0)
    {
        return 2;
    }
    else if([sellerSneakerArray count]>0 || [buyerSneakerArray count]>0)
    {
        return 1;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"sectionHeader";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *headerLabel = (UILabel *)[headerView viewWithTag:10];
    
    if(section==0)
    {
        headerLabel.text = @"Sneaker details";
    }
    else
    {
        headerLabel.text = @"Buyer sneaker details";
    }
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return [sellerSneakerArray count];
    }
    else
    {
        return [buyerSneakerArray count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = nil;
    
    if(indexPath.section == 0)
    {
        dict = [sellerSneakerArray objectAtIndex:indexPath.row];
    }
    else
    {
        dict = [buyerSneakerArray objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *cell = [offscreenCells objectForKey:@"sneakerInfoCell"];
    if (!cell && cell.tag!=-1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"sneakerInfoCell"];
        cell.tag = -1;
        [offscreenCells setObject:cell forKey:@"sneakerInfoCell"];
    }
    
    UILabel *sneakerNameLbl = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *conditionLbl = (UILabel *)[cell.contentView viewWithTag:12];
    UILabel *brandNameLbl = (UILabel *)[cell.contentView viewWithTag:13];
    UILabel *sizeLbl = (UILabel *)[cell.contentView viewWithTag:14];
    
    sneakerNameLbl.text = dict[@"sneakername"];
    brandNameLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Brand" andValue:dict[@"sneakerbrand"]];
    conditionLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Condition" andValue:dict[@"sneakercondition"]];
    sizeLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Size" andValue:dict[@"sneakersize"]];
    
    //fieldValueLbl.text = dict[@"value"];
    
    sneakerNameLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (sneakerNameLbl.frame.origin.x + 8.0);
    brandNameLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (brandNameLbl.frame.origin.x + 8.0);
    conditionLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (conditionLbl.frame.origin.x + 8.0);
    
    
    //[cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    
    return height;
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = nil;
    
    if(indexPath.section == 0)
    {
        dict = [sellerSneakerArray objectAtIndex:indexPath.row];
    }
    else
    {
        dict = [buyerSneakerArray objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sneakerInfoCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UIImageView *sneakerThumbImageView = (UIImageView *)[cell.contentView viewWithTag:10];
    UILabel *sneakerNameLbl = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *conditionLbl = (UILabel *)[cell.contentView viewWithTag:12];
    UILabel *brandNameLbl = (UILabel *)[cell.contentView viewWithTag:13];
    UILabel *sizeLbl = (UILabel *)[cell.contentView viewWithTag:14];
    
    sneakerNameLbl.text = dict[@"sneakername"];
    brandNameLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Brand" andValue:dict[@"sneakerbrand"]];
    conditionLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Condition" andValue:dict[@"sneakercondition"]];
    sizeLbl.attributedText = [self getCommonLabelAttributedStringForName:@"Size" andValue:dict[@"sneakersize"]];
    
    sneakerNameLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (sneakerNameLbl.frame.origin.x + 8.0);
    brandNameLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (brandNameLbl.frame.origin.x + 8.0);
    conditionLbl.preferredMaxLayoutWidth = self.view.frame.size.width - (conditionLbl.frame.origin.x + 8.0);
    
    
    __block UIImageView *blockThumbImage = sneakerThumbImageView;
    
    NSString *urlStr = dict[@"sneakerimg"];
    /*if(dict[@"sneakerimg"] && [dict[@"sneakerimg"] count]>0)
     {
     urlStr = [dict[@"picture"] objectAtIndex:0][@"picture"];
     }*/
    
    /*[sneakerThumbImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
     blockThumbImage.image = image;
     
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
     LKLog(@"error - %@",error);
     }];*/
    
    [sneakerThumbImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        blockThumbImage.image = image;
    }];
    
    
    [cell layoutIfNeeded];
    
    return cell;
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = nil;
    if(indexPath.section == 0)
    {
        dict = [sellerSneakerArray objectAtIndex:indexPath.row];
    }
    else
    {
        dict = [buyerSneakerArray objectAtIndex:indexPath.row];
    }
    
    //[self performSegueWithIdentifier:@"ReqestDetailVcToSneakerDetailVc" sender:dict];
    
    //[self getAndDisplaySneakerDetailForSneakerId:dict[@"sneakerid"]];
}


#pragma mark - Keyboard Notifications

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
    
    
    if([reviewTxt isFirstResponder])
    {
        [ratingPopupScroll setContentInset:bottomInset];
        [ratingPopupScroll setScrollIndicatorInsets:bottomInset];
        
        
        
        CGRect textFieldRect = [ratingView convertRect:reviewTxt.bounds fromView:reviewTxt];
        textFieldRect = CGRectMake(textFieldRect.origin.x, ratingView.frame.origin.y+textFieldRect.origin.y, textFieldRect.size.width, textFieldRect.size.height);
        
        CGRect rect = self.view.frame;
        rect.size.height -= keyboardHeight;
        
        /*if (!CGRectContainsPoint(rect, textFieldRect.origin))
        {
            [ratingPopupScroll scrollRectToVisible:textFieldRect animated:YES];
        }*/
    }
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
    
    [ratingPopupScroll setContentInset:bottomInset];
    [ratingPopupScroll setScrollIndicatorInsets:bottomInset];
}


#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.textColor = [UIColor blackColor];
    
    if([[textView.text lowercaseString] isEqualToString:[@"Write review..." lowercaseString]])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([textView.text length]==0)
    {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = @"Write review...";
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text length]==0)
        return YES;
    
    NSString *textStr = [textView.text stringByAppendingString:text];
    
    if([textStr length]>1000)
        return NO;
    
    
    return YES;
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
