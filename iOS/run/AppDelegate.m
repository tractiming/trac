//
//  AppDelegate.m
//  run
//
//  Created by Griffin Kelly on 5/3/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//

#import "AppDelegate.h"
#import "SiginViewController.h"
#import "Heap.h"
#import "TutorialViewController.h"
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@implementation AppDelegate

//depending if logged in, show splash screen and segue to either login or workoutviewcontroller
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Heap setAppId:@"1813560945"];
#ifdef DEBUG
    [Heap enableVisualizer];
#endif

    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    [GIDSignIn sharedInstance].delegate = self;
    
    // NSLog(@"entered funt");
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    //NSString *savedToken =@"dfda";
    // Show login view if not logged in already
    if(savedToken == NULL){
        NSLog(@"HI");
        [self showLoginScreen:NO];
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
              
               // NSLog(@"To Login Screen");
                return YES;
            }
        }
    
    @catch (NSException * e) {
        //NSLog(@"Exception: %@", e);
        [self showLoginScreen:NO];
        return YES;
    }
    }
    

    
   [self showLoginScreen:NO];
    return YES;
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations on signed in user here.
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *name = user.profile.name;
    NSString *email = user.profile.email;
    NSLog(@"Customer details: %@ %@ %@ %@", userId, idToken, name, email);
    @try{
        [self backendAuth:idToken :email :userId];
    }
    @catch(NSException * e){
        
    }
}

- (void)backendAuth:(NSString*)idToken :(NSString*)email : (NSString*)userID{
    NSString *signinEndpoint = @"https://trac-us.appspot.com/google-auth/";
    NSString *tracClient = @"u75WXsu8ybif8e8i0Ufvy8qPcdywwj2JY0ydfScH";

    NSDictionary *params = @{@"id_token": idToken,@"email":email,@"trac_client_id":tracClient};
    NSError *error2 = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error2];
    NSMutableURLRequest *request_google = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:signinEndpoint]];
    [request_google setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request_google setHTTPMethod:@"POST"];
    [request_google setHTTPBody:jsonData];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request_google
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               int responseStatusCode = [httpResponse statusCode];
                               if(responseStatusCode == 201 || responseStatusCode == 200){
                                   if ([data length] >0 && error == nil)
                                   {
                                       
                                       json = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:0
                                                                                error:nil];
                                       NSLog(@"JSON %@", json);
                                       self.access_token = [json objectForKey:@"access_token"];
                                       //store sequrity token in NSuserdefaults
                                       NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
                                       [defaults setObject:self.access_token forKey:@"token"];
                                       [defaults synchronize];
                                       
                                       //[self performSegueWithIdentifier:@"login_success" sender:self];
                                       //[self.window.rootViewController performSegueWithIdentifier:@"login_success" sender:self];
                                       
                                       UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                                       while (topRootViewController.presentedViewController)
                                       {
                                           //NSLog(@"Help me!!!");
                                           topRootViewController = topRootViewController.presentedViewController;
                                       }
                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                                       
                                       
                                       if(![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                                                  objectForKey:@"first_time"]]) {
                                           [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"first_time"];
                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                           TutorialViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"tutorialController"];
                                           [topRootViewController presentViewController:loginViewController animated:YES completion:nil];
                                           
                                       }
                                       else{
                                           UINavigationController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"navigationController"];
                                           [topRootViewController presentViewController:loginViewController animated:YES completion:nil];
                                       }

                                       
                                       
                                       [self.window makeKeyAndVisible];
                                       
                                   }
                                   else if ([data length] == 0 && error == nil)
                                   {
                                       NSLog(@"Nothing was downloaded.");
                                   }
                                   else if (error != nil){
                                       NSLog(@"Error = %@", error);
                                   }
                               }
                               else
                                   return;
                               
                           }];
}


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication,
                              UIApplicationOpenURLOptionsAnnotationKey: annotation};
    return [self application:application
                     openURL:url
                     options:options];
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // [START_EXCLUDE]
    NSDictionary *statusText = @{@"statusText": @"Disconnected user" };

}
//Enter differnet storyboard depending on iPad or iPhone
-(void) showLoginScreen:(BOOL)animated
{
    
    if ( IDIOM == IPAD) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        SiginViewController *viewController = (SiginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
        self.window.rootViewController = viewController;
        [self.window makeKeyAndVisible];

    }
    else {
         // Get login screen from storyboard and present it
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        SiginViewController *viewController = (SiginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
        
        self.window.rootViewController = viewController;
        [self.window makeKeyAndVisible];
    }

    
   
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
