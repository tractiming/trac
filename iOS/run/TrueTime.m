//
//  TrueTime.m
//  TRAC
//
//  Created by Griffin Kelly on 2/28/16.
//  Copyright © 2016 Griffin Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrueTime.h"
#import <sys/sysctl.h>

@implementation TrueTime

+ (NSTimeInterval)uptime {
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    
    struct timeval now;
    struct timezone tz;
    gettimeofday(&now, &tz);
    
    double uptime = -1;
    
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        uptime = now.tv_sec - boottime.tv_sec;
        uptime += (double)(now.tv_usec - boottime.tv_usec) / 1000000.0;
    }
    return uptime;
}
@end
