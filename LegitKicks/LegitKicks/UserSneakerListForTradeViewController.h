//
//  RequestForTradeViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 17/01/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSneakerListForTradeViewController : UIViewController
{
    IBOutlet UICollectionView *sneakerCollectionView;
    IBOutlet UILabel *noSneakerFoundLbl;
    
    NSMutableArray *sneakerArray;
}
@property(nonatomic, retain)NSDictionary *sneakerDict;

@end
