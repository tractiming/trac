//
//  TRACDoc.m
//  TRAC
//
//  Created by Griffin Kelly on 2/15/16.
//  Copyright © 2016 Griffin Kelly. All rights reserved.
//


#import "TRACDoc.h"
#import "Data.h"
#import "TRACDatabase.h"

#define kDataKey        @"Data"
#define kDataFile       @"data.plist"


@implementation TRACDoc
@synthesize data = _data;
@synthesize docPath = _docPath;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (id)initWithDocPath:(NSString *)docPath {
    if ((self = [super init])) {
        _docPath = [docPath copy];
    }
    return self;
}

- (id)initWithTitle:(NSArray*)storedIDs toast:(NSArray*)storedToast reset:(NSArray*)storedReset{
    if ((self = [super init])) {
        _data = [[Data alloc] initWithTitle:storedIDs toast:storedToast reset:storedReset];
    }
    return self;
}

- (void)dealloc {

    _data = nil;

    _docPath = nil;

}

- (BOOL)createDataPath: (NSString *) SessionID {
    if (_docPath == nil) {
        self.docPath = [TRACDatabase nextDocPath: SessionID];
    }
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:_docPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    return success;
    
}

- (Data *)data {
    if (_data != nil) return _data;
    
    NSString *dataPath = [_docPath stringByAppendingPathComponent:kDataFile];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:dataPath];
    if (codedData == nil) return nil;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    _data = [unarchiver decodeObjectForKey:kDataKey];
    [unarchiver finishDecoding];
    
    return _data;
    
}

- (void)saveData:(NSString*) SessionID{
    if (_data == nil) return;
    
    [self createDataPath:SessionID];
    NSString *dataPath = [_docPath stringByAppendingPathComponent:kDataFile];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_data forKey:kDataKey];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
    
}


- (void)deleteDoc {
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:_docPath error:&error];
    if (!success) {
        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }
    
}

@end

