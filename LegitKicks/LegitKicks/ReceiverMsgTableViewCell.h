//
//  ReceiverMsgTableViewCell.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 02/02/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiverMsgTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *msgBackView;
@property (weak, nonatomic) IBOutlet UITextView *msgTextview;
@property (weak, nonatomic) IBOutlet UILabel *msgLbl;
@property (weak, nonatomic) IBOutlet UILabel *msgDateTimeLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgTextviewHeightConstraint;
@end
