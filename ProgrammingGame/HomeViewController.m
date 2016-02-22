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
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
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

- (void)keyboardDidShow: (NSNotification *) notif{
    self.tableView.userInteractionEnabled = NO;
    self.logoutButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.8
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.opaqueMask.alpha = 1;
                     }
                     completion:nil];
    
}

- (void)keyboardDidHide: (NSNotification *) notif{
    self.tableView.userInteractionEnabled = YES;
    self.logoutButton.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.8
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.opaqueMask.alpha = 0;
                     }
                     completion:nil];
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
    if ([self.usernameTextField.text isEqualToString:@""]) { //nothing was entered
        self.usernameTextField.text = @"";
        self.errorMessage.text = @"No name entered!";
        [self.addFriendLogo setUserInteractionEnabled:YES];
    } else if ([self.usernameTextField.text isEqualToString:[mySession nickname]]) { //trying to add themselves
        self.usernameTextField.text = @"";
        self.errorMessage.text = @"You cannot add yourself";
        [self.addFriendLogo setUserInteractionEnabled:YES];
    } else {
        //check if user exists in usersRef
        Firebase *ref = [[Firebase alloc] initWithUrl: @"https://programminggame.firebaseio.com/usersRef"];
        [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (!snapshot.value[self.usernameTextField.text]) { //user does not exist
                self.usernameTextField.text = @"";
                self.errorMessage.text = @"Username not found";
                [self.addFriendLogo setUserInteractionEnabled:YES];
            } else { //user has been found
                //add friend request to my file
                NSString *myUid = [mySession myRootRef].authData.uid;
                NSString *friendUid = snapshot.value[self.usernameTextField.text];
                NSString *myUsername = [mySession nickname];
                NSString *friendUsername = self.usernameTextField.text;
                
                
                __block bool shouldBeTwo = NO; //if you are now friends
                //get friend's list to see if he sent a request to us
                Firebase *friendsRef = [[[[mySession myRootRef] childByAppendingPath:@"users"] childByAppendingPath:friendUid]  childByAppendingPath:@"friends"];
                [friendsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                    NSString *s = @"1";
                    if (snapshot.value[myUsername]) {//if he has added you as a friend
                        s = @"2";
                        shouldBeTwo = YES;
                    }
                    NSDictionary *status = @{
                                             @"status": s,
                                             @"uid" : myUid
                                             };
                    NSDictionary *newFriend = @{
                                                myUsername: status
                                                };
                    [friendsRef updateChildValues:newFriend];
                    
                    //get my file to see if I have already sent a request to friend
                    __block Firebase *myRef = [[[[mySession myRootRef] childByAppendingPath:@"users"] childByAppendingPath:myUid]  childByAppendingPath:@"friends"];
                    [myRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                        NSString *s = @"0";
                        if (shouldBeTwo) {
                            s = @"2";
                        } else if (snapshot.value[friendUsername]) {//if i have already added him as a friend
                            s = snapshot.value[friendUsername][@"status"];
                        }
                        
                        NSDictionary *status = @{
                                                 @"status": s,
                                                 @"uid" : friendUid
                                                 };
                        NSDictionary *newFriend = @{
                                                    friendUsername: status
                                                    };
                        [myRef updateChildValues:newFriend];
                        
                        self.usernameTextField.text = @"";
                        self.errorMessage.text = @"Friend added!";
                        
                    }];
                    [self.addFriendLogo setUserInteractionEnabled:YES];
                }];
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



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[mySession friends] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsTableViewCell *customCell = [self.tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    
    NSString *aKey = [keyArr objectAtIndex:[indexPath row]];
    customCell.friendLabel.text = aKey;
    NSString *msg = statusMessages[[mySession friends][aKey][@"status"]];
    customCell.statusMessage.text = msg;
    return customCell;
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
