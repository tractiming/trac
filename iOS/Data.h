//
//  Data.h
//  TRAC
//
//  Created by Griffin Kelly on 2/15/16.
//  Copyright © 2016 Griffin Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Data : NSObject <NSCoding> {
    NSArray *_storedIDs;
    NSArray *_storedToast;
    NSArray *_storedReset;
    
}

@property (copy) NSArray *storedIDs;
@property  NSArray* storedToast;
@property  NSArray* storedReset;

- (id)initWithTitle:(NSArray*)storedIDs toast:(NSArray*)storedToast reset:(NSArray*)storedReset;

@end
