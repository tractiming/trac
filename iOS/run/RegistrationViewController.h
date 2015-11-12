//
//  RegistrationViewController.h
//  TRAC
//
//  Created by Griffin Kelly on 11/11/15.
//  Copyright (c) 2015 Griffin Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistrationViewController : UITableViewController <UITextFieldDelegate>

- (IBAction)registerClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)backgroundTap:(id)sender;
@property (strong, nonatomic) NSArray *usertypeArray;
@property (weak, nonatomic) IBOutlet UITextField *txtOrganization;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirm;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;

@end
