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
#import "Workout.h"


#define TRACQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
//#define workoutURL [NSURL URLWithString:@"http://localhost:8888/workoutTestList.json"] //2
//change url as necessary

#import "RosterTableViewController.h"
#import "Reachability.h"

@interface RosterTableViewController ()

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *compass_background;
@property (nonatomic, strong) UIImageView *compass_spinner;
@property (assign) BOOL isRefreshIconsOverlap;
@property (assign) BOOL isRefreshAnimating;


@end

@implementation RosterTableViewController
{
    NSMutableArray *title;
    NSMutableArray *date;
    NSMutableArray *url;
    NSString *numSessions;
    NSMutableArray *idNumberSelector;
    NSString *url_token;
    NSString *pagination_url;
    UIActivityIndicatorView *spinner;
    
    int fakedTotalItemCount;
    int nextFifteen;
    NSString *savedToken;
    int totalSessions;
    int searchIndexPath;
    BOOL pullToRefresh;
    NSMutableArray *workoutArray;
    NSString *workoutName;
    NSString *workoutDate;
    
}

@synthesize tableData;
@synthesize workoutSearchBar;
@synthesize filteredTitleArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Create a light gray background behind datatable
    CGRect frame = self.tableData.bounds;
    frame.origin.y = -frame.size.height;
    UIView* grayView = [[UIView alloc] initWithFrame:frame];
    grayView.backgroundColor = [UIColor lightGrayColor];
    [self.tableData addSubview:grayView];
    
    self.navigationItem.title = @"Roster";
    

    //initialize array for search
    self.filteredTitleArray = [NSMutableArray arrayWithCapacity:[title count]];
    
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
    savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    //add token to url to find session data
    NSLog(@"Secutiy Token: %@",savedToken);
    
    url_token = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/athletes/?access_token=%@", savedToken];
    
    //initialize spinner for data load
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    float navigationBarHeight = [[self.navigationController navigationBar] frame].size.height;
    float tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, (self.view.frame.size.height  - navigationBarHeight - tabBarHeight) / 4.0);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    
    
    [self setupRefreshControl];
    
    
    
}



- (void)setupRefreshControl
{
    // TODO: Programmatically inserting a UIRefreshControl
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableData addSubview:self.refreshControl];
    // Setup the loading view, which will hold the moving graphics
    self.refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshLoadingView.backgroundColor = [UIColor clearColor];
    
    // Setup the color view, which will display the rainbowed background
    self.refreshColorView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    self.refreshColorView.alpha = 0.30;
    
    // Create the graphic image views
    self.compass_background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ticks.png"]];
    self.compass_spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock_hand.png"]];
    
    // Add the graphics to the loading view
    [self.refreshLoadingView addSubview:self.compass_background];
    [self.refreshLoadingView addSubview:self.compass_spinner];
    
    // Clip so the graphics don't stick out
    self.refreshLoadingView.clipsToBounds = YES;
    
    // Hide the original spinner icon
    self.refreshControl.tintColor = [UIColor clearColor];
    
    // Add the loading and colors views to our refresh control
    [self.refreshControl addSubview:self.refreshColorView];
    [self.refreshControl addSubview:self.refreshLoadingView];
    
    // Initalize flags
    self.isRefreshIconsOverlap = NO;
    self.isRefreshAnimating = NO;
    
    // When activated, invoke our refresh function
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh:(id)sender{
    
    
    // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
    // This is where you'll make requests to an API, reload data, or process information
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self doLoad];
        // When done requesting/reloading/processing invoke endRefreshing, to close the control
        [self.refreshControl endRefreshing];
    });
    // -- FINISHED SOMETHING AWESOME, WOO! --
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Get the current size of the refresh controller
    CGRect refreshBounds = self.refreshControl.bounds;
    
    // Distance the table has been pulled >= 0
    CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
    //NSLog(@"pullDistnace2: %f",self.refreshControl.frame.origin.y);
    // Half the width of the table
    CGFloat midX = tableData.frame.size.width / 2.0;
    
    // Calculate the width and height of our graphics
    CGFloat compassHeight = self.compass_background.bounds.size.height;
    CGFloat compassHeightHalf = compassHeight / 2.0;
    
    CGFloat compassWidth = self.compass_background.bounds.size.width;
    CGFloat compassWidthHalf = compassWidth / 2.0;
    
    CGFloat spinnerHeight = self.compass_spinner.bounds.size.height;
    CGFloat spinnerHeightHalf = spinnerHeight / 2.0;
    
    CGFloat spinnerWidth = self.compass_spinner.bounds.size.width;
    CGFloat spinnerWidthHalf = spinnerWidth / 2.0;
    
    // Calculate the pull ratio, between 0.0-1.0
    CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), 100.0) / 100.0;
    
    // Set the Y coord of the graphics, based on pull distance
    CGFloat compassY = pullDistance / 2.0 - compassHeightHalf;
    CGFloat spinnerY = pullDistance / 2.0 - spinnerHeightHalf;
    
    // Calculate the X coord of the graphics, adjust based on pull ratio
    CGFloat compassX = (midX + compassWidthHalf) - (compassWidth * pullRatio);
    CGFloat spinnerX = (midX - spinnerWidth - spinnerWidthHalf) + (spinnerWidth * pullRatio);
    
    // When the compass and spinner overlap, keep them together
    if (fabsf(compassX - spinnerX) < 1.0) {
        self.isRefreshIconsOverlap = YES;
    }
    
    // If the graphics have overlapped or we are refreshing, keep them together
    if (self.isRefreshIconsOverlap || self.refreshControl.isRefreshing) {
        compassX = midX - compassWidthHalf;
        spinnerX = midX - spinnerWidthHalf;
    }
    
    // Set the graphic's frames
    CGRect compassFrame = self.compass_background.frame;
    compassFrame.origin.x = compassX;
    compassFrame.origin.y = compassY;
    
    CGRect spinnerFrame = self.compass_spinner.frame;
    spinnerFrame.origin.x = spinnerX;
    spinnerFrame.origin.y = spinnerY;
    
    self.compass_background.frame = compassFrame;
    self.compass_spinner.frame = spinnerFrame;
    
    // Set the encompassing view's frames
    refreshBounds.size.height = pullDistance;
    
    self.refreshColorView.frame = refreshBounds;
    self.refreshLoadingView.frame = refreshBounds;
    
    // If we're refreshing and the animation is not playing, then play the animation
    if (self.refreshControl.isRefreshing && !self.isRefreshAnimating) {
        // NSLog(@"Pull Distance ENTERS: %f",pullDistance);
        [self animateRefreshView];
    }
    
    
}

- (void)animateRefreshView
{
    // Background color to loop through for our color view
    NSArray *colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor orangeColor],[UIColor magentaColor]];
    static int colorIndex = 0;
    
    // Flag that we are animating
    self.isRefreshAnimating = YES;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                         [self.compass_spinner setTransform:CGAffineTransformRotate(self.compass_spinner.transform, M_PI_2)];
                         
                         // Change the background color
                         self.refreshColorView.backgroundColor = [colorArray objectAtIndex:colorIndex];
                         colorIndex = (colorIndex + 1) % colorArray.count;
                     }
                     completion:^(BOOL finished) {
                         // If still refreshing, keep spinning, else reset
                         if (self.refreshControl.isRefreshing) {
                             [self animateRefreshView];
                         }else{
                             [self resetAnimation];
                         }
                     }];
}

- (void)resetAnimation
{
    // Reset our flags and background color
    self.isRefreshAnimating = NO;
    self.isRefreshIconsOverlap = NO;
    self.refreshColorView.backgroundColor = [UIColor clearColor];
}

//pull to refresh--async task
- (void) doLoad
{
    NSLog(@"Pull to Refresh");
    pullToRefresh = YES;

    
    dispatch_async(TRACQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:url_token]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self fetchedData:data];
            [self.tableData reloadData];
            
            
        });
        
        
    });
    [self.refreshControl endRefreshing];
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
                    [self doLoad];
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
                    [self doLoad];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Check scrolled percentage
    //
    CGFloat yOffset = tableView.contentOffset.y;
    CGFloat height = tableView.contentSize.height;
    CGFloat scrolledPercentage = yOffset / height;

}




- (NSArray *)fetchedData:(NSData *)responseData {
    @try {
        

            //parse out the json data
        
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseData //1
                                  
                                  options:kNilOptions
                                  error:&error];
        
        NSDictionary* user= [json valueForKey:@"user"];
        NSMutableArray* firstname= [user valueForKey:@"first_name"];
        NSMutableArray* lastname= [user valueForKey:@"last_name"];
        NSMutableArray* id_str = [json valueForKey:@"tag"];
        NSLog(@"%@, %@", firstname, lastname);
        title=[[NSMutableArray alloc] init];

        for (int i=0; i<[firstname count];i++){
            NSString *combined = [NSString stringWithFormat:@"%@ %@", [firstname objectAtIndex:i], [lastname objectAtIndex:i]];
            [title addObject:combined];
      
            
            if(i==0){
                
                //Attempt to make workout a dictionary
                Workout *initialArray = [Workout new];
                initialArray.name = combined;
                initialArray.date = [id_str objectAtIndex:i];
               
                
                workoutArray = [NSMutableArray arrayWithObjects:initialArray, nil];
                
            }
            else{
                
                //Attempt to make workout a dictionary
                Workout *initialArray = [Workout new];
                initialArray.name = combined;
                initialArray.date = [id_str objectAtIndex:i];
         
                [workoutArray addObject:initialArray];
                
                
            }

            
            
            
            
        }
        date = id_str;

        
            return title;
            return date;

        
        
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %s","Except!");
        return title;
        return date;

        
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
        NSLog(@"Filtered Count %lu", (unsigned long)self.filteredTitleArray.count);
        return [self.filteredTitleArray count];
    } else {
        NSLog(@"Regular Count Array");
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
        Workout *workout = nil;
        workout = [self.filteredTitleArray objectAtIndex:indexPath.row];
        cell.textLabel.text = workout.name;
        cell.detailTextLabel.text= workout.date;

        //TODO: Fix this so date is correct
        //cell.detailTextLabel.text= date[indexPath.row];
    } else {
        cell.textLabel.text = title[indexPath.row];
        cell.detailTextLabel.text = date[indexPath.row];

    }
    
    
    //NSLog(@"Date: %@", date);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"Selected in search view controler");
        NSLog(@"Index Path %ld", (long)indexPath.row);
        searchIndexPath = indexPath.row;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"showWorkoutDetail" sender:self];
        
    }
    
}



//For Searching Table Content
#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredTitleArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchText];
    self.filteredTitleArray = [NSMutableArray arrayWithArray:[workoutArray filteredArrayUsingPredicate:predicate]];
    
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
