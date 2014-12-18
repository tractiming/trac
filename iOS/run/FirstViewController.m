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
#import "CustomCell.h"
#import "CustomCelliPad.h"
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad


@interface FirstViewController()
{
    //NSArray *name;
    NSArray *name;
    UIActivityIndicatorView *spinner;
}
@end

@implementation FirstViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"URL: %@", self.urlName);
   

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //spinner.color = [UIColor grayColor];
    float navigationBarHeight = [[self.navigationController navigationBar] frame].size.height;
    float tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, (self.view.frame.size.height  - navigationBarHeight - tabBarHeight) / 4.0);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    //Async Task Called
    dispatch_async(kBgQueue, ^{
        
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:self.urlName]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            
            [self fetchedData:data];
            [self.tableData reloadData];
            [spinner removeFromSuperview];
        });});
    
    NSLog(@"Fires Every? 10");
    
    SecondViewController *svc = [self.tabBarController.viewControllers objectAtIndex:1];
    svc.urlName_VC2 = self.urlName;
    
    // regular [super init], etc. etc.
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(sendRequest) userInfo:nil repeats:YES];
    // other custom initialization continues
    
    
    
   // NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(viewDidLoad) userInfo:nil repeats:YES];
    //[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

        
}


- (void) sendRequest
{
    //Async Task Called
    dispatch_async(kBgQueue, ^{
        
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:self.urlName]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            
            [self fetchedData:data];
            [self.tableData reloadData];
            [spinner removeFromSuperview];
        });});
    
    NSLog(@"Firest every? 10");
    
    SecondViewController *svc = [self.tabBarController.viewControllers objectAtIndex:1];
    svc.urlName_VC2 = self.urlName;
}

- (NSArray *)fetchedData:(NSData *)responseData {
    //parse out the json data
    
    @try {
        NSError* error;
        NSLog(@"Feteched Data: %@",responseData);
        NSDictionary* json= [NSJSONSerialization
                             JSONObjectWithData:responseData //1
                             
                             options:kNilOptions
                             error:&error];
        
        NSDictionary* workoutid = [json valueForKey:@"id"]; //2
        // NSDictionary* date = [json valueForKey:@"start_time"];
        NSString* results = [json valueForKey:@"results"];
        NSData* results_data = [results dataUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"Results: %@",results_data);
        
        
        NSDictionary* resultsParsed= [NSJSONSerialization
                                      JSONObjectWithData:results_data //1
                                      
                                      options:kNilOptions
                                      error:&error];
        NSLog(@"Results (Dictionary): %@", resultsParsed);
        NSDictionary* date = [resultsParsed valueForKey:@"date"];
        
        self.runners= [resultsParsed valueForKey:@"runners"];
        
        NSArray* interval = [self.runners valueForKey:@"interval"];
        self.summationTimeArray=[[NSMutableArray alloc] init];
        self.lasttimearray=[[NSMutableArray alloc] init];
        
        //find the last relevant interval
        for (NSArray *personalinterval in interval ) {
            
            NSLog(@"Loop Data: %@", personalinterval);
            NSArray* lastsettime=[personalinterval lastObject];
            NSLog(@"Loop Data time: %@", lastsettime);
            NSArray* lasttime=[lastsettime lastObject];
            NSLog(@"Last Rep: %@", lasttime);
            //arraycounter = [lasttimearray count];
            // NSLog(@"the coutn: %@", arraycounter);
            
            NSNumber *sum = [lastsettime valueForKeyPath:@"@sum.self"];
            NSLog(@"Sum: %@", sum);
            NSNumber *minutes = @([sum integerValue] / 60);
            NSNumber *seconds = @([sum integerValue] % 60);
            NSLog(@"SEconds: %@", seconds);
            
            if ([seconds intValue]<10) {
                NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@",minutes,seconds];
                NSLog(@"TIME? %@",elapsedtime);
                self.summationTimeArray = [self.summationTimeArray arrayByAddingObject:elapsedtime];
                
            }
            else{
                NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@",minutes,seconds];
                NSLog(@"TIME? %@",elapsedtime);
                self.summationTimeArray = [self.summationTimeArray arrayByAddingObject:elapsedtime];
                
            }
            
            
            //NSMutableArray *timeArray=[self.splitString stringByAppendingString:[NSString stringWithFormat:@"%@",subInterval]];
            
            //self.summationTimeArray = [self.summationTimeArray arrayByAddingObject:elapsedtime];
            NSLog(@"Sum Array: %@", self.summationTimeArray);
            
            
            self.lasttimearray = [self.lasttimearray arrayByAddingObject:lasttime];
        }
        
        
        //    // Initialize Labels
        self.humanReadble.text = [NSString stringWithFormat:@"Date: %@", date];
        self.jsonSummary.text = [NSString stringWithFormat:@"WorkoutID: %@", workoutid];
        return self.runners;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %s","Except!");
        return self.runners;
    }

   
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     NSLog(@"Names tableview: %@", self.runners);
    return [self.runners count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
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
        NSLog(@"Does THIS APPEAR: %@", self.lasttimearray);
        return cell;
    }
    else{
        static NSString *simpleTableIdentifier = @"myCell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        [tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"myCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    }
    
    cell.Name.text = self.runners[indexPath.row][@"name"];
    cell.Split.text= [NSString stringWithFormat:@"%@",self.lasttimearray[indexPath.row]];
    cell.Total.text= [NSString stringWithFormat:@"%@",self.summationTimeArray[indexPath.row]];
    NSLog(@"Does THIS APPEAR: %@", self.lasttimearray);
        return cell;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}



@end
