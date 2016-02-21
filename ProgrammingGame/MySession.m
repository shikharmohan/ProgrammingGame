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
        friends = [[NSMutableArray alloc] init];
        myRootRef = [[Firebase alloc] initWithUrl:@"https://programminggame.firebaseio.com/"];
        nickname = @"";
        if ([nickname isEqualToString:@""] && myRootRef.authData) {
            NSString *url = [NSString stringWithFormat:@"https://programminggame.firebaseio.com/users/%@", myRootRef.authData.uid];
            NSLog(@"uid: %@ - url %@", myRootRef.authData.uid, url);
            Firebase *ref = [[Firebase alloc] initWithUrl: url];
            __block NSString *val;
            [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                val = snapshot.value[@"nickname"];
                NSLog(@"Nickname snapshot: %@", snapshot.value[@"nickname"]);
                nickname = val;
                [[NSNotificationCenter defaultCenter] postNotificationName: @"nicknameChanged" object:nil];
            }];
        }
        
        
    }
    return self;
}

@end
