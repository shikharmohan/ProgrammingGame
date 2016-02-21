//
//  AddFriendViewController.h
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/21/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface AddFriendViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UILabel *bckLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
- (IBAction)addFriend:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UIImageView *errorEmoji;

@end
