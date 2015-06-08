//
//  RequestForTradeViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 01/02/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "RequestForTradeViewController.h"
#import "UserSneakerListForTradeViewController.h"
#import "AskQuestionViewController.h"

@interface RequestForTradeViewController ()

@end

@implementation RequestForTradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setBackButtonToNavigationBar];
    
    self.title = @"Request For Trade";
    
    tradeNowBtn.layer.cornerRadius = 4.0;
    askQuestionBtn.layer.cornerRadius = 4.0;
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"RequestForTradeVcToSneakerListForTradeVc"])
    {
        UserSneakerListForTradeViewController *sneakerListVc = (UserSneakerListForTradeViewController *)segue.destinationViewController;
        sneakerListVc.sneakerDict = [[NSDictionary alloc] initWithDictionary:self.sneakerDict];
    }
    else if([segue.identifier isEqualToString:@"ReqForTradeVcToAskQuestionVc"])
    {
        AskQuestionViewController *askQuestionVc = segue.destinationViewController;
        askQuestionVc.sneakerDict = [[NSDictionary alloc] initWithDictionary:_sneakerDict];
    }
}


@end
