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

@interface HomeViewController () <UITextFieldDelegate>

@end

@implementation HomeViewController
int numFriends;
NSDictionary *statusMessages;
NSArray *keyArr;

- (void)viewDidLoad {
    
    //observers for changes on firebase server
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"nicknameChanged"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"friendsChanged"
                                               object:nil];
    
    self.nicknameLabel.text = [mySession nickname];
    
    //table view setup
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    //status messages
    statusMessages = @{
        @"0": @"friend request sent",
        @"1" : @"accept friend request",
        @"2" : @"friends",
        @"3": @"game request sent",
        @"4": @"accept game request",
        @"5" : @"GAME ON"
        };
    
    //put observer on keybaord
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.tableView.userInteractionEnabled = YES;
    self.opaqueMask.userInteractionEnabled = NO;
    
    //retrieve friends:
    [self retrieveFriends];
    
    //retrieve game
    [self retrieveGame];
    
    [super viewDidLoad];
}

#pragma mark - Cleanup

-(void)clearMemory {
    [mySession setFriends:[[NSMutableDictionary alloc] init]];
    [mySession setNickname:@""];
    self.nicknameLabel.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Firebase Handling
-(void) retrieveFriends {
    Firebase *ref = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/friends", [mySession myRootRef].authData.uid]];
    
    // Attach a block to read the data at our friends reference
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self getFriendsArray];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)getFriendsArray {
    //update friend array
    Firebase *usersRef = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@", [mySession myRootRef].authData.uid]];
    [usersRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [mySession setFriends:snapshot.value[@"friends"]];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"friendsChanged" object:nil];
    }];
    
}

-(void) retrieveGame {
    //setup game on scenario
    Firebase *ref = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/game", [mySession myRootRef].authData.uid]];
    
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value != [NSNull null]) {
            [mySession setGame:snapshot.value];
            [self navigateToGameVC];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void)setUpGame:(NSString*)friendUsername withUid:(NSString*)uid withRef:(Firebase*)ref{
    
    NSDictionary *status = @{
                             @"uid": uid,
                             @"name" : friendUsername,
                             @"letter" : @"a",
                             @"start" :[mySession nickname]
                             };
    [[ref childByAppendingPath:@"/game"] updateChildValues:status];
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

#pragma mark - Notification Handling

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"nicknameChanged"]) {
        self.nicknameLabel.text = [mySession nickname];
        [self getFriendsArray];
        
    } else if ([[notification name] isEqualToString:@"friendsChanged"]) {
        [[mySession friends] removeObjectForKey:[mySession nickname]];
        [self sortDictionary];
        [self.tableView reloadData];
    }
}



#pragma mark - Navigation

-(void)navigateToLogin {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"loginVC"];
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)navigateToGameVC {
    Firebase *remRef = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/game", [mySession myRootRef].authData.uid]];
    [remRef removeAllObservers];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"gameVC"];
    
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - Keyboard

- (void)keyboardWillShow: (NSNotification *) notif{
    self.tableView.userInteractionEnabled = NO;
    self.logoutButton.userInteractionEnabled = NO;
    self.opaqueMask.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.opaqueMask.alpha = 1;
                     }
                     completion:nil];
    
}

- (void)keyboardWillHide: (NSNotification *) notif{
    self.tableView.userInteractionEnabled = YES;
    self.logoutButton.userInteractionEnabled = YES;
    self.opaqueMask.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.8
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.opaqueMask.alpha = 0;
                     }
                     completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.usernameTextField]) {
        [self.usernameTextField resignFirstResponder];
    }
    return NO;
}


#pragma mark - Add Friend Methods

- (IBAction)addFriendPressed:(id)sender {
    [self.addFriendLogo setUserInteractionEnabled:NO];
    NSString *usernameEntered = self.usernameTextField.text;
    self.usernameTextField.text = @"";
    if ([usernameEntered isEqualToString:@""]) { //nothing was entered
        self.errorMessage.text = @"No name entered!";
        [self.addFriendLogo setUserInteractionEnabled:YES];
    } else if ([usernameEntered isEqualToString:[mySession nickname]]) { //trying to add themselves
        self.errorMessage.text = @"You cannot add yourself";
        [self.addFriendLogo setUserInteractionEnabled:YES];
    } else {
        //check if user exists in usersRef
        Firebase *ref = [[Firebase alloc] initWithUrl: @"https://programminggame.firebaseio.com/usersRef"];
        [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (!snapshot.value[usernameEntered]) { //user does not exist
                self.errorMessage.text = @"Username not found";
                [self.addFriendLogo setUserInteractionEnabled:YES];
            } else { //user has been found
                NSString *myUid = [mySession myRootRef].authData.uid;
                NSString *friendUid = snapshot.value[usernameEntered];
                NSString *myUsername = [mySession nickname];
                NSString *friendUsername = usernameEntered;
                
                [self updateStatusFromAdd:usernameEntered withUid:myUid withFriendUid:friendUid withFriendUsername:friendUsername withMyUsername:myUsername];
            }
        }];
    }
    [self.view endEditing:YES];
    [self fadeErrorMessage];
    
}

-(void) fadeErrorMessage {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.errorMessage.alpha = 0;
                             
                         }
                         completion:^(BOOL finished) {
                             self.errorMessage.text = @"";
                             self.errorMessage.alpha = 1;
                         }];
        
    });
}

#pragma mark - Logout

- (IBAction)logoutPressed:(id)sender {
    [[mySession myRootRef] unauth];
    [self clearMemory];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Status updates

- (void) updateStatusFromAdd:(NSString *)username withUid:(NSString *)refUid withFriendUid:(NSString *)friendUid withFriendUsername:(NSString *)friendUsername withMyUsername:(NSString *)myUsername{
    Firebase *ref = [[[[mySession myRootRef] childByAppendingPath:@"users"] childByAppendingPath:refUid]  childByAppendingPath:@"friends"];
    [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value[username]) { //you are friend with that person
            NSString *snapValue = snapshot.value[username][@"status"];
            if ([snapValue isEqualToString:@"1"]) {
                [self updateStatus:@"2" withUid:friendUid withFriendUid:refUid withFriendUsername:myUsername]; //update friend list
                [self updateStatus:@"2" withUid:refUid withFriendUid:friendUid withFriendUsername:friendUsername]; //update my friend list
            }
            if ([snapValue isEqualToString:@"0"]) {
                self.errorMessage.text = @"Already sent request";
            } else if ([snapValue isEqualToString:@"1"]) {
                self.errorMessage.text = @"Accepted friend request";
            } else {
                self.errorMessage.text = @"Already friends";
            }
        } else { //you become friends
            [self updateStatus:@"0" withUid:refUid withFriendUid:friendUid withFriendUsername:friendUsername];
            [self updateStatus:@"1" withUid:friendUid withFriendUid:refUid withFriendUsername:myUsername];
            self.errorMessage.text = @"Friend added!";
        }
        [self.addFriendLogo setUserInteractionEnabled:YES];
    }];
}

-(void) updateStatus:(NSString *)s withUid:(NSString *)refUid withFriendUid:(NSString *)friendUid withFriendUsername:(NSString *)friendUsername {
    Firebase *ref = [[[[mySession myRootRef] childByAppendingPath:@"users"] childByAppendingPath:refUid]  childByAppendingPath:@"friends"];
    if ([s isEqualToString:@"-1"]) {
        [[ref childByAppendingPath:friendUsername] removeValue];
    } else if ([s isEqualToString:@"-2"]) {
        //do nothing
    } else {
        NSDictionary *status = @{
                                 @"status": s,
                                 @"uid" : friendUid
                                 };
        
        NSDictionary *updatedFriend = @{
                                        friendUsername: status
                                        };
        [ref updateChildValues:updatedFriend withCompletionBlock:^(NSError *error, Firebase *ref) {
            if (error) {
                NSLog(@"Error updating status%@", error);
            }
            
        }];
        if ([s isEqualToString:@"5"]) {
            [self setUpGame:friendUsername withUid:friendUid withRef:[[[mySession myRootRef] childByAppendingPath:@"users"] childByAppendingPath:refUid]];
        }
    }
    
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[mySession friends] count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsTableViewCell *customCell = [self.tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    
    NSString *aKey = [keyArr objectAtIndex:[indexPath row]];
    customCell.friendLabel.text = aKey;
    NSString *msg = statusMessages[[mySession friends][aKey][@"status"]];
    customCell.statusMessage.text = msg;
    return customCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"wants to delete user");
        //add code here for when you hit delete
    }
}


-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unfriend" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        //remove friendhsip
                                        FriendsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                                        NSString *myUid = [mySession myRootRef].authData.uid;
                                        NSString *friendUid = [mySession friends][cell.friendLabel.text][@"uid"];
                                        NSString *myUsername = [mySession nickname];
                                        NSString *friendUsername = cell.friendLabel.text;
                                        
                                        //update friend list
                                        [self updateStatus:@"-1" withUid:friendUid withFriendUid:myUid withFriendUsername:myUsername];
                                        
                                        //update my friend list
                                        [self updateStatus:@"-1" withUid:myUid withFriendUid:friendUid withFriendUsername:friendUsername];
                                        self.errorMessage.text = [NSString stringWithFormat:@"Unfriended %@", friendUsername];
                                        [self fadeErrorMessage];
                                    }];
    deleteBtn.backgroundColor = [UIColor  lightGrayColor];
    
    return @[deleteBtn];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *reverseStatus = @{
                      @"friend request sent" : @"0",
                      @"accept friend request" : @"1",
                      @"friends" : @"2",
                      @"game request sent" : @"3",
                      @"accept game request" : @"4",
                      @"GAME ON" : @"5"
                      };
    NSDictionary *statusEquivalence = @{
                          @"0" : @"-2",
                          @"1" : @"2",
                          @"2" : @"3",
                          @"3": @"2",
                          @"4": @"5",
                          @"5": @"5",
                          };
    NSDictionary *friendEquivalence = @{
                          @"0" : @"-2",
                          @"1" : @"2",
                          @"2" : @"4",
                          @"3": @"2",
                          @"4": @"5",
                          @"5": @"5",
                          };
    
    FriendsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *myUid = [mySession myRootRef].authData.uid;
    NSString *friendUid = [mySession friends][cell.friendLabel.text][@"uid"];
    NSString *myUsername = [mySession nickname];
    NSString *friendUsername = cell.friendLabel.text;
    NSString *cellStatus = reverseStatus[cell.statusMessage.text];
    NSString *friendStatus = friendEquivalence[cellStatus];
    NSString *myStatus = statusEquivalence[cellStatus];
    
    //update friend list
    [self updateStatus:friendStatus withUid:friendUid withFriendUid:myUid withFriendUsername:myUsername];
    
    //update my friend list
    [self updateStatus:myStatus withUid:myUid withFriendUid:friendUid withFriendUsername:friendUsername];
    
    if ([cellStatus isEqualToString:@"0"]) {
        self.errorMessage.text = @"Already sent request";
    } else if ([cellStatus isEqualToString:@"1"]) {
        self.errorMessage.text = @"Accepted friend request";
    } else if ([cellStatus isEqualToString:@"2"]) {
        self.errorMessage.text = @"Sent game request";
    } else if ([cellStatus isEqualToString:@"4"]) {
        self.errorMessage.text = @"Accepted game request";
    }
    [self fadeErrorMessage];
}

@end
