//
//  Data.h
//  TRAC
//
//  Created by Griffin Kelly on 2/15/16.
//  Copyright © 2016 Griffin Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Data : NSObject <NSCoding> {
    NSString *_title;
    float _rating;
}

@property (copy) NSString *title;
@property  float rating;

- (id)initWithTitle:(NSString*)title rating:(float)rating;

@end
