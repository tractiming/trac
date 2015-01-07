//
//  AppDelegate.m
//  run
//
//  Created by Griffin Kelly on 5/3/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//

#import "AppDelegate.h"
#import "SiginViewController.h"
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@implementation AppDelegate

//depending if logged in, show splash screen and segue to either login or workoutviewcontroller
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"entered funt");
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    // Show login view if not logged in already
    if(savedToken == NULL){
        NSLog(@"HI");
        [self showLoginScreen:NO];
    }
    
    return YES;
}
//Enter differnet storyboard depending on iPad or iPhone
-(void) showLoginScreen:(BOOL)animated
{
    
    if ( IDIOM == IPAD) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        SiginViewController *viewController = (SiginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
        [self.window makeKeyAndVisible];
        [self.window.rootViewController presentViewController:viewController
                                                     animated:animated
                                                   completion:nil];
    }
    else {
         // Get login screen from storyboard and present it
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        SiginViewController *viewController = (SiginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
        [self.window makeKeyAndVisible];
        [self.window.rootViewController presentViewController:viewController
                                                     animated:animated
                                                   completion:nil];
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
