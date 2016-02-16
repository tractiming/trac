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

- (id)initWithTitle:(NSArray*)storedIDs toast:(NSArray*)storedToast {
    if ((self = [super init])) {
        _storedToast = storedToast;
        _storedIDs = storedIDs;
    }
    return self;
}

- (void)dealloc {

    _storedIDs = nil;

}

#pragma mark NSCoding

#define kTitleKey       @"Title"
#define kToastKey      @"Toast"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_storedIDs forKey:kTitleKey];
    [encoder encodeObject:_storedToast forKey:kToastKey];

}

- (id)initWithCoder:(NSCoder *)decoder {
    NSArray *storedIDs = [decoder decodeObjectForKey:kTitleKey];
    NSArray *storedToast = [decoder decodeObjectForKey:kToastKey];
    return [self initWithTitle:storedIDs toast:storedToast];
}

@end
