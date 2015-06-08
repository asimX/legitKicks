//
//  ClosetDetailViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 13/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClosetDetailViewController : UIViewController
{
    IBOutlet UIImageView *topBackgroundImageView;
    IBOutlet UIImageView *profileImageView;
    IBOutlet UIView *tabView;
    IBOutlet UILabel *sneakerLbl;
    IBOutlet UILabel *sneakerCountLbl;
    IBOutlet UILabel *followingLbl;
    IBOutlet UILabel *followingCountLbl;
    IBOutlet UIButton *sneakerTabBtn;
    IBOutlet UIButton *followingTabBtn;
    IBOutlet UIImageView *tabSelectionImage;
    IBOutlet NSLayoutConstraint *selectionImageLeadingConstraint;
    IBOutlet UIButton *followBtn;
    
    IBOutlet UICollectionView *closetCollectionView;
    
}
@property(nonatomic, retain)NSString *closetid;

@end
