//
//  ThirdViewController.h
//  TRAC
//
//  Created by Griffin Kelly on 4/16/15.
//  Copyright (c) 2015 Griffin Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThirdViewController : UIViewController

- (IBAction)logoutClicked:(id)sender;
- (IBAction)resetWorkout:(id)sender;
//- (IBAction)calibrateWorkout:(id)sender;
//- (IBAction)endWorkout:(id)sender;
- (IBAction)goButton:(id)sender;
@property (nonatomic, strong) NSString *urlID;
@property (nonatomic, strong) NSDictionary *jsonData;
@property (weak, nonatomic) IBOutlet UISwitch *sensorSwitch;
@property (weak, nonatomic) IBOutlet UITextField *sensorTextField;
- (IBAction)switchPressed:(id)sender;

@property (nonatomic, strong) NSString *start_time;
@property (nonatomic, strong) NSString *end_time;


@end
