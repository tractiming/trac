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


@interface FirstViewController()

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
    
}

- (IBAction)editAction:(id)sender
{
    [self.tableData setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender
{
    [self.tableData setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (void)updateButtonsToMatchTableState
{
    if (self.tableData.editing)
    {
        // Show the option to cancel the edit.
        self.parentViewController.navigationItem.rightBarButtonItem = self.cancelButton;
        [self showActionToolbar:YES];
       
    }
    else
    {
        [self showActionToolbar:YES];
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

- (void)viewWillDisappear:(BOOL)animated {

    [timer invalidate];
    [actionToolbar removeFromSuperview];

}
- (void)viewWillAppear:(BOOL)animated{
    
    
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
    UIBarButtonItem *splitButton =[[UIBarButtonItem alloc]initWithTitle:@"Split" style:UIBarButtonItemStyleDone target:self action:@selector(splitAction)];
    [actionToolbar setItems:[NSArray arrayWithObject:splitButton]];
    //UIBarButtonItem *resetButton =[[UIBarButtonItem alloc]initWithTitle:@"Reset" style:UIBarButtonItemStyleDone target:self action:@selector(resetAction)];
    //[actionToolbar setItems:[NSArray :resetButton]];
    [self updateButtonsToMatchTableState];
        
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.view.superview addSubview:actionToolbar];
}

- (void)showActionToolbar:(BOOL)show
{

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
                    [self.lasttimearray addObject:@"NT"];
                    [self.summationTimeArray addObject:@"NT"];
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
                    NSArray *superlasttime = [lasttime lastObject];
                    
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
                    
                    NSMutableDictionary *athleteDictionary = [NSMutableDictionary new];
                    [athleteDictionary setObject:[self.runners objectAtIndex:index] forKey:@"name"];
                    [athleteDictionary setObject:[self.runnerID objectAtIndex:index] forKey:@"athleteID"];
                    [athleteDictionary setObject:superlasttime forKey:@"lastSplit"];
                    [athleteDictionary setObject:[NSNumber numberWithInt:subindex] forKey:@"numberSplits"];
                    [athleteDictionary setObject:elapsedtime forKey:@"totalTime"];
                    [self.athleteDictionaryArray addObject:athleteDictionary];
                    
                }
                
            }
            
            else{
                
                //Does the row exist from a previous polling. Check Athlete IDs versus stored dictionary.
                NSMutableArray *tempArray = [self.athleteDictionaryArray valueForKey:@"athleteID"];
                NSUInteger closestIndex = [tempArray indexOfObject:[self.runnerID objectAtIndex:index]];
                NSLog(@"Index %lu", (unsigned long)closestIndex);
                //If the new index is in the dictionary, and if it hasnt loaded all the splits update them and reload.
                if (closestIndex){
                    if ([personalinterval count] > [[self.athleteDictionaryArray objectAtIndex:closestIndex] valueForKey:@"numberSplits"]) {
                        NSLog(@"Append IF Statement");
                        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:closestIndex inSection:0];
                        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                        
                        //update the dictionary here for that index
                        NSMutableDictionary *tempDict = [self.athleteDictionaryArray objectAtIndex:closestIndex];
                        [tempDict removeObjectForKey:@"lastSplit"];
                        [tempDict removeObjectForKey:@"numberSplits"];
                        [tempDict removeObjectForKey:@"totalTime"];
                      //  [tempDict setObject:superlasttime forKey:@"lastSplit"];
                        //[tempDict setObject:[NSNumber numberWithInt:subindex] forKey:@"numberSplits"];
                        [tempDict setObject:elapsedtime forKey:@"totalTime"];
                        
                        [self.tableData reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
                //Otherwise load and append to bottom.
                else if (!closestIndex){
                    NSLog(@"Append Else Statement");
                    NSIndexPath* rowToAdd = [NSIndexPath indexPathForRow:[tempArray count]+1 inSection:0];
                    NSArray* rowsToAdd = [NSArray arrayWithObjects:rowToAdd, nil];
                    
                    NSMutableDictionary *athleteDictionary = [NSMutableDictionary new];
                    [athleteDictionary setObject:[self.runners objectAtIndex:index] forKey:@"name"];
                    [athleteDictionary setObject:[self.runnerID objectAtIndex:index] forKey:@"athleteID"];
                    //[athleteDictionary setObject:superlasttime forKey:@"lastSplit"];
                    //[athleteDictionary setObject:[NSNumber numberWithInt:subindex] forKey:@"numberSplits"];
                    [athleteDictionary setObject:elapsedtime forKey:@"totalTime"];
                    [self.athleteDictionaryArray addObject:athleteDictionary];
                    
                    [self.tableData insertRowsAtIndexPaths:rowsToAdd withRowAnimation:UITableViewRowAnimationBottom];
                    
                    
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
