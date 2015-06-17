//
//  ViewController.m
//  RF
//
//  Created by Vincent Lai on 6/12/15.
//  Copyright (c) 2015 Vincent Lai. All rights reserved.
//

#import "ViewController.h"
#import <UIImageView+AFNetworking.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.movie[@"title"];
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"synopsis"];
    
    NSString *posterURLString = [self.movie valueForKeyPath:@"posters.thumbnail"];
    [self.posterView setImageWithURL:[NSURL URLWithString:posterURLString]];
    
    posterURLString = [self.movie valueForKeyPath:@"posters.detailed"];
    posterURLString = [self convertPosterUrlStringToHighRes:posterURLString];
    [self.posterView setImageWithURL:[NSURL URLWithString:posterURLString]];
    // Do any additional setup after loading the view, typically from a nib.
    //NSString *apiURLString = ;
    
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:apiURLString
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)convertPosterUrlStringToHighRes:(NSString*)urlString {
    NSRange range = [urlString rangeOfString:@".*cloudfront.net/" options:NSRegularExpressionSearch];
    NSString *returnValue = urlString;
    if(range.length > 0) {
        returnValue = [urlString stringByReplacingCharactersInRange:range withString:@"https://content6.flixster.com/"];
    }
    return returnValue;
}




@end
