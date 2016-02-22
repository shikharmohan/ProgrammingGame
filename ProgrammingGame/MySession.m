//
//  MySession.m
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/20/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "MySession.h"

@implementation MySession
@synthesize nickname;
@synthesize friends;
@synthesize myRootRef;
@synthesize game;
@synthesize gameLines;

+ (id)sharedManager {
    static MySession *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


- (id)init {
    if (self = [super init]) {
        friends = [[NSMutableDictionary alloc] init];
        myRootRef = [[Firebase alloc] initWithUrl:@"https://programminggame.firebaseio.com/"];
        nickname = @"";
        gameLines = [[NSMutableArray alloc] init];
        game = [[NSMutableDictionary alloc] init];
        if ([nickname isEqualToString:@""] && myRootRef.authData) {
            Firebase *ref = [[Firebase alloc] initWithUrl: [NSString stringWithFormat:@"https://programminggame.firebaseio.com/users/%@", myRootRef.authData.uid]];
            [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                nickname = snapshot.value[@"nickname"];
                if (![nickname isEqualToString:@""]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName: @"nicknameChanged" object:nil];
                }
            }];
        }
        
    }
    return self;
}

@end
