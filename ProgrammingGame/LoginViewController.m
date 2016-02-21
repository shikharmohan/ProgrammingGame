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
    
    self.confirmButton.clipsToBounds = YES;
    self.confirmButton.layer.cornerRadius = 5;
    
    //text fields
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.nicknameLabel.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [self clearTextFields];
    self.titleLabel.text = @"Login";
    [self.loginButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    self.errorMessageLabel.hidden = YES;
    
    self.nicknameLabel.alpha = 0;
    self.usernameTextField.transform = CGAffineTransformMakeTranslation(0, 0);
    self.passwordTextField.transform = CGAffineTransformMakeTranslation(0, 0);
    self.loginButton.transform = CGAffineTransformMakeTranslation(0, 0);
    self.confirmButton.transform = CGAffineTransformMakeTranslation(0, 0);
    
    [self resignKeyboards];
}

-(void) clearTextFields {
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
    self.nicknameLabel.text = @"";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)resignKeyboards {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.nicknameLabel resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignKeyboards];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if ([textField isEqual:self.nicknameLabel]) {
        [self.usernameTextField becomeFirstResponder];
    } else if ([textField isEqual:self.usernameTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}
-(void)signUpTransitionDown {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.nicknameLabel.transform = CGAffineTransformMakeTranslation(0, 70);
                         self.nicknameLabel.alpha = 1;
                         
                         self.usernameTextField.transform = CGAffineTransformMakeTranslation(0, 70);
                         self.passwordTextField.transform = CGAffineTransformMakeTranslation(0, 70);
                         self.loginButton.transform = CGAffineTransformMakeTranslation(0, 70);
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
                         self.nicknameLabel.transform = CGAffineTransformMakeTranslation(0, 0);
                         self.nicknameLabel.alpha = 0;
                         
                         self.usernameTextField.transform = CGAffineTransformMakeTranslation(0, 0);
                         self.passwordTextField.transform = CGAffineTransformMakeTranslation(0, 0);
                         self.loginButton.transform = CGAffineTransformMakeTranslation(0, 0);
                         self.confirmButton.transform = CGAffineTransformMakeTranslation(0, 0);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}
- (IBAction)pressedLogin:(id)sender {
    [self resignKeyboards];
    self.errorMessageLabel.hidden = YES;
    if ([self.titleLabel.text isEqualToString:@"Sign Up"]) {
        self.titleLabel.text = @"Login";
        [self clearTextFields];
        [self signUpTransitionUp];
        [self.loginButton setEnabled:NO];
        [self.loginButton setTitle:@"Sign up" forState:UIControlStateNormal];
    } else {
        self.titleLabel.text = @"Sign Up";
        [self signUpTransitionDown];
        [self.loginButton setEnabled:NO];
        [self.loginButton setTitle:@"Cancel" forState:UIControlStateNormal];
    }
    [self.loginButton setEnabled:YES];
    
}

-(void)navigateToMainVC {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
 
    UIViewController* controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"homeVC"];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loginUser:(NSString *)nickname {
    [[mySession myRootRef] authUser:self.usernameTextField.text password:self.passwordTextField.text
    withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            // There was an error logging in to this account
            NSLog(@"Error - %@", error);
            
            self.errorMessageLabel.text = @"Login error";
            self.errorMessageLabel.hidden = NO;
            self.passwordTextField.text = @"";
            self.usernameTextField.text = @"";
        } else {
            NSLog(@"Nickname %@ - Auth Data - %@", nickname, authData);
            if (nickname) {
                Firebase *usersRef = [[mySession myRootRef] childByAppendingPath: @"usersRef"];
                
                NSDictionary *updatedDict = @{
                                           nickname: authData.uid,
                                           };
                [usersRef updateChildValues: updatedDict];
                
                
                NSDictionary *newUser = @{
                                          @"nickname":nickname
                                          };
                [[[[mySession myRootRef] childByAppendingPath:@"users"]
                  childByAppendingPath:authData.uid] setValue:newUser];
                [mySession setNickname:nickname];
                [[NSNotificationCenter defaultCenter] postNotificationName: @"nicknameChanged" object:nil];
            } else {
                if ([[mySession nickname] isEqualToString:@""]) {
                    Firebase *ref = [[Firebase alloc] initWithUrl: [NSString stringWithFormat:@"https://programminggame.firebaseio.com/users/%@", [mySession myRootRef].authData.uid]];
                    [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                        [mySession setNickname:snapshot.value[@"nickname"]];
                        [[NSNotificationCenter defaultCenter] postNotificationName: @"nicknameChanged" object:nil];
                    }];
                }

            }
           
            
            self.errorMessageLabel.text = @"Login Successful";
            self.errorMessageLabel.hidden = NO;
            [self navigateToMainVC];
            // We are now logged in
            
        }
    }];
    [self.confirmButton setEnabled:YES];

}

- (void)signUpUser {
    [[mySession myRootRef] createUser:self.usernameTextField.text password:self.passwordTextField.text
 withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
     if (error) {
         // There was an error creating the account
         NSLog(@"Error - %@", error);
         self.errorMessageLabel.text = @"Sign up error";
         self.errorMessageLabel.hidden = NO;
         self.passwordTextField.text = @"";
         self.usernameTextField.text = @"";
     } else {
         self.errorMessageLabel.hidden = YES;
         NSString *uid = [result objectForKey:@"uid"];
         NSLog(@"Successfully created user account with uid: %@", uid);
         self.errorMessageLabel.text = @"Sign up Successful";
         self.errorMessageLabel.hidden = NO;
         
         [self loginUser:self.nicknameLabel.text];
     }
 }];
    [self.confirmButton setEnabled:YES];
}

-(void) errorSignUpLogin:(bool)shouldStop withMessage:(NSString*)errorMessage {
    if ([self.passwordTextField.text isEqualToString:@""] || [self.usernameTextField.text isEqualToString:@""]|| shouldStop) {
        self.errorMessageLabel.text = errorMessage;
        self.errorMessageLabel.hidden = NO;
        [self.confirmButton setEnabled:YES];
    } else if ([self.titleLabel.text isEqual:@"Login"]) {
        [self loginUser:nil];
    } else {
        [self signUpUser];
    }
}

- (IBAction)didConfirm:(id)sender {
    [self resignKeyboards];
    [self.confirmButton setEnabled:NO];
    if ([self.titleLabel.text isEqual:@"Sign Up"]) {
        if ([self.nicknameLabel.text isEqualToString:@""]) {
            [self errorSignUpLogin:YES withMessage:@"Please fill out all fields"];
        } else {
            Firebase *ref = [[Firebase alloc] initWithUrl: @"https://programminggame.firebaseio.com/usersRef"];
            [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if (!snapshot.value[self.nicknameLabel.text]) {
                    [self errorSignUpLogin:NO withMessage:@"Please fill out all fields"];
                } else {
                    [self errorSignUpLogin:YES withMessage:@"Username already in use"];
                    [self clearTextFields];
                }
            }];
        }
        
    }else {
        [self errorSignUpLogin:NO withMessage:@"Please fill out all fields"];
    }
    
    
    
}
@end
