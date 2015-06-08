//
//  AskQuestionViewController.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 02/02/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AskQuestionViewController : UIViewController
{
    IBOutlet UITableView *conversationTable;
    IBOutlet UITextView *questionTextView;
    IBOutlet UIButton *sendBtn;
    IBOutlet NSLayoutConstraint *textviewHeightConstraint;
}
@property(nonatomic, retain)NSDictionary *sneakerDict;

@end
