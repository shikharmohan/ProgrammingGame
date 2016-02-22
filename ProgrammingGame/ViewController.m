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
bool firstTimeLetter;
bool didSendLetter;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //add observer for keyboard entry
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"KeyboardEntry"
                                               object:nil];
    
    //first time through ref setup
    firstTimeLetter = YES;
    didSendLetter = NO;
    
    //hide all letters
    self.mainLetter.alpha = 0;
    self.incomingLetter.alpha = 0;
    
    //get game turn
    [self pullGameTurnFromFirebase];
    
    //get game letter
    [self pullGameLetterFromFirebase];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Firebase pull
-(void) pullGameLetterFromFirebase {
    Firebase *ref = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/game/letter", [mySession myRootRef].authData.uid]];
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {//observe turn change
        if (snapshot.value != [NSNull null]) {
            [mySession game][@"letter"] = snapshot.value;
            if (firstTimeLetter) {
            firstTimeLetter = NO;
            } else {
                [self setUpLetter];
            }
            
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

-(void) pullGameTurnFromFirebase {
    Firebase *ref = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/game/start", [mySession myRootRef].authData.uid]];
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {//observe turn change
        if (snapshot.value != [NSNull null]) {
            [mySession game][@"start"] = snapshot.value;
            [self setUpTurn];
        }
    } withCancelBlock:^(NSError *error) {
         NSLog(@"%@", error.description);
    }];
}

#pragma mark - turn & letter setup
-(void) setUpLetter {
    NSString *newLetter = [mySession game][@"letter"];
    if ([newLetter length] > 1){
        [self.incomingLetter setFont:[self.incomingLetter.font fontWithSize:60.0]];
    } else {
        [self.incomingLetter setFont:[self.incomingLetter.font fontWithSize:110.0]];
    }
    self.friendLabel.text = [NSString stringWithFormat:@"%@: %@", [mySession game][@"name"],[newLetter substringToIndex:1]];
    self.myLabel.text = [mySession nickname];
    self.incomingLetter.text = newLetter;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.incomingLetter.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                               delay:0.5
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.incomingLetter.alpha = 0;
                                          }
                                          completion:^(BOOL finished) {
                                              [self updateTurn];
                                          }];
                     }];
}

-(void) setUpTurn {
    if ([[mySession game][@"start"] isEqualToString:[mySession nickname]]) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.friendEmoji.alpha = 0.3;
                             self.friendLabel.alpha = 0.3;
                             self.myEmoji.alpha = 1;
                             self.myLabel.alpha = 1;
                             self.keyboardMask.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             self.containerView.userInteractionEnabled = YES;
                         }];
        self.containerView.userInteractionEnabled = YES;
        
    } else {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.myEmoji.alpha = 0.3;
                             self.myLabel.alpha = 0.3;
                             self.friendEmoji.alpha = 1;
                             self.friendLabel.alpha = 1;
                             self.keyboardMask.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             self.containerView.userInteractionEnabled = NO;
                         }];
        self.containerView.userInteractionEnabled = NO;
        didSendLetter = NO;
        
    }
    if ([self.myLabel.text isEqualToString:@"Me"] || [self.friendLabel.text isEqualToString:@"Friend"]){
        self.myLabel.text = [mySession nickname];
        self.friendLabel.text = [mySession game][@"name"];
    }
    
}



-(void) updateTurn {
    NSString *newTurn  = [mySession nickname];
    if ([[mySession game][@"start"] isEqualToString:[mySession nickname]]) { //if it is my turn
        self.containerView.userInteractionEnabled = YES;
        newTurn = [mySession game][@"name"];
    } else {
        self.containerView.userInteractionEnabled = NO;
        didSendLetter = NO;
    }
    
    Firebase *friendRef = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/game/start", [mySession game][@"uid"]]];
    Firebase *myRef = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/game/start", [mySession myRootRef].authData.uid]];
    [friendRef setValue:newTurn];
    [myRef setValue:newTurn];
    
}

-(void) updateLetter:(NSString*) str {
    Firebase *friendRef = [[mySession myRootRef] childByAppendingPath: [NSString stringWithFormat:@"users/%@/game/letter", [mySession game][@"uid"]]];
    [friendRef setValue:str];
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
        if (!didSendLetter) { //to prevent from double keyboard entry
            didSendLetter = YES;
            NSDictionary *userInfo = notification.userInfo;
            NSString *newLetter = (NSString*)[userInfo objectForKey:@"letter"];
            //change size of letter depending on count
            if ([newLetter length] > 1){
                [self.mainLetter setFont:[self.mainLetter.font fontWithSize:60.0]];
            } else {
                
                [self.mainLetter setFont:[self.mainLetter.font fontWithSize:110.0]];
            }
            self.mainLetter.text = newLetter;
            self.myLabel.text = [NSString stringWithFormat:@"%@: %@", [mySession nickname],[newLetter substringToIndex:1]];
            self.friendLabel.text = [mySession game][@"name"];
            self.mainLetter.alpha = 1;
            [self updateLetter:newLetter];
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.mainLetter.transform = CGAffineTransformMakeTranslation(0, -150);
                                 self.mainLetter.alpha = 0; // fade letter out
                                 self.keyboardMask.alpha = 1; //set up keyboard mask
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.5
                                                       delay:0
                                                     options:UIViewAnimationOptionCurveEaseOut
                                                  animations:^{
                                                      self.mainLetter.transform = CGAffineTransformMakeTranslation(0,0);
                                                  }
                                                  completion:nil];
                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     [self setUpTurn];
                                 });
                             }];

        }
        
    }
    
}

@end
