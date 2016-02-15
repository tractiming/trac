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
    UIImage *_thumbImage;
    UIImage *_fullImage;
    NSString *_docPath;
}

@property (retain) Data *data;
@property (retain) UIImage *thumbImage;
@property (retain) UIImage *fullImage;
@property (copy) NSString *docPath;

- (id)init;
- (id)initWithDocPath:(NSString *)docPath;
- (id)initWithTitle:(NSString*)title rating:(float)rating thumbImage:(UIImage *)thumbImage fullImage:(UIImage *)fullImage;
- (void)saveData;
- (void)saveImages;
- (void)deleteDoc;

@end
