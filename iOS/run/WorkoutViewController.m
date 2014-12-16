//
//  WorkoutViewController.m
//  run
//
//  Created by Griffin Kelly on 10/20/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//
#import <UIKit/UITabBarController.h>
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "SiginViewController.h"


#define TRACQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
//#define workoutURL [NSURL URLWithString:@"http://localhost:8888/workoutTestList.json"] //2
//change url as necessary

#import "WorkoutViewController.h"

@interface WorkoutViewController ()

@end

@implementation WorkoutViewController
{
NSArray *title;
NSMutableArray *date;
NSMutableArray *url;

    
}

@synthesize tableData;






- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initialize table data
    
    
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    NSLog(@"Secutiy Token: %@",savedToken);
    NSString *url_token = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/?access_token=%@", savedToken];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //spinner.color = [UIColor grayColor];
    float navigationBarHeight = [[self.navigationController navigationBar] frame].size.height;
    float tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, (self.view.frame.size.height  - navigationBarHeight - tabBarHeight) / 4.0);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    dispatch_async(TRACQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:url_token]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self fetchedData:data];
            [self.tableData reloadData];
            [spinner removeFromSuperview];
        });
        
        
    });
    
    
    //NSLog(@"Names view load: %@", self.runners);
    
    //    dispatch_async(kBgQueue, ^{
    //        NSData* data = [NSData dataWithContentsOfURL:
    //                        kLatestKivaLoansURL];
    //        [self performSelectorOnMainThread:@selector(fetchedData:)
    //                               withObject:data waitUntilDone:YES];
    //    });
    
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
   [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:53/255.0f green:119/255.0f blue:168/255.0f alpha:1.0f]];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],UITextAttributeTextColor, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
}

- (NSArray *)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
    //NSDictionary* workoutid = [json valueForKey:@"workoutID"]; //2
    
    title= [json valueForKey:@"name"];
    date = [json valueForKey:@"start_time"];
    url = [json valueForKey:@"id"];
    int date_length = [date count];
  NSLog(@"Length: %d", date_length);
    
    int i;
    NSString *tempvar;
    NSMutableArray *temparray;
    NSString *idurl;
    NSMutableArray *idarray;
    
    
    for (i=0; i<date_length; i++) {
        tempvar = date[i];
        tempvar = [tempvar substringToIndex:10];
        idurl = url[i];
        NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
        NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/%@/?access_token=%@", idurl,savedToken];
        
        
        if(i==0){
            temparray=[NSMutableArray arrayWithObject:tempvar];
            idarray = [NSMutableArray arrayWithObject:idurl2];
        }
        else{
        [temparray addObject:tempvar];
        [idarray addObject:idurl2];
        //[temparray addObject:tempvar];
        //[temparray replaceObjectAtIndex:i+1 withObject:tempvar];
        //[temparray replaceObjectAtIndex:i+1 withObject:tempvar];
            
NSLog(@"IDArray %@", idarray);
        }
    }
    
    date = temparray;
    url = idarray;
    
    //    // Initialize Labels
    return title;
    return date;
    return url;
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [title count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = title[indexPath.row];
    cell.detailTextLabel.text= date[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSLog(@"Date: %@", date);
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showWorkoutDetail"]) {
        NSIndexPath *indexPath = [self.tableData indexPathForSelectedRow];
       UITabBarController *tabViewController = segue.destinationViewController;
        FirstViewController *firstVC=[[tabViewController viewControllers] objectAtIndex:0];
        
        
        
        firstVC.urlName = [url objectAtIndex:indexPath.row];
    }
}

- (IBAction)logoutClicked:(id)sender{
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    NSLog(@"Secutiy Token: %@",savedToken);
    [self performSegueWithIdentifier:@"logout" sender:self];

}




@end