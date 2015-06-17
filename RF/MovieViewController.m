//
//  MovieViewController.m
//  RF
//
//  Created by Vincent Lai on 6/12/15.
//  Copyright (c) 2015 Vincent Lai. All rights reserved.
//

#import "MovieViewController.h"
#import "MovieCell.h"
#import <UIImageView+AFNetworking.h>
#import "ViewController.h"

@interface MovieViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;


@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
   
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredMovie.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MovieCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyMovieCell" forIndexPath:indexPath];
    NSDictionary *movie = self.filteredMovie[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"synopsis"];
    NSString *posterURLString = [movie valueForKeyPath:@"posters.thumbnail"];
    [cell.posterView setImageWithURL:[NSURL URLWithString:posterURLString]];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MovieCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *movie = self.filteredMovie[indexPath.row];
    
    ViewController *destinationVC = segue.destinationViewController;
    destinationVC.movie = movie;
}

- (NSString *)convertPosterUrlStringToHighRes:(NSString*)urlString {
    NSRange range = [urlString rangeOfString:@".*cloundfront.net/" options:NSRegularExpressionSearch];
    NSString *returnValue = urlString;
    if(range.length > 0) {
        returnValue = [urlString stringByReplacingCharactersInRange:range withString:@"http://content6.flixster.com/"];
    }
    return returnValue;
}


- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"1233333");
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName:@"www.google.com"];
    [hostReachable startNotifier];
    
    // now patiently wait for the notification
}

- (void)checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self->internetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self->internetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self->internetActive = YES;
            
            break;
        }
    }
   
    if (internetActive == YES)
    {
        [self dismissAlertMessage];
        [self loadMovieInfo];
    }
    else
    {
        [self displayAlertMessage];
    }
}

- (void)displayAlertMessage{
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"alert20.png"];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
    NSMutableAttributedString *alertText= [[NSMutableAttributedString alloc] initWithString:@"Network Error"];
    [myString appendAttributedString:alertText];
    
    self.alertLabel.attributedText = myString;
    [self.alertLabel setHidden:NO];
}

- (void)dismissAlertMessage{
    [self.alertLabel setHidden:YES];
}

- (void)loadMovieInfo{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    NSString *apiURLString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:apiURLString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.movies = dict[@"movies"];
        
        [self filterMovies];
        
        [self.tableView reloadData];
    }];
}

-(void)refresh:(UIRefreshControl *)refreshControl {
    // do something here to refresh.
    int64_t delay = 2.0; // In seconds
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        if (internetActive == YES)
        {
            [self dismissAlertMessage];
            [self loadMovieInfo];
        }
        else
        {
            [self displayAlertMessage];
        }
        [refreshControl endRefreshing];
        
        // Or put the code from doSomethingLater: inline here
    });
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    [self filterMovies];
    [self.tableView reloadData];
    if(searchText.length == 0)
        [self.movieSearch resignFirstResponder];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.movieSearch resignFirstResponder];
}

- (void) filterMovies {
    NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString* search = self.movieSearch.text;
        if ([search length] == 0) {
            return YES;
        }
        
        NSString* title = evaluatedObject[@"title"];
        
        if ([[title lowercaseString] rangeOfString:[search lowercaseString]].location != NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    }];
    
    self.filteredMovie = [self.movies filteredArrayUsingPredicate:p];
}

@end
