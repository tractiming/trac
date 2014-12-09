//
//  CustomCell.h
//  TRAC
//
//  Created by Griffin Kelly on 12/8/14.
//  Copyright (c) 2014 Griffin Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property(weak, nonatomic) IBOutlet UILabel *Name;
@property(weak, nonatomic) IBOutlet UILabel *Split;
@property(weak, nonatomic) IBOutlet UILabel *Total;

@end
