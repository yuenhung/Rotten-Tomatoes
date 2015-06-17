//
//  MovieCell.m
//  RF
//
//  Created by Vincent Lai on 6/12/15.
//  Copyright (c) 2015 Vincent Lai. All rights reserved.
//

#import "MovieCell.h"

@implementation MovieCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.posterView.image = nil;
}

@end
