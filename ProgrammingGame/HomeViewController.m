//
//  HomeViewController.m
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/21/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "HomeViewController.h"
#import "MySession.h"
#import "FriendsTableViewCell.h"

#define mySession [MySession sharedManager]

@interface HomeViewController ()

@end

@implementation HomeViewController
bool isContainerOpen;
int numFriends;

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"nicknameChanged"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"friendsChanged"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"friendAdded"
                                               object:nil];
    self.nicknameLabel.text = [mySession nickname];
    self.addFriendView.translatesAutoresizingMaskIntoConstraints = YES;
    isContainerOpen = NO;
    self.addFriendView.frame = CGRectMake( self.addFriendView.frame.origin.x,
                             self.addFriendView.frame.origin.y,
                             self.addFriendView.frame.size.width,0);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getFriendsArray {
    //update friend array
    Firebase *usersRef = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@", [mySession myRootRef].authData.uid]];
    [usersRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [mySession setFriends:snapshot.value[@"friends"]];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"friendsChanged" object:nil];
    }];

}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"nicknameChanged"]) {
        NSLog(@"Recieved nickname changed notif");
        self.nicknameLabel.text = [mySession nickname];
        [self getFriendsArray];
        
    } else if ([[notification name] isEqualToString:@"friendsChanged"]) {
        [self.tableView reloadData];
    } else if ([[notification name] isEqualToString:@"friendAdded"]) {
        [self closeContainer];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)navigateToLogin {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"loginVC"];
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(void) openContainer {
    [self.logoutButton setUserInteractionEnabled:NO];
    [self.tableView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.opaqueMask.alpha = 1;
                     }];
    
    self.addFriendView.hidden = NO;
    [self.addFriendLogo setTitle:@"x" forState:UIControlStateNormal];
    UIView* viewB = [[self.childViewControllers.lastObject view] superview];
    [UIView animateWithDuration:1.0
                     animations:^{
                         viewB.frame = CGRectMake( self.addFriendView.frame.origin.x,
                                                               self.addFriendView.frame.origin.y,
                                                               self.addFriendView.frame.size.width,
                                                               self.addFriendView.frame.size.height + 145);
                     }
                     completion:^(BOOL finished){
                         [self.addFriendLogo setEnabled:YES];
                         isContainerOpen = YES;
                         viewB.userInteractionEnabled = YES;
                         // whatever you need to do when animations are complete
                     }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)closeContainer {
    [self.view endEditing:YES];
    [self.addFriendLogo setTitle:@"+" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.opaqueMask.alpha = 0;
                     }];
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.addFriendView.frame = CGRectMake( self.addFriendView.frame.origin.x,
                                                               self.addFriendView.frame.origin.y,
                                                               self.addFriendView.frame.size.width,
                                                               self.addFriendView.frame.size.height - 145);
                     }
                     completion:^(BOOL finished){
                         [self.logoutButton setUserInteractionEnabled:YES];
                         [self.tableView setUserInteractionEnabled:YES];
                         [self.addFriendLogo setEnabled:YES];
                         [self.addFriend setEnabled:YES];
                         isContainerOpen = NO;
                         self.addFriendView.hidden = YES;
                         // whatever you need to do when animations are complete
                     }];
}

- (IBAction)addFriendPressed:(id)sender {
    [self.addFriend setEnabled:NO];
    [self.addFriendLogo setEnabled:NO];
    if (!isContainerOpen) {
        [self openContainer];
    }
    
    

}

-(void)clearMemory {
    [mySession setFriends:[[NSMutableDictionary alloc] init]];
    [mySession setNickname:@""];
    self.nicknameLabel.text = @"";
}

- (IBAction)logoutPressed:(id)sender {
    [[mySession myRootRef] unauth];
    [self clearMemory];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)addCancellPressed:(id)sender {
    if (isContainerOpen) {
        [self closeContainer];
    } else {
        [self openContainer];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [[mySession friends] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsTableViewCell *customCell = [self.tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    
    NSArray *keys = [[mySession friends] allKeys];
    NSString *aKey = [keys objectAtIndex:[indexPath row]];
    customCell.friendLabel.text = aKey;
    return customCell;
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath
                    animated:(BOOL)animated
              scrollPosition:(UITableViewScrollPosition)scrollPosition {
    
}

@end
