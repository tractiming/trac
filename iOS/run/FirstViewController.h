//
//  FirstViewController.h
//  run
//
//  Created by Griffin Kelly on 5/3/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface FirstViewController :UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSArray *runners;
@property (strong, nonatomic) NSMutableArray *lasttimearray;
@property (strong, nonatomic) NSMutableArray *summationTimeArray;
//@property (strong, nonatomic) NSArray *name;
@property (weak, nonatomic) IBOutlet UITableView *tableData;
@property (weak, nonatomic)  IBOutlet UILabel* humanReadble;
@property (weak, nonatomic) IBOutlet UILabel* jsonSummary;
@property (nonatomic, strong) NSString *urlName;

   // IBOutlet UITableView* groupTable;

@end
