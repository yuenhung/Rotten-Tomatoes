//
//  MovieCell.h
//  RF
//
//  Created by Vincent Lai on 6/12/15.
//  Copyright (c) 2015 Vincent Lai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

@end
