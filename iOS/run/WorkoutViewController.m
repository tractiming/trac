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
#import "Reachability.h"

@interface WorkoutViewController ()

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;


@end

@implementation WorkoutViewController
{
NSArray *title;
NSMutableArray *date;
NSMutableArray *url;
    NSMutableArray *idNumberSelector;
    NSString *url_token;
    UIActivityIndicatorView *spinner;
    UIRefreshControl *refreshControl;
 
}

@synthesize tableData;
@synthesize workoutSearchBar;
@synthesize filteredWorkoutArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
      self.filteredWorkoutArray = [NSMutableArray arrayWithCapacity:[title count]];
   
    // Hide the search bar until user scrolls up
    CGRect newBounds = self.tableData.bounds;
    newBounds.origin.y = newBounds.origin.y + workoutSearchBar.bounds.size.height;
    self.tableData.bounds = newBounds;
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityHasChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityHasChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor. Apple.com as its never down... should probably switch to our site at some point
   NSString *remoteHostName = @"www.apple.com";
    
	self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
	[self.hostReachability startNotifier];

 
	
    // Initialize table data
    //get token from nsuserdefaults
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    //add token to url to find session data
    NSLog(@"Secutiy Token: %@",savedToken);
    url_token = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/?access_token=%@", savedToken];
    
    //initialize spinner
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    float navigationBarHeight = [[self.navigationController navigationBar] frame].size.height;
    float tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, (self.view.frame.size.height  - navigationBarHeight - tabBarHeight) / 4.0);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    //pull to refresh set up
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(doLoad) forControlEvents:UIControlEventValueChanged];
    [self.tableData addSubview:refreshControl];
    

    
}

//pull to refresh--async task
- (void) doLoad
{
    NSLog(@"Pull to Refresh");
    dispatch_async(TRACQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:url_token]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self fetchedData:data];
            [self.tableData reloadData];
            
            
        });
        
        
    });
    [refreshControl endRefreshing];
}



/*!
 * Called by Reachability whenever status changes.
 */
-(void) reachabilityHasChanged:(NSNotification *)notice
{
    // called after network status changes
    
    NetworkStatus hostStatus = [self.hostReachability currentReachabilityStatus];
    BOOL hostActive;
    
    //if network changes try async task again
    switch (hostStatus)
    {
        case ReachableViaWWAN:
        {
            NSLog(@"3G");
            
            hostActive=YES;
            
            dispatch_async(TRACQueue, ^{
                NSData* data = [NSData dataWithContentsOfURL:
                                [NSURL URLWithString:url_token]];
                
                dispatch_async(dispatch_get_main_queue() ,^{
                    [self fetchedData:data];
                    [self.tableData reloadData];
                    [spinner removeFromSuperview];
                });
                
                
            });
            break;
        }
        case ReachableViaWiFi:
        {
            
             NSLog(@"WIFI");
            dispatch_async(TRACQueue, ^{
                NSData* data = [NSData dataWithContentsOfURL:
                                [NSURL URLWithString:url_token]];
                
                dispatch_async(dispatch_get_main_queue() ,^{
                    [self fetchedData:data];
                    [self.tableData reloadData];
                    [spinner removeFromSuperview];
                });
                
                
            });
            
            hostActive=YES;
            break;
        }
        case NotReachable:
        {
            //if no internet conenction, have popup appear
            hostActive=NO;
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"No Internet Connection" message:@"You currently do not have internet connectivity." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            break;
        }
            
    }
    
    
}




-(void)awakeFromNib{
    [super awakeFromNib];
    //set colors for navigation bar and text
   [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:53/255.0f green:119/255.0f blue:168/255.0f alpha:1.0f]];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],UITextAttributeTextColor, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
}



- (NSArray *)fetchedData:(NSData *)responseData {
    @try {
        
        //parse out the json data
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData //1
                              
                              options:kNilOptions
                              error:&error];
        
        //NSDictionary* workoutid = [json valueForKey:@"workoutID"]; //2
        
        //variable for json decoding
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
        NSMutableArray *idNumber;
        
        //interate through id and associate url with each date
        for (i=0; i<date_length; i++) {
            tempvar = date[i];
            tempvar = [tempvar substringToIndex:10];
            idurl = url[i];
            NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
            NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/%@/?access_token=%@", idurl,savedToken];
            
            //to initialize array, for the first entry create variable, then add object for subsequent entries
            if(i==0){
                temparray=[NSMutableArray arrayWithObject:tempvar];
                idarray = [NSMutableArray arrayWithObject:idurl2];
                idNumber = [NSMutableArray arrayWithObject:idurl];
            }
            else{
                [temparray addObject:tempvar];
                [idarray addObject:idurl2];
                [idNumber addObject:idurl];
                //[temparray addObject:tempvar];
                //[temparray replaceObjectAtIndex:i+1 withObject:tempvar];
                //[temparray replaceObjectAtIndex:i+1 withObject:tempvar];
                
                NSLog(@"IDArray %@", idarray);
            }
        }
        idNumberSelector = idNumber;
        date = temparray;
        url = idarray;
        
        idNumberSelector = [[idNumberSelector reverseObjectEnumerator] allObjects];
        //flip orientation of arrays
        date = [[date reverseObjectEnumerator] allObjects];
        title = [[title reverseObjectEnumerator] allObjects];
        url = [[url reverseObjectEnumerator] allObjects];
        //    // Initialize Labels
        return title;
        return date;
        return url;

    }
    @catch (NSException *exception) {
        NSLog(@"Exception %s","Except!");
        return title;
        return date;
        return url;

    }
    
    
    
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredWorkoutArray count];
    } else {
        return [title count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //put data into cells for tableView
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = self.filteredWorkoutArray[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //TODO: Fix this so date is correct
        //cell.detailTextLabel.text= date[indexPath.row];
    } else {
        cell.textLabel.text = title[indexPath.row];
        cell.detailTextLabel.text= date[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    NSLog(@"Date: %@", date);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"showWorkoutDetail" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //on view controller change, move to next page, and pass url to next view
    if ([segue.identifier isEqualToString:@"showWorkoutDetail"]) {
       
       UITabBarController *tabViewController = segue.destinationViewController;
        FirstViewController *firstVC=[[tabViewController viewControllers] objectAtIndex:0];
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];

        
      if (self.searchDisplayController.active) {
          
          NSLog(@"Search Active");
          
          
                 NSLog(@"Index Path %ld", (long)indexPath.section);
          firstVC.urlID = [idNumberSelector objectAtIndex:indexPath.row];
          firstVC.urlName = [url objectAtIndex:indexPath.row];
          
      }
          else{
              
              NSLog(@"Normal Segue");
              NSIndexPath *indexPath = [self.tableData indexPathForSelectedRow];
              firstVC.urlID = [idNumberSelector objectAtIndex:indexPath.row];
              firstVC.urlName = [url objectAtIndex:indexPath.row];
          }
        
    }
}

- (IBAction)logoutClicked:(id)sender{
    //if logout clicked, perform segue and clear token
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    NSLog(@"Secutiy Token: %@",savedToken);
    [self performSegueWithIdentifier:@"logout" sender:self];

}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredWorkoutArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
    self.filteredWorkoutArray = [NSMutableArray arrayWithArray:[title filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}




@end
