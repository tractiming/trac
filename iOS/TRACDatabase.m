//
//  TRACDatabase.m
//  TRAC
//
//  Created by Griffin Kelly on 2/15/16.
//  Copyright © 2016 Griffin Kelly. All rights reserved.
//

#import "TRACDatabase.h"
#import "TRACDoc.h"

@implementation TRACDatabase

+ (NSString *)getPrivateDocsDir {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    return documentsDirectory;
    
}

+ (NSMutableArray *)loadDocs: (NSString *) sessionID {
    
    // Get private docs dir
    NSString *documentsDirectory = [TRACDatabase getPrivateDocsDir];
    NSLog(@"Loading bugs from %@", documentsDirectory);
    
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    NSLog(@"Files Names: %@",files);
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
    
    // Create TRAC for each file
    NSMutableArray *retval = [NSMutableArray arrayWithCapacity:files.count];
    for (NSString *file in files) {
        
        if ([file.pathExtension compare:@"trac" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            
            if([[NSString stringWithFormat:@"%@",sessionID] isEqualToString:[NSString stringWithFormat:@"%@",[[file lastPathComponent] stringByDeletingPathExtension]] ]){
                NSLog(@"Hello hello");
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:file];
                TRACDoc *doc = [[TRACDoc alloc] initWithDocPath:fullPath];
                [retval addObject:doc];
               
            }
        }
    }
    
    return retval;
    
}

+ (void)deletePath: (NSString *) sessionID {
    
    // Get private docs dir
    NSString *documentsDirectory = [TRACDatabase getPrivateDocsDir];
    NSLog(@"Loading bugs from %@", documentsDirectory);
    
    // Get contents of documents directory
    NSString *fullPath;
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    NSLog(@"Files Names: %@",files);
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
    }
    
    for (NSString *file in files) {
        
        if ([file.pathExtension compare:@"trac" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            
            if([[NSString stringWithFormat:@"%@",sessionID] isEqualToString:[NSString stringWithFormat:@"%@",[[file lastPathComponent] stringByDeletingPathExtension]] ]){
                NSLog(@"Hello hello");
                fullPath = [documentsDirectory stringByAppendingPathComponent:file];
                NSLog(@"Load Docs Delete Path %@",fullPath);
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
                if (!success) {
                    NSLog(@"Error removing document path: %@", error.localizedDescription);
                }
            }
        }
    }
    
    
}

+ (NSString *)nextDocPath:(NSString *) sessionID {
    
    // Get private docs dir
    NSString *documentsDirectory = [TRACDatabase getPrivateDocsDir];
    
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
    
    // Search for an available name
    int maxNumber = 0;
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"trac" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString *fileName = [file stringByDeletingPathExtension];
            maxNumber = MAX(maxNumber, fileName.intValue);
        }
    }
    NSInteger sessionint = [sessionID integerValue];
    // Get available name
    NSString *availableName = [NSString stringWithFormat:@"%ld.trac", (long)sessionint];
    return [documentsDirectory stringByAppendingPathComponent:availableName];
    
}

@end