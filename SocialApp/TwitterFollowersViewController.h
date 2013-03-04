//
//  TwitterFollowersViewController.h
//  SocialApp
//
//  Created by ben on 3/2/13.
//  Copyright (c) 2013 NSScreencast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

/**
 `TwitterFollowersViewController` is a subclass of `UITableView` for showing the followers & avatars
 of a twitter account.
 
 ## Usage
 
 This view controller requires an `ACAccountStore` to be provided via the `accountStore` property
 before the controller is displayed.
 
 This view controller does not handle the `ACAccountStoreDidChangeNotification` however it may be
 dismissed if the presenting view controller listens for this notification.
 
 ## Limitations
 
 @warning This controller assumes there is only one twitter account in settings.  If multiple are present the last one added will be used.
 
 @warning Only the first 100 followers are listed.
*/
 
@interface TwitterFollowersViewController : UITableViewController

/** Sets the account store that is used to interact with twitter.
@property (nonatomic, strong) ACAccountStore *accountStore;

@end
