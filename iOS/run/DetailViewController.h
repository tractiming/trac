//
//  DetailViewController.h
//  TRAC
//
//  Created by Griffin Kelly on 8/5/15.
//  Copyright (c) 2015 Griffin Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableData;
@property (strong, nonatomic) NSMutableArray *workoutDetail;
@property (strong, nonatomic) NSMutableArray *counterArray;
@property (strong, nonatomic) NSString *runnersName;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSArray *runners;
@property (strong, nonatomic) NSMutableArray *lasttimearray;
@property (strong, nonatomic) NSMutableArray *personalSplits;
@property (strong, nonatomic) NSMutableData *data;
@property (weak, nonatomic) NSMutableDictionary *json;

//@property(nonatomic,assign) SecondViewController *second;

@end
