//
//  WorkoutViewController.h
//  run
//
//  Created by Griffin Kelly on 10/20/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableData;
- (IBAction)logoutClicked:(id)sender;

@end
