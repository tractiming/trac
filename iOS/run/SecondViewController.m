//
//  SecondViewController.m
//  run
//
//  Created by Griffin Kelly on 5/3/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//
//NSString *url3=@"http://76.12.155.219/trac/splits/w1000.json";
#define TRACQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
//#define workoutURL [NSURL URLWithString:url3] //2
//http://76.12.155.219/trac/splits/w1000.json
#import "SecondViewController.h"
#import "DetailViewController.h"
#import "WorkoutViewController.h"
#import "RunnerDetail.h"

@interface SecondViewController ()

@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *compass_background;
@property (nonatomic, strong) UIImageView *compass_spinner;
@property (assign) BOOL isRefreshIconsOverlap;
@property (assign) BOOL isRefreshAnimating;

@end


@implementation SecondViewController
{
    //NSArray *name;
    NSArray *name;
    UIRefreshControl *refreshControl;
    NSArray* interval;
    NSString *runnersName;
    NSMutableArray *runnersArray;
    int searchIndexPath;
}

@synthesize workoutSearchBar;
@synthesize filteredRunnersArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Create a light gray background behind datatable
    CGRect frame = self.tableData.bounds;
    frame.origin.y = -frame.size.height;
    UIView* grayView = [[UIView alloc] initWithFrame:frame];
    grayView.backgroundColor = [UIColor lightGrayColor];
    [self.tableData addSubview:grayView];

    
    //initialize array for search
    self.filteredRunnersArray = [NSMutableArray arrayWithCapacity:[self.runners count]];
    
    // Hide the search bar until user scrolls up
    CGRect newBounds = self.tableData.bounds;
    newBounds.origin.y = newBounds.origin.y + workoutSearchBar.bounds.size.height;
    self.tableData.bounds = newBounds;
    
    //Initialize the spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    float navigationBarHeight = [[self.navigationController navigationBar] frame].size.height;
    float tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, (self.view.frame.size.height  - navigationBarHeight - tabBarHeight) / 4.0);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    dispatch_async(TRACQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:self.urlName_VC2]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self fetchedData:data];
            [self.tableData reloadData];
            [spinner removeFromSuperview];

        });
        
    
    });

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
    CGFloat midX = self.tableData.frame.size.width / 2.0;
    
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




//Pull to refresh class called when pulled
- (void) doLoad
{
    dispatch_async(TRACQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:self.urlName_VC2]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self fetchedData:data];
            [self.tableData reloadData];
            
            
        });
        
        
    });
    [refreshControl endRefreshing];
}

- (NSArray *)fetchedData:(NSData *)responseData {
    @try {
        //parse out the json data
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData //1
                              
                              options:kNilOptions
                              error:&error];
        
        
        NSString* results = [json valueForKey:@"results"];
        self.runners= [results valueForKey:@"name"];
        interval = [results valueForKey:@"splits"];
        int array_length = [self.runners count];
        runnersArray = [NSMutableArray array];
        for (int kk=0;kk<array_length;kk++)
        {
            RunnerDetail *initialArray = [RunnerDetail new];
            initialArray.runnerName = self.runners[kk];
            initialArray.splitArray = interval[kk];
            [runnersArray addObject:initialArray];
        }

        
        return runnersArray;
        

    }
    @catch (NSException *exception) {
        return self.runners;
    }
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredRunnersArray count];
    } else {
        //number of rows in tableview
        return [self.runners count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        RunnerDetail *runnerDetail = nil;
        runnerDetail = [self.filteredRunnersArray objectAtIndex:indexPath.row];
        cell.textLabel.text = runnerDetail.runnerName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        //set data into cells, name and icon
        cell.textLabel.text = self.runners[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    searchIndexPath = indexPath.row;
    if (self.searchDisplayController.active) {
        NSLog(@"It used the search thing");
        RunnerDetail *runnerDetail = nil;
        runnerDetail = [self.filteredRunnersArray objectAtIndex:indexPath.row];
        self.personalSplits=[[NSMutableArray alloc] init];
        self.counterArray = [NSMutableArray array];
        self.splitString= self.runners[indexPath.row];
        NSInteger ii=0;

        //on click, display every repeat done. iterate through all splits per individual selected
        for (NSArray *personalRepeats in runnerDetail.splitArray ) {
            ii=ii+1;
            
            NSString *counter = [[NSNumber numberWithInt:ii] stringValue];
            [self.counterArray addObject:counter];
            
            for(NSArray *subInterval in personalRepeats){
                
                //Initalize Array in loop?
                
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                NSNumber *sum = [f numberFromString:subInterval];
                NSNumber *sumInt =@([sum integerValue]);
                NSNumber*decimal =[NSNumber numberWithFloat:(([sum floatValue]-[sumInt floatValue])*1000)];
                NSNumber *decimalInt = @([decimal integerValue]);
                
                
                //to do add decimal to string, round to 3 digits
                NSNumber *minutes = @([sum integerValue] / 60);
                NSNumber *seconds = @([sum integerValue] % 60);
                NSNumber *ninty = [NSNumber numberWithInt:90];
                
                if ([sumInt intValue]<[ninty intValue]){
                    //if less than 90 display in seconds
                    self.personalSplits=[self.personalSplits arrayByAddingObject:subInterval];
                }
                else{
                    //If greater than 90 seconds display in minute format
                    //If less than 10 format with additional 0
                    if ([seconds intValue]<10) {
                        NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@.%@",minutes,seconds,decimalInt];
                        self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                        
                    }
                    //If greater than 10 seconds, dont use the preceding 0
                    else{
                        NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@.%@",minutes,seconds,decimalInt];
                        self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                        
                    }
                }
                
            }
        }

    
    }
    else{
    NSLog(@"Non active search?");
    self.personalSplits=[[NSMutableArray alloc] init];
    self.counterArray = [NSMutableArray array];
    self.splitString= self.runners[indexPath.row];
    NSInteger ii=0;
    //on click, display every repeat done. iterate through all splits per individual selected
    for (NSArray *personalRepeats in interval[indexPath.row] ) {
        ii=ii+1;
       
        NSString *counter = [[NSNumber numberWithInt:ii] stringValue];
        [self.counterArray addObject:counter];
        
        for(NSArray *subInterval in personalRepeats){

                //Initalize Array in loop?
                
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                NSNumber *sum = [f numberFromString:subInterval];
                NSNumber *sumInt =@([sum integerValue]);
                NSNumber*decimal =[NSNumber numberWithFloat:(([sum floatValue]-[sumInt floatValue])*1000)];
                NSNumber *decimalInt = @([decimal integerValue]);
                
               
                //to do add decimal to string, round to 3 digits
                NSNumber *minutes = @([sum integerValue] / 60);
                NSNumber *seconds = @([sum integerValue] % 60);
                NSNumber *ninty = [NSNumber numberWithInt:90];
               
                if ([sumInt intValue]<[ninty intValue]){
                    //if less than 90 display in seconds
                    self.personalSplits=[self.personalSplits arrayByAddingObject:subInterval];
                                   }
                else{
                    //If greater than 90 seconds display in minute format
                    //If less than 10 format with additional 0
                    if ([seconds intValue]<10) {
                        NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@.%@",minutes,seconds,decimalInt];
                        self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];

                    }
                    //If greater than 10 seconds, dont use the preceding 0
                    else{
                        NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@.%@",minutes,seconds,decimalInt];
                        self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                       
                    }
                }

        }
    }
    
    runnersName = self.runners[indexPath.row];
        
    }
    [self performSegueWithIdentifier:@"workoutDetail" sender:tableView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //on view controller change, move to next page, and pass url to next view

    if ([segue.identifier isEqualToString:@"workoutDetail"]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        if (self.searchDisplayController.active) {
            RunnerDetail *runnerDetail = nil;
            runnerDetail = [self.filteredRunnersArray objectAtIndex:searchIndexPath];
            detailViewController.runnersName = runnerDetail.runnerName;
            detailViewController.urlString = self.urlName_VC2;

            detailViewController.workoutDetail = self.personalSplits;
            detailViewController.counterArray = self.counterArray;

        }
        else{
            detailViewController.workoutDetail = self.personalSplits;
            detailViewController.runnersName = runnersName;
            detailViewController.counterArray = self.counterArray;
            detailViewController.urlString = self.urlName_VC2;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


//For Searching Table Content
#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredRunnersArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"runnerName contains[c] %@",searchText];
    self.filteredRunnersArray = [NSMutableArray arrayWithArray:[runnersArray filteredArrayUsingPredicate:predicate]];
    NSLog(@"DOes this work? %@", self.filteredRunnersArray);
    
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
