//
//  ReviewListTableViewCell.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 02/04/15.
//  Copyright (c) 2015 Sunil Zalavadiya. All rights reserved.
//

#import "ReviewListTableViewCell.h"

@implementation ReviewListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    _ratingView.starImage = [UIImage imageNamed:@"unrated_sneaker_ic20x20"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rated_sneaker_ic20x20"];
    _ratingView.maxRating = 5.0;
    _ratingView.horizontalMargin = 0;
    _ratingView.editable=NO;
    _ratingView.rating= 0.0;
    _ratingView.displayMode=EDStarRatingDisplayAccurate;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
