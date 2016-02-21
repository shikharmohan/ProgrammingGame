//
//  AddFriendViewController.m
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/21/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "AddFriendViewController.h"
#import "MySession.h"

#define mySession [MySession sharedManager]

@interface AddFriendViewController () <UITextFieldDelegate>

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameTextField.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.usernameTextField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.usernameTextField]) {
        [self.usernameTextField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (IBAction)addFriend:(id)sender {
    if ([self.usernameTextField.text isEqualToString:@""]) {
        self.usernameTextField.text = @"";
        self.errorMessage.text = @"No name entered!";
        self.errorMessage.hidden = NO;
    } else if ([self.usernameTextField.text isEqualToString:[mySession nickname]]) {
        self.usernameTextField.text = @"";
        self.errorMessage.text = @"You cannot add yourself";
        self.errorMessage.hidden = NO;
    } else {
        //check if user exists
        Firebase *ref = [[Firebase alloc] initWithUrl: @"https://programminggame.firebaseio.com/usersRef"];
        [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (!snapshot.value[self.usernameTextField.text]) { //aka the name is not found
                self.usernameTextField.text = @"";
                self.errorMessage.text = @"Username not found";
                self.errorMessage.hidden = NO;
            } else {
                //add friend request to my file
                NSString *myUid = [mySession myRootRef].authData.uid;
                NSString *friendUid = snapshot.value[self.usernameTextField.text];
                NSString *myUsername = [mySession nickname];
                NSString *friendUsername = self.usernameTextField.text;
                
                
                __block bool shouldBeTwo = NO;
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
                        self.errorMessage.hidden = NO;
                        [[NSNotificationCenter defaultCenter] postNotificationName: @"friendAdded" object:nil];
                        
                    }];
                    
                }];
                
                
                
                
                
            }
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.errorMessage.hidden = YES;
    });
    

}
@end
