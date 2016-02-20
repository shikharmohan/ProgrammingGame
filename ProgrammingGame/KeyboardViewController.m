//
//  KeyboardViewController.m
//  ProgrammingGame
//
//  Created by Shana Azria Dev on 2/20/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import "KeyboardViewController.h"

@interface KeyboardViewController ()

@end

@implementation KeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)notifyParent:(NSString*)str {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:str forKey:@"letter"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"KeyboardEntry" object:nil userInfo:userInfo];
}

- (IBAction)tab:(id)sender {
    [self notifyParent:@"Tab"];
}

- (IBAction)clear:(id)sender {
    [self notifyParent:@"Clear line"];
}

- (IBAction)less:(id)sender {
    [self notifyParent:@"<"];
}

- (IBAction)greater:(id)sender {
    [self notifyParent:@">"];
}

- (IBAction)plus:(id)sender {
    [self notifyParent:@"+"];
}

- (IBAction)eq:(id)sender {
    [self notifyParent:@"="];
}

- (IBAction)times:(id)sender {
    [self notifyParent:@"*"];
}

- (IBAction)q:(id)sender {
    [self notifyParent:@"q"];
}

- (IBAction)w:(id)sender {
    [self notifyParent:@"w"];
}

- (IBAction)e:(id)sender {
    [self notifyParent:@"e"];
}

- (IBAction)r:(id)sender {
    [self notifyParent:@"r"];
}

- (IBAction)t:(id)sender {
    [self notifyParent:@"t"];
}

- (IBAction)y:(id)sender {
    [self notifyParent:@"y"];
}

- (IBAction)u:(id)sender {
    [self notifyParent:@"u"];
}

- (IBAction)i:(id)sender {
    [self notifyParent:@"i"];
}

- (IBAction)o:(id)sender {
    [self notifyParent:@"o"];
}

- (IBAction)p:(id)sender {
    [self notifyParent:@"p"];
}

- (IBAction)a:(id)sender {
    [self notifyParent:@"a"];
}

- (IBAction)s:(id)sender {
    [self notifyParent:@"s"];
}

- (IBAction)d:(id)sender {
    [self notifyParent:@"d"];
}

- (IBAction)f:(id)sender {
    [self notifyParent:@"f"];
}

- (IBAction)g:(id)sender {
    [self notifyParent:@"g"];
}

- (IBAction)h:(id)sender {
    [self notifyParent:@"h"];
}

- (IBAction)j:(id)sender {
    [self notifyParent:@"j"];
}

- (IBAction)k:(id)sender {
    [self notifyParent:@"k"];
}

- (IBAction)l:(id)sender {
    [self notifyParent:@"l"];
}

- (IBAction)z:(id)sender {
    [self notifyParent:@"z"];
}

- (IBAction)x:(id)sender {
    [self notifyParent:@"x"];
}

- (IBAction)c:(id)sender {
    [self notifyParent:@"c"];
}

- (IBAction)v:(id)sender {
    [self notifyParent:@"v"];
}

- (IBAction)b:(id)sender {
    [self notifyParent:@"b"];
}

- (IBAction)n:(id)sender {
    [self notifyParent:@"n"];
}

- (IBAction)m:(id)sender {
    [self notifyParent:@"m"];
}

- (IBAction)one:(id)sender {
    [self notifyParent:@"1"];
}

- (IBAction)two:(id)sender {
    [self notifyParent:@"2"];
}

- (IBAction)three:(id)sender {
    [self notifyParent:@"3"];
}

- (IBAction)four:(id)sender {
    [self notifyParent:@"4"];
}

- (IBAction)five:(id)sender {
    [self notifyParent:@"5"];
}

- (IBAction)six:(id)sender {
    [self notifyParent:@"6"];
}

- (IBAction)seven:(id)sender {
    [self notifyParent:@"7"];
}

- (IBAction)eight:(id)sender {
    [self notifyParent:@"8"];
}

- (IBAction)nine:(id)sender {
    [self notifyParent:@"9"];
}

- (IBAction)zero:(id)sender {
    [self notifyParent:@"0"];
}

- (IBAction)lbracket:(id)sender {
    [self notifyParent:@"["];
}

- (IBAction)rBracket:(id)sender {
    [self notifyParent:@"]"];
}

- (IBAction)lCurly:(id)sender {
    [self notifyParent:@"{"];
}

- (IBAction)rCurly:(id)sender {
    [self notifyParent:@"}"];
}

- (IBAction)lPar:(id)sender {
    [self notifyParent:@"("];
}

- (IBAction)rPar:(id)sender {
    [self notifyParent:@")"];
}

- (IBAction)hashtag:(id)sender {
    [self notifyParent:@"#"];
}

- (IBAction)percent:(id)sender {
    [self notifyParent:@"%"];
}

- (IBAction)orLine:(id)sender {
    [self notifyParent:@"|"];
}

- (IBAction)andLetter:(id)sender {
    [self notifyParent:@"&"];
}

- (IBAction)hyphen:(id)sender {
    [self notifyParent:@"-"];
}

- (IBAction)colon:(id)sender {
    [self notifyParent:@":"];
}

- (IBAction)semiColon:(id)sender {
    [self notifyParent:@";"];
}

- (IBAction)space:(id)sender {
    [self notifyParent:@"Space"];
}

- (IBAction)dot:(id)sender {
    [self notifyParent:@"."];
}

- (IBAction)comma:(id)sender {
    [self notifyParent:@","];
}

- (IBAction)exclamation:(id)sender {
    [self notifyParent:@"!"];
}



@end
