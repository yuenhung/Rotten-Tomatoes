//
//  MovieViewController.h
//  RF
//
//  Created by Vincent Lai on 6/12/15.
//  Copyright (c) 2015 Vincent Lai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface MovieViewController : UIViewController
{
    Reachability* internetReachable;
    Reachability* hostReachable;
    BOOL internetActive;
    BOOL hostActive;
}
@property (weak, nonatomic) IBOutlet UISearchBar *movieSearch;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSArray *filteredMovie;
@property BOOL isFiltered;

- (void)checkNetworkStatus:(NSNotification *)notice;
- (void)displayAlertMessage;
- (void)dismissAlertMessage;
- (void)loadMovieInfo;
- (void)refresh:(UIRefreshControl *)refreshControl;


@end