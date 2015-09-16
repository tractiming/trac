    //
//  SiginViewController.m
//  run
//
//  Created by Griffin Kelly on 10/11/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//

#import "SiginViewController.h"



@interface SiginViewController ()

@end

@implementation SiginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)signinClicked:(id)sender {
    
    //if signin button clicked query server with credentials
    NSInteger success = 0;
    @try {
        
        if([[self.txtUsername text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""] ) {
            //if sign in failed
            [self alertStatus:@"Please enter Username and Password" :@"Sign in Failed!" :0];
            
        } else {
            //if success
            //NSString *post =[[NSString alloc] initWithFormat:@"username=%@&password=%@&grant_type=password&client_id=%@",[self.txtUsername text],[self.txtPassword text],[self.txtUsername text]];
            //NSLog(@"Post: %@",post);
            

            NSString *userpass = [NSString stringWithFormat:@"%@:%@", [self.txtUsername text],[self.txtPassword text]];
            NSData *nsdata = [userpass dataUsingEncoding:NSUTF8StringEncoding];
            
            // Get NSString from NSData object in Base64
            NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
            NSString *basicencoding = [NSString stringWithFormat:@"Basic %@", base64Encoded];
            // Print the Base64 encoded string
            NSLog(@"Encoded: %@", basicencoding);
            
            NSURL *url=[NSURL URLWithString:@"https://trac-us.appspot.com/api/login/"];
            
            //NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            //NSLog(@"Post Data:%@", postData);
           // NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:basicencoding forHTTPHeaderField:@"Authorization"];
            //[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            //[request setHTTPBody:postData];
            
            
            //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = nil;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            NSLog(@"Response code: %ld", (long)[response statusCode]);
            //NSLog(@"Error Code: %@", [error localizedDescription]);
            
            if ([response statusCode] >= 200 && [response statusCode] < 300)
            {
                //NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSASCIIStringEncoding];
                //NSLog(@"Response ==> %@", responseData);
                
                NSError *error = nil;
                NSDictionary *jsonData = [NSJSONSerialization
                                          JSONObjectWithData:urlData
                                          options:NSJSONReadingMutableContainers
                                          error:&error];
                
                success = [jsonData[@"success"] integerValue];
               // NSLog(@"Success: %ld",(long)success);
                
                if(success == 0)
                {
                    //Parse Tokens
                    self.client_id = [jsonData objectForKey:@"client_id"];
                    self.client_secret = [jsonData objectForKey:@"client_secret"];
                    NSString *post =[[NSString alloc] initWithFormat:@"username=%@&password=%@&client_id=%@&client_secret=%@&grant_type=password",[self.txtUsername text],[self.txtPassword text],self.client_id, self.client_secret];

                    
                    NSURL *url=[NSURL URLWithString:@"https://trac-us.appspot.com/oauth2/token/"];
                    
                    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                    NSLog(@"Post Data:%@", postData);
                    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    [request setURL:url];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:postData];
                    
                    
                    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
                    
                    NSError *error = [[NSError alloc] init];
                    NSHTTPURLResponse *response = nil;
                    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                    
                    NSLog(@"Response code: %ld", (long)[response statusCode]);
                    // NSLog(@"Error Code: %@", [error localizedDescription]);
                    
                    if ([response statusCode] >= 200 && [response statusCode] < 300)
                    {
                        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSASCIIStringEncoding];
                        NSLog(@"Response ==> %@", responseData);
                        
                        NSError *error = nil;
                        NSDictionary *jsonData = [NSJSONSerialization
                                                  JSONObjectWithData:urlData
                                                  options:NSJSONReadingMutableContainers
                                                  error:&error];
                        
                        success = [jsonData[@"success"] integerValue];
                        NSLog(@"Success: %ld",(long)success);
                        
                        if(success == 0)
                        {
                            NSLog(@"Login SUCCESS");

                            //NSLog(@"SecToken: %@", [jsonData objectForKey:@"access_token"]);
                            self.access_token = [jsonData objectForKey:@"access_token"];
                            
                            //store sequrity token in NSuserdefaults
                            NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
                            [defaults setObject:self.access_token forKey:@"token"];
                            [defaults synchronize];
                            [self performSegueWithIdentifier:@"login_success" sender:self];
                            //return self.access_token;
                            
                            
                            
                        }
                    }
                    else{
                        NSString *error_msg = (NSString *) jsonData[@"error_message"];
                        [self alertStatus:error_msg :@"Sign in Failed!" :0];
                    }
                } else {
                    
                    NSString *error_msg = (NSString *) jsonData[@"error_message"];
                    [self alertStatus:error_msg :@"Sign in Failed!" :0];
                }
                
            } else {
                //if (error) NSLog(@"Error: %@", error);
                [self alertStatus:@"Connection Failed" :@"Sign in Failed!" :0];
            }
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Sign in Failed." :@"Error!" :0];
    }
   // if (success) {
    //    [self performSegueWithIdentifier:@"login_success" sender:self];
   // }
}

//configure popup if signin fails

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}



- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
