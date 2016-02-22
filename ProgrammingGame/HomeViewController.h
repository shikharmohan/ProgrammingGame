//
//  HomeViewController.h
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/21/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
//logout
- (IBAction)logoutPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

//title
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

//add friend
@property (weak, nonatomic) IBOutlet UIButton *addFriendLogo;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UILabel *opaqueMask;
- (IBAction)addFriendPressed:(id)sender;

//table view
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
