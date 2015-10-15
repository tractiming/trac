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
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
#define UITableViewCellEditingStyleMultiSelect (3)


@interface FirstViewController() <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

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

- (void)updateSplitButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableData indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == self.athleteDictionaryArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        splitButton.title = NSLocalizedString(@"Split All", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"Split (%d)", @"Title for delete button with placeholder for number");
        splitButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
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
    // Open a dialog with just an OK button.
	NSString *actionTitle;
    if (([[self.tableData indexPathsForSelectedRows] count] == 1)) {
        actionTitle = NSLocalizedString(@"Are you sure you want to split this individual?", @"");
    }
    else
    {
        actionTitle = NSLocalizedString(@"Are you sure you want to create a split for these people?", @"");
    }
    
    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:okTitle
                                                    otherButtonTitles:nil];
    
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    // Show from our table view (pops up in the middle of the table).
	[actionSheet showInView:self.view];
}


- (void)resetAction:(id)sender{
    // Delete what the user selected.
    NSArray *selectedRows = [self.tableData indexPathsForSelectedRows];
    NSLog(@"Selected Rows, %@",selectedRows);
    BOOL resetSpecificRows = selectedRows.count > 0;

    if (resetSpecificRows)
    {
        // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
        
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:selectionIndex.row];
            [tempDict removeObjectForKey:@"countStart"];
            [tempDict setObject:[tempDict valueForKey:@"numberSplits"] forKey:@"countStart"];
            NSLog(@"Updated Reset");
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
            NSLog(@"Updated Reset");
            
        }
       
    }



    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// The user tapped one of the OK/Cancel buttons.
	if (buttonIndex == 0)
	{
		// Delete what the user selected.
        NSArray *selectedRows = [self.tableData indexPathsForSelectedRows];
        NSLog(@"Selected Rows, %@",selectedRows);
        BOOL splitSpecificRows = selectedRows.count > 0;
        
        //Get current time in UTC
        NSDate *currentDate = [[NSDate alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS"];
        [dateFormatter setTimeZone:timeZone];
        NSString *localDateString = [dateFormatter stringFromDate:currentDate];
        NSLog(@"Date time %@", localDateString);
        NSDictionary *sendThis;
        NSMutableArray * s = [NSMutableArray new];
        if (splitSpecificRows)
        {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
            
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:selectionIndex.row];
                [s addObject:@[[tempDict valueForKey:@"athleteID"],localDateString]];
            }
            sendThis = @{@"s": s};
            NSLog(@"JSON %@",sendThis);
        }
        else
        {
            NSArray *selectedRows = [self.tableData indexPathsForVisibleRows];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:selectionIndex.row];
                [s addObject:@[[tempDict valueForKey:@"athleteID"],localDateString]];
            }
            sendThis = @{@"s": s};
            NSLog(@"JSON %@",sendThis);
            // Delete everything, delete the objects from our data model.
            //Take every row and put into json. Then Send it
        }
        
        // Exit editing mode after the deletion.
        //async task now.
        
        
        
        NSInteger success = 0;
        
        @try {
            
            NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
            NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/individual_splits/?access_token=%@",savedToken];
            
            NSURL *url=[NSURL URLWithString:idurl2];
            NSError *error2 = nil;
            
            NSArray *array = [s copy];
            NSString *post =[[NSString alloc] initWithFormat:@"s=%@",array];
            NSData *jsonData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:post options:0 error:&error2];
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
            //NSMutableData *data = [NSMutableData data];
            //[data appendData:[sendThis dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
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
                NSLog(@"Failed");
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSASCIIStringEncoding];
                NSLog(@"Response ==> %@", responseData);
            }
            
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            
        }

        
       
        
        
        
        [self.tableData setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
	}
}

- (void)viewWillDisappear:(BOOL)animated {

    [timer invalidate];
    [actionToolbar removeFromSuperview];
    self.parentViewController.navigationItem.rightBarButtonItem = nil;

}
- (void)viewWillAppear:(BOOL)animated{
    self.parentViewController.navigationItem.rightBarButtonItem = self.editButton;
    
NSLog(@"Reappear");
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
    
    actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 416, 320, 44)];
    splitButton =[[UIBarButtonItem alloc]initWithTitle:@"Split All" style:UIBarButtonItemStyleDone target:self action:@selector(splitAction:)];
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetAction:)];
    splitButton.width = [[UIScreen mainScreen] bounds].size.width/2;
    [actionToolbar setItems:@[splitButton,resetButton]];
    [self updateButtonsToMatchTableState];
    [self showActionToolbar:NO];
        
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.view.superview addSubview:actionToolbar];
}

- (void)showActionToolbar:(BOOL)show
{
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
    NSLog(@"Toolbar Frame, TableView Frame %f,%f",toolbarFrame.origin.y,tableViewFrame.size.height);
	actionToolbar.frame = toolbarFrame;
	self.tableData.frame = tableViewFrame;
	
	[UIView commitAnimations];
}

- (void) sendRequest
{
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
    //parse out the json data
    
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
        self.summationTimeArray=[[NSMutableArray alloc] init];
        self.lasttimearray=[[NSMutableArray alloc] init];
       
        //Iterate through most recent JSON request
        NSUInteger index = 0;
       
        for (NSArray *personalinterval in self.interval) {
            
            if(Executed ==TRUE){
                if(!personalinterval || !personalinterval.count){
                    elapsedtime = [NSString stringWithFormat:@"NT"];
                    superlasttime = [NSString stringWithFormat:@"NT"];
                    universalIndex = 0;
                }
                else{
                    //adds all intervals together to give cumulative time
                    NSMutableArray *finaltimeArray=[[NSMutableArray alloc] init];
                    NSUInteger subindex = 0;
                    for (NSArray *subinterval in personalinterval){
                        NSArray* subs=[subinterval lastObject];
                        finaltimeArray =[finaltimeArray arrayByAddingObject:subs];
                        subindex++;
                    }
                    universalIndex = subindex;
                    
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
                        NSLog(@"Last Time %@",lasttime);
                    }
                    else{
                        //If greater than 90 seconds display in minute format
                        //If less than 10 format with additional 0
                        if ([lastsplitseconds intValue]<10) {
                            NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                            [lasttime addObject:elapsedtime];
                            NSLog(@"Last Time %@",lasttime);
                            //self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                            
                        }
                        //If greater than 10 seconds, dont use the preceding 0
                        else{
                            NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                            [lasttime addObject:elapsedtime];
                            NSLog(@"Last Time %@",lasttime);
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
                NSMutableDictionary *athleteDictionary = [NSMutableDictionary new];
                [athleteDictionary setObject:[self.runners objectAtIndex:index] forKey:@"name"];
                [athleteDictionary setObject:[self.runnerID objectAtIndex:index] forKey:@"athleteID"];
                [athleteDictionary setObject:superlasttime forKey:@"lastSplit"];
                [athleteDictionary setObject:[NSNumber numberWithInt:universalIndex] forKey:@"numberSplits"];
                [athleteDictionary setObject:[NSNumber numberWithInt:0] forKey:@"countStart"];
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
                   
                    
                    NSNumber *jsonCount = [NSNumber numberWithInt:[personalinterval count]];
                    NSNumber *oldCount = [[self.athleteDictionaryArray objectAtIndex:closestIndex] valueForKey:@"numberSplits"];
                    
                    if (jsonCount > oldCount) {
                        //NSLog(@"Append IF Statement");
                        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:closestIndex inSection:0];
                        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                        NSArray *tempArray= [self.interval objectAtIndex:index];
                        
                        
                        
                        //adds all intervals together to give cumulative time
                        NSMutableArray *finaltimeArray=[[NSMutableArray alloc] init];
                        NSMutableDictionary *tempDictIndex = [self.athleteDictionaryArray objectAtIndex:closestIndex];
                        NSInteger rangeVar = [[tempDictIndex valueForKey:@"countStart"] integerValue];
                        NSLog(@"Errors Here? %ld", (long)rangeVar);
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
                            NSLog(@"Last Time %@",lasttime);
                        }
                        else{
                            //If greater than 90 seconds display in minute format
                            //If less than 10 format with additional 0
                            if ([lastsplitseconds intValue]<10) {
                                NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                                [lasttime addObject:elapsedtime];
                                NSLog(@"Last Time %@",lasttime);
                                //self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                                
                            }
                            //If greater than 10 seconds, dont use the preceding 0
                            else{
                                NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                                [lasttime addObject:elapsedtime];
                                NSLog(@"Last Time %@",lasttime);
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
                //Otherwise load and append to bottom.
                else{
                    
                    
                    NSIndexPath* rowToAdd = [NSIndexPath indexPathForRow:[tempArray count] inSection:0];
                    NSArray* rowsToAdd = [NSArray arrayWithObjects:rowToAdd, nil];
                    NSArray *tempArray= [self.interval objectAtIndex:index];
                    
                    
                    if(!tempArray || !tempArray.count){
                        
                        elapsedtime = [NSString stringWithFormat:@"NT"];
                        superlasttime = [NSString stringWithFormat:@"NT"];
                        universalIndex = 0;
                    }
                    else{
                        //adds all intervals together to give cumulative time
                        NSMutableArray *finaltimeArray=[[NSMutableArray alloc] init];
                        NSMutableDictionary *tempDictIndex = [self.athleteDictionaryArray objectAtIndex:closestIndex];
                        NSInteger rangeVar = [[tempDictIndex valueForKey:@"countStart"] integerValue];
                        NSLog(@"Errors Here? %ld", (long)rangeVar);
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
                            NSLog(@"Last Time %@",lasttime);
                        }
                        else{
                            //If greater than 90 seconds display in minute format
                            //If less than 10 format with additional 0
                            if ([lastsplitseconds intValue]<10) {
                                NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                                [lasttime addObject:elapsedtime];
                                NSLog(@"Last Time %@",lasttime);
                                //self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                                
                            }
                            //If greater than 10 seconds, dont use the preceding 0
                            else{
                                NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@.%@",lastsplitminutes,lastsplitseconds,decimalInt];
                                [lasttime addObject:elapsedtime];
                                NSLog(@"Last Time %@",lasttime);
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
                    [athleteDictionary setObject:elapsedtime forKey:@"totalTime"];
                    [self.athleteDictionaryArray addObject:athleteDictionary];
                    NSLog(@"Athlete Dict %@", self.athleteDictionaryArray);
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
      

        self.humanReadble.text = [NSString stringWithFormat:@"Date: %@", self.workoutDate];

        return self.runners;
  }
    @catch (NSException *exception) {
        NSLog(@"Exception.......... %s","Except!");
        return self.runners;
    }

   
}



- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateSplitButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateButtonsToMatchTableState];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.runners count];
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
        
        cell.Name.text = self.runners[indexPath.row][@"name"];
        cell.Split.text= [NSString stringWithFormat:@"%@",self.lasttimearray[indexPath.row]];
        cell.Total.text= [NSString stringWithFormat:@"%@",self.summationTimeArray[indexPath.row]];
        return cell;
    }
    else{
        static NSString *simpleTableIdentifier = @"myCell";
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
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
