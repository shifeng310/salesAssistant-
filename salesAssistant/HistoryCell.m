//
//  HistoryCell.m
//  salesAssistant
//
//  Created by 方鸿灏 on 13-7-24.
//  Copyright (c) 2013年 feng. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell

@synthesize lb_content;
@synthesize lb_name;
@synthesize lb_time;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)dealloc
{
    lb_content = nil;
    lb_name = nil;
    lb_time = nil;
}

+ (CGFloat) calCellHeight:(NSDictionary *)data
{
	return 78.0f;
}

- (void) setContent:(NSMutableDictionary *)data
{
    NSString *staff = [data objectForKey:@"username"];
    NSString *desc = [data objectForKey:@"content"];
    NSString *date = [data objectForKey:@"addtime"];
    
    NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
	[date_formatter setDateFormat:@"yy-MM-dd hh:mm:ss"];
	NSString *post_date = [date_formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[date doubleValue]]];
    
    lb_content.text = desc;
    
    lb_name.text = staff;
    lb_time.text = post_date;
}

@end
