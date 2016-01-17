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
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"jamison.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(receiveToggleAuthUINotification:)
     name:@"ToggleAuthUINotification"
     object:nil];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:@"ToggleAuthUINotification"
     object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)createAccountClicked:(id)sender{
    
    [self performSegueWithIdentifier:@"create_account" sender:self];
 //   [self presentModalViewController:@"create_account" animated:YES];
    if (![[self modalViewController] isBeingPresented]) {
        [self dismissModalViewControllerAnimated:YES];
    }
}


- (IBAction)signinClicked:(id)sender {
    
    //if signin button clicked query server with credentials
    NSInteger success = 0;
    @try {
        
        if([[self.txtUsername text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""] ) {
            //if sign in failed
            [self alertStatus:@"Please enter Username and Password" :@"Sign in Failed!" :0];
            
        } else {
            NSString *ios_client = @"u75WXsu8ybif8e8i0Ufvy8qPcdywwj2JY0ydfScH";
            NSString *post =[[NSString alloc] initWithFormat:@"username=%@&password=%@&client_id=%@&grant_type=password",[self.txtUsername text],[self.txtPassword text],ios_client];
            
            NSURL *url=[NSURL URLWithString:@"https://trac-us.appspot.com/api/login/"];
            
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            //NSLog(@"Post Data:%@", postData);
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            [request setHTTPShouldHandleCookies:NO];
            
            //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = nil;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            NSLog(@"Response code: %ld", (long)[response statusCode]);
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSASCIIStringEncoding];
            NSLog(@"Response ==> %@", responseData);
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
                //NSLog(@"Success: %ld",(long)success);
                
                if(success == 0)
                {
                    //NSLog(@"Login SUCCESS");
                    
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
                //NSString *error_msg = (NSString *) jsonData[@"error_message"];
                //[self alertStatus:error_msg :@"Sign in Failed!" :0];
                [self alertStatus:@"Sign in Failed." :@"Error!" :0];
            }

        }
    }
    @catch (NSException * e) {
        //NSLog(@"Exception: %@", e);
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
