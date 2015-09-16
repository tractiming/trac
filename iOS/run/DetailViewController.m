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
    NSString *elapsedtime;
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
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(doLoad) forControlEvents:UIControlEventValueChanged];
    [self.tableData addSubview:refreshControl];
    
}

- (void) doLoad
{
    
       dispatch_async(TRACQueue, ^{
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self fetchedData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.urlString]]];
            [self.tableData reloadData];
            
            
        });
        
        
    });
    [refreshControl endRefreshing];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     NSLog(@"Names tableview: %lu", (unsigned long) [self.workoutDetail count]);
    //Number of rows in tableview
    return [self.workoutDetail count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    //set data into cells, counter and split
    cell.textLabel.text = self.counterArray[indexPath.row];
    cell.detailTextLabel.text = self.workoutDetail[indexPath.row];

    
    return cell;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSArray *)fetchedData:(NSData *)responseData {
    @try {
        //parse out the json data
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];

        NSString* results = [json valueForKey:@"results"];

        //Find the name of the runner from SecondVC passed variable and match array index of runner
        self.runners= [results valueForKey:@"name"];
        NSUInteger indexOfTheObject =[self.runners indexOfObject:self.runnersName];
        interval = [results valueForKey:@"splits"];
        
        //Re-initalize variables
        self.personalSplits=[[NSMutableArray alloc] init];
        self.counterArray = [NSMutableArray array];

        NSInteger ii=0;
        
        //to display last relevant interval
        for (NSArray *personalinterval in interval[indexOfTheObject] ) {
            ii=ii+1;
            NSString *counter = [[NSNumber numberWithInt:ii] stringValue];
            [self.counterArray addObject:counter];

            for(NSArray *subInterval in personalinterval){
                //if the first interval create array
                    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                    f.numberStyle = NSNumberFormatterDecimalStyle;
                    NSNumber *sum = [f numberFromString:subInterval];
                    NSNumber *sumInt =@([sum integerValue]);
                    NSNumber *decimal =[NSNumber numberWithFloat:(([sum floatValue]-[sumInt floatValue])*1000)];
                    NSNumber *decimalInt = @([decimal integerValue]);

                    //to do add decimal to string, round to 3 digits
                    NSNumber *minutes = @([sum integerValue] / 60);
                    NSNumber *seconds = @([sum integerValue] % 60);
                    NSNumber *ninty = [NSNumber numberWithInt:90];
                    
                    
                    if ([sumInt intValue]<[ninty intValue]){
                        //if less than 90 display in seconds
                       [self.personalSplits addObject:subInterval];

                    }
                    else{
                        //if greater than 90 seconds display in minute format
                        //format total time in minute second format
                        if ([seconds intValue]<10) {
                            elapsedtime = [NSString stringWithFormat:@"%@:0%@.%@",minutes,seconds,decimalInt];
                            [self.personalSplits addObject:elapsedtime];

                        }
                        else{
                            elapsedtime = [NSString stringWithFormat:@"%@:%@.%@",minutes,seconds,decimalInt];
                            [self.personalSplits addObject:elapsedtime];

                            
                        }
                    }
            }
            self.workoutDetail = self.personalSplits;
            
        }
        return self.workoutDetail;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %s","Except!");
        return self.workoutDetail;

    }
    
    
}



@end
