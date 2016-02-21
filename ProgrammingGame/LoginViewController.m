//
//  LoginViewController.m
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/20/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController () <UITextFieldDelegate>

@end

@implementation LoginViewController
Firebase *myRootRef;

- (void)viewDidLoad {
    [super viewDidLoad];
    myRootRef = [[Firebase alloc] initWithUrl:@"https://programminggame.firebaseio.com/"];
    
    self.confirmButton.clipsToBounds = YES;
    self.confirmButton.layer.cornerRadius = 5;
    
    //text fields
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
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
    [self.passwordTextField resignFirstResponder];
    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    
    if ([textField isEqual:self.usernameTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (IBAction)pressedLogin:(id)sender {
    self.errorMessageLabel.hidden = YES;
    if ([self.titleLabel.text isEqualToString:@"Sign Up"]) {
        self.titleLabel.text = @"Login";
        [self.loginButton setEnabled:NO];
        [self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    } else {
        self.titleLabel.text = @"Sign Up";
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

- (void)loginUser {
    [myRootRef authUser:self.usernameTextField.text password:self.passwordTextField.text
    withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            // There was an error logging in to this account
            self.errorMessageLabel.text = @"Login error";
            self.errorMessageLabel.hidden = NO;
            self.passwordTextField.text = @"";
            self.usernameTextField.text = @"";
        } else {
            
            NSLog(@"Hello - %@", authData);
            
            NSDictionary *newUser = @{
                                      @"nickname":@"Shana"
                                      };
            [[[myRootRef childByAppendingPath:@"users"]
              childByAppendingPath:authData.uid] setValue:newUser];
            
            self.errorMessageLabel.text = @"Login Successful";
            self.errorMessageLabel.hidden = NO;
            [self navigateToMainVC];
            // We are now logged in
            
        }
    }];
    [self.confirmButton setEnabled:YES];

}

- (void)signUpUser {
    [myRootRef createUser:self.usernameTextField.text password:self.passwordTextField.text
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
         [self loginUser];
     }
 }];
    [self.confirmButton setEnabled:YES];
}

- (IBAction)didConfirm:(id)sender {
    [self.confirmButton setEnabled:NO];
    
    if ([self.passwordTextField.text isEqualToString:@""] || [self.usernameTextField.text isEqualToString:@""]) {
        self.errorMessageLabel.text = @"Please enter a username/password";
        self.errorMessageLabel.hidden = NO;
        [self.confirmButton setEnabled:YES];
    } else if ([self.titleLabel.text isEqual:@"Login"]) {
        [self loginUser];
    } else {
        [self signUpUser];
    }
    
}
@end
