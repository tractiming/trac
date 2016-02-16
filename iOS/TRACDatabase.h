//
//  TRACDatabase.h
//  TRAC
//
//  Created by Griffin Kelly on 2/15/16.
//  Copyright © 2016 Griffin Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRACDatabase : NSObject {
    
}

+ (NSMutableArray *)loadDocs;
+ (NSString *)nextDocPath;

@end
