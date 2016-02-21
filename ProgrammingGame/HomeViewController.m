//
//  HomeViewController.m
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/21/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "HomeViewController.h"
#import "MySession.h"

#define mySession [MySession sharedManager]

@interface HomeViewController ()

@end

@implementation HomeViewController
bool isContainerOpen;

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"nicknameChanged"
                                               object:nil];
    self.nicknameLabel.text = [mySession nickname];
    self.addFriendView.translatesAutoresizingMaskIntoConstraints = YES;
    isContainerOpen = NO;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"nicknameChanged"]) {
        NSLog(@"Recieved nickname changed notif");
        self.nicknameLabel.text = [mySession nickname];
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
    [self.addFriendLogo setTitle:@"x" forState:UIControlStateNormal];
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.addFriendView.frame = CGRectMake( self.addFriendView.frame.origin.x,
                                                               self.addFriendView.frame.origin.y,
                                                               self.addFriendView.frame.size.width,
                                                               self.addFriendView.frame.size.height + 145);
                     }
                     completion:^(BOOL finished){
                         [self.addFriendLogo setEnabled:YES];
                         isContainerOpen = YES;
                         // whatever you need to do when animations are complete
                     }];
}

-(void)closeContainer {
    [self.addFriendLogo setTitle:@"+" forState:UIControlStateNormal];
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.addFriendView.frame = CGRectMake( self.addFriendView.frame.origin.x,
                                                               self.addFriendView.frame.origin.y,
                                                               self.addFriendView.frame.size.width,
                                                               self.addFriendView.frame.size.height - 145);
                     }
                     completion:^(BOOL finished){
                         [self.addFriendLogo setEnabled:YES];
                         [self.addFriend setEnabled:YES];
                         isContainerOpen = NO;
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
    [mySession setFriends:nil];
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
@end
