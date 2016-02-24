//
//  Data.m
//  TRAC
//
//  Created by Griffin Kelly on 2/15/16.
//  Copyright © 2016 Griffin Kelly. All rights reserved.
//

#import "Data.h"

@implementation Data
@synthesize storedIDs = _storedIDs;
@synthesize storedToast = _storedToast;
@synthesize storedReset = _storedReset;

- (id)initWithTitle:(NSArray*)storedIDs toast:(NSArray*)storedToast reset:(NSArray*)storedReset{
    if ((self = [super init])) {
        _storedToast = storedToast;
        _storedIDs = storedIDs;
        _storedReset = storedReset;
    }
    return self;
}

- (void)dealloc {

    _storedIDs = nil;

}

#pragma mark NSCoding

#define kTitleKey       @"Title"
#define kToastKey      @"Toast"
#define kResetKey      @"Reset"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_storedIDs forKey:kTitleKey];
    [encoder encodeObject:_storedToast forKey:kToastKey];
    [encoder encodeObject:_storedReset forKey:kResetKey];

}

- (id)initWithCoder:(NSCoder *)decoder {
    NSArray *storedIDs = [decoder decodeObjectForKey:kTitleKey];
    NSArray *storedToast = [decoder decodeObjectForKey:kToastKey];
    NSArray *storedReset = [decoder decodeObjectForKey:kResetKey];
    return [self initWithTitle:storedIDs toast:storedToast reset:storedReset];
}

@end
