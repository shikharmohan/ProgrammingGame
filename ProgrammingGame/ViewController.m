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
        if([newLetter isEqualToString:@"Space"] || [newLetter isEqualToString:@"Clear line"] || [newLetter isEqualToString:@"Tab"]) {
            [self.mainLetter setFont:[self.mainLetter.font fontWithSize:60.0]];
        } else {
            [self.mainLetter setFont:[self.mainLetter.font fontWithSize:110.0]];
        }
        self.mainLetter.text = newLetter;
        
    }
    
    
}

@end
