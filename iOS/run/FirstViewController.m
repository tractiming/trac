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

@interface FirstViewController()
{
    //NSArray *name;
    NSArray *name;
    
}
@end

@implementation FirstViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"URL: %@", self.urlName);
    dispatch_queue_t  queue = dispatch_queue_create("com.firm.app.timer", 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 20ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);

   // NSString *url=self.urlName;
    //NSLog(@"URL:%@", url);
    dispatch_source_set_event_handler(timer,^{ dispatch_async(kBgQueue, ^{
        NSLog(@"Every ?!");
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:self.urlName]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            NSLog(@"Every How many?!");
            [self fetchedData:data];
            [self.tableData reloadData];
        });});});
    
    
    dispatch_resume(timer);
    NSLog(@"Every 2!");
    
    
    SecondViewController *svc = [self.tabBarController.viewControllers objectAtIndex:1];
    svc.urlName_VC2 = self.urlName;
    
    
   // NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(viewDidLoad) userInfo:nil repeats:YES];
    //[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

        
}
- (NSArray *)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSLog(@"Feteched Data: %@",responseData);
    NSDictionary* json= [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSDictionary* workoutid = [json valueForKey:@"id"]; //2
    //NSDictionary* date = [json valueForKey:@"start_time"];
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
    self.lasttimearray=[[NSMutableArray alloc] init];
    
    
    for (NSArray *personalinterval in interval ) {
        
        NSLog(@"Loop Data: %@", personalinterval);
        NSArray* lastsettime=[personalinterval lastObject];
        NSLog(@"Loop Data time: %@", lastsettime);
        NSArray* lasttime=[lastsettime lastObject];
        NSLog(@"Last Rep: %@", lasttime);
        //arraycounter = [lasttimearray count];
        // NSLog(@"the coutn: %@", arraycounter);
        
        self.lasttimearray=[self.lasttimearray arrayByAddingObject:lasttime];
    }
    
        
        
        NSLog(@"URL: %@", self.urlName);

    
    
    
//    // Initialize Labels
    self.humanReadble.text = [NSString stringWithFormat:@"Date: %@", date];
    self.jsonSummary.text = [NSString stringWithFormat:@"WorkoutID: %@", workoutid];
    return self.runners;
   
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     NSLog(@"Names tableview: %@", self.runners);
    return [self.runners count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = self.runners[indexPath.row][@"name"];
    cell.detailTextLabel.text= [NSString stringWithFormat:@"%@",self.lasttimearray[indexPath.row]];
    NSLog(@"Does THIS APPEAR: %@", self.lasttimearray);
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}



@end
