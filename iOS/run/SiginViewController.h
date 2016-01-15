//
//  SiginViewController.h
//  run
//
//  Created by Griffin Kelly on 10/11/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/SignIn.h>

@interface SiginViewController : UIViewController <GIDSignInUIDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
- (IBAction)signinClicked:(id)sender;
- (IBAction)createAccountClicked:(id)sender;
- (IBAction)backgroundTap:(id)sender;
@property (nonatomic, strong) NSString *access_token;
@property (nonatomic, strong) NSString *client_id;
@property (nonatomic, strong) NSString *client_secret;
@property (weak, nonatomic) IBOutlet GIDSignInButton *signInButton;


@end
