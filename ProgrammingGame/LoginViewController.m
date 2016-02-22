//
//  LoginViewController.m
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/20/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "LoginViewController.h"
#import "MySession.h"

#define mySession [MySession sharedManager]

@interface LoginViewController () <UITextFieldDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //round confirm button
    self.confirmButton.clipsToBounds = YES;
    self.confirmButton.layer.cornerRadius = 5;
    
    //set up text fields
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.nicknameTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [self resetView];
}

#pragma mark - View Setup

-(void) clearTextFields {
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
    self.nicknameTextField.text = @"";
}


-(void) resetView {
    [self clearTextFields];
    
    //reset title + signup button titles
    self.titleLabel.text = @"Login";
    [self.signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    
    //hide nickname
    self.nicknameTextField.alpha = 0;
    
    //bring all text fields + button to original positions
    self.usernameTextField.transform = CGAffineTransformMakeTranslation(0, 0);
    self.passwordTextField.transform = CGAffineTransformMakeTranslation(0, 0);
    self.signupButton.transform = CGAffineTransformMakeTranslation(0, 0);
    self.confirmButton.transform = CGAffineTransformMakeTranslation(0, 0);
    
    [self resignKeyboards];
}


#pragma mark - Keyboard Setup

-(void)resignKeyboards {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.nicknameTextField resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignKeyboards];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.nicknameTextField]) {
        [self.usernameTextField becomeFirstResponder];
    } else if ([textField isEqual:self.usernameTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

#pragma mark - View animations

-(void)signUpTransitionDown {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         //show nickname
                         self.nicknameTextField.alpha = 1;
                         
                         //set position of text fields + button down
                         self.nicknameTextField.transform = CGAffineTransformMakeTranslation(0, 70);
                         self.usernameTextField.transform = CGAffineTransformMakeTranslation(0, 70);
                         self.passwordTextField.transform = CGAffineTransformMakeTranslation(0, 70);
                         self.signupButton.transform = CGAffineTransformMakeTranslation(0, 70);
                         self.confirmButton.transform = CGAffineTransformMakeTranslation(0, 70);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

-(void)signUpTransitionUp {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         //hide nickname
                         self.nicknameTextField.alpha = 0;
                         
                         //set position of text fields + button back to orignal pos
                         self.nicknameTextField.transform = CGAffineTransformMakeTranslation(0, 0);
                         self.usernameTextField.transform = CGAffineTransformMakeTranslation(0, 0);
                         self.passwordTextField.transform = CGAffineTransformMakeTranslation(0, 0);
                         self.signupButton.transform = CGAffineTransformMakeTranslation(0, 0);
                         self.confirmButton.transform = CGAffineTransformMakeTranslation(0, 0);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - Navigation

-(void)navigateToMainVC {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
 
    UIViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"homeVC"];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Login & sign up

-(void) fadeErrorMessage {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.errorMessageLabel.alpha = 0;
                             
                         }
                         completion:^(BOOL finished) {
                             self.errorMessageLabel.text = @"";
                             self.errorMessageLabel.alpha = 1;
                         }];

    });
}

- (IBAction)pressedSignup:(id)sender {
    [self resignKeyboards];
    [self.signupButton setEnabled:NO];
    if ([self.titleLabel.text isEqualToString:@"Sign Up"]) { //cancel pressed - go back to login screen
        //change titles
        self.titleLabel.text = @"Login";
        [self.signupButton setTitle:@"Sign up" forState:UIControlStateNormal];
        
        //clear + transition
        [self clearTextFields];
        [self signUpTransitionUp];
    } else { //sign up pressed - go to signup screen
        //change titles
        self.titleLabel.text = @"Sign Up";
        [self.signupButton setTitle:@"Cancel" forState:UIControlStateNormal];
        
        //transition
        [self signUpTransitionDown];
        
    }
    [self.signupButton setEnabled:YES];
    
}

- (void)signUpUser {
    [[mySession myRootRef] createUser:self.usernameTextField.text password:self.passwordTextField.text
             withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
                 if (error) {
                     // There was an error creating the account
                     NSLog(@"Error - %@", error);
                     self.errorMessageLabel.text = @"Sign up error";
                     self.passwordTextField.text = @"";
                     self.usernameTextField.text = @"";
                     
                     [self fadeErrorMessage];
                     
                 } else {
                     self.errorMessageLabel.text = @"Sign up Successful";
                     [self loginUser:self.nicknameTextField.text];
                 }
             }];
    [self.confirmButton setEnabled:YES];
}

-(void) loginSuccess {
    self.errorMessageLabel.text = @"Login Successful";
    [self navigateToMainVC];
    // We are now logged in
}

- (void)loginUser:(NSString *)nickname {
    [[mySession myRootRef] authUser:self.usernameTextField.text password:self.passwordTextField.text
    withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            // There was an error logging in to this account
            NSLog(@"Error logging in - %@", error);
            
            self.errorMessageLabel.text = @"Invalid email/password";
            self.passwordTextField.text = @"";
            self.usernameTextField.text = @"";
        } else if (nickname) {
            //add nickname to usersRef
            Firebase *usersRef = [[mySession myRootRef] childByAppendingPath: @"usersRef"];
            NSDictionary *tempFriends = @{
                                          nickname:@"temp"
                                          };
            NSDictionary *updatedDict = @{
                                       nickname: authData.uid,
                                       };
            [usersRef updateChildValues: updatedDict];
            
            //set up user
            NSDictionary *newUser = @{
                                      @"nickname":nickname,
                                      @"friends": tempFriends
                                      };
            [[[[mySession myRootRef] childByAppendingPath:@"users"]
              childByAppendingPath:authData.uid] setValue:newUser];
            [mySession setNickname:nickname];
        
            [self loginSuccess];
            
            //post notif
            [[NSNotificationCenter defaultCenter] postNotificationName: @"nicknameChanged" object:nil];
        } else if ([[mySession nickname] isEqualToString:@""]) {
            Firebase *ref = [[Firebase alloc] initWithUrl: [NSString stringWithFormat:@"https://programminggame.firebaseio.com/users/%@", [mySession myRootRef].authData.uid]];
            [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                [mySession setNickname:snapshot.value[@"nickname"]];
                [self loginSuccess];
                [[NSNotificationCenter defaultCenter] postNotificationName: @"nicknameChanged" object:nil];
            }];
        }
        
    }];
    [self fadeErrorMessage];
    
    [self.confirmButton setEnabled:YES];

}



-(void) errorSignUpLogin:(bool)shouldStop withMessage:(NSString*)errorMessage {
    if ([self.passwordTextField.text isEqualToString:@""] || [self.usernameTextField.text isEqualToString:@""]|| shouldStop) {
        self.errorMessageLabel.text = errorMessage;
        [self.confirmButton setEnabled:YES];
        [self fadeErrorMessage];
    } else if ([self.titleLabel.text isEqual:@"Login"]) {
        [self loginUser:nil];
    } else {
        [self signUpUser];
    }
}

- (IBAction)didConfirm:(id)sender {
    [self resignKeyboards];
    [self.confirmButton setEnabled:NO];
    if ([self.titleLabel.text isEqual:@"Sign Up"]) {//wants to sign up
        if ([self.nicknameTextField.text isEqualToString:@""]) { //not all fields set up
            [self errorSignUpLogin:YES withMessage:@"Please fill out all fields"];
        } else {
            Firebase *ref = [[Firebase alloc] initWithUrl: @"https://programminggame.firebaseio.com/usersRef"];
            [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if (!snapshot.value[self.nicknameTextField.text]) {
                    [self errorSignUpLogin:NO withMessage:@"Please fill out all fields"];
                } else {
                    [self errorSignUpLogin:YES withMessage:@"Username already in use"];
                    [self clearTextFields];
                }
            }];
        }
        
    }else { //wants to login
        [self errorSignUpLogin:NO withMessage:@"Please fill out all fields"];
    }
    
    
    
}
@end
