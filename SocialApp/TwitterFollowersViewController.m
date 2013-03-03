//
//  TwitterFollowersViewController.m
//  SocialApp
//
//  Created by ben on 3/2/13.
//  Copyright (c) 2013 NSScreencast. All rights reserved.
//

#import "TwitterFollowersViewController.h"
#import "TwitterFollowerCell.h"
#import "UIImageView+AFNetworking.h"
#import <Social/Social.h>

@interface TwitterFollowersViewController ()

@property (nonatomic, strong) NSDictionary *followerDictionary;

@end

@implementation TwitterFollowersViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (UIBarButtonItem *)doneButton {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                         target:self
                                                         action:@selector(onDone:)];
}

- (UIBarButtonItem *)tweetButton {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                         target:self
                                                         action:@selector(onCompose:)];
}

- (void)onDone:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)onCompose:(id)sender {
    NSString *tweetText = @"I'm tweeting from iOS 6 😏";
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:tweetText];
    [self presentViewController:tweetSheet
                       animated:YES
                     completion:^{
                         NSLog(@"Done tweeting");
                     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Twitter Followers";
    self.navigationItem.rightBarButtonItem = [self doneButton];
    self.navigationItem.leftBarButtonItem = [self tweetButton];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.576 blue:0.752 alpha:1.000];
    
    [self.tableView registerClass:[TwitterFollowerCell class]
           forCellReuseIdentifier:@"Cell"];
    
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [store requestAccessToAccountsWithType:twitterAccountType
                                   options:nil
                                completion:^(BOOL granted, NSError *error) {
                                    if (granted) {
                                        [self fetchTwitterFollowers];
                                    } else {
                                        NSLog(@"Not granted: %@", [error localizedDescription]);
                                    }
                                }];
}

- (void)fetchTwitterFollowers {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"];
    NSDictionary *params = @{@"screen_name": @"nsscreencast", @"skip_status": @"1", @"count":@"100"};
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *accounts = [self.accountStore accountsWithAccountType:twitterAccountType];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:params];
    [request setAccount:[accounts lastObject]];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                NSError *jsonError = nil;
                NSDictionary *followerData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                             options:NSJSONReadingAllowFragments
                                                                               error:&jsonError];
                if (followerData) {
                    // NSLog(@"Response: %@", followerData);
                    self.followerDictionary = followerData;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                } else {
                    NSLog(@"JSON Parsing error: %@", jsonError);
                }
            } else {
                NSLog(@"Server returned HTTP %d", urlResponse.statusCode);
            }
        } else {
            NSLog(@"Something went wrong: %@", [error localizedDescription]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    }];
}

#pragma mark - Table view data source

- (NSArray *)followers {
    return self.followerDictionary[@"users"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count =[[self followers] count];
    NSLog(@"got %u users", count);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *follower = [self followers][indexPath.row];
    cell.textLabel.text = follower[@"screen_name"];
    cell.detailTextLabel.text = follower[@"description"];
    
    NSURL *imageUrl = URLIFY(follower[@"profile_image_url"]);
    UIImage *defaultImage = [UIImage imageNamed:@"twitter_avatar.png"];
    cell.imageView.contentMode = UIViewContentModeCenter;
    [cell.imageView setImageWithURL:imageUrl placeholderImage:defaultImage];
    
    return cell;
}

@end
