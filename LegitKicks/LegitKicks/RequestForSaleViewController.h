//
//  RequestForSaleViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 16/01/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestForSaleViewController : UIViewController
{
    IBOutlet UIButton *purchaseNowBtn;
    IBOutlet UITextField *offerTxt;
    IBOutlet UIButton *makeOfferBtn;
    IBOutlet UIButton *askQuestionBtn;
}
@property(nonatomic, retain)NSDictionary *sneakerDict;

@end
