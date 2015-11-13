//
//  RegistrationViewController.m
//  TRAC
//
//  Created by Griffin Kelly on 11/11/15.
//  Copyright (c) 2015 Griffin Kelly. All rights reserved.
//

#import "RegistrationViewController.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    self.usertypeArray =[[NSArray alloc] initWithObjects:@"Coach",@"Athlete", nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.txtOrganization) {
        [self.txtOrganization resignFirstResponder];
        [self.txtUsername becomeFirstResponder];
    } else if (textField == self.txtUsername) {
        [self.txtUsername resignFirstResponder];
        [self.txtPassword becomeFirstResponder];
    }
    else if (textField == self.txtPassword) {
        [self.txtPassword resignFirstResponder];
        [self.txtConfirm becomeFirstResponder];
    }
    else if (textField == self.txtConfirm) {
        [self.txtConfirm resignFirstResponder];
        [self.txtEmail becomeFirstResponder];
    }
    else if (textField == self.txtEmail) {
        [self.txtEmail resignFirstResponder];
    }
    return YES;
}

- (IBAction)registerClicked:(id)sender {
    //Meat and potatoes here
    
    //if signin button clicked query server with credentials
    NSInteger success = 0;
    @try {
        
        if([[self.txtUsername text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""] || [[self.txtConfirm text] isEqualToString:@""] || [[self.txtOrganization text] isEqualToString:@""] || [[self.txtEmail text] isEqualToString:@""] ) {
            //if not enough information
            [self alertStatus:@"Please enter all information" :@"Registration Failed!" :0];
        
        } else if ([[self.txtPassword text] isEqualToString:[self.txtConfirm text]]) {
            //if success
            
            
            NSString *post = [NSString stringWithFormat:@"username=%@&password=%@&user_type=coach&organization=%@&email=%@", [self.txtUsername text],[self.txtPassword text],
                            [self.txtOrganization text],[self.txtEmail text]];
            
            NSURL *urlreg=[NSURL URLWithString:@"https://trac-us.appspot.com/api/register/"];

            //NSURL *url=[NSURL URLWithString:urlreg];
            
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            //NSLog(@"Post Data:%@", postData);
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:urlreg];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            [request setHTTPShouldHandleCookies:NO];
            
            
            //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = nil;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            //NSLog(@"Response code: %ld", (long)[response statusCode]);
            //NSLog(@"Error Code: %@", [error localizedDescription]);
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSASCIIStringEncoding];
            NSLog(@"Response ==> %@", responseData);
            if ([response statusCode] >= 200 && [response statusCode] < 300)
            {
               //NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSASCIIStringEncoding];
               // NSLog(@"Response ==> %@", responseData);
                
                NSError *error = nil;
                NSDictionary *jsonData = [NSJSONSerialization
                                          JSONObjectWithData:urlData
                                          options:NSJSONReadingMutableContainers
                                          error:&error];
                
                success = [jsonData[@"success"] integerValue];
                 NSLog(@"Success: %ld",(long)success);
                 [self alertStatus:@"Registration Success" :@"Registration Success!" :1];
                
                
             }
            else {
              [self alertStatus:@"Server Error" :@"Registration Failed!" :0];
            }
        }
        else{
            [self alertStatus:@"Passwords do not match" :@"Registration Failed!" :0];
        }
    }
    @catch (NSException * e) {
        //NSLog(@"Exception: %@", e);
        [self alertStatus:@"Registration Failed." :@"Error!" :0];
    }

}
- (IBAction)cancelClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"cancel_create" sender:self];
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



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1){
        if (buttonIndex == 0)
        {
            [self performSegueWithIdentifier:@"cancel_create" sender:self];
        }
    }
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}






/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end