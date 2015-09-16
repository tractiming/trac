//
//  RunnerDetail.h
//  TRAC
//
//  Created by Griffin Kelly on 9/3/15.
//  Copyright (c) 2015 Griffin Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunnerDetail : NSObject

@property (nonatomic, strong) NSString *runnerName; // name of runer
@property (nonatomic, strong) NSMutableArray *counterArray; // counter of splits
@property (nonatomic, strong) NSMutableArray *splitArray; // raw JSON splits array
@property (nonatomic, strong) NSMutableArray *parsedSplitArray; // splits array


@end