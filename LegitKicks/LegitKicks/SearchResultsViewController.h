//
//  SearchResultsViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 09/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsViewController : UIViewController
{
    IBOutlet UISearchBar *searchbar;
    IBOutlet UICollectionView *sneakerCollectionView;
    IBOutlet UILabel *noSneakerFoundLbl;
    
    NSMutableArray *sneakerArray;
}
@property(nonatomic, retain)NSDictionary *filterDict;
@property(nonatomic, retain)NSString *searchString;

@end
