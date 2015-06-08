//
//  AddSneakerViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 28/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddSneakerViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UICollectionView *sneakerImageCollectionView;
    IBOutlet UILabel *addPhotoLbl;
    IBOutlet UITextField *brandTxt;
    IBOutlet UITextField *modelTxt;
    IBOutlet UITextField *conditionTxt;
    IBOutlet UITextField *sizeTxt;
    IBOutlet UITextField *valueTxt;
    IBOutlet UITextView *descriptionTxt;
    IBOutlet UISegmentedControl *sneakerForSegmentControl;
    IBOutlet UIButton *addSneakerBtn;
    
    UIPickerView *generalPickerView;
}

@end
