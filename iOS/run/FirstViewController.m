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

    NSArray *name;
    UIActivityIndicatorView *spinner;
    NSTimer *timer;
}
@end

@implementation FirstViewController

- (void)viewWillDisappear:(BOOL)animated {

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

    
    // call timer on launch and call sendRequest every 5 seconds
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(sendRequest) userInfo:nil repeats:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

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
        NSString* num_results = [json valueForKey:@"num_results"];

        self.runners= [results valueForKey:@"name"];
        
        NSArray* interval = [results valueForKey:@"splits"];
        self.summationTimeArray=[[NSMutableArray alloc] init];
        self.lasttimearray=[[NSMutableArray alloc] init];
       

        //find the last relevant interval
        for (NSArray *personalinterval in interval ) {
            
            if(!personalinterval || !personalinterval.count){
            [self.lasttimearray addObject:@"NT"];
            [self.summationTimeArray addObject:@"NT"];
            }
            else{
                //adds all intervals together to give cumulative time
                NSMutableArray *finaltimeArray=[[NSMutableArray alloc] init];
                    for (NSArray *subinterval in personalinterval){
                        NSArray* subs=[subinterval lastObject];
                        finaltimeArray =[finaltimeArray arrayByAddingObject:subs];
                    }
                
                NSNumber *sum = [finaltimeArray valueForKeyPath:@"@sum.floatValue"];
                
                NSArray* lastsettime=[personalinterval lastObject];

                NSArray* lasttime=[lastsettime lastObject];

            NSNumber *minutes = @([sum integerValue] / 60);
            NSNumber *seconds = @([sum integerValue] % 60);

            //format total time in minute second format
            if ([seconds intValue]<10) {
                NSString* elapsedtime = [NSString stringWithFormat:@"%@:0%@",minutes,seconds];
                [self.summationTimeArray addObject:elapsedtime];
                
            }
            else{
                NSString* elapsedtime = [NSString stringWithFormat:@"%@:%@",minutes,seconds];
                [self.summationTimeArray addObject:elapsedtime];
                
            }
            
            [self.lasttimearray addObject:lasttime];
            }
        }


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

        cell.Name.text = self.runners[indexPath.row];
        cell.Split.text= [NSString stringWithFormat:@"%@",self.lasttimearray[indexPath.row]];
        cell.Total.text= [NSString stringWithFormat:@"%@",self.summationTimeArray[indexPath.row]];
        return cell;
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}



@end
