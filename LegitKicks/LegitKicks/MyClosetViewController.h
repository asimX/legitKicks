//
//  MyClosetViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 20/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyClosetViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIImageView *topBackgroundImageView;
    IBOutlet UIButton *addBannerBtn;
    IBOutlet UIImageView *profileImageView;
    IBOutlet UIButton *profileBtn;
    IBOutlet UIView *tabView;
    IBOutlet UILabel *sneakerLbl;
    IBOutlet UILabel *sneakerCountLbl;
    IBOutlet UILabel *followingLbl;
    IBOutlet UILabel *followingCountLbl;
    IBOutlet UIButton *sneakerTabBtn;
    IBOutlet UIButton *followingTabBtn;
    IBOutlet UIImageView *tabSelectionImage;
    IBOutlet NSLayoutConstraint *selectionImageLeadingConstraint;
    
    IBOutlet UICollectionView *closetCollectionView;
    
}

@end
