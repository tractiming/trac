//
//  TokenVerification.m
//  TRAC
//
//  Created by Griffin Kelly on 2/28/16.
//  Copyright © 2016 Griffin Kelly. All rights reserved.
//
#import "TokenVerification.h"
#import <Foundation/Foundation.h>

@implementation TokenVerification

+ (BOOL)findToken{

        
        // NSLog(@"entered funt");
        NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
        
        //NSString *savedToken =@"dfda";
        // Show login view if not logged in already
        if(savedToken == NULL){
            NSLog(@"HI");

        }
        else{
            //NSLog(@"Going to the calendar");
            
            
            
            @try {
                
                
                //if success
                NSString *tokenURL = [NSString stringWithFormat:@"https://trac-us.appspot.com/api/verifyLogin/?token=%@",savedToken];
                NSURL *url=[NSURL URLWithString:tokenURL];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:url];
                [request setHTTPMethod:@"GET"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                
                NSError *error = nil;
                NSHTTPURLResponse *response = nil;
                NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSASCIIStringEncoding];
                // NSLog(@"Response ==> %@", responseData);
                
                
                // NSLog(@"Response code: %ld", (long)[response statusCode]);
                
                if ([response statusCode] == 200 )
                {
                  NSLog(@"Redirect to YES");
                    // NSLog(@"To Login Screen");
                    return YES;
                }
                else{
                    NSLog(@"Redirect to NO");
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    return NO;
                }
            }
            
            @catch (NSException * e) {
                //NSLog(@"Exception: %@", e);

                return NO;
            }
        }
        

        return YES;
    }


@end
