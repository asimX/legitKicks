//
//  HomeViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 16/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController
{
    IBOutlet UIView *topTabView;
    IBOutlet UIButton *forTradeTabBtn;
    IBOutlet UIButton *forSaleTabBtn;
    IBOutlet UIImageView *tabSelectionImage;
    IBOutlet UICollectionView *sneakerCollectionView;
    IBOutlet NSLayoutConstraint *selectionImageLeadingConstraint;
    IBOutlet UISearchBar *searchbar;
    IBOutlet UILabel *noSneakerFoundLbl;
    
    NSMutableArray *sneakerArray;
    NSMutableArray *sneakerForTradeArray;
    NSMutableArray *sneakerForSaleArray;
}

@end
