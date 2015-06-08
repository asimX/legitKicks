//
//  FlagUserViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 02/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlagUserViewController : UIViewController
{
    IBOutlet UITextView *flagDescriptionTextView;
    IBOutlet UIButton *submitBtn;
}
@property(nonatomic, retain)NSDictionary *userDict;

@end
