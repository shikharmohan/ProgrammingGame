//
//  ViewController.m
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/20/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"KeyboardEntry"
                                               object:nil];
    //self.youEmoji.hidden = YES;
    //self.youLabel.hidden = YES;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"KeyboardEntry"]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *newLetter = (NSString*)[userInfo objectForKey:@"letter"];
        if ([newLetter length] > 1){
            [self.mainLetter setFont:[self.mainLetter.font fontWithSize:60.0]];
        } else {
            [self.mainLetter setFont:[self.mainLetter.font fontWithSize:110.0]];
        }
        self.mainLetter.text = newLetter;
        self.mainLetter.alpha = 1;
        [UIView animateWithDuration:0.9
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             // moves label down 100 units in the y axis
                             self.mainLetter.transform = CGAffineTransformMakeTranslation(0, -150);
                             // fade label in
                             self.mainLetter.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  // move label down further by 100 units
                                                  self.mainLetter.transform = CGAffineTransformMakeTranslation(0,0);
                                                  
                                              }
                                              completion:nil];
                         }];
        
    }
    
    
    
}

@end
