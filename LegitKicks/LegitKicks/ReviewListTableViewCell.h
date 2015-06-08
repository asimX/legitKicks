//
//  ReviewListTableViewCell.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 02/04/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface ReviewListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLbl;
@property (weak, nonatomic) IBOutlet UILabel *reviewDescLbl;
@property (weak, nonatomic) IBOutlet UILabel *reviewDateLbl;
@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;
@end
