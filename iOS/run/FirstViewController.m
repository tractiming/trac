//
//  FirstViewController.m
//  run
//
//  Created by Griffin Kelly on 5/3/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//
//NSString *url=@"http://localhost:8888/api/sessions/3.json";

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
//#define kLatestKivaLoansURL [NSURL URLWithString:self.urlName] //2
//http://76.12.155.219/trac/json/test.json

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "CustomCell.h"
#import "CustomCelliPad.h"
#import "UIView+Toast.h"
#import "TRACDatabase.h"
#import "TRACDoc.h"
#import "Data.h"
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
#define UITableViewCellEditingStyleMultiSelect (3)
#import "SSSnackbar.h"
#import "TokenVerification.h"

@interface FirstViewController() <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, assign) CFTimeInterval ticks;

@end



@implementation FirstViewController
{
    
    NSArray *name;
    UIActivityIndicatorView *spinner;
    NSTimer *timer;
    UIToolbar *actionToolbar;
    NSString* elapsedtime;
    BOOL Executed;
    NSUInteger universalIndex;
    NSArray *superlasttime;
    UIBarButtonItem *splitButton;
    UIBarButtonItem *resetButton;
    NSMutableString *countedTime;
    UILabel *toastText;
    UIView *customView;
    double CurrentTime;
    double tempTime;
    double tempTimeMax;
    
}
@synthesize tracDoc = _tracDoc;

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

- (void)updateSplitButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableData indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == self.athleteDictionaryArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        splitButton.title = NSLocalizedString(@"Split All", @"");
        resetButton.title = NSLocalizedString(@"Reset All", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"Split (%d)", @"Title for delete button with placeholder for number");
        splitButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
        NSString *titleFormatString2 =
        NSLocalizedString(@"Reset (%d)", @"Title for delete button with placeholder for number");
        resetButton.title = [NSString stringWithFormat:titleFormatString2, selectedRows.count];
    }
}
- (void)updateButtonsToMatchTableState
{
    if (self.tableData.editing)
    {
        // Show the option to cancel the edit.
        self.parentViewController.navigationItem.rightBarButtonItem = self.cancelButton;
        
        [self updateSplitButtonTitle];
       
    }
    else
    {
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (self.runners.count > 0)
        {
            self.editButton.enabled = YES;
        }
        else
        {
            self.editButton.enabled = YES;
        }
        self.parentViewController.navigationItem.rightBarButtonItem = self.editButton;
    }
}

- (void)splitAction:(id)sender
{
    // Delete what the user selected.
    NSArray *selectedRows = [self.tableData indexPathsForSelectedRows];
    //NSLog(@"Selected Rows, %@",selectedRows);
    BOOL splitSpecificRows = selectedRows.count > 0;
    
    //Get current time in UTC
    NSDate *currentDate = [[NSDate alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS"];
    [dateFormatter setTimeZone:timeZone];
    NSString *localDateString = [dateFormatter stringFromDate:currentDate];
    NSMutableArray * s = [NSMutableArray new];
    if (splitSpecificRows)
    {
        // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
        
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            
            NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:selectionIndex.row];
            NSUInteger indexOfTheObject = [self.selectedRunners indexOfObject:[tempDict valueForKey:@"athleteID"]];
            NSDictionary *tempCreatedDict = @{@"athlete":[tempDict valueForKey:@"athleteID"],@"sessions":@[self.urlID],@"tag":[NSNull null],@"reader":[NSNull null],@"time":[self.selectedRunnersUTC objectAtIndex:indexOfTheObject]};
            [s addObject:tempCreatedDict];
           
            NSLog(@"Value of S: %@",s);
            
            //For the toast to keep time
            NSLog(@"%@, %@", [tempDict valueForKey:@"countStart"], [tempDict valueForKey:@"numberSplits"]);
            double tempHolder =[[tempDict valueForKey:@"numberSplits"] doubleValue];
            
            if ([[tempDict valueForKey:@"lastSplit"] isEqualToString:@"DNS"]){
                NSLog(@"Entered DNS?");
                [tempDict removeObjectForKey:@"dateTime"];
                [tempDict setObject:[self.selectedRunnersToast objectAtIndex:indexOfTheObject] forKey:@"dateTime"];
            }
            else if ([[tempDict valueForKey:@"countStart"] doubleValue] == 0) {
                //Do Nothing
            }
            else if ([[tempDict valueForKey:@"countStart"] doubleValue] == tempHolder){
                [tempDict removeObjectForKey:@"dateTime"];
                [tempDict setObject:[self.selectedRunnersToast objectAtIndex:indexOfTheObject] forKey:@"dateTime"];
                NSLog(@"Executed");
            }
        }

    }
    else
    {
        //For Split ALL
        NSArray *selectedRows = [self.tableData indexPathsForVisibleRows];
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:selectionIndex.row];
            NSDictionary *tempCreatedDict = @{@"athlete":[tempDict valueForKey:@"athleteID"],@"sessions":@[self.urlID],@"tag":[NSNull null],@"reader":[NSNull null],@"time":localDateString};
            [s addObject:tempCreatedDict];
            
            NSLog(@"Value of S: %@",s);
            
            //For the toast to keep time
            NSLog(@"%@, %@", [tempDict valueForKey:@"countStart"], [tempDict valueForKey:@"numberSplits"]);
            double tempHolder =[[tempDict valueForKey:@"numberSplits"] doubleValue];
            
            if ([[tempDict valueForKey:@"lastSplit"] isEqualToString:@"DNS"]){
                NSLog(@"Entered DNS?");
                [tempDict removeObjectForKey:@"dateTime"];
                [tempDict setObject:[NSNumber numberWithDouble:CACurrentMediaTime()] forKey:@"dateTime"];
            }
            else if ([[tempDict valueForKey:@"countStart"] doubleValue] == 0) {
                //Do Nothing
            }
            else if ([[tempDict valueForKey:@"countStart"] doubleValue] == tempHolder){
                [tempDict removeObjectForKey:@"dateTime"];
                [tempDict setObject:[NSNumber numberWithDouble:CACurrentMediaTime()] forKey:@"dateTime"];
                NSLog(@"Executed");
            }
        }        // Delete everything, delete the objects from our data model.
        //Take every row and put into json. Then Send it
    }
    
    
    //Clear the selection arrays
    [self.selectedRunnersUTC removeAllObjects];
    [self.selectedRunners removeAllObjects];
    [self.selectedRunnersToast removeAllObjects];
    // Exit editing mode after the deletion.
    //async task now.
    
    
    
    NSInteger success = 0;
    
    @try {
        
        NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
        NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/splits/?access_token=%@",savedToken];
        
        NSURL *url=[NSURL URLWithString:idurl2];
        NSError *error2 = nil;
        
        //NSData *jsonData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:s options:0 error:&error2];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
        //NSMutableData *data = [NSMutableData data];
        //[data appendData:[sendThis dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        NSLog(@"JSON Data Format: %@",jsonString);
        
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"%ld",(long)[response statusCode]);
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
    

    //[self showActionToolbar:NO];
    //[self.tableData setEditing:NO animated:YES];
    //[self updateButtonsToMatchTableState];
    //NSLog(@"Hits Again?");
    [self sendRequest];

    
}


- (void)resetAction:(id)sender{
    //[self splitAction:nil];
    // Delete what the user selected.
    NSArray *selectedRows = [self.tableData indexPathsForSelectedRows];
    //NSLog(@"Selected Rows, %@",selectedRows);
    BOOL resetSpecificRows = selectedRows.count > 0;
    //reset counter index and on click of reset button refresh rows to start at 0.
    NSNumber *minutes = @(0);
    NSNumber *seconds = @(0);
    elapsedtime = [NSString stringWithFormat:@"%@:0%@",minutes,seconds];
    
    
    if (resetSpecificRows)
    {
        // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
        
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:selectionIndex.row];
            [tempDict removeObjectForKey:@"countStart"];
            [tempDict setObject:[tempDict valueForKey:@"numberSplits"] forKey:@"countStart"];
            //NSLog(@"Updated Reset");
            [tempDict removeObjectForKey:@"totalTime"];
            [tempDict setObject:elapsedtime forKey:@"totalTime"];
            [tempDict removeObjectForKey:@"dateTime"];
            [tempDict setObject:[NSNumber numberWithDouble:CACurrentMediaTime()] forKey:@"dateTime"];
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:selectionIndex.row inSection:0];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
            [self.tableData reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
            [self updateButtonsToMatchTableState];
        }

    }
    else
    {
        NSArray *selectedRows = [self.tableData indexPathsForVisibleRows];
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:selectionIndex.row];
            [tempDict removeObjectForKey:@"countStart"];
            [tempDict setObject:[tempDict valueForKey:@"numberSplits"] forKey:@"countStart"];
            //NSLog(@"Updated Reset");
            [tempDict removeObjectForKey:@"totalTime"];
            [tempDict setObject:elapsedtime forKey:@"totalTime"];
            [tempDict removeObjectForKey:@"dateTime"];
            [tempDict setObject:[NSNumber numberWithDouble:CACurrentMediaTime()] forKey:@"dateTime"];
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:selectionIndex.row inSection:0];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
            [self.tableData reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
            [self updateButtonsToMatchTableState];
            
        }
       
    }

    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.resetValueArray removeAllObjects];
    [self.athleteIDArray removeAllObjects];
    [self.utcTimeArray removeAllObjects];
    NSLog(@"Trying to save");
    for (NSMutableDictionary *tempDict in self.athleteDictionaryArray) {
        NSLog(@"Something is null %@, %@, %@",[tempDict valueForKey:@"countStart"], [tempDict valueForKey:@"athleteID"], [tempDict valueForKey:@"dateTime"]);

        [self.resetValueArray addObject:[tempDict valueForKey:@"countStart"]];
        [self.athleteIDArray addObject: [tempDict valueForKey:@"athleteID"]];
        [self.utcTimeArray addObject:[tempDict valueForKey:@"dateTime"]];
    }
    NSLog(@"Data in here? %@, %@, %@",self.resetValueArray, self.athleteIDArray, self.utcTimeArray);
    
    TRACDoc *newDoc = [[TRACDoc alloc] initWithTitle:self.athleteIDArray toast:self.utcTimeArray reset:self.resetValueArray];
    [newDoc saveData:self.urlID];
    
    [timer invalidate];
    [actionToolbar removeFromSuperview];
    self.parentViewController.navigationItem.rightBarButtonItem = nil;

}
- (void)viewWillAppear:(BOOL)animated{
    
    BOOL redirect = [TokenVerification findToken];
    if (!redirect) {
        [self performSegueWithIdentifier:@"logout_exception" sender:self];
    }
    
    
    self.selectedRunners = [[NSMutableArray alloc] init];
    self.selectedRunnersUTC = [[NSMutableArray alloc] init];
    self.selectedRunnersToast = [[NSMutableArray alloc] init];
    
    
    NSMutableArray *loadDocs = [TRACDatabase loadDocs:self.urlID];
    for (TRACDoc* doc in loadDocs)
    {
        TRACDoc* datatoLoad = doc;
        self.athleteIDArray = [[NSMutableArray alloc] initWithArray:datatoLoad.data.storedIDs];
        self.utcTimeArray = [[NSMutableArray alloc] initWithArray:datatoLoad.data.storedToast];
        self.resetValueArray = [[NSMutableArray alloc] initWithArray:datatoLoad.data.storedReset];
        NSLog(@"Stored Array Values %@,%@,%@",datatoLoad.data.storedIDs,datatoLoad.data.storedToast,datatoLoad.data.storedReset);
        
    }
    [TRACDatabase deletePath:self.urlID];
    
    if([loadDocs count]== 0 || loadDocs == nil){
        NSLog(@"Init Arrays as doc is null");
        self.resetValueArray = [[NSMutableArray alloc] init];
        self.athleteIDArray = [[NSMutableArray alloc] init];
        self.utcTimeArray = [[NSMutableArray alloc] init];
    }
    
    self.parentViewController.navigationItem.rightBarButtonItem = self.editButton;
    self.tableData.contentInset = UIEdgeInsetsMake(0,0,44,0);
//NSLog(@"Reappear");
    dispatch_async(kBgQueue, ^{
        
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:self.urlName]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            
            [self fetchedData:data];
            [self.tableData reloadData];
            [spinner removeFromSuperview];
        });});

    
    // call timer on launch and call sendRequest every 5 seconds
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(sendRequest) userInfo:nil repeats:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CurrentTime = CACurrentMediaTime();

    

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    [self.tableData addGestureRecognizer:lpgr];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"myNotification"
                                               object:nil];
    
    self.athleteDictionaryArray = [[NSMutableArray alloc] init];
    Executed = TRUE;
    self.tableData.allowsMultipleSelectionDuringEditing = YES;
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    [self.tabBarController.navigationItem setTitle:self.workoutName];
    //initilize spinner
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    float navigationBarHeight = [[self.navigationController navigationBar] frame].size.height;

    float tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, (self.view.frame.size.height  - navigationBarHeight - tabBarHeight) / 4.0);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    //Async Task Called
    SecondViewController *svc = [self.tabBarController.viewControllers objectAtIndex:1];
    svc.urlName_VC2 = self.urlName;
    
    ThirdViewController *tvc = [self.tabBarController.viewControllers objectAtIndex:2];
    tvc.urlID = self.urlID;
    
    if (IDIOM ==IPAD) {
        actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 416, self.view.frame.size.width, 44)];
    }
    else{
        actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 416, 320, 44)];
    }
    splitButton =[[UIBarButtonItem alloc]initWithTitle:@"Split All" style:UIBarButtonItemStyleDone target:self action:@selector(splitAction:)];
    resetButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetAction:)];
    splitButton.width = [[UIScreen mainScreen] bounds].size.width/2;
    [actionToolbar setItems:@[splitButton,resetButton]];
    [self updateButtonsToMatchTableState];
    [self showActionToolbar:NO];
        
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    
     CGPoint location = [gestureRecognizer locationInView:self.tableData];
    
    NSIndexPath *indexPath = [self.tableData indexPathForRowAtPoint:location];
    if (indexPath == nil) {
        //NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if([self.timer isValid])
        {
            NSLog(@"If Clock is running, invalidate it");
            [self.timer invalidate];
            self.timer = nil;
        }
        
        
        NSLog(@"long press on table view at row %ld", (long)indexPath.row);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshTimeLabel:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        });
        
        
        
        tempTime = [[[self.athleteDictionaryArray objectAtIndex:indexPath.row] valueForKey:@"dateTime"] doubleValue];
        if (tempTime != 0){
            tempTimeMax = CACurrentMediaTime() - tempTime + 99999999;
            }
        else{
            tempTimeMax = CACurrentMediaTime() - CurrentTime + 99999999;
        }
        
        customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        [customView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)]; // autoresizing masks are respected on custom views
        toastText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        toastText.adjustsFontSizeToFitWidth = true;
        toastText.textAlignment = NSTextAlignmentCenter;
        [toastText setTextColor:[UIColor whiteColor]];
        [toastText setCenter:customView.center];
        
        SSSnackbar *snackbar;
        snackbar = [self snackbarForQuickRunningItem:toastText atIndexPath:indexPath];
        [snackbar show];
       
    } else {
       // NSLog(@"gestureRecognizer.state = %ld", gestureRecognizer.state);
    }
    
    // More coming soon...
}

- (SSSnackbar *)snackbarForQuickRunningItem:(UILabel *)itemView atIndexPath:(NSIndexPath *)indexPath {
    
    SSSnackbar *snackbar = [SSSnackbar snackbarWithMessage:itemView
                                                actionText:@"Hide"
                                                  duration:99999999
                                               actionBlock:^(SSSnackbar *sender){[self.timer invalidate];
                                               }
                                            dismissalBlock:^(SSSnackbar *sender){[self.timer invalidate];
                                            }];
    return snackbar;
}


-(void)refreshTimeLabel:(id)sender
{
    NSLog(@"Hit the time label");
    // Timers are not guaranteed to tick at the nominal rate specified, so this isn't technically accurate.
    // However, this is just an example to demonstrate how to stop some ongoing activity, so we can live with that inaccuracy.
    _ticks = 0.1;
    double time = CACurrentMediaTime() - CurrentTime;
    time += _ticks;
    
    if (tempTime != 0)
    {
         time = CACurrentMediaTime() - tempTime;
    }
    NSLog(@"%f",time);
    //CFTimeInterval maxticks = _ticks + 3;
    NSLog(@"%f, %f",time,tempTimeMax);
    if (time < tempTimeMax){
        double seconds = fmod(time, 60.0);
        double minutes = fmod(trunc(time / 60.0), 60.0);
        double hours = trunc(time / 3600.0);
        toastText.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%04.1f", hours, minutes, seconds];
    }
    else{
       // [_timer invalidate];
    }
}


- (void)receiveNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"myNotification"]) {
        //NSLog(@"Hello its me : %@",notification.object);
        self.storeDelete = notification.object;
        //doSomething here.
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.view.superview addSubview:actionToolbar];
}

- (void)showActionToolbar:(BOOL)show
{
    //NSLog(@"Entered it again");
    CGRect toolbarFrame = actionToolbar.frame;
	CGRect tableViewFrame = self.tableData.frame;
    UITabBarController *tabBarController = [UITabBarController new];
    CGFloat tabBarHeight = tabBarController.tabBar.frame.size.height;
	if (show)
	{
		toolbarFrame.origin.y = actionToolbar.superview.frame.size.height - toolbarFrame.size.height-tabBarHeight;
		tableViewFrame.size.height -= toolbarFrame.size.height;
	}
	else
	{
		toolbarFrame.origin.y = actionToolbar.superview.frame.size.height-tabBarHeight;
		tableViewFrame.size.height += toolbarFrame.size.height;
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
    //NSLog(@"Toolbar Frame, TableView Frame %f,%f",toolbarFrame.origin.y,tableViewFrame.size.height);
	actionToolbar.frame = toolbarFrame;
	self.tableData.frame = tableViewFrame;
	
	[UIView commitAnimations];
}

- (void) sendRequest
{
    //NSLog(@"This is Null??");
    //Async Task Called
    dispatch_async(kBgQueue, ^{
        
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:self.urlName]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            
            [self fetchedData:data];
            
            [spinner removeFromSuperview];
        });});

    SecondViewController *svc = [self.tabBarController.viewControllers objectAtIndex:1];
    svc.urlName_VC2 = self.urlName;
}

- (NSArray *)fetchedData:(NSData *)responseData {
    //NSLog(@"Delete? %@",self.storeDelete);
    if (self.storeDelete)
    {
        NSLog(@"Enters the if");
        Executed = TRUE;
        [self.athleteDictionaryArray removeAllObjects];
        [self.tableData reloadData];
        self.storeDelete = NULL;
    }
    //parse out the json data
    
    //NSLog(@"Enters Fetched Data Again");
   @try {
        NSError* error;
        NSDictionary* json= [NSJSONSerialization
                             JSONObjectWithData:responseData //1
                             
                             options:kNilOptions
                             error:&error];

        NSString* results = [json valueForKey:@"results"];

        self.runners= [results valueForKey:@"name"];
        self.runnerID = [results valueForKey:@"id"];
        self.interval = [results valueForKey:@"splits"];
        self.has_split = [results valueForKey:@"has_split"];

       self.summationTimeArray = [[NSMutableArray alloc] init];
       self.lasttimearray = [[NSMutableArray alloc] init];
       
        //Iterate through most recent JSON request
        NSUInteger index = 0;
       
        for (NSArray *personalinterval in self.interval) {
           
            if(Executed == TRUE){
                if(![[self.has_split objectAtIndex:index] boolValue]){
                    elapsedtime = [NSString stringWithFormat:@"DNS"];
                    superlasttime = [NSString stringWithFormat:@"DNS"];
                    universalIndex = NULL;
                }
                else if(!personalinterval || !personalinterval.count){
                    elapsedtime = [NSString stringWithFormat:@"NT"];
                    superlasttime = [NSString stringWithFormat:@"NT"];
                    universalIndex = 0;
                }
                else{
                    //adds all intervals together to give cumulative time
                    NSArray *tempArray = [self.interval objectAtIndex:index];
                    
                    //adds all intervals together to give cumulative time
                    NSMutableArray *finaltimeArray=[[NSMutableArray alloc] init];
                    NSInteger rangeVar;
                    
                    NSUInteger indexOfAthlete = [self.athleteIDArray indexOfObject:[self.runnerID objectAtIndex:index]];
                    
                    if (self.utcTimeArray == nil || [self.utcTimeArray count] == 0)
                    {
                        NSLog(@"Setting Zero");
                        rangeVar = [[NSNumber numberWithInt:0] integerValue];
                    }
                    else{
                        NSLog(@"Varying Time");
                        rangeVar = [[self.resetValueArray objectAtIndex:indexOfAthlete] integerValue];
                    }
                    
                   
                    if(rangeVar == 0){
                        //do nothing because you want the 0 to be counted in the elapsed time.
                    }
                    else
                    {
                        //Dont count the rest period so skip 1.
                        rangeVar = rangeVar + 1;
                    }
                    NSArray *resetViewCount = [tempArray subarrayWithRange: NSMakeRange(rangeVar, [tempArray count]-rangeVar)];
                    NSLog(@"Reset View Count: %@",resetViewCount);
                    
                    for (NSArray *subinterval in resetViewCount){
                        NSArray* subs=[subinterval lastObject];
                        finaltimeArray =[finaltimeArray arrayByAddingObject:subs];
                        
                    }
                    universalIndex = [tempArray count];

                    
                    NSNumber *sum = [finaltimeArray valueForKeyPath:@"@sum.floatValue"];
                    
                    NSArray* lastsettime=[personalinterval lastObject];
                    NSNumber *lastsplit = [lastsettime valueForKeyPath:@"@sum.floatValue"];
                    NSNumber *sumInt =@([lastsplit integerValue]);
                    NSNumber *ninty = [NSNumber numberWithInt:90];
                    NSNumber*decimal =[NSNumber numberWithFloat:(([lastsplit floatValue]-[sumInt floatValue])*1000)];
                    NSNumber *decimalInt = @([decimal integerValue]);
                    
                    
                    //to do add decimal to string, round to 3 digits
                    NSNumber *lastsplitminutes = @([lastsplit integerValue] / 60);
                    NSNumber *lastsplitseconds = @([lastsplit integerValue] % 60);
                    NSMutableArray *lasttime = [[NSMutableArray alloc] init];
                    if ([lastsplit intValue]<[ninty intValue]){
                        //if less than 90 display in seconds
                        lasttime=[personalinterval lastObject];
                        //NSLog(@"Last Time %@",lasttime);
                    }
                    else{
                        //If greater than 90 seconds display in minute format
                        //If less than 10 format with additional 0
                        if ([lastsplitseconds intValue]<10) {
                            NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                            [lasttime addObject:elapsedtime];
                            //NSLog(@"Last Time %@",lasttime);
                            //self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                            
                        }
                        //If greater than 10 seconds, dont use the preceding 0
                        else{
                            NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                            [lasttime addObject:elapsedtime];
                            //NSLog(@"Last Time %@",lasttime);
                        }
                    }
                    
                    
                    //NSArray* lasttime=[lastsettime lastObject];
                    superlasttime = [lasttime lastObject];
                    
                    NSNumber *minutes = @([sum integerValue] / 60);
                    NSNumber *seconds = @([sum integerValue] % 60);
                    
                    //format total time in minute second format
                    if ([seconds intValue]<10) {
                        elapsedtime = [NSString stringWithFormat:@"%@:0%@",minutes,seconds];
                        [self.summationTimeArray addObject:elapsedtime];
                        
                    }
                    else{
                        elapsedtime = [NSString stringWithFormat:@"%@:%@",minutes,seconds];
                        [self.summationTimeArray addObject:elapsedtime];
                        
                    }
                    
                    [self.lasttimearray addObject:superlasttime];
                    NSLog(@"Array, %@",self.lasttimearray);
                    
                    
                    
                }
                NSUInteger indexOfAthlete = [self.athleteIDArray indexOfObject:[self.runnerID objectAtIndex:index]];

                
                NSMutableDictionary *athleteDictionary = [NSMutableDictionary new];
                [athleteDictionary setObject:[self.runners objectAtIndex:index] forKey:@"name"];
                [athleteDictionary setObject:[self.runnerID objectAtIndex:index] forKey:@"athleteID"];
                [athleteDictionary setObject:superlasttime forKey:@"lastSplit"];
                if (self.utcTimeArray == nil || [self.utcTimeArray count] == 0)
                {
                    NSLog(@"Setting Zero");
                    [athleteDictionary setObject:[NSNumber numberWithInt:0] forKey:@"countStart"];
                    [athleteDictionary setObject:[NSNumber numberWithDouble:0] forKey:@"dateTime"];
                }
                else{
                    NSLog(@"Varying Time");
                    [athleteDictionary setObject:[self.resetValueArray objectAtIndex:indexOfAthlete] forKey:@"countStart"];
                    [athleteDictionary setObject:[self.utcTimeArray objectAtIndex:indexOfAthlete] forKey:@"dateTime"];
                }
                
                
                [athleteDictionary setObject:[NSNumber numberWithInt:universalIndex] forKey:@"numberSplits"];
                [athleteDictionary setObject:elapsedtime forKey:@"totalTime"];
                [self.athleteDictionaryArray addObject:athleteDictionary];
                
            }
            
            else{
                //Does the row exist from a previous polling. Check Athlete IDs versus stored dictionary.
                NSMutableArray *tempArray = [self.athleteDictionaryArray valueForKey:@"athleteID"];
                BOOL found = CFArrayContainsValue ( (__bridge CFArrayRef)tempArray, CFRangeMake(0, tempArray.count), (CFNumberRef) [self.runnerID objectAtIndex:index]);
                NSUInteger closestIndex = [tempArray indexOfObject:[self.runnerID objectAtIndex:index]];
                //NSLog(@"Index %lu", (unsigned long)closestIndex);
                //If the new index is in the dictionary, and if it hasnt loaded all the splits update them and reload.
                if (found){
                    
                    if ([[self.has_split objectAtIndex:index] boolValue]) {
                        NSLog(@"Last Split String: %@", [[self.athleteDictionaryArray objectAtIndex:closestIndex] valueForKey:@"lastSplit"]);
                        if ( [[[self.athleteDictionaryArray objectAtIndex:closestIndex] valueForKey:@"lastSplit"] isEqualToString:@"DNS"])
                        {
                            NSLog(@"Deleted Checkbox again");
                            elapsedtime = [NSString stringWithFormat:@"NT"];
                            superlasttime = [NSString stringWithFormat:@"NT"];
                            universalIndex = 0;
                            
                            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:closestIndex inSection:0];
                            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                            NSArray *tempArray= [self.interval objectAtIndex:index];
                            //update the dictionary here for that index
                            NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:closestIndex];
                            [tempDict removeObjectForKey:@"lastSplit"];
                            [tempDict removeObjectForKey:@"numberSplits"];
                            [tempDict removeObjectForKey:@"totalTime"];
                            [tempDict setObject:superlasttime forKey:@"lastSplit"];
                            [tempDict setObject:[NSNumber numberWithInt:universalIndex] forKey:@"numberSplits"];
                            [tempDict setObject:elapsedtime forKey:@"totalTime"];
                            
                            [self.tableData reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                        }
                        else if ((unsigned long)[personalinterval count] > (long)[[[self.athleteDictionaryArray objectAtIndex:closestIndex] valueForKey:@"numberSplits"] integerValue]) {
                            
                            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:closestIndex inSection:0];
                            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                            NSArray *tempArray= [self.interval objectAtIndex:index];
                        
                        //adds all intervals together to give cumulative time
                        NSMutableArray *finaltimeArray=[[NSMutableArray alloc] init];
                        NSMutableDictionary *tempDictIndex = [self.athleteDictionaryArray objectAtIndex:closestIndex];
                        NSInteger rangeVar = [[tempDictIndex valueForKey:@"countStart"] integerValue];
                        if(rangeVar == 0){
                            //do nothing because you want the 0 to be counted in the elapsed time.
                        }
                        else
                        {
                            //Dont count the rest period so skip 1.
                            rangeVar = rangeVar + 1;
                        }
                        NSArray *resetViewCount = [tempArray subarrayWithRange: NSMakeRange(rangeVar, [tempArray count]-rangeVar)];
                            NSLog(@"Reset View Count: %@",resetViewCount);

                        for (NSArray *subinterval in resetViewCount){
                            NSArray* subs=[subinterval lastObject];
                            finaltimeArray =[finaltimeArray arrayByAddingObject:subs];
                            
                        }
                        universalIndex = [tempArray count];
                        
                        NSNumber *sum = [finaltimeArray valueForKeyPath:@"@sum.floatValue"];
                        
                        NSArray* lastsettime=[tempArray lastObject];
                        NSNumber *lastsplit = [lastsettime valueForKeyPath:@"@sum.floatValue"];
                        NSNumber *sumInt =@([lastsplit integerValue]);
                        NSNumber *ninty = [NSNumber numberWithInt:90];
                        NSNumber*decimal =[NSNumber numberWithFloat:(([lastsplit floatValue]-[sumInt floatValue])*1000)];
                        NSNumber *decimalInt = @([decimal integerValue]);
                        
                        
                        //to do add decimal to string, round to 3 digits
                        NSNumber *lastsplitminutes = @([lastsplit integerValue] / 60);
                        NSNumber *lastsplitseconds = @([lastsplit integerValue] % 60);
                        NSMutableArray *lasttime = [[NSMutableArray alloc] init];
                        if ([lastsplit intValue]<[ninty intValue]){
                            //if less than 90 display in seconds
                            lasttime=[tempArray lastObject];
                        }
                        else{
                            //If greater than 90 seconds display in minute format
                            //If less than 10 format with additional 0
                            if ([lastsplitseconds intValue]<10) {
                                NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                                [lasttime addObject:elapsedtime];
                                
                                //self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                                
                            }
                            //If greater than 10 seconds, dont use the preceding 0
                            else{
                                NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                                [lasttime addObject:elapsedtime];
                               
                            }
                        }
                        
                        
                        //NSArray* lasttime=[lastsettime lastObject];
                        superlasttime = [lasttime lastObject];
                        
                        NSNumber *minutes = @([sum integerValue] / 60);
                        NSNumber *seconds = @([sum integerValue] % 60);
                        
                        //format total time in minute second format
                        if ([seconds intValue]<10) {
                            elapsedtime = [NSString stringWithFormat:@"%@:0%@",minutes,seconds];

                        }
                        else{
                            elapsedtime = [NSString stringWithFormat:@"%@:%@",minutes,seconds];

                        }

                        
                        
                        //update the dictionary here for that index
                        NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:closestIndex];
                        [tempDict removeObjectForKey:@"lastSplit"];
                        [tempDict removeObjectForKey:@"numberSplits"];
                        [tempDict removeObjectForKey:@"totalTime"];
                        [tempDict setObject:superlasttime forKey:@"lastSplit"];
                        [tempDict setObject:[NSNumber numberWithInt:universalIndex] forKey:@"numberSplits"];
                        [tempDict setObject:elapsedtime forKey:@"totalTime"];
                        
                        [self.tableData reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }
                }
                //Otherwise load and append to bottom.
                else{
                    //NSLog(@"In Else Statement2 ");
                    NSIndexPath* rowToAdd = [NSIndexPath indexPathForRow:[tempArray count] inSection:0];
                    NSArray* rowsToAdd = [NSArray arrayWithObjects:rowToAdd, nil];
                    NSArray *tempArray= [self.interval objectAtIndex:index];
                    //NSLog(@" Has Split: %@",[self.has_split objectAtIndex:index]);
                    if(![[self.has_split objectAtIndex:index] boolValue]){
                        elapsedtime = [NSString stringWithFormat:@"DNS"];
                        superlasttime = [NSString stringWithFormat:@"DNS"];
                        universalIndex = NULL;
                        
                    }
                    else if(!tempArray || !tempArray.count){
                        elapsedtime = [NSString stringWithFormat:@"NT"];
                        superlasttime = [NSString stringWithFormat:@"NT"];
                        universalIndex = 0;
                    }
                    else{
                        //adds all intervals together to give cumulative time
                        NSMutableArray *finaltimeArray=[[NSMutableArray alloc] init];
                        NSMutableDictionary *tempDictIndex = [self.athleteDictionaryArray objectAtIndex:closestIndex];
                        NSInteger rangeVar = [[tempDictIndex valueForKey:@"countStart"] integerValue]+1;
                        NSArray *resetViewCount = [tempArray subarrayWithRange: NSMakeRange(rangeVar, [tempArray count]-rangeVar)];
                        for (NSArray *subinterval in resetViewCount){
                            NSArray* subs=[subinterval lastObject];
                            finaltimeArray =[finaltimeArray arrayByAddingObject:subs];
                            
                        }
                        universalIndex = [tempArray count];
                        
                        NSNumber *sum = [finaltimeArray valueForKeyPath:@"@sum.floatValue"];
                        
                        NSArray* lastsettime=[tempArray lastObject];
                        NSNumber *lastsplit = [lastsettime valueForKeyPath:@"@sum.floatValue"];
                        NSNumber *sumInt =@([lastsplit integerValue]);
                        NSNumber *ninty = [NSNumber numberWithInt:90];
                        NSNumber*decimal =[NSNumber numberWithFloat:(([lastsplit floatValue]-[sumInt floatValue])*1000)];
                        NSNumber *decimalInt = @([decimal integerValue]);
                        
                        
                        //to do add decimal to string, round to 3 digits
                        NSNumber *lastsplitminutes = @([lastsplit integerValue] / 60);
                        NSNumber *lastsplitseconds = @([lastsplit integerValue] % 60);
                        NSMutableArray *lasttime = [[NSMutableArray alloc] init];
                        if ([lastsplit intValue]<[ninty intValue]){
                            //if less than 90 display in seconds
                            lasttime=[tempArray lastObject];
                            //NSLog(@"Last Time %@",lasttime);
                        }
                        else{
                            //If greater than 90 seconds display in minute format
                            //If less than 10 format with additional 0
                            if ([lastsplitseconds intValue]<10) {
                                NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                                [lasttime addObject:elapsedtime];
                               // NSLog(@"Last Time %@",lasttime);
                                //self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                                
                            }
                            //If greater than 10 seconds, dont use the preceding 0
                            else{
                                NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                                [lasttime addObject:elapsedtime];
                               // NSLog(@"Last Time %@",lasttime);
                            }
                        }
                        
                        
                        //NSArray* lasttime=[lastsettime lastObject];
                        NSArray *superlasttime = [lasttime lastObject];
                        
                        NSNumber *minutes = @([sum integerValue] / 60);
                        NSNumber *seconds = @([sum integerValue] % 60);
                        
                        //format total time in minute second format
                        if ([seconds intValue]<10) {
                            elapsedtime = [NSString stringWithFormat:@"%@:0%@",minutes,seconds];
                            
                        }
                        else{
                            elapsedtime = [NSString stringWithFormat:@"%@:%@",minutes,seconds];
                            
                        }
                    }

                    
                    NSMutableDictionary *athleteDictionary = [NSMutableDictionary new];
                    [athleteDictionary setObject:[self.runners objectAtIndex:index] forKey:@"name"];
                    [athleteDictionary setObject:[self.runnerID objectAtIndex:index] forKey:@"athleteID"];
                    [athleteDictionary setObject:superlasttime forKey:@"lastSplit"];
                    [athleteDictionary setObject:[NSNumber numberWithInt:universalIndex] forKey:@"numberSplits"];
                    [athleteDictionary setObject:[NSNumber numberWithDouble:0] forKey:@"dateTime"];
                    [athleteDictionary setObject:elapsedtime forKey:@"totalTime"];
                    [athleteDictionary setObject:[NSNumber numberWithDouble:0] forKey:@"countStart"];
                    [self.athleteDictionaryArray addObject:athleteDictionary];
                    [self.tableData beginUpdates];
                    [self.tableData insertRowsAtIndexPaths:rowsToAdd withRowAnimation:UITableViewRowAnimationBottom];
                    [self.tableData endUpdates];
                    
                }

            }
            
            index++;
           
        }
       //Only load the full table the first time, after that append it.
       if(Executed ==TRUE){
           [self.tableData reloadData];
       }
       Executed = FALSE;
      [self updateButtonsToMatchTableState];

        self.humanReadble.text = [NSString stringWithFormat:@"Date: %@", self.workoutDate];

        return self.runners;
  }
    @catch (NSException *exception) {
        NSLog(@"An exception occurred: %@", exception.name);
        NSLog(@"Here are some details: %@", exception.reason);
        return self.runners;
    }

   
}



- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:indexPath.row];
    // Update the delete button's title based on how many items are selected.
    NSUInteger indexOfTheObject = [self.selectedRunners indexOfObject:[tempDict valueForKey:@"athleteID"]];
    [self.selectedRunners removeObjectAtIndex:indexOfTheObject];
    [self.selectedRunnersUTC removeObjectAtIndex:indexOfTheObject];
    [self.selectedRunnersToast removeObjectAtIndex:indexOfTheObject];
    NSLog(@"UTC %@",self.selectedRunnersUTC);
    NSLog(@"Indecies %@",self.selectedRunners);
    [self updateSplitButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:indexPath.row];
    NSDate *currentDate = [[NSDate alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS"];
    [dateFormatter setTimeZone:timeZone];
    NSString *localDateString = [dateFormatter stringFromDate:currentDate];
    
    [self.selectedRunners addObject:[tempDict valueForKey:@"athleteID"]];
    [self.selectedRunnersUTC addObject:localDateString];
    [self.selectedRunnersToast addObject:[NSNumber numberWithDouble:CACurrentMediaTime()]];
    NSLog(@"UTC %@",self.selectedRunnersUTC);
    NSLog(@"Indecies %@",self.selectedRunners);
    // Update the delete button's title based on how many items are selected.
    [self updateButtonsToMatchTableState];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.athleteDictionaryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //depending on ipad or phone use different custom cell spacing, and fill in cell data
    if (IDIOM ==IPAD) {
        static NSString *simpleTableIdentifier = @"myCelliPad";
        CustomCelliPad *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            
            [tableView registerNib:[UINib nibWithNibName:@"CustomCelliPad" bundle:nil] forCellReuseIdentifier:@"myCelliPad"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"myCelliPad"];
        }
        
        NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:indexPath.row];
        
        cell.Name.text = [tempDict valueForKey:@"name"];
        cell.Split.text= [tempDict valueForKey:@"lastSplit"];
        cell.Total.text= [tempDict valueForKey:@"totalTime"];
        return cell;
    }
    else{
        static NSString *simpleTableIdentifier = @"myCell";
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        //NSLog(@"Fails nil?");
        [tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"myCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    }
        NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:indexPath.row];
       
        cell.Name.text = [tempDict valueForKey:@"name"];
        cell.Split.text= [tempDict valueForKey:@"lastSplit"];
        cell.Total.text= [tempDict valueForKey:@"totalTime"];

        
        return cell;
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}



@end
