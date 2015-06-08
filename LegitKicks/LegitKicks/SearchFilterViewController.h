//
//  SearchFilterViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 07/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchFilterViewController : UIViewController
{
    IBOutlet UIScrollView *scroll;
    IBOutlet UILabel *filtersLbl;
    IBOutlet UILabel *brandLbl;
    IBOutlet UITextField *brandTxt;
    IBOutlet UILabel *sizeLbl;
    IBOutlet UILabel *selectedSizeLbl;
    IBOutlet UILabel *conditionLbl;
    IBOutlet UILabel *selectedConditionLbl;
    IBOutlet UILabel *priceLbl;
    IBOutlet UITextField *minimumPriceTxt;
    IBOutlet UITextField *maximumPriceTxt;
    IBOutlet UISegmentedControl *searchTypeSegmentControl;
    IBOutlet UILabel *sortLbl;
    IBOutlet UISegmentedControl *sortTypeSegmentControl;
    IBOutlet UIButton *searchBtn;
}

@end
