//
//  ThirdViewController.m
//  TRAC
//
//  Created by Griffin Kelly on 4/16/15.
//  Copyright (c) 2015 Griffin Kelly. All rights reserved.
//

#import "ThirdViewController.h"
#define TRACQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@interface ThirdViewController ()

@end

@implementation ThirdViewController

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
        NSLog(@"URL ID: %@", self.urlID);
     NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
     NSString *url = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/%@/?access_token=%@", self.urlID,savedToken];
    dispatch_async(TRACQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:url]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self fetchedData:data];
           // [self.tableData reloadData];
            NSDictionary* id_num = [self.jsonData valueForKey:@"id"];
             NSLog(@"URL ID IN VIew did load: %@", id_num);
        });
        
        
    });

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)logoutClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    NSLog(@"Secutiy Token: %@",savedToken);
    [self performSegueWithIdentifier:@"logout" sender:self];

}
- (IBAction)endWorkout:(id)sender{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *theDate = [dateFormat stringFromDate:now];
    NSString *theTime = [timeFormat stringFromDate:now];
    
    //What Time Zone Should we work with?
    
    NSString *newStopTime= [NSString stringWithFormat:@"%@ %@", theDate, theTime];
    NSLog(@"%@", newStopTime);

    
    NSInteger success = 0;
    
    @try {
        
        
        NSDictionary* name = [self.jsonData valueForKey:@"name"];
        NSDictionary* start_time = [self.jsonData valueForKey:@"start_time"];
        //NSDictionary* stop_time = [self.jsonData valueForKey:@"stop_time"];
        NSDictionary* rest_time = [self.jsonData valueForKey:@"rest_time"];
        NSDictionary* track_size = [self.jsonData valueForKey:@"track_size"];
        NSDictionary* interval_distance = [self.jsonData valueForKey:@"interval_distance"];
        NSDictionary* interval_number = [self.jsonData valueForKey:@"interval_number"];
        NSDictionary* filter_choice = [self.jsonData valueForKey:@"filter_choice"];
        //if success
        NSString *post =[[NSString alloc] initWithFormat:@"id=%@&name=%@&start_time=%@&stop_time=%@&rest_time=%@&track_size=%@&interval_distance=%@&interval_number=%@&filter_choice=%@",self.urlID,name,start_time,newStopTime,rest_time,track_size,interval_distance,interval_number,filter_choice];
        NSLog(@"Post: %@",post);
        
        NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
        NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/%@/?access_token=%@", self.urlID,savedToken];
        
        NSURL *url=[NSURL URLWithString:idurl2];
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSLog(@"Post Data:%@", postData);
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"PUT"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        
        //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSLog(@"Response code: %ld", (long)[response statusCode]);
        // NSLog(@"Error Code: %@", [error localizedDescription]);
        
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
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Success!" message:@"Successfully changed end time of workout" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                //return self.access_token;
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
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    NSString *url = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/%@/?access_token=%@", self.urlID,savedToken];
    dispatch_async(TRACQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:url]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self fetchedData:data];
            // [self.tableData reloadData];
            NSDictionary* id_num = [self.jsonData valueForKey:@"id"];
            NSLog(@"URL ID IN VIew did load: %@", id_num);
        });
        
        
    });


}
- (IBAction)resetWorkout:(id)sender{
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Reset Workout?"
                                                       message:@"These results will be permanently deleted."
                                                      delegate:self
                             
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:@"Cancel",nil];
    [theAlert show];

}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"The %@ button was tapped.", [theAlert buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex == 0)
    {
        NSLog(@"Discard");
        
        //if signin button clicked query server with credentials
        NSInteger success = 0;
        @try {
            
            
            //if success
            NSString *post =[[NSString alloc] initWithFormat:@"id=%@",self.urlID];
            NSLog(@"Post: %@",post);
            
            NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
            NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/TimingSessionReset/?access_token=%@", savedToken];
            
            NSURL *url=[NSURL URLWithString:idurl2];
            
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSLog(@"Post Data:%@", postData);
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            
            //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = nil;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            NSLog(@"Response code: %ld", (long)[response statusCode]);
            // NSLog(@"Error Code: %@", [error localizedDescription]);
            
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
                    
                    //return self.access_token;
                } else {
                    
                    NSLog(@"Failed");
                    
                }
                
            } else {
                //if (error) NSLog(@"Error: %@", error);
                NSLog(@"Failed");
                
            }
            
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            
        }
        
    }
    
    
}


- (IBAction)startWorkout:(id)sender {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *theDate = [dateFormat stringFromDate:now];
    NSString *theTime = [timeFormat stringFromDate:now];
    
    //What Time Zone Should we work with?
    
    NSString *newStartTime= [NSString stringWithFormat:@"%@ %@", theDate, theTime];
    NSLog(@"%@", newStartTime);
    
    
    int daysToAdd = 1;
    NSDate *newDate = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
    NSString *futureDate = [dateFormat stringFromDate:newDate];
    NSString *futureTime = [timeFormat stringFromDate:newDate];
    
    
    NSString *EndTime= [NSString stringWithFormat:@"%@ %@", futureDate, futureTime];
    NSLog(@"%@", EndTime);
    
    NSInteger success = 0;
    
    @try {
        

        NSDictionary* name = [self.jsonData valueForKey:@"name"];
        //NSDictionary* start_time = [self.jsonData valueForKey:@"start_time"];
        //NSDictionary* stop_time = [self.jsonData valueForKey:@"stop_time"];
        NSDictionary* rest_time = [self.jsonData valueForKey:@"rest_time"];
        NSDictionary* track_size = [self.jsonData valueForKey:@"track_size"];
        NSDictionary* interval_distance = [self.jsonData valueForKey:@"interval_distance"];
        NSDictionary* interval_number = [self.jsonData valueForKey:@"interval_number"];
        NSDictionary* filter_choice = [self.jsonData valueForKey:@"filter_choice"];
        //if success
        NSString *post =[[NSString alloc] initWithFormat:@"id=%@&name=%@&start_time=%@&stop_time=%@&rest_time=%@&track_size=%@&interval_distance=%@&interval_number=%@&filter_choice=%@",self.urlID,name,newStartTime,EndTime,rest_time,track_size,interval_distance,interval_number,filter_choice];
        NSLog(@"Post: %@",post);
        
        NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
        NSString *idurl2 = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/%@/?access_token=%@", self.urlID,savedToken];
        
        NSURL *url=[NSURL URLWithString:idurl2];
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSLog(@"Post Data:%@", postData);
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"PUT"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        
        //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSLog(@"Response code: %ld", (long)[response statusCode]);
        // NSLog(@"Error Code: %@", [error localizedDescription]);
        
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
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Success!" message:@"Successfully changed start time of workout" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                //return self.access_token;
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

    
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    NSString *url = [NSString stringWithFormat: @"https://trac-us.appspot.com/api/sessions/%@/?access_token=%@", self.urlID,savedToken];
    dispatch_async(TRACQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:url]];
        
        dispatch_async(dispatch_get_main_queue() ,^{
            [self fetchedData:data];
            // [self.tableData reloadData];
            NSDictionary* id_num = [self.jsonData valueForKey:@"id"];
            NSLog(@"URL ID IN VIew did load: %@", id_num);
        });
        
        
    });


    
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
- (NSDictionary *)fetchedData:(NSData *)responseData {
    @try {
        //parse out the json data
        NSError* error;
       self.jsonData = [NSJSONSerialization
                              JSONObjectWithData:responseData //1
                              
                              options:kNilOptions
                              error:&error];
        
        //NSArray* workoutid = [json valueForKey:@"workoutID"]; //2
        // NSArray* date = [json valueForKey:@"date"];
       
         NSDictionary* id_num = [self.jsonData valueForKey:@"id"];
        NSDictionary* name = [self.jsonData valueForKey:@"name"];
//        NSDictionary* start_time = [json valueForKey:@"start_time"];
//        NSDictionary* stop_time = [json valueForKey:@"stop_time"];
//        NSDictionary* rest_time = [json valueForKey:@"rest_time"];
//        NSDictionary* track_size = [json valueForKey:@"track_size"];
//        NSDictionary* interval_distance = [json valueForKey:@"interval_distance"];
//        NSDictionary* interval_number = [json valueForKey:@"interval_number"];
        NSDictionary* filter_choice = [self.jsonData valueForKey:@"filter_choice"];
        NSLog(@"URL ID: %@", name);
        NSLog(@"URL ID: %@", filter_choice);
        //self.jsonData = [NSString stringWithFormat:@"Date: %@", id_num];

        
        // NSLog(@"Names fetcheddata: %@", self.runners);
        return self.jsonData;
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %s","Except!");

        return self.jsonData;
    }
    
    
}


@end
