//
//  AskQuestionViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 02/02/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "AskQuestionViewController.h"
#import "SenderMsgTableViewCell.h"
#import "ReceiverMsgTableViewCell.h"

#define WRITE_MESSAGE_STR   @"Write message..."

@interface AskQuestionViewController ()
{
    UIToolbar *keyboardToolbar;
    NSMutableArray *conversationArray;
    
    BOOL loadNextConversationData;
    NSInteger totalConversationPageCount;
    NSInteger conversationOffset;
    NSInteger dataLimit;
    BOOL isLoadingData;
}
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation AskQuestionViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Ask A Question";
    [sendBtn setTitle:NSLocalizedString(@"send", nil) forState:UIControlStateNormal];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setBackButtonToNavigationBar];
    
    self.offscreenCells = [NSMutableDictionary dictionary];
    conversationArray = [[NSMutableArray alloc] init];
    loadNextConversationData = YES;
    
    keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,44)];
    keyboardToolbar.barStyle = UIBarStyleBlack;
    keyboardToolbar.tintColor = [UIColor whiteColor];
    //keyboardToolbar.barTintColor = [UIColor colorWithRed:47.0/255.0 green:190.0/255.0 blue:182.0/255.0 alpha:1.0];
    //keyboardToolbar.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:190.0/255.0 blue:182.0/255.0 alpha:1.0];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(keyboardToolbarDoneClicked:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *items = [[NSArray alloc] initWithObjects:flex, barButtonItem, nil];
    [keyboardToolbar setItems:items];
    
    questionTextView.inputAccessoryView = keyboardToolbar;
    
    questionTextView.layer.cornerRadius = 4.0;
    sendBtn.layer.cornerRadius = 4.0;
    
    questionTextView.layer.borderColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
    questionTextView.layer.borderWidth = 1.0;
    
    questionTextView.text = WRITE_MESSAGE_STR;
    
    //[questionTextView becomeFirstResponder];
    
    //[conversationTable registerClass:[SenderMsgTableViewCell class] forHeaderFooterViewReuseIdentifier:@"SenderCell"];
    //[conversationTable registerClass:[ReceiverMsgTableViewCell class] forHeaderFooterViewReuseIdentifier:@"ReceiverCell"];
    
    [self loadConversationFromWebserver];
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
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)keyboardToolbarDoneClicked:(id)sender
{
    [questionTextView resignFirstResponder];
}

-(void)loadConversationFromWebserver
{
    if(isLoadingData || !loadNextConversationData)
        return;
    
    isLoadingData = YES;
    
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"getconversationlist",
                                 @"senderid" : [LKKeyChain objectForKey:@"userid"],
                                 @"recieverid" : _sneakerDict[@"userid"],
                                 @"sellersneakerid" : _sneakerDict[@"sneakerid"],
                                 @"Page" : @(conversationOffset)};
        LKLog(@"params = %@",params);
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:loading];
        [loading show:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.operationQueue cancelAllOperations];
        
        [manager POST:GET_COVERSATION_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            LKLog(@"JSON: %@", responseObject);
            
            [loading hide:YES];
            
            if([responseObject[@"success"] integerValue] == 1)
            {
                [conversationArray addObjectsFromArray:responseObject[@"alldata"]];
                
                [conversationTable reloadData];
                
                conversationOffset = conversationOffset + 1;
                
                totalConversationPageCount = [responseObject[@"totalpage"] integerValue];
                
                
                if([responseObject[@"alldata"] count]==0 || conversationOffset >= totalConversationPageCount)
                {
                    loadNextConversationData = NO;
                }
                else
                {
                    loadNextConversationData = YES;
                }
            }
            else
            {
                [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"unable_load_data_alert", nil)];
            }
            
            isLoadingData = NO;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [loading hide:YES];
            
            LKLog(@"failed response string = %@",operation.responseString);
            [Utility displayHttpFailureError:error];
            
            isLoadingData = NO;
        }];
    }
    else
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
    }
}

-(IBAction)sendBtnClicked:(id)sender
{
    if([questionTextView.text isEqualToString:WRITE_MESSAGE_STR])
    {
        [self.view makeToast:@"Please enter message."];
    }
    else
    {
        [questionTextView resignFirstResponder];
        
        if([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSDictionary *params = @{@"method" : @"addconversationmessage",
                                     @"senderid" : [LKKeyChain objectForKey:@"userid"],
                                     @"recieverid" : _sneakerDict[@"userid"],
                                     @"sellersneakerid" : _sneakerDict[@"sneakerid"],
                                     @"conversation_desc" : questionTextView.text};
            LKLog(@"params = %@",params);
            
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
            
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            
            MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view.window];
            [self.view.window addSubview:loading];
            [loading show:YES];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager.operationQueue cancelAllOperations];
            
            [manager POST:ADD_COVERSATION_API_URL parameters:@{@"data" : jsonString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                LKLog(@"JSON: %@", responseObject);
                
                [loading hide:YES];
                
                if([responseObject[@"success"] integerValue] == 1)
                {
                    [conversationArray insertObject:responseObject[@"conversation"] atIndex:0];
                    [conversationTable reloadData];
                    
                    questionTextView.textColor = [UIColor lightGrayColor];
                    questionTextView.text = WRITE_MESSAGE_STR;
                }
                else
                {
                    [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:@"Your message was not sent, please try again."];
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



#pragma mark Tableview delegate/datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [conversationArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]] isEqualToString:[NSString stringWithFormat:@"%@", [conversationArray objectAtIndex:indexPath.row][@"recieverid"]]])
    {
        ReceiverMsgTableViewCell *cell = [self.offscreenCells objectForKey:@"ReceiverCell"];
        if (!cell && cell.tag!=-1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiverCell"];
            cell.tag = -1;
            [self.offscreenCells setObject:cell forKey:@"ReceiverCell"];
        }
        
        
        cell.msgLbl.text = [conversationArray objectAtIndex:indexPath.row][@"conversation_desc"];
        cell.msgLbl.preferredMaxLayoutWidth = tableView.bounds.size.width - 69.0;
        //cell.msgTextviewHeightConstraint.constant = cell.msgTextview.contentSize.height;
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        // Get the actual height required for the cell
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        // Add an extra point to the height to account for the cell separator, which is added between the bottom
        // of the cell's contentView and the bottom of the table view cell.
        //height += 1;
        
        return height;
    }
    else
    {
        SenderMsgTableViewCell *cell = [self.offscreenCells objectForKey:@"SenderCell"];
        if (!cell && cell.tag!=-1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SenderCell"];
            cell.tag = -1;
            [self.offscreenCells setObject:cell forKey:@"SenderCell"];
        }
        
        cell.msgLbl.text = [conversationArray objectAtIndex:indexPath.row][@"conversation_desc"];
        cell.msgLbl.preferredMaxLayoutWidth = tableView.bounds.size.width - 69.0;
        //cell.msgTextviewHeightConstraint.constant = cell.msgTextview.contentSize.height;
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        // Get the actual height required for the cell
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        // Add an extra point to the height to account for the cell separator, which is added between the bottom
        // of the cell's contentView and the bottom of the table view cell.
        //∂height += 1;
        
        return height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(!isLoadingData && indexPath.row==[conversationArray count]-1 && loadNextConversationData)
    {
        [self loadConversationFromWebserver];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    
    NSDate *date = [formatter dateFromString:[conversationArray objectAtIndex:indexPath.row][@"conversation_time"]];
    
    [formatter setDateFormat:@"MMM dd yyyy hh:mm a"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    
    
    if([[NSString stringWithFormat:@"%@", [LKKeyChain objectForKey:@"userid"]] isEqualToString:[NSString stringWithFormat:@"%@", [conversationArray objectAtIndex:indexPath.row][@"recieverid"]]])
    {
        ReceiverMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiverCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.msgBackView.layer.cornerRadius = 5.0;
        cell.msgBackView.layer.masksToBounds = YES;
        
        cell.msgLbl.text = [conversationArray objectAtIndex:indexPath.row][@"conversation_desc"];
        cell.msgDateTimeLbl.text = [formatter stringFromDate:date];
        //cell.msgTextviewHeightConstraint.constant = cell.msgTextview.contentSize.height;
        
        [cell layoutIfNeeded];
        
        return cell;
    }
    else
    {
        SenderMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SenderCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.msgBackView.layer.cornerRadius = 5.0;
        cell.msgBackView.layer.masksToBounds = YES;
        
        cell.msgLbl.text = [conversationArray objectAtIndex:indexPath.row][@"conversation_desc"];
        cell.msgDateTimeLbl.text = [formatter stringFromDate:date];
        //cell.msgTextviewHeightConstraint.constant = cell.msgTextview.contentSize.height;
        
        [cell layoutIfNeeded];
        
        return cell;
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}



#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.textColor = [UIColor blackColor];
    
    if([textView.text isEqualToString:WRITE_MESSAGE_STR])
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
        textView.text = WRITE_MESSAGE_STR;
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

- (void)textViewDidChange:(UITextView *)textView
{
    if([textView contentSize].height <80.0)
    {
        textviewHeightConstraint.constant = [textView contentSize].height;
        NSLog(@"height = %f", textviewHeightConstraint.constant);
    }
    //[bottomChatView layoutIfNeeded];
    /*CGRect frame = textView.frame;
     frame.origin.y = CGRectGetMaxY(frame) - [textView contentSize].height;
     frame.size.height = [textView contentSize].height;
     textView.frame = frame;*/
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
