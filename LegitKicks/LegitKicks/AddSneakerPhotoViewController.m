//
//  AddSneakerPhotoViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 06/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "AddSneakerPhotoViewController.h"
#import "UIImage+ProportionalFill.h"
#import "AddSneakerPhotoCell.h"

@interface AddSneakerPhotoViewController ()
{
    
}

@end

@implementation AddSneakerPhotoViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Add Sneaker Photo";
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setBackButtonToNavigationBar];
    
    if(self.selectedImageArray==nil)
        self.selectedImageArray = [[NSMutableArray alloc] init];
    
    [imageTableView reloadData];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SneakerImageSelectionDone" object:self.selectedImageArray];
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)fromGalleryBtnClicked:(id)sender
{
    if([self.selectedImageArray count] < 8)
    {
        [self loadPhotoGalleryView];
    }
    else
    {
        [self.view makeToast:@"You can select maximum 8 images for sneaker."];
    }
}

-(IBAction)capturePhotoBtnClicked:(id)sender
{
    if([self.selectedImageArray count] < 8)
    {
        [self loadCameraCaptureView];
    }
    else
    {
        [self.view makeToast:@"You can select maximum 8 images for sneaker."];
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
        
        imageToUse = [imageToUse imageScaledToFitSize:CGSizeMake(600, 400)];
        [self.selectedImageArray addObject:imageToUse];
        [imageTableView reloadData];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark Tableview delegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.selectedImageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddSneakerPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sneakerImageCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.trashBtn.tag = indexPath.row;
    
    if([[self.selectedImageArray objectAtIndex:indexPath.row] isKindOfClass:[UIImage class]])
    {
        cell.sneakerImageView.image = [self.selectedImageArray objectAtIndex:indexPath.row];
    }
    else
    {
        
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(IBAction)trashBtnClicked:(id)sender
{
    NSInteger index = [sender tag];
    
    [self.selectedImageArray removeObjectAtIndex:index];
    [imageTableView reloadData];
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
