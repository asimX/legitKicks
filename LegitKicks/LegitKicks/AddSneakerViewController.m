//
//  AddSneakerViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 28/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "AddSneakerViewController.h"
#import "AddSneakerPhotoViewController.h"
#import "MFSideMenu.h"

#define WRITE_DESC_TEXT     @"Write description..."


@interface AddSneakerViewController ()
{
    UIToolbar *keyboardToolbar;
    UITextField *lastTextfield;
    BOOL isImageSelected;
    UIImageView *tempImage;
    
    NSArray *commonArray;
    
    NSArray *brandArray;
    NSArray *conditionArray;
    NSArray *sizeArray;
    
    NSInteger selectedBrandIndex;
    
    NSArray *sneakerImageArray;
    
    NSInteger selectedCondtionIndex;
}

@end

@implementation AddSneakerViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Add Sneaker";
    /*firstnameTxt.placeholder = NSLocalizedString(@"first_name", nil);
    lastnameTxt.placeholder = NSLocalizedString(@"last_name", nil);
    emailTxt.placeholder = NSLocalizedString(@"email_address", nil);
    passwordTxt.placeholder = NSLocalizedString(@"password", nil);
    confirmPasswordTxt.placeholder = NSLocalizedString(@"confirm_password", nil);
    [addSneakerBtn setTitle:NSLocalizedString(@"register", nil) forState:UIControlStateNormal];*/
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sneakerImageSelectionDone:) name:@"SneakerImageSelectionDone" object:nil];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"FromSideMenu"])
    {
        [self setMenuButtonToNavigationBar];
    }
    else
    {
        [self setBackButtonToNavigationBar];
    }
    
    tempImage = [[UIImageView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [scroll layoutIfNeeded];
    
    //conditionArray = @[@"Deadstock(DS - 10/10) - Never worn/Brand New", @"VeryNear Deadstock (VNDS - 9+/10) - Minor Flaws/Wears", @"GoodCondition (9/10) - Some Flaws/Wears", @"SemiBeat (8/10) - Multiple Flaws/Wears", @"Beat(7/10 or less) - Heavy Flaws/Wears"];
    conditionArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"SneakerConditionArray"];
    
    
    sizeArray = @[@"1", @"1.5", @"2", @"2.5", @"3", @"3.5", @"4", @"4.5", @"5", @"5.5", @"6", @"6.5", @"7", @"7.5", @"8", @"8.5", @"9", @"9.5", @"10", @"10.5", @"11", @"11.5", @"12", @"12.5", @"13", @"13.5", @"14", @"15", @"16", @"17", @"18"];
    
    
    [self modifyTextfield:brandTxt withDropdownImage:YES];
    [self modifyTextfield:modelTxt withDropdownImage:NO];
    [self modifyTextfield:conditionTxt withDropdownImage:YES];
    [self modifyTextfield:sizeTxt withDropdownImage:YES];
    [self modifyTextfield:valueTxt withDropdownImage:NO];
    
    descriptionTxt.layer.cornerRadius = 5.0;
    addSneakerBtn.layer.cornerRadius = 5.0;
    
    
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
    //modelTxt.inputAccessoryView = keyboardToolbar;
    conditionTxt.inputAccessoryView = keyboardToolbar;
    sizeTxt.inputAccessoryView = keyboardToolbar;
    valueTxt.inputAccessoryView = keyboardToolbar;
    descriptionTxt.inputAccessoryView = keyboardToolbar;
    
    generalPickerView = [[UIPickerView alloc] init];
    generalPickerView.delegate = self;
    generalPickerView.dataSource = self;
    [generalPickerView reloadAllComponents];
    
    brandTxt.inputView = generalPickerView;
    //modelTxt.inputView = generalPickerView;
    conditionTxt.inputView = generalPickerView;
    sizeTxt.inputView = generalPickerView;
    
    descriptionTxt.text = WRITE_DESC_TEXT;
    descriptionTxt.textColor = [UIColor lightGrayColor];
    
    
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

#pragma mark Set Menu button to Navigationbar
- (void)setMenuButtonToNavigationBar
{
    UIImage *backButtonImage = [UIImage imageNamed:@"menu_btn"];
    CGRect buttonFrame = CGRectMake(0, 0, 44, 44);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = buttonFrame;
    [button addTarget:self action:@selector(menuBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:backButtonImage forState:UIControlStateNormal];
    
    
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, settingItem, nil]];
    
}

-(IBAction)menuBtnClicked:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
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
    [descriptionTxt resignFirstResponder];
}

-(void)sneakerImageSelectionDone:(NSNotification *)notification
{
    NSLog(@"notification obj = %@",[notification object]);
    sneakerImageArray = [[NSArray alloc] initWithArray:[notification object]];
    [sneakerImageCollectionView reloadData];
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



-(IBAction)addSneakerPhotoBtnClicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"select_photo", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"take_a_photo", nil), NSLocalizedString(@"choose_existing", nil), NSLocalizedString(@"cancel", nil), nil];
    alert.tag = 100;
    [alert show];
}

-(IBAction)sneakerForSegmentClicked:(id)sender
{
    
}

-(void)resetAllFields
{
    sneakerImageArray = nil;
    brandTxt.text = @"";
    modelTxt.text = @"";
    conditionTxt.text = @"";
    sizeTxt.text = @"";
    valueTxt.text = @"";
    descriptionTxt.text = WRITE_DESC_TEXT;
    descriptionTxt.textColor = [UIColor lightGrayColor];
    
}

-(IBAction)addSneakerBtnClicked:(id)sender
{
    if([sneakerImageArray count]==0)
    {
        [self.view makeToast:NSLocalizedString(@"select_atleast_one_sneaker_image_alert", nil)];
    }
    else if([brandTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"select_brand_name_alert", nil)];
    }
    else if([modelTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_model_name_alert", nil)];
    }
    else if([conditionTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"select_condition_alert", nil)];
    }
    else if([sizeTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"select_size_alert", nil)];
    }
    else if([valueTxt.text length]==0)
    {
        [self.view makeToast:NSLocalizedString(@"enter_value_alert", nil)];
    }
    else if([descriptionTxt.text length]==0 || [descriptionTxt.text isEqualToString:WRITE_DESC_TEXT])
    {
        [self.view makeToast:NSLocalizedString(@"enter_description_alert", nil)];
    }
    else
    {
        if([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSString *forTradeStr = @"0";
            NSString *forSaleStr = @"0";
            
            if(sneakerForSegmentControl.selectedSegmentIndex==2)
            {
                forTradeStr = @"1";
                forSaleStr = @"1";
            }
            else if(sneakerForSegmentControl.selectedSegmentIndex==0)
            {
                forTradeStr = @"1";
                forSaleStr = @"0";
            }
            else if(sneakerForSegmentControl.selectedSegmentIndex==1)
            {
                forTradeStr = @"0";
                forSaleStr = @"1";
            }
            
            
            NSDictionary *params = @{@"method" : @"CreateASneaker",
                                     @"sneakerid" : @"0",
                                     @"userid" : [LKKeyChain objectForKey:@"userid"],
                                     //@"closetid" : [LKKeyChain objectForKey:@"userid"],
                                     //@"closetid" : @"",
                                     @"sneakername" : modelTxt.text,
                                     @"size" : sizeTxt.text,
                                     @"brandid" : [brandArray objectAtIndex:selectedBrandIndex][@"brandid"],
                                     //@"condition" : conditionTxt.text,
                                     @"condition" : [NSString stringWithFormat:@"%@",[conditionArray objectAtIndex:selectedCondtionIndex][@"id"]],
                                     @"description" :descriptionTxt.text,
                                     @"value" : valueTxt.text,
                                     @"fortrade" : forTradeStr,
                                     @"forsale" : forSaleStr,
                                     @"imagecount" : @([sneakerImageArray count])};
            LKLog(@"params = %@",params);
            
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
            
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            
            MBProgressHUD *loading = [[MBProgressHUD alloc] initWithView:self.view.window];
            [self.view.window addSubview:loading];
            [loading show:YES];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager.operationQueue cancelAllOperations];
            
            [manager POST:BASE_API parameters:@{@"data" : jsonString} constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
             {
                 for(int i=0; i<[sneakerImageArray count]; i++)
                 {
                     UIImage *image = [sneakerImageArray objectAtIndex:i];
                     [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:[NSString stringWithFormat:@"picture%d",i] fileName:[NSString stringWithFormat:@"picture%d.jpg",i] mimeType:@"image/jpeg"];
                 }
             } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 LKLog(@"JSON: %@", responseObject);
                 
                 [loading hide:YES];
                 
                 if([responseObject[@"success"] integerValue] == 1)
                 {
                     if([[NSUserDefaults standardUserDefaults] boolForKey:@"FromSideMenu"])
                     {
                         [self.navigationController.view.window makeToast:NSLocalizedString(@"sneaker_added_successfully_alert", nil)];
                         [self resetAllFields];
                     }
                     else
                     {
                         [self.navigationController.view.window makeToast:NSLocalizedString(@"sneaker_added_successfully_alert", nil)];
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                 }
                 else
                 {
                     [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"sneaker_does_not_added_successfully_alert", nil)];
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


#pragma mark UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100 && buttonIndex==0)
    {
        [self loadCameraCaptureView];
    }
    else if(alertView.tag==100 && buttonIndex==1)
    {
        [self loadPhotoGalleryView];
    }
}


#pragma mark Load camera capture view
-(void)loadCameraCaptureView
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        mediaUI.allowsEditing = NO;
        
        mediaUI.delegate = self;
        
        mediaUI.showsCameraControls = YES;
        
        [self presentViewController:mediaUI animated:YES completion:nil];
    }
    else
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"camera_not_available", nil)];
    }
}

#pragma mark Load photo gallery view
-(void)loadPhotoGalleryView
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        // Displays saved pictures and movies, if both are available, from the
        // Camera Roll album.
        mediaUI.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypePhotoLibrary];
        
        mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        mediaUI.allowsEditing = NO;
        
        mediaUI.delegate = self;
        
        [self presentViewController:mediaUI animated:YES completion:nil];
    }
    else
    {
        [Utility displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"gallery_not_available", nil)];
    }
}

#pragma mark ImagePickerViewController delegate method
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    isImageSelected = YES;
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo)
    {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        
        tempImage.image = imageToUse;
        
        //sneakerImage.image = imageToUse;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    else if(lastTextfield==sizeTxt)
    {
         titleLbl.font = [UIFont systemFontOfSize:20.0];
        titleLbl.text = [commonArray objectAtIndex:row];
    }
    else if(lastTextfield==conditionTxt)
    {
        titleLbl.font = [UIFont systemFontOfSize:13.0];
        titleLbl.text = [commonArray objectAtIndex:row][@"condition"];
    }
    else
    {
        titleLbl.font = [UIFont systemFontOfSize:13.0];
        titleLbl.text = [commonArray objectAtIndex:row];
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
    else if(lastTextfield==conditionTxt)
    {
        selectedCondtionIndex = row;
        lastTextfield.text = [commonArray objectAtIndex:row][@"condition"];
    }
    else
    {
        lastTextfield.text = [commonArray objectAtIndex:row];
    }
}


#pragma mark - CollectionView Datasource/Delegate Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.bounds.size.width, sneakerImageCollectionView.frame.size.height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [sneakerImageArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"sneakerImageCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UIImageView *sneakerImageView = (UIImageView *)[cell.contentView viewWithTag:10];
    
    if([[sneakerImageArray objectAtIndex:indexPath.row] isKindOfClass:[UIImage class]])
    {
        sneakerImageView.image = [sneakerImageArray objectAtIndex:indexPath.row];
    }
    else
    {
        /*__block UIImageView *blockThumbImage = sneakerImageView;
        
        NSString *urlStr = @"";
        if(dict[@"picture"] && [dict[@"picture"] count]>0)
        {
            urlStr = [dict[@"picture"] objectAtIndex:0][@"picture"];
        }
        
        [sneakerThumbImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             blockThumbImage.image = image;
             
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             
         }];*/
    }
    
    
    //[cell.projectImageView setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"no_image"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"AddSneakerVcToAddSneakerPhotoVc" sender:nil];
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
    
    if([descriptionTxt isFirstResponder] && !CGRectContainsPoint(rect, descriptionTxt.frame.origin))
    {
        [scroll scrollRectToVisible:descriptionTxt.frame animated:YES];
    }
    else if (!CGRectContainsPoint(rect, lastTextfield.frame.origin))
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
    
    
    if(textField==conditionTxt)
    {
        commonArray = conditionArray;
        [generalPickerView reloadAllComponents];
        
        if([conditionTxt.text length]==0)
        {
            [generalPickerView selectRow:0 inComponent:0 animated:NO];
            conditionTxt.text = [commonArray objectAtIndex:0][@"condition"];
            selectedCondtionIndex = 0;
        }
        else
        {
            //NSInteger index = [commonArray indexOfObject:conditionTxt.text];
            [generalPickerView selectRow:selectedCondtionIndex inComponent:0 animated:NO];
        }
    }
    else if(textField==brandTxt)
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
    else if(textField==sizeTxt)
    {
        commonArray = sizeArray;
        [generalPickerView reloadAllComponents];
        
        if([sizeTxt.text length]==0)
        {
            [generalPickerView selectRow:0 inComponent:0 animated:NO];
            sizeTxt.text = [commonArray objectAtIndex:0];
        }
        else
        {
            NSInteger index = [commonArray indexOfObject:sizeTxt.text];
            [generalPickerView selectRow:index inComponent:0 animated:NO];
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


#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.textColor = [UIColor blackColor];
    
    if([textView.text isEqualToString:WRITE_DESC_TEXT])
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
        textView.text = WRITE_DESC_TEXT;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"AddSneakerVcToAddSneakerPhotoVc"])
    {
        AddSneakerPhotoViewController *addSneakerPhotoVc = (AddSneakerPhotoViewController *)segue.destinationViewController;
        addSneakerPhotoVc.selectedImageArray = [[NSMutableArray alloc] initWithArray:sneakerImageArray];
    }
}


@end
