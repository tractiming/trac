//
//  TRACDoc.h
//  TRAC
//
//  Created by Griffin Kelly on 2/15/16.
//  Copyright © 2016 Griffin Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Data;

@interface TRACDoc : NSObject {
    Data *_data;
    NSString *_docPath;
}

@property (retain) Data *data;
@property (copy) NSString *docPath;

- (id)init;
- (id)initWithDocPath:(NSString *)docPath;
- (id)initWithTitle:(NSArray*)storedIDs toast:(NSArray*)storedToast reset:(NSArray*)storedReset;
- (void)saveData:(NSString*) SessionID;
- (void)deleteDoc:(NSString*) dataPath;

@end
