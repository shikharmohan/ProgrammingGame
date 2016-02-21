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

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"nicknameChanged"
                                               object:nil];
    self.addFriend.clipsToBounds = YES;
    self.addFriend.layer.cornerRadius = 5;
    self.nicknameLabel.text = [mySession nickname];
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

- (IBAction)addFriendPressed:(id)sender {
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
@end
