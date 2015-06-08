//
//  AddSneakerPhotoViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 06/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddSneakerPhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UITableView *imageTableView;
}
@property(nonatomic, retain)NSMutableArray *selectedImageArray;
@end
