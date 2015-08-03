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

@interface SecondViewController ()
{
    //NSArray *name;
    NSArray *name;
     UIRefreshControl *refreshControl;
    NSArray* interval;
}
//@property (strong, nonatomic) NSArray *runners;
//@property (strong, nonatomic) IBOutlet UITableView *tableData;
@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initialize table data
    NSLog(@"URL TEST/TESt:%@",self.urlName_VC2);
    
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
    //NSLog(@"Names view load: %@", self.runners);
    
//    dispatch_async(kBgQueue, ^{
//        NSData* data = [NSData dataWithContentsOfURL:
//                        kLatestKivaLoansURL];
//        [self performSelectorOnMainThread:@selector(fetchedData:)
//                               withObject:data waitUntilDone:YES];
//    });
    
    //Pull to Refresh Setup
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(doLoad) forControlEvents:UIControlEventValueChanged];
    [self.tableData addSubview:refreshControl];
    
    
    
    }

//Pull to refresh class called when pulled
- (void) doLoad
{
    NSLog(@"Pull to Refresh");
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
        
        //NSArray* workoutid = [json valueForKey:@"workoutID"]; //2
        // NSArray* date = [json valueForKey:@"date"];
        
        NSString* results = [json valueForKey:@"results"];
        //NSData* results_data = [results dataUsingEncoding:NSUTF8StringEncoding];
        
//        NSLog(@"Results: %@",results_data);
//        
//        
//        NSDictionary* resultsParsed= [NSJSONSerialization
//                                      JSONObjectWithData:results_data //1
//                                      
//                                      options:kNilOptions
//                                      error:&error];

        
        self.runners= [results valueForKey:@"name"];
        
        interval = [results valueForKey:@"splits"];
        self.lasttimearray=[[NSMutableArray alloc] init];;
        
        //to display last relevant interval--not being displayed currently
        for (NSArray *personalinterval in interval ) {
            
            // NSLog(@"Loop Data: %@", personalinterval);
            NSArray* lastsettime=[personalinterval lastObject];
            // NSLog(@"Loop Data time: %@", lastsettime);
            NSArray* lasttime=[lastsettime lastObject];
            // NSLog(@"Last Rep: %@", lasttime);
            //arraycounter = [lasttimearray count];
            // NSLog(@"the coutn: %@", arraycounter);
            
            self.lasttimearray=[self.lasttimearray arrayByAddingObject:lasttime];
            
            
            
            
            NSLog(@"Adding Reps: %@", self.lasttimearray);
            
            
        }
        
        
        
        
        
        // NSLog(@"Names fetcheddata: %@", self.runners);
        return self.runners;
        

    }
    @catch (NSException *exception) {
        NSLog(@"Exception %s","Except!");
        return self.runners;
    }
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // NSLog(@"Names tableview: %@", self.runners);
    //number of rows in tableview
    return [self.runners count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    //set data into cells, name and icon
    cell.textLabel.text = self.runners[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
    //cell.detailTextLabel.text= [NSString stringWithFormat:@"%@",self.lasttimearray[indexPath.row]];
    //NSLog(@"Does THIS APPEAR: %@", self.lasttimearray);
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UIAlertView *messageAlert = [[UIAlertView alloc]
   //                             initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    self.personalSplits=[[NSMutableArray alloc] init];
    self.splitString= self.runners[indexPath.row];
    NSInteger ii=0;
    //on click, display every repeat done. iterate through all splits per individual selected
    for (NSArray *personalRepeats in interval[indexPath.row] ) {
        ii=ii+1;
        NSLog(@"Loop Data: %@", personalRepeats);
        
        self.splitString=[self.splitString stringByAppendingString:[NSString stringWithFormat:@"\r\rInterval Number: %ld \r      Splits: ", (long)ii]];
        
        NSInteger jj=0;
        for(NSArray *subInterval in personalRepeats){
            NSLog(@" Subinterval count %ld", (long)jj);
            //if the first interval create array
            if (jj==0) {
                NSLog(@"Subinterval %@",subInterval);
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                NSNumber *sum = [f numberFromString:subInterval];
                NSLog(@"SUM VALUE%@",sum);
                NSNumber *sumInt =@([sum integerValue]);
                NSNumber*decimal =[NSNumber numberWithFloat:(([sum floatValue]-[sumInt floatValue])*1000)];
                NSNumber *decimalInt = @([decimal integerValue]);
                
               
                //to do add decimal to string, round to 3 digits
                NSNumber *minutes = @([sum integerValue] / 60);
                NSNumber *seconds = @([sum integerValue] % 60);
                NSLog(@"SEconds: %@", seconds);
                NSNumber *ninty = [NSNumber numberWithInt:90];
                if ([sumInt intValue]<[ninty intValue]){
                    //if less than 90 display in seconds
                    NSLog(@"YES %@, %@",sumInt, subInterval);
                    self.personalSplits=[self.personalSplits arrayByAddingObject:subInterval];
                    self.splitString=[self.splitString stringByAppendingString:[NSString stringWithFormat:@"%@",subInterval]];
                    jj=jj+1;
                }
                else{
                    //if greater than 90 seconds display in minute format
                    //format total time in minute second format
                    if ([seconds intValue]<10) {
                        NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@.%@",minutes,seconds,decimalInt];
                        self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                        self.splitString=[self.splitString stringByAppendingString:[NSString stringWithFormat:@"%@",elapsedtime]];
                        jj=jj+1;
                        
                    }
                    else{
                        NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@.%@",minutes,seconds,decimalInt];
                        self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                        self.splitString=[self.splitString stringByAppendingString:[NSString stringWithFormat:@"%@",elapsedtime]];
                        jj=jj+1;
                    }
                }
                
                
            }
            //else add to the already created array
            else
            {
            NSLog(@"LKAJSLKJLSKJlk %@",subInterval);
            self.personalSplits=[self.personalSplits arrayByAddingObject:subInterval];
            self.splitString=[self.splitString stringByAppendingString:[NSString stringWithFormat:@", %@ ",subInterval]];
            jj=jj+1;
            }
        }
    }
    
    
    
    
    //set text to see splits
     self.splitViewer.text = [NSString stringWithFormat:@"Name: %@", self.splitString];
    // Display Alert Message
    //[messageAlert show];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
