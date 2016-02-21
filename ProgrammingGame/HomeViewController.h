//
//  HomeViewController.h
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/21/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
- (IBAction)addFriendPressed:(id)sender;
- (IBAction)logoutPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addFriend;
@property (weak, nonatomic) IBOutlet UIButton *addFriendLogo;
@property (weak, nonatomic) IBOutlet UIView *addFriendView;
- (IBAction)addCancellPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;


@property (weak, nonatomic) IBOutlet UILabel *opaqueMask;
@end
