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

#import "WorkoutViewController.h"
#import "Reachability.h"

@interface WorkoutViewController ()

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

@implementation WorkoutViewController
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
@synthesize filteredWorkoutArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Create a light gray background behind datatable
    CGRect frame = self.tableData.bounds;
    frame.origin.y = -frame.size.height;
    UIView* grayView = [[UIView alloc] initWithFrame:frame];
    grayView.backgroundColor = [UIColor lightGrayColor];
    [self.tableData addSubview:grayView];

    
    fakedTotalItemCount = 15;
    //initialize array for search
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
    savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    //add token to url to find session data
    NSLog(@"Secutiy Token: %@",savedToken);
    if (IDIOM ==IPAD) {
        url_token = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/?limit=25&offset=0&access_token=%@", savedToken];
    }
    else{
        url_token = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/?limit=15&offset=0&access_token=%@", savedToken];
    }
    //initialize spinner for data load
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    float navigationBarHeight = [[self.navigationController navigationBar] frame].size.height;
    float tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, (self.view.frame.size.height  - navigationBarHeight - tabBarHeight) / 4.0);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    
    //Put in TRAC image on header
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"traclogo_small.png"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    imageView.frame = titleView.bounds;
    [titleView addSubview:imageView];
    self.navigationItem.titleView = titleView;
    
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
    if (IDIOM ==IPAD) {
        fakedTotalItemCount = 25;
    }
    else{
        fakedTotalItemCount = 15;
    }
    
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
    nextFifteen = fakedTotalItemCount + 15;
   
    if (totalSessions>fakedTotalItemCount)
        self.hasNextPage = YES;
    else
        self.hasNextPage = NO;
    
    // Check if all the conditions are met to allow loading the next page
    //
    NSLog(@"Is Loading? %d",self.isLoading);
    if ((scrolledPercentage > .2f) && !self.isLoading && self.hasNextPage)
        [self loadNextPage];
}


- (void)loadNextPage{
    if (self.isLoading) return;
    self.isLoading = YES;
    
    //(yOffset < (height / 8.0) && !self.isLoading && self.hasNextPage)
    NSLog(@"Table View Scroll");
    //define URL
    //
    pagination_url = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/?limit=15&offset=%d&access_token=%@", fakedTotalItemCount, savedToken];
    //pagination_url = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/session_Pag/?i1=16&i2=31&access_token=%@", savedToken];
    NSLog(@"%@",pagination_url);
    dispatch_async(TRACQueue, ^{
        NSData* data2 = [NSData dataWithContentsOfURL:
                         [NSURL URLWithString:pagination_url]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            //[self.tableData beginUpdates];
            [self fetchedData:data2];
            [self.tableData reloadData];
            //[indexPath isEqual:[NSIndexPath indexPathForRow:[self tableView:self.tableData numberOfRowsInSection:0]-1 inSection:0]];
            // [self.tableData endUpdates];
            
        });
        
        
    });
    
    
    fakedTotalItemCount = fakedTotalItemCount + 15;

    
    
}

- (NSArray *)fetchedData:(NSData *)responseData {
    @try {
        
        if (title.count>0 && !pullToRefresh){
            //parse out the json data
            NSLog(@"Count Test");
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseData //1
                                  
                                  options:kNilOptions
                                  error:&error];
            
            //NSDictionary* workoutid = [json valueForKey:@"workoutID"]; //2
            
            //Uncover number of sessions, and nested dictionary for sessions
            numSessions = [json valueForKey:@"count"];
            totalSessions = [numSessions intValue];
          //  NSLog(@"Results: %@",numSessions);
            
            NSDictionary* results = [json valueForKey:@"results"];
          //  NSLog(@"Results2: %@",results);
          //  NSLog(@"Results (Dictionary): %@", results);
            
            NSMutableArray* appendedTitle= [results valueForKey:@"name"];
            NSMutableArray* appendedDate = [results valueForKey:@"start_time"];
            NSMutableArray* appendedUrl = [results valueForKey:@"id"];
           // NSLog(@"Appended URL VIEW%@",appendedUrl);
            
            
            
            int date_length = [appendedDate count];
            NSLog(@"Length: %d", date_length);
            NSLog(@"Name: %@", appendedTitle);
            
            int i;
            NSString *tempvar;
            NSMutableArray *temparray;
            NSString *idurl;
            NSMutableArray *idarray;
            NSMutableArray *idNumber;
            NSMutableArray *TitleArray;
            NSString *tempTitle;
            NSLog(@"NULL??? %@",idurl);
            
            //interate through id and associate url with each date
            for (i=0; i<date_length; i++) {
                tempTitle = appendedTitle[i];
                tempvar = appendedDate[i];
                tempvar = [tempvar substringToIndex:10];
                idurl = appendedUrl[i];
                NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/%@/individual_results/?all_athletes=true&access_token=%@",idurl, savedToken];
                
                //to initialize array, for the first entry create variable, then add object for subsequent entries
                if(i==0){
                    
                    temparray=[NSMutableArray arrayWithObject:tempvar];
                    idarray = [NSMutableArray arrayWithObject:idurl2];
                    idNumber = [NSMutableArray arrayWithObject:idurl];
                    
                    //Attempt to make workout a dictionary
                    Workout *initialArray = [Workout new];
                    initialArray.name = tempTitle;
                    initialArray.date = tempvar;
                    initialArray.url = idurl2;
                    initialArray.urlID = idurl;
                    
                    [workoutArray addObject:initialArray];
                    
                }
                else{
                    [temparray addObject:tempvar];
                    [idarray addObject:idurl2];
                    [idNumber addObject:idurl];
                    //[temparray addObject:tempvar];
                    //[temparray replaceObjectAtIndex:i+1 withObject:tempvar];
                    //[temparray replaceObjectAtIndex:i+1 withObject:tempvar];
                    
                   // NSLog(@"IDArray %@", idarray);
                    Workout *initialArray = [Workout new];
                    initialArray.name = tempTitle;
                    initialArray.date = tempvar;
                    initialArray.url = idurl2;
                    initialArray.urlID = idurl;
                    
                    [workoutArray addObject:initialArray];
                    
                    
                
                    
                }
            }
            [idNumberSelector addObjectsFromArray:idNumber];
            appendedDate = temparray;
            appendedUrl = idarray;
            
            NSLog(@"Debug Tag1");
            //idNumberSelector = [[idNumberSelector reverseObjectEnumerator] allObjects];
            //flip orientation of arrays
            //date = [[date reverseObjectEnumerator] allObjects];
            //title = [[title reverseObjectEnumerator] allObjects];
            //url = [[url reverseObjectEnumerator] allObjects];
            //    // Initialize Labels
           
            TitleArray = [NSMutableArray array];
            [TitleArray setArray:title];
            [TitleArray addObjectsFromArray:appendedTitle];
            title = TitleArray;

            [date addObjectsFromArray:appendedDate];


            [url addObjectsFromArray:appendedUrl];

            
            //NSLog(@"Date :%@",date);
           // NSLog(@"Appended Title%@",TitleArray);
           // NSLog(@"Appended Title%@",url);
            NSLog(@"Debug Tag 2");
            
            Workout *obj = [workoutArray objectAtIndex:17];
            NSLog(@"Workout number 17 : %@",obj.name);
            // Once the request is finished, call this
            self.isLoading = NO;
            
            return title;
            return date;
            return url;

        }
        else{
        //parse out the json data
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData //1
                              
                              options:kNilOptions
                              error:&error];
        
        //NSDictionary* workoutid = [json valueForKey:@"workoutID"]; //2
        
        //Uncover number of sessions, and nested dictionary for sessions
        numSessions = [json valueForKey:@"count"];
        totalSessions = [numSessions intValue];
            NSLog(@"Total Sessions %d",totalSessions);

        NSDictionary* results = [json valueForKey:@"results"];


        title= [results valueForKey:@"name"];
        date = [results valueForKey:@"start_time"];
        url = [results valueForKey:@"id"];
        int date_length = [date count];
        //NSLog(@"Length: %d", date_length);
        
        int i;
        NSString *tempvar;
        NSMutableArray *temparray;
        NSString *idurl;
        NSMutableArray *idarray;
        NSMutableArray *idNumber;
        NSString *tempTitle;
        
        //interate through id and associate url with each date
        for (i=0; i<date_length; i++) {
            tempvar = date[i];
            tempvar = [tempvar substringToIndex:10];
            idurl = url[i];
            tempTitle = title[i];
            
            NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/%@/individual_results/?all_athletes=true&access_token=%@",idurl, savedToken];
            
            //to initialize array, for the first entry create variable, then add object for subsequent entries
            if(i==0){
                temparray=[NSMutableArray arrayWithObject:tempvar];
                idarray = [NSMutableArray arrayWithObject:idurl2];
                idNumber = [NSMutableArray arrayWithObject:idurl];
                
                //Attempt to make workout a dictionary
                Workout *initialArray = [Workout new];
                initialArray.name = tempTitle;
                initialArray.date = tempvar;
                initialArray.url = idurl2;
                initialArray.urlID = idurl;
                
                workoutArray = [NSMutableArray arrayWithObjects:initialArray, nil];
                
            }
            else{
                
                [temparray addObject:tempvar];
                [idarray addObject:idurl2];
                [idNumber addObject:idurl];
                
                //Attempt to make workout a dictionary
                Workout *initialArray = [Workout new];
                initialArray.name = tempTitle;
                initialArray.date = tempvar;
                initialArray.url = idurl2;
                initialArray.urlID = idurl;
                
                [workoutArray addObject:initialArray];
                

            }
        }
        idNumberSelector = idNumber;
        date = temparray;
        url = idarray;

        //    // Initialize Labels
        Workout *obj = [workoutArray objectAtIndex:13];
       // NSLog(@"worwkout number 3 : %@",obj.name);
        
            
        pullToRefresh = NO;
            // Once the request is finished, call this
            self.isLoading = NO;
        return title;
        return date;
        return url;
        }

    }
    @catch (NSException *exception) {
        NSLog(@"Exception %s","Except!");
        // Once the request is finished, call this
        self.isLoading = NO;
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
        NSLog(@"Filtered Count %lu", (unsigned long)self.filteredWorkoutArray.count);
        return [self.filteredWorkoutArray count];
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
        workout = [self.filteredWorkoutArray objectAtIndex:indexPath.row];
        cell.textLabel.text = workout.name;
        cell.detailTextLabel.text= workout.date;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //TODO: Fix this so date is correct
        //cell.detailTextLabel.text= date[indexPath.row];
    } else {
        cell.textLabel.text = title[indexPath.row];
        cell.detailTextLabel.text= date[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //on view controller change, move to next page, and pass url to next view
    if ([segue.identifier isEqualToString:@"showWorkoutDetail"]) {
       
        UITabBarController *tabViewController = segue.destinationViewController;
        FirstViewController *firstVC=[[tabViewController viewControllers] objectAtIndex:0];
        

        
        if (self.searchDisplayController.active) {
            Workout *workout = nil;
            workout = [self.filteredWorkoutArray objectAtIndex:searchIndexPath];
            

            firstVC.urlID = workout.urlID;
            firstVC.urlName = workout.url;
            firstVC.workoutDate = workout.date;
            firstVC.workoutName = workout.name;
          
        }
        else{
              
            NSLog(@"Normal Segue");
            NSIndexPath *indexPath = [self.tableData indexPathForSelectedRow];
            firstVC.urlID = [idNumberSelector objectAtIndex:indexPath.row];
            firstVC.urlName = [url objectAtIndex:indexPath.row];
            firstVC.workoutDate = [date objectAtIndex:indexPath.row];
            firstVC.workoutName = [title objectAtIndex:indexPath.row];
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

- (IBAction)createWorkout:(id)sender{
    //if plus button clicked, create workout "On-the-run"
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Create Workout?"
                                                       message:@"Are you sure you want to create a workout?"
                                                      delegate:self
                             
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:@"Cancel",nil];
    [theAlert show];
    
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"The %@ button was tapped.", [theAlert buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex == 0)
    {
        NSLog(@"Discard");
        
        //if signin button clicked query server with credentials
        
        
        NSInteger success = 0;
        @try {
            
            NSString *post =[[NSString alloc] initWithFormat:@"name=On-The-Run Workout"];
            NSLog(@"Post: %@",post);
            
            NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
            NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/?access_token=%@", savedToken];
            
            NSURL *url=[NSURL URLWithString:idurl2];
            
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
                    NSLog(@"SUCCESS");
                    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Success!" message:@"Successfully created workout!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    [self doLoad];
                    //return self.access_token;
                } else {
                    
                    NSLog(@"Failed");
                    
                }
                
            } else {
                //if (error) NSLog(@"Error: %@", error);
                NSLog(@"Failed");
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSASCIIStringEncoding];
                NSLog(@"Response ==> %@", responseData);
            }
            
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            
        }
        
        
        
    }
    
    
}


//For Searching Table Content
#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredWorkoutArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchText];
    self.filteredWorkoutArray = [NSMutableArray arrayWithArray:[workoutArray filteredArrayUsingPredicate:predicate]];
    
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
