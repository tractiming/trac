//
//  RosterTableViewController.h
//  TRAC
//
//  Created by Griffin Kelly on 11/2/15.
//  Copyright (c) 2015 Griffin Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RosterTableViewController : UIViewController  <UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableData;

@property (strong,nonatomic) NSMutableArray *filteredTitleArray;
@property (nonatomic, strong) NSString *urlID;
@property (nonatomic,retain) UIRefreshControl *refreshControl NS_AVAILABLE_IOS(6_0);;

@property IBOutlet UISearchBar *workoutSearchBar;


/**
 *  Set this flag when loading data.
 */
@property (nonatomic, assign) BOOL isLoading;


/**
 *  Set this flag if more data can be loaded.
 */
@property (assign, nonatomic) BOOL hasNextPage;


/**
 *  The current page loaded from the server. Used for pagination.
 */
@property (assign, nonatomic) int currentPage;

@end
