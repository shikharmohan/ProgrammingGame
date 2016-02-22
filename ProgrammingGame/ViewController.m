//
//  ViewController.m
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/20/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "ViewController.h"
#import "MySession.h"

#define mySession [MySession sharedManager]

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //add observer for keyboard entry
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"KeyboardEntry"
                                               object:nil];
    
    //get game
    [self pullGameFromFirebase];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Firebase pull
-(void) pullGameFromFirebase {
    Firebase *ref = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/game/start", [mySession myRootRef].authData.uid]];
    [ref observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.value != [NSNull null]) {
            [mySession game][@"start"] = snapshot.value;
            [self setUpTurn];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

#pragma mark - turn setup

-(void) setUpTurn {
    if ([[mySession game][@"start"] isEqualToString:[mySession nickname]]) {
        self.myMask.alpha = 0;
        self.friendMask.alpha = 1;
        self.keyboardMask.alpha = 0;
        self.containerView.userInteractionEnabled = YES;
    } else {
        self.myMask.alpha = 1;
        self.friendMask.alpha = 0;
        self.keyboardMask.alpha = 1;
        self.containerView.userInteractionEnabled = NO;
    }
    self.myLabel.text = [mySession nickname];
    self.friendLabel.text = [mySession game][@"name"];
}

-(void) changeTurn {
    NSString *newTurn  = [mySession nickname];
    if ([[mySession game][@"start"] isEqualToString:[mySession nickname]]) { //if it is my turn
        self.containerView.userInteractionEnabled = YES;
        newTurn = [mySession game][@"name"];
    } else {
        self.containerView.userInteractionEnabled = NO;
    }
    
    Firebase *myRef = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/game/start", [mySession myRootRef].authData.uid]];
    Firebase *friendRef = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/game/start", [mySession game][@"uid"]]];
    
    [myRef setValue:newTurn];
    [friendRef setValue:newTurn];
    
}


#pragma mark - Push to Firebase

-(void) sendLetter:(NSString *)letter {
    Firebase *myRef = [[[[mySession myRootRef] childByAppendingPath:@"users"] childByAppendingPath:[mySession myRootRef].authData.uid]  childByAppendingPath:@"/gameLetters/letter"];
    Firebase *friendRef = [[[[mySession myRootRef] childByAppendingPath:@"users"] childByAppendingPath:[mySession game][@"uid"]]  childByAppendingPath:@"/gameLetters/letter"];
   
    [myRef setValue: letter];
    [friendRef setValue: letter];
}


#pragma mark -Keyboard entry handling
- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"KeyboardEntry"]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *newLetter = (NSString*)[userInfo objectForKey:@"letter"];
        //change size of letter depending on count
        if ([newLetter length] > 1){
            [self.mainLetter setFont:[self.mainLetter.font fontWithSize:60.0]];
        } else {
            [self.mainLetter setFont:[self.mainLetter.font fontWithSize:110.0]];
        }
        self.mainLetter.text = newLetter;
        self.mainLetter.alpha = 1;
        [UIView animateWithDuration:0.8
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.mainLetter.transform = CGAffineTransformMakeTranslation(0, -150);
                             self.mainLetter.alpha = 0; // fade letter out
                             self.keyboardMask.alpha = 1; //set up keyboard mask
                             
                             //change masks of emojis
                             self.myMask.alpha = 1;
                             self.friendMask.alpha = 0;
                             
                             [self changeTurn];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.5
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  self.mainLetter.transform = CGAffineTransformMakeTranslation(0,0);
                                                  
                                              }
                                              completion:nil];
                         }];
        
    }
    
    
    
}

@end
