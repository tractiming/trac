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


@interface FirstViewController()
{
    //NSArray *name;
    NSArray *name;
    UIActivityIndicatorView *spinner;
    NSTimer *timer;
}
@end

@implementation FirstViewController

- (void)viewWillDisappear:(BOOL)animated {

        NSLog(@"Pressed Back");
    [timer invalidate];

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
    
    NSLog(@"Fires Every? 10");
    
    // call timer on launch and call sendRequest every 5 seconds
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(sendRequest) userInfo:nil repeats:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"URL: %@", self.urlName);
    NSLog(@"URL ID: %@", self.urlID);
   
    //initilize spinner
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //spinner.color = [UIColor grayColor];
    float navigationBarHeight = [[self.navigationController navigationBar] frame].size.height;
   // self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"discard.png"] style:UIBarButtonItemStylePlain target:self action:@selector(myRightButton)];

    float tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, (self.view.frame.size.height  - navigationBarHeight - tabBarHeight) / 4.0);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    //Async Task Called

    
    SecondViewController *svc = [self.tabBarController.viewControllers objectAtIndex:1];
    svc.urlName_VC2 = self.urlName;
    
    ThirdViewController *tvc = [self.tabBarController.viewControllers objectAtIndex:2];
    NSLog(@"ID: %@",self.urlID);
    tvc.urlID = self.urlID;
    

    // other custom initialization continues
    
    
   // NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(viewDidLoad) userInfo:nil repeats:YES];
    //[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

        
}

//- (void) myRightButton
//{
//    NSLog(@"Pressed");
//    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Reset Workout?"
//                                                       message:@"These results will be permanently deleted."
//                                                      delegate:self
//                             
//                                             cancelButtonTitle:@"OK"
//                                             otherButtonTitles:@"Cancel",nil];
//    [theAlert show];
//}
//
//- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSLog(@"The %@ button was tapped.", [theAlert buttonTitleAtIndex:buttonIndex]);
//    if (buttonIndex == 0)
//    {
//        NSLog(@"Discard");
//        
//        //if signin button clicked query server with credentials
//        NSInteger success = 0;
//        @try {
//            
//
//                //if success
//                NSString *post =[[NSString alloc] initWithFormat:@"id=%@",self.urlID];
//                NSLog(@"Post: %@",post);
//            
//                NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
//                NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/TimingSessionReset/?access_token=%@", savedToken];
//            
//                NSURL *url=[NSURL URLWithString:idurl2];
//                
//                NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
//                NSLog(@"Post Data:%@", postData);
//                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
//                
//                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//                [request setURL:url];
//                [request setHTTPMethod:@"POST"];
//                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//                [request setHTTPBody:postData];
//                
//                
//                //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
//                
//                NSError *error = [[NSError alloc] init];
//                NSHTTPURLResponse *response = nil;
//                NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//                
//                NSLog(@"Response code: %ld", (long)[response statusCode]);
//                // NSLog(@"Error Code: %@", [error localizedDescription]);
//                
//                if ([response statusCode] >= 200 && [response statusCode] < 300)
//                {
//                    NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSASCIIStringEncoding];
//                    NSLog(@"Response ==> %@", responseData);
//                    
//                    NSError *error = nil;
//                    NSDictionary *jsonData = [NSJSONSerialization
//                                              JSONObjectWithData:urlData
//                                              options:NSJSONReadingMutableContainers
//                                              error:&error];
//                    
//                    success = [jsonData[@"success"] integerValue];
//                    NSLog(@"Success: %ld",(long)success);
//                    
//                    if(success == 0)
//                    {
//                        NSLog(@"SUCCESS");
//                        
//                        //return self.access_token;
//                    } else {
//                        
//                        NSLog(@"Failed");
//
//                    }
//                    
//                } else {
//                    //if (error) NSLog(@"Error: %@", error);
//                    NSLog(@"Failed");
//
//                }
//            
//        }
//        @catch (NSException * e) {
//            NSLog(@"Exception: %@", e);
//            
//        }
//        
//    }
//    
//    
//}

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
        
        //NSDictionary* workoutid = [json valueForKey:@"name"]; //2
        // NSDictionary* date = [json valueForKey:@"start_time"];
        NSString* results = [json valueForKey:@"results"];
        NSString* num_results = [json valueForKey:@"num_results"];
        //NSData* results_data = [results dataUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"#Results: %@",results);
        
        //parse json
//        NSDictionary* resultsParsed= [NSJSONSerialization
//                                      JSONObjectWithData:results_data //1
//                                      
//                                      options:kNilOptions
//                                      error:&error];
       // NSLog(@"Results (Dictionary): %@", resultsParsed);
       // NSDictionary* date = [resultsParsed valueForKey:@"date"];
        //NSLog(@"Name????: %@",[results valueForKey:@"name"]);
        self.runners= [results valueForKey:@"name"];
        
        NSArray* interval = [results valueForKey:@"splits"];
        self.summationTimeArray=[[NSMutableArray alloc] init];
        self.lasttimearray=[[NSMutableArray alloc] init];
       

        //find the last relevant interval
        for (NSArray *personalinterval in interval ) {
            
            if(!personalinterval || !personalinterval.count){
            NSLog(@"ITS EMPTY");
            self.lasttimearray = [self.lasttimearray arrayByAddingObject:@"NT"];
            self.summationTimeArray = [self.summationTimeArray arrayByAddingObject:@"NT"];
            }
            else{
                //adds all intervals together to give cumulative time
                NSMutableArray *finaltimeArray=[[NSMutableArray alloc] init];
                    for (NSArray *subinterval in personalinterval){
                        NSArray* subs=[subinterval lastObject];
                        finaltimeArray =[finaltimeArray arrayByAddingObject:subs];
                    }
                        
                
                NSNumber *sum = [finaltimeArray valueForKeyPath:@"@sum.floatValue"];
                
                
                NSLog(@"Personal Interval: %@", personalinterval);
                NSArray* lastsettime=[personalinterval lastObject];
                NSLog(@"Loop Data time: %@", lastsettime);
                NSArray* lasttime=[lastsettime lastObject];
                NSLog(@"Last Rep: %@", lasttime);
            //arraycounter = [lasttimearray count];
            // NSLog(@"the coutn: %@", arraycounter);
            
            //determine minute and seconds
            //NSNumber *sum = [lastsettime valueForKeyPath:@"@sum.self"];
            NSLog(@"Sum: %@", sum);
            NSNumber *minutes = @([sum integerValue] / 60);
            NSNumber *seconds = @([sum integerValue] % 60);
            NSLog(@"SEconds: %@", seconds);
            
            //format total time in minute second format
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
        }
        NSLog(@"TimeArrays %@",self.lasttimearray);
        
        //    // Initialize Labels
    
        //TODO: Fix these so they return name and date.
        //self.humanReadble.text = [NSString stringWithFormat:@"Date: %@", date];
        //self.jsonSummary.text = [NSString stringWithFormat:@"Workout Name: %@", workoutid];
        return self.runners;
  }
    @catch (NSException *exception) {
        NSLog(@"Exception.......... %s","Except!");
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
       // NSLog(@"TimeArray %@",self.lasttimearray[indexPath.row]);
        

    NSLog(@"IN else Timearray %@",self.lasttimearray);
    cell.Name.text = self.runners[indexPath.row];
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
