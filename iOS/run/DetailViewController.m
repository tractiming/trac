//
//  DetailViewController.m
//  TRAC
//
//  Created by Griffin Kelly on 8/5/15.
//  Copyright (c) 2015 Griffin Kelly. All rights reserved.
//

#import "DetailViewController.h"
#define TRACQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1


@interface DetailViewController ()

@end

@implementation DetailViewController
{
UIRefreshControl *refreshControl;
NSArray* interval;
}
@synthesize tableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.runnersName;
    NSLog(@"Array is passed %@", self.counterArray);
    // Do any additional setup after loading the view.
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(doLoad) forControlEvents:UIControlEventValueChanged];
    [self.tableData addSubview:refreshControl];
    
}

- (void) doLoad
{
    NSLog(@"Pull to Refresh %@", self.urlString);
    //[self.second doLoad];
    dispatch_async(TRACQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:self.urlString]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self fetchedData:data];
            [self.tableData reloadData];
            
            
        });
        
        
    });

    [refreshControl endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     NSLog(@"Names tableview: %lu", (unsigned long) [self.workoutDetail count]);
    //number of rows in tableview
    return [self.workoutDetail count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    //set data into cells, name and icon
    cell.textLabel.text = self.counterArray[indexPath.row];
    cell.detailTextLabel.text = self.workoutDetail[indexPath.row];
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    
    return cell;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



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
        NSUInteger indexOfTheObject =[self.runners indexOfObject:self.runnersName];
        NSLog(@"index match? %lu",(unsigned long)indexOfTheObject);
        
        interval = [results valueForKey:@"splits"];
        
        
        self.personalSplits =[[NSMutableArray alloc] init];
        
        self.counterArray = [[NSMutableArray alloc] init];

        NSInteger ii=0;
        
        //to display last relevant interval--not being displayed currently
        for (NSArray *personalinterval in interval[indexOfTheObject] ) {
            
            ii=ii+1;
            NSString *counter = [[NSNumber numberWithInt:ii] stringValue];
            [self.counterArray addObject:counter];
            
            
        
            NSInteger jj=0;
            for(NSArray *subInterval in personalinterval){
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
            
                        jj=jj+1;
                    }
                    else{
                        //if greater than 90 seconds display in minute format
                        //format total time in minute second format
                        if ([seconds intValue]<10) {
                            NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@.%@",minutes,seconds,decimalInt];
                            self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                          
                            jj=jj+1;
                            
                        }
                        else{
                            NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@.%@",minutes,seconds,decimalInt];
                            self.personalSplits=[self.personalSplits arrayByAddingObject:elapsedtime];
                            
                            jj=jj+1;
                        }
                    }
                    
                    
                }
                //else add to the already created array
                else
                {
                    self.personalSplits=[self.personalSplits arrayByAddingObject:subInterval];
                    jj=jj+1;
                }
            }

            self.workoutDetail = self.personalSplits;

            
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %s","Except!");

    }
    
    
}



@end
