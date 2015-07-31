//
//  Workout.h
//  TRAC
//
//  Created by Griffin Kelly on 7/30/15.
//  Copyright (c) 2015 Griffin Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Workout : NSObject

@property (nonatomic, strong) NSString *name; // name of workout
@property (nonatomic, strong) NSString *date; // date of workout
@property (nonatomic, strong) NSString *url; // url of workout
@property (nonatomic, strong) NSString *urlID; // JSON ID for the particular workout

@end
