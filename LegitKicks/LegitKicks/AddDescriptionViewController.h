//
//  AddDescriptionViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 06/08/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMTextView.h"

@class AddDescriptionViewController;

@protocol AddDescVcDelegate <NSObject>

-(void)addDesc:(NSString *)descStr viewController:(AddDescriptionViewController *)viewController;

@end

@interface AddDescriptionViewController : UIViewController
{
    IBOutlet SAMTextView *descriptionTxt;
    IBOutlet UIButton *submitBtn;
}

@property(nonatomic, weak)id<AddDescVcDelegate> delegate;

@end
