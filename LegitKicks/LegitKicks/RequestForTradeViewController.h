//
//  RequestForTradeViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 01/02/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestForTradeViewController : UIViewController
{
    IBOutlet UIButton *tradeNowBtn;
    IBOutlet UIButton *askQuestionBtn;
}
@property(nonatomic, retain)NSDictionary *sneakerDict;

@end
