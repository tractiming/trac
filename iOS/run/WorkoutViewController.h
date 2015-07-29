//
//  WorkoutViewController.h
//  run
//
//  Created by Griffin Kelly on 10/20/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutViewController : UIViewController  <UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableData;
- (IBAction)logoutClicked:(id)sender;
- (IBAction)createWorkout:(id)sender;
@property (strong,nonatomic) NSMutableArray *filteredWorkoutArray;

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
