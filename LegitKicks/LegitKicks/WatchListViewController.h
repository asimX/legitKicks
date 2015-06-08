//
//  WishListViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 20/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WatchListViewController : UIViewController
{
    IBOutlet UICollectionView *sneakerCollectionView;
    IBOutlet UILabel *noSneakerFoundLbl;
    
    NSMutableArray *sneakerArray;
}

@end
