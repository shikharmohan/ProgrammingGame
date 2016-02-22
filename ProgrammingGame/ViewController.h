//
//  ViewController.h
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/20/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface ViewController : UIViewController
//avatars
@property (weak, nonatomic) IBOutlet UIImageView *myEmoji;
@property (weak, nonatomic) IBOutlet UIImageView *friendEmoji;
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendMask;
@property (weak, nonatomic) IBOutlet UILabel *myMask;

//letter to show
@property (weak, nonatomic) IBOutlet UILabel *mainLetter;

//container view + mask
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *keyboardMask;

@end

