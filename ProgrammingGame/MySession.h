//
//  MySession.h
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/20/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>

@interface MySession : NSObject {
    NSString *nickname;
    NSMutableDictionary *friends;
    Firebase *myRootRef;
}

@property (strong, nonatomic) NSString* nickname;
@property (strong, nonatomic) NSMutableDictionary *friends;
@property (strong) Firebase *myRootRef;
+ (id)sharedManager;

@end
