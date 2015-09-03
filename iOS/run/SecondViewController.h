//
//  SecondViewController.h
//  run
//
//  Created by Griffin Kelly on 5/3/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *runners;
@property (strong, nonatomic) NSMutableArray *lasttimearray;
@property (strong, nonatomic) NSMutableArray *personalSplits;
@property (strong, nonatomic) NSMutableString *splitString;
@property (strong, nonatomic) NSMutableArray *counterArray;
@property (nonatomic,retain) UIRefreshControl *refreshControl NS_AVAILABLE_IOS(6_0);

@property (weak, nonatomic) IBOutlet UITableView *tableData;
@property (weak, nonatomic) IBOutlet UITextView *splitViewer;
@property (nonatomic, strong) NSString *urlName_VC2;
@property IBOutlet UISearchBar *workoutSearchBar;
@property (strong,nonatomic) NSMutableArray *filteredRunnersArray;
@end