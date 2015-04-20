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
- (IBAction)startWorkout:(id)sender;
- (IBAction)endWorkout:(id)sender;
- (IBAction)goButton:(id)sender;
@property (nonatomic, strong) NSString *urlID;
@property (nonatomic, strong) NSDictionary *jsonData;




@end
