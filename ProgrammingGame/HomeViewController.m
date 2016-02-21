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
NSDictionary *statusMessages;
NSArray *keyArr;

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
    
    //status messages
    statusMessages = @{
        @"0": @"friend request sent",
        @"1" : @"accept friend request",
        @"2" : @"friends",
        @"3": @"game request sent",
        @"4": @"accept game request",
        @"5" : @"GAME ON"
        };
    
    //retrieve friends:
    Firebase *ref = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/friends", [mySession myRootRef].authData.uid]];
    // Attach a block to read the data at our friends reference
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self getFriendsArray];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    //setup game on scenario
    ref = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/game", [mySession myRootRef].authData.uid]];
    // Attach a block to read the data at our friends reference
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self navigateToGameVC];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
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

- (void) sortDictionary {
    NSArray *myArray  = [[mySession friends] keysSortedByValueUsingComparator: ^(NSDictionary *obj1, NSDictionary *obj2) {
        
        if ([obj1[@"status"] intValue] > [obj2[@"status"] intValue]) {
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        if ([obj1[@"status"] intValue] < [obj2[@"status"] intValue]) {
            
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    keyArr = myArray;
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"nicknameChanged"]) {
        NSLog(@"Receivved nickname changed notif");
        self.nicknameLabel.text = [mySession nickname];
        [self getFriendsArray];
        
    } else if ([[notification name] isEqualToString:@"friendsChanged"]) {
        NSLog(@"Receivved friends arr changed notif");
        [[mySession friends] removeObjectForKey:[mySession nickname]];
        [self sortDictionary];
        [self.tableView reloadData];
    } else if ([[notification name] isEqualToString:@"friendAdded"]) {
        NSLog(@"Receivved friends added notif");
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
                                                               self.addFriendView.frame.size.height + 80);
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
                                                               self.addFriendView.frame.size.height - 80);
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
-(void)navigateToGameVC {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"gameVC"];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsTableViewCell *customCell = [self.tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    
    NSString *aKey = [keyArr objectAtIndex:[indexPath row]];
    customCell.friendLabel.text = aKey;
    NSLog(@"Message status %@", [mySession friends][aKey][@"status"]);
    NSString *msg = statusMessages[[mySession friends][aKey][@"status"]];
    customCell.statusMessage.text = msg;
    return customCell;
}




-(void)setUpGame:(NSString*)friendUsername withUid:(NSString*)uid withRef:(Firebase*)ref{
    
        NSDictionary *status = @{
                                 @"uid": uid,
                                 @"name" : friendUsername
                                 };
    [[ref childByAppendingPath:@"/game"] updateChildValues:status];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FriendsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    //add friend request to my file
    NSString *myUid = [mySession myRootRef].authData.uid;
    NSString *friendUid = [mySession friends][cell.friendLabel.text][@"uid"];
    NSString *myUsername = [mySession nickname];
    NSString *friendUsername = cell.friendLabel.text;
    
    
    if ([cell.statusMessage.text isEqualToString:statusMessages[@"2"]] || [cell.statusMessage.text isEqualToString:statusMessages[@"1"]] || [cell.statusMessage.text isEqualToString:statusMessages[@"4"]]) {
        //get friend's list to see if he sent a request to us
        Firebase *friendsRef = [[[[mySession myRootRef] childByAppendingPath:@"users"] childByAppendingPath:friendUid]  childByAppendingPath:@"friends"];
        [friendsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSString *s;
            if ([cell.statusMessage.text isEqualToString:statusMessages[@"1"]]) { //you are accepting his friend request
                s = @"2";
            } else if ([cell.statusMessage.text isEqualToString:statusMessages[@"4"]]) { // you are accepting his game request
                s = @"5";
                [self setUpGame:myUsername withUid:myUid withRef:[[[mySession myRootRef] childByAppendingPath:@"users"] childByAppendingPath:friendUid]];
            } else { //you are sending a game request
                s = @"4";
            }
           
            NSDictionary *status = @{
                                     @"status": s,
                                     @"uid" : myUid
                                     };
            NSDictionary *newFriend = @{
                                        myUsername: status
                                        };
            [friendsRef updateChildValues:newFriend];
            
        }];
        
        //get my file to see if I have already sent a request to friend
        __block Firebase *myRef = [[[[mySession myRootRef] childByAppendingPath:@"users"] childByAppendingPath:myUid]  childByAppendingPath:@"friends"];
        [myRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSString *s;
            if ([cell.statusMessage.text isEqualToString:statusMessages[@"1"]]) { //you are accepting his friend request
                s = @"2";
            } else if ([cell.statusMessage.text isEqualToString:statusMessages[@"4"]]) { // you are accepting his game request
                s = @"5";
                [self setUpGame:friendUsername withUid:friendUid withRef:[[[mySession myRootRef] childByAppendingPath:@"users"] childByAppendingPath:myUid]];
            } else { //you are sending a game request
                s = @"3";
            }
            
            NSDictionary *status = @{
                                     @"status": s,
                                     @"uid" : friendUid
                                     };
            NSDictionary *newFriend = @{
                                        friendUsername: status
                                        };
            [myRef updateChildValues:newFriend];
            
        }];


    }
    
    
    
}

@end
