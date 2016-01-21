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

@interface RosterTableViewController () <UIActionSheetDelegate>

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *compass_background;
@property (nonatomic, strong) UIImageView *compass_spinner;
@property (assign) BOOL isRefreshIconsOverlap;
@property (assign) BOOL isRefreshAnimating;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

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
    UIToolbar *actionToolbar;
    int fakedTotalItemCount;
    int nextFifteen;
    NSString *savedToken;
    int totalSessions;
    int searchIndexPath;
    BOOL pullToRefresh;
    NSMutableArray *workoutArray;
    NSString *workoutName;
    NSString *workoutDate;
    UIBarButtonItem *splitButton;
    UIBarButtonItem *resetButton;
    NSMutableArray* teamIDs;
    
}

@synthesize tableData;
@synthesize workoutSearchBar;
@synthesize filteredTitleArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButton;
    self.tableData.allowsMultipleSelectionDuringEditing = YES;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    //Define Toolbar
    if (IDIOM ==IPAD) {
        actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 416, self.view.frame.size.width, 44)];
    }
    else{
        actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 416, 320, 44)];
    }
    splitButton =[[UIBarButtonItem alloc]initWithTitle:@"Register" style:UIBarButtonItemStyleDone target:self action:@selector(registerAction:)];
    resetButton = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(createAction:)];
    splitButton.width = [[UIScreen mainScreen] bounds].size.width/2;
    [actionToolbar setItems:@[splitButton,resetButton]];
    
    
    
    [self updateButtonsToMatchTableState];
    [self showActionToolbar:NO];
    //Bad hack to get toolbar to not show when searching
    [self showActionToolbar:YES];
    //Create a light gray background behind datatable
    CGRect frame = self.tableData.bounds;
    frame.origin.y = -frame.size.height;
    UIView* grayView = [[UIView alloc] initWithFrame:frame];
    grayView.backgroundColor = [UIColor lightGrayColor];
    [self.tableData addSubview:grayView];
    
    self.navigationItem.title = @"Roster";
    

    //initialize array for search
    self.filteredTitleArray = [NSMutableArray arrayWithCapacity:[title count]];
    
    
    
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
    
    url_token = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/athletes/?primary_team=True&access_token=%@", savedToken];
    
    //initialize spinner for data load
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    float navigationBarHeight = [[self.navigationController navigationBar] frame].size.height;
    float tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, (self.view.frame.size.height  - navigationBarHeight - tabBarHeight) / 4.0);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    
    
    [self setupRefreshControl];
    [self getTeamID];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [actionToolbar removeFromSuperview];
    self.navigationItem.rightBarButtonItem = nil;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.view.superview addSubview:actionToolbar];
}

- (void)updateButtonsToMatchTableState
{
    if (self.tableData.editing)
    {
        // Show the option to cancel the edit.
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        
        //[self updateSplitButtonTitle];
        
    }
    else
    {
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (self.filteredTitleArray.count > 0)
        {
            self.editButton.enabled = YES;
        }
        else
        {
            self.editButton.enabled = YES;
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
}

- (void)showActionToolbar:(BOOL)show
{
    NSLog(@"Entered it again");
    CGRect toolbarFrame = actionToolbar.frame;
	CGRect tableViewFrame = self.tableData.frame;
	if (show)
	{
		toolbarFrame.origin.y = actionToolbar.superview.frame.size.height - toolbarFrame.size.height;
		tableViewFrame.size.height -= toolbarFrame.size.height;
	}
	else
	{
		toolbarFrame.origin.y = actionToolbar.superview.frame.size.height;
		tableViewFrame.size.height += toolbarFrame.size.height;
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
    NSLog(@"Toolbar Frame, TableView Frame %f,%f",toolbarFrame.origin.y,tableViewFrame.size.height);
	actionToolbar.frame = toolbarFrame;
	self.tableData.frame = tableViewFrame;
	
	[UIView commitAnimations];
}

- (IBAction)editAction:(id)sender
{
    [self.tableData setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
    [self showActionToolbar:YES];
}

- (IBAction)cancelAction:(id)sender
{
    [self.tableData setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
    [self showActionToolbar:NO];
}

- (void)registerAction:(id)sender
{
    
    // Delete what the user selected.
    NSArray *selectedRows = [self.tableData indexPathsForSelectedRows];
    BOOL splitSpecificRows = selectedRows.count > 0;
    

    NSDictionary *athleteData;
    NSMutableArray * s = [NSMutableArray new];
    if (splitSpecificRows)
    {
        // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
        
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            Workout *workout = nil;
            workout = [workoutArray objectAtIndex:selectionIndex.row];
            [s addObject:workout.urlID];

           
        }
        athleteData = @{@"athletes": s};
        NSLog(@"%@",athleteData);

    }
    
    // Exit editing mode after the deletion.
    //async task now.
    
    
    
    NSInteger success = 0;
    
    @try {
        
        NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
        NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/%@/register_athletes/?access_token=%@",self.urlID,savedToken];
        
        NSURL *url=[NSURL URLWithString:idurl2];
        NSError *error2 = nil;
        
        NSArray *array = [s copy];
        NSString *post;
        post =[[NSString alloc] initWithFormat:@"s=[%@]",array];

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:athleteData options:0 error:&error2];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
        NSLog(@"JSON Data Format: %@",jsonString);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
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
                
                
            } else {
                
                NSLog(@"Failed");
                
            }
            
        } else {
            //if (error) NSLog(@"Error: %@", error);
            //NSLog(@"Failed");
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSASCIIStringEncoding];
            NSLog(@"Response ==> %@", responseData);
        }
        
    }
    @catch (NSException * e) {
        // NSLog(@"Exception: %@", e);
        
    }
    
    
}

- (void)createAction:(id)sender{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add Runner" message:@"Add a new runner to your roster" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    
    // Alert style customization
    [[av textFieldAtIndex:1] setSecureTextEntry:NO];
    [[av textFieldAtIndex:0] setPlaceholder:@"Full Name"];
    [[av textFieldAtIndex:1] setPlaceholder:@"ID Number"];
    
    [av show];

}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger success = 0;
    if(buttonIndex == 1){
        if([[alert textFieldAtIndex:0] text].length > 0)
        {
            NSLog(@"Greater than 0");
            //Parse Name into first and last
            NSArray *unparsedString = [[[alert textFieldAtIndex:0] text] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSArray *parsedArray = [unparsedString filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
            
            //Take Data and Create a new user
            NSLog(@"First & Last: %@", parsedArray);
            
            NSString *urlString = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/athletes/?access_token=%@",savedToken];
            UITextField *tagField = [alert textFieldAtIndex:1];
            
            NSURL *urlPost=[NSURL URLWithString:urlString];
            NSError *error2 = nil;
            NSString *fname;
            NSString *lname;
            NSString *tagid = [alert textFieldAtIndex:1].text;
            NSString *teamid = [teamIDs objectAtIndex:0];
            NSDictionary *params;
            
            if ([parsedArray count] == 1 && tagid.length == 0){
                fname = [parsedArray objectAtIndex:0];
                NSString *username = [NSString stringWithFormat:@"%@-%@",fname,teamid];
                params = @{@"first_name": fname,@"username":username,@"team":teamid};
            }
            else if ([parsedArray count] == 1 && tagid.length > 0){
                fname = [parsedArray objectAtIndex:0];
                NSString *username = [NSString stringWithFormat:@"%@-%@",fname,teamid];
                params = @{@"first_name": fname,@"tag":tagid,@"username":username,@"team":teamid};
            }
            else if ([parsedArray count] > 1 && tagid.length == 0){
                fname = [parsedArray objectAtIndex:0];
                lname = [parsedArray objectAtIndex:1];
                NSString *username = [NSString stringWithFormat:@"%@-%@-%@",fname,lname,teamid];
                params = @{@"first_name": fname,@"last_name":lname,@"username":username,@"team":teamid};
            }
            else
            {
                fname = [parsedArray objectAtIndex:0];
                lname = [parsedArray objectAtIndex:1];
                NSString *username = [NSString stringWithFormat:@"%@-%@-%@",fname,lname,teamid];
                params = @{@"first_name": fname,@"last_name":lname,@"username":username,@"tag":tagid,@"team":teamid};
                
            }
            
            
           
            //NSError *error2 = nil;
            
            NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error2];
            
            
            NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
          
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:urlPost];
            [request setHTTPMethod:@"POST"];
            
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = nil;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
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
                    dispatch_async(TRACQueue, ^{
                        NSData* data = [NSData dataWithContentsOfURL:
                                        [NSURL URLWithString:url_token]];
                        
                        dispatch_async(dispatch_get_main_queue() ,^{
                            [self fetchedData:data];
                            [self.tableData reloadData];
                        });
                    });
                    
                } else {
                    
                    NSLog(@"Failed");
                    
                }
                
            } else {
                //if (error) NSLog(@"Error: %@", error);
                //NSLog(@"Failed");
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSASCIIStringEncoding];
                NSLog(@"Response ==> %@", responseData);
            }
        }
    }
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

- (void) getTeamID
{
    NSString *teamURL = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/teams/?primary_team=True&access_token=%@", savedToken];
    NSLog(@"Team ID: %@",savedToken);
    
    dispatch_async(TRACQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:teamURL]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self fetchTeam:data];
           
        });
        
        
    });
    [self.refreshControl endRefreshing];
}

- (NSArray *)fetchTeam:(NSData *)responseData {
    @try {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData //1
                              
                              options:kNilOptions
                              error:&error];
        if (!json || !json.count)
        {
            [self addPrimaryTeam];
        }
        else
        {
        
        teamIDs= [json valueForKey:@"id"];
        }
        return teamIDs;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %s","Except!");
        return teamIDs;
    }
    
}

-(void)addPrimaryTeam{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Create Team:"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              UITextField *temp = alert.textFields.firstObject;
                                                              
                                                              NSLog(@"%@",temp.text);
                                                              NSString *newPrimaryTeam = temp.text;
                                                              [self createTeam:newPrimaryTeam];

                                                          }];

    [alert addAction:defaultAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Team Name";
        textField.keyboardType = UIKeyboardTypeDefault;
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

-(void) createTeam:(NSString*)teamname
{
    NSString *urlEndpoint = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/teams/?access_token=%@", savedToken];
    Boolean primary_team = true;
    
    NSDictionary *params = @{@"name": teamname,@"primary_team":[NSNumber numberWithBool:primary_team]};
    NSError *error2 = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error2];
    NSMutableURLRequest *request_google = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlEndpoint]];
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
                               
                               if ([data length] >0 && error == nil)
                               {
                                   
                                   json = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:0
                                                                            error:nil];
                                   NSLog(@"The create worked %@", json);
                                   teamIDs= [json valueForKey:@"id"];
                               }
                           }];
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


            //parse out the json data
        
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseData //1
                                  
                                  options:kNilOptions
                                  error:&error];
        
        NSMutableArray* urlID= [json valueForKey:@"id"];
        NSMutableArray* firstname= [json valueForKey:@"first_name"];
        NSMutableArray* lastname= [json valueForKey:@"last_name"];
        NSMutableArray* jsontag = [json valueForKey:@"tag"];
        NSMutableArray *id_str = [NSMutableArray arrayWithArray:jsontag];
        NSLog(@"%@, %@", firstname, lastname);
        title=[[NSMutableArray alloc] init];

        for (int i=0; i<[firstname count];i++){
            NSString *combined = [NSString stringWithFormat:@"%@ %@", [firstname objectAtIndex:i], [lastname objectAtIndex:i]];
            [title addObject:combined];
      
            
            if(i==0){
                
                //Attempt to make workout a dictionary
                Workout *initialArray = [Workout new];
                initialArray.name = combined;
                NSString *displayNameType = @"";
                if ([id_str objectAtIndex:i] == [NSNull null]){
                    [id_str replaceObjectAtIndex:i withObject:displayNameType];
                }
                initialArray.date = [id_str objectAtIndex:i];
                initialArray.urlID = [urlID objectAtIndex:i];
                
                workoutArray = [NSMutableArray arrayWithObjects:initialArray, nil];
                
            }
            else{
                //Attempt to make workout a dictionary
                Workout *initialArray = [Workout new];
                initialArray.name = combined;
                if ([id_str objectAtIndex:i] == [NSNull null]){
                    [id_str replaceObjectAtIndex:i withObject:@""];
                }
                initialArray.date = [id_str objectAtIndex:i];
                initialArray.urlID = [urlID objectAtIndex:i];
                [workoutArray addObject:initialArray];
                
                
            }
            
            
            
            
            
        }
        

            date = id_str;
            return title;
            return date;

        
    
    
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
        //[self performSegueWithIdentifier:@"showWorkoutDetail" sender:self];
        
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
