//
//  ListCell.h
//  salesAssistant
//
//  Created by feng on 7/19/13.
//  Copyright (c) 2013 feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListCell : UITableViewCell
{
    IBOutlet UIImageView            *img_handle;
    IBOutlet UILabel                *lb_staff;
    IBOutlet UILabel                *lb_desc;
    IBOutlet UILabel                *lb_date;
    IBOutlet UILabel                *lb_handle;
    IBOutlet UIButton               *btn_handle;
    NSUInteger                      type;
}

@property (nonatomic, strong) UIImageView *img_handle;
@property (nonatomic, strong) UILabel *lb_staff;
@property (nonatomic, strong) UILabel *lb_desc;
@property (nonatomic, strong) UILabel *lb_date;
@property (nonatomic, strong) UIButton *btn_handle;
@property (nonatomic, strong) UILabel *lb_handle;

+ (CGFloat) calCellHeight:(NSDictionary *)data;

- (void) setContent:(NSDictionary *)data;

@end
