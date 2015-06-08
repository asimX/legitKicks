//
//  SearchFilterViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 07/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "SearchFilterViewController.h"
#import "MCPanelViewController.h"
#import "FilterMultiSelectionViewController.h"
#import "SearchResultsViewController.h"

@interface SearchFilterViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIToolbar *keyboardToolbar;
    UITextField *lastTextfield;
    UIPickerView *generalPickerView;
    
    NSArray *commonArray;
    NSArray *brandArray;
    NSInteger selectedBrandIndex;
    
    NSArray *selectedSizeArray;
    NSArray *selectedConditionArray;
    
    BOOL isSizeSelection;
    
    
    MCPanelViewController *rightPanelViewController;
}

@end

@implementation SearchFilterViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"search", nil);
    filtersLbl.text = [NSLocalizedString(@"filters", nil) stringByAppendingString:@" :"];
    sizeLbl.text = [NSLocalizedString(@"size", nil) stringByAppendingString:@" :"];
    conditionLbl.text = [NSLocalizedString(@"condition", nil) stringByAppendingString:@" :"];
    priceLbl.text = [NSLocalizedString(@"price", nil) stringByAppendingString:@" :"];
    sortLbl.text = [NSLocalizedString(@"sort_by", nil) stringByAppendingString:@" :"];
    
    [searchBtn setTitle:NSLocalizedString(@"apply", nil) forState:UIControlStateNormal];
    
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.navigationController removeGestureRecognizersFromViewForScreenEdgeGestureWithPanelViewController:rightPanelViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setBackButtonToNavigationBar];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sneakerImageSelectionDone:) name:@"SneakerImageSelectionDone" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAndUpdateSelectedSizeArray:) name:@"CheckForFilterSelectedSize" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAndUpdateSelectedConditionArray:) name:@"CheckForFilterSelectedCondition" object:nil];
    
    
    [self modifyTextfield:brandTxt withDropdownImage:YES];
    
    searchBtn.layer.cornerRadius = 5.0;
    
    keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,44)];
    keyboardToolbar.barStyle = UIBarStyleBlack;
    keyboardToolbar.tintColor = [UIColor whiteColor];
    //keyboardToolbar.barTintColor = [UIColor colorWithRed:47.0/255.0 green:190.0/255.0 blue:182.0/255.0 alpha:1.0];
    //keyboardToolbar.backgroundColor = [UIColor colorWithRed:47.0/255.0 green:190.0/255.0 blue:182.0/255.0 alpha:1.0];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(keyboardToolbarDoneClicked:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *items = [[NSArray alloc] initWithObjects:flex, barButtonItem, nil];
    [keyboardToolbar setItems:items];
    
    brandTxt.inputAccessoryView = keyboardToolbar;
    minimumPriceTxt.inputAccessoryView = keyboardToolbar;
    maximumPriceTxt.inputAccessoryView = keyboardToolbar;
    
    generalPickerView = [[UIPickerView alloc] init];
    generalPickerView.delegate = self;
    generalPickerView.dataSource = self;
    [generalPickerView reloadAllComponents];
    brandTxt.inputView = generalPickerView;
    
    
    selectedConditionArray = [NSArray array];
    selectedSizeArray = [NSArray array];
    
    
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"searchFilterDict"]!=nil)
    {
        NSDictionary *filterDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchFilterDict"];
        
        
        selectedSizeArray = filterDict[@"size"];
        selectedConditionArray = filterDict[@"condition"];
        
        selectedSizeLbl.text = @"Any";
        selectedConditionLbl.text = @"Any";
        
        if([selectedSizeArray count]>0)
        {
            selectedSizeLbl.text = [selectedSizeArray componentsJoinedByString:@", "];
        }
        
        if([selectedConditionArray count]>0)
        {
            selectedConditionLbl.text = [selectedConditionArray componentsJoinedByString:@", "];
        }
        
        
        if([filterDict[@"searchType"] integerValue]==0 || [filterDict[@"searchType"] length]==0)
        {
            searchTypeSegmentControl.selectedSegmentIndex = 2;
        }
        else if([filterDict[@"searchType"] integerValue]==1)
        {
            searchTypeSegmentControl.selectedSegmentIndex = 0;
        }
        else if([filterDict[@"searchType"] integerValue]==2)
        {
            searchTypeSegmentControl.selectedSegmentIndex = 1;
        }
        
        if([filterDict[@"orderby"] isEqualToString:@"date"] || [filterDict[@"orderby"] length]==0)
        {
            sortTypeSegmentControl.selectedSegmentIndex = 0;
        }
        else if([filterDict[@"orderby"] isEqualToString:@"rating"])
        {
            sortTypeSegmentControl.selectedSegmentIndex = 1;
        }
        else if([filterDict[@"orderby"] isEqualToString:@"distance"])
        {
            sortTypeSegmentControl.selectedSegmentIndex = 2;
        }
        
        
        minimumPriceTxt.text = filterDict[@"minPrice"];
        maximumPriceTxt.text = filterDict[@"maxPrice"];
    }
    
    
    
    [self loadBrandsFromWebserver];
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


-(void)modifyTextfield:(UITextField *)txtField withDropdownImage:(BOOL)isDropDown
{
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    txtField.leftView = paddingView;
    txtField.leftViewMode = UITextFieldViewModeAlways;
    
    if(isDropDown)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imgView.image = [UIImage imageNamed:@"dropdown_arrow"];
        [txtField setRightView:imgView];
        [txtField setRightViewMode:UITextFieldViewModeAlways];
    }
    else
    {
        [txtField setRightView:paddingView];
        [txtField setRightViewMode:UITextFieldViewModeAlways];
    }
    
    txtField.layer.cornerRadius = 5.0;
    txtField.layer.borderColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
    txtField.layer.borderWidth = 1.0;
}

-(IBAction)keyboardToolbarDoneClicked:(id)sender
{
    [lastTextfield resignFirstResponder];
}


-(IBAction)sizeBtnClicked:(id)sender
{
    isSizeSelection = YES;
    //[self performSegueWithIdentifier:@"SearchFilterVcToMultiSelectionVc" sender:selectedSizeArray];
    
    FilterMultiSelectionViewController *filterMultiSelectionVc = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterMultiSelectionVc"];
    filterMultiSelectionVc.preferredContentSize = CGSizeMake(280, 0);
    filterMultiSelectionVc.title = @"Select size";
    filterMultiSelectionVc.filterType = SIZE_FILTER_TYPE;
    filterMultiSelectionVc.selectedListArray = [[NSMutableArray alloc] initWithArray:selectedSizeArray];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:filterMultiSelectionVc];
    
    rightPanelViewController = [navigationController viewControllerInPanelViewController];
    [self.navigationController addGestureRecognizerToViewForScreenEdgeGestureWithPanelViewController:rightPanelViewController withDirection:MCPanelAnimationDirectionRight];
    [self.navigationController presentPanelViewController:rightPanelViewController withDirection:MCPanelAnimationDirectionRight];
}

-(IBAction)conditionBtnClicked:(id)sender
{
    isSizeSelection = NO;
    //[self performSegueWithIdentifier:@"SearchFilterVcToMultiSelectionVc" sender:selectedConditionArray];
    
    FilterMultiSelectionViewController *filterMultiSelectionVc = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterMultiSelectionVc"];
    filterMultiSelectionVc.preferredContentSize = CGSizeMake(280, 0);
    filterMultiSelectionVc.title = @"Select condition";
    filterMultiSelectionVc.filterType = CONDITION_FILTER_TYPE;
    filterMultiSelectionVc.selectedListArray = [[NSMutableArray alloc] initWithArray:selectedConditionArray];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:filterMultiSelectionVc];
    
    rightPanelViewController = [navigationController viewControllerInPanelViewController];
    [self.navigationController addGestureRecognizerToViewForScreenEdgeGestureWithPanelViewController:rightPanelViewController withDirection:MCPanelAnimationDirectionRight];
    [self.navigationController presentPanelViewController:rightPanelViewController withDirection:MCPanelAnimationDirectionRight];
}


-(void)loadBrandsFromWebserver
{
    if([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSDictionary *params = @{@"method" : @"GetBrands"};
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
                brandArray = [[NSArray alloc] initWithArray:responseObject[@"brands"]];
                
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"searchFilterDict"]!=nil)
                {
                    NSDictionary *filterDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchFilterDict"];
                    
                    if([filterDict[@"brand"][@"brandid"] length]>0)
                    {
                        NSString *predicateStr = [NSString stringWithFormat:@"brandid == %@ || brandid == '%@'", filterDict[@"brand"][@"brandid"], filterDict[@"brand"][@"brandid"]];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateStr];
                        
                        NSArray *resultsAr = [brandArray filteredArrayUsingPredicate:predicate];
                        if([resultsAr count]==1)
                        {
                            selectedBrandIndex = [brandArray indexOfObject:[resultsAr objectAtIndex:0]];
                            
                            brandTxt.text = [brandArray objectAtIndex:selectedBrandIndex][@"brandname"];
                        }
                    }
                }
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

-(void)checkAndUpdateSelectedSizeArray:(NSNotification *)notification
{
    selectedSizeArray = [[NSArray alloc] initWithArray:[notification object]];
    
    if([selectedSizeArray count]==0)
    {
        selectedSizeLbl.text = @"Any";
    }
    else
    {
        NSString *sizeStr = @"";
        
        for(int i=0; i<[selectedSizeArray count]; i++)
        {
            
            if([sizeStr length]>0)
            {
                sizeStr = [sizeStr stringByAppendingFormat:@", %@",[selectedSizeArray objectAtIndex:i]];
            }
            else
            {
                sizeStr = [sizeStr stringByAppendingFormat:@"%@",[selectedSizeArray objectAtIndex:i]];
            }
        }
        selectedSizeLbl.text = sizeStr;
    }
}

-(void)checkAndUpdateSelectedConditionArray:(NSNotification *)notification
{
    selectedConditionArray = [[NSArray alloc] initWithArray:[notification object]];
    
    if([selectedConditionArray count]==0)
    {
        selectedConditionLbl.text = @"Any";
    }
    else
    {
        NSString *conditionStr = @"";
        
        for(int i=0; i<[selectedConditionArray count]; i++)
        {
            
            if([conditionStr length]>0)
            {
                conditionStr = [conditionStr stringByAppendingFormat:@", %@",[selectedConditionArray objectAtIndex:i]];
            }
            else
            {
                conditionStr = [conditionStr stringByAppendingFormat:@"%@",[selectedConditionArray objectAtIndex:i]];
            }
        }
        selectedConditionLbl.text = conditionStr;
    }
}

-(IBAction)searchBtnClicked:(id)sender
{
    //[Utility displayAlertWithTitle:@"Search" andMessage:@"Under construction!!"];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)applyFilterBtnClicked:(id)sender
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[brandArray objectAtIndex:selectedBrandIndex] forKey:@"brand"];
    [dict setObject:selectedSizeArray forKey:@"size"];
    [dict setObject:selectedConditionArray forKey:@"condition"];
    [dict setObject:minimumPriceTxt.text forKey:@"minPrice"];
    [dict setObject:maximumPriceTxt.text forKey:@"maxPrice"];
    
    if(searchTypeSegmentControl.selectedSegmentIndex==0)
    {
        [dict setObject:@"1" forKey:@"searchType"];
    }
    else if(searchTypeSegmentControl.selectedSegmentIndex==1)
    {
        [dict setObject:@"2" forKey:@"searchType"];
    }
    else if(searchTypeSegmentControl.selectedSegmentIndex==2)
    {
        [dict setObject:@"0" forKey:@"searchType"];
    }
    
    if(sortTypeSegmentControl.selectedSegmentIndex==0)
    {
        [dict setObject:@"date" forKey:@"orderby"];
    }
    else if(sortTypeSegmentControl.selectedSegmentIndex==1)
    {
        [dict setObject:@"rating" forKey:@"orderby"];
    }
    else if(sortTypeSegmentControl.selectedSegmentIndex==2)
    {
        [dict setObject:@"distance" forKey:@"orderby"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"searchFilterDict"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:POST_APPLY_FILTER_NOTIFICATION object:nil];
}


#pragma mark - UIPickerView Datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [commonArray count];
}

#pragma mark UIPickerView Delegate

/*- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
 {
 return [commonArray objectAtIndex:row];
 }*/


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *titleLbl = (id)view;
    if (!titleLbl) {
        titleLbl= [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, [pickerView rowSizeForComponent:component].width-5.0, [pickerView rowSizeForComponent:component].height)];
    }
    
    titleLbl.textColor = [UIColor blackColor];//[UIColor colorWithRed:210.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    if(lastTextfield==brandTxt)
    {
        titleLbl.font = [UIFont systemFontOfSize:17.0];
        titleLbl.text = [commonArray objectAtIndex:row][@"brandname"];
    }
    
    return titleLbl;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(lastTextfield==brandTxt)
    {
        selectedBrandIndex = row;
        lastTextfield.text = [commonArray objectAtIndex:row][@"brandname"];
    }
    else
    {
        lastTextfield.text = [commonArray objectAtIndex:row];
    }
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
    [scroll setContentInset:bottomInset];
    [scroll setScrollIndicatorInsets:bottomInset];
    
    
    CGRect rect = self.view.frame; rect.size.height -= keyboardHeight;
    
    if (!CGRectContainsPoint(rect, lastTextfield.frame.origin))
    {
        [scroll scrollRectToVisible:lastTextfield.frame animated:YES];
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
    [scroll setContentInset:bottomInset];
    [scroll setScrollIndicatorInsets:bottomInset];
}



#pragma mark - TextField delegate method

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    lastTextfield = textField;
    
    
    if(textField==brandTxt)
    {
        if([brandArray count]==0)
        {
            [self loadBrandsFromWebserver];
            [textField resignFirstResponder];
            return;
        }
        commonArray = brandArray;
        [generalPickerView reloadAllComponents];
        
        if([brandTxt.text length]==0)
        {
            [generalPickerView selectRow:0 inComponent:0 animated:NO];
            brandTxt.text = [commonArray objectAtIndex:0][@"brandname"];
            selectedBrandIndex = 0;
        }
        else
        {
            [generalPickerView selectRow:selectedBrandIndex inComponent:0 animated:NO];
        }
    }
    
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"SearchFilterVcToMultiSelectionVc"])
    {
        FilterMultiSelectionViewController *filterMultiSelectionVc = (FilterMultiSelectionViewController *)segue.destinationViewController;
        if(isSizeSelection)
        {
            filterMultiSelectionVc.title = @"Select size";
            filterMultiSelectionVc.filterType = SIZE_FILTER_TYPE;
        }
        else
        {
            filterMultiSelectionVc.title = @"Select condition";
            filterMultiSelectionVc.filterType = CONDITION_FILTER_TYPE;
        }
        
        filterMultiSelectionVc.selectedListArray = [[NSMutableArray alloc] initWithArray:sender];
    }
    else if([segue.identifier isEqualToString:@"FilterVcToSearchResultsVc"])
    {
        
        /*NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:brandTxt.text forKey:@"brand"];
        [dict setObject:brandTxt.text forKey:@"size"];
        [dict setObject:brandTxt.text forKey:@"condition"];
        [dict setObject:brandTxt.text forKey:@"minPrice"];
        [dict setObject:brandTxt.text forKey:@"maxPrice"];
        [dict setObject:brandTxt.text forKey:@"fortrade"];
        [dict setObject:brandTxt.text forKey:@"forsale"];
        [dict setObject:brandTxt.text forKey:@"brand"];*/
        
        
        SearchResultsViewController *searchResultsVc = (SearchResultsViewController *)segue.destinationViewController;
        searchResultsVc.filterDict = [[NSDictionary alloc] initWithDictionary:nil];
    }
}


@end
