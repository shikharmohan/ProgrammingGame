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
    [self.bckLabel.layer setCornerRadius:10];
    self.bckLabel.layer.masksToBounds = YES;
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
    } else {
        //check if user exists
        Firebase *ref = [[Firebase alloc] initWithUrl: @"https://programminggame.firebaseio.com/usersRef"];
        [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (!snapshot.value[self.usernameTextField.text]) { //aka the name is not found
                self.usernameTextField.text = @"";
                self.errorMessage.text = @"'s username not found";
                self.errorMessage.hidden = NO;
            } else {
                //add user to friend list of current user
                Firebase *usersRef = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/friends", [mySession myRootRef].authData.uid]];
                NSDictionary *updatedDict = @{
                                              self.usernameTextField.text :snapshot.value[self.usernameTextField.text]
                                              };
                [usersRef updateChildValues: updatedDict];
                
                //update friend array
                usersRef = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@", [mySession myRootRef].authData.uid]];
                [usersRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                    [mySession setFriends:snapshot.value[@"friends"]];
                    NSLog(@"friends array updated: %@", [mySession friends]);
                    [[NSNotificationCenter defaultCenter] postNotificationName: @"friendsChanged" object:nil];
                }];
                self.usernameTextField.text = @"";
                self.errorMessage.text = @" added!";
                
            }
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.errorMessage.hidden = YES;
    });
    

}
@end
