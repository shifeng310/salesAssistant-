//
//  ListCell.m
//  salesAssistant
//
//  Created by feng on 7/19/13.
//  Copyright (c) 2013 feng. All rights reserved.
//

#import "ListCell.h"
#import "FristViewController.h"


@implementation ListCell

@synthesize lb_date;
@synthesize lb_staff;
@synthesize lb_desc;
@synthesize img_handle;
@synthesize btn_handle;
@synthesize lb_handle;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)dealloc
{
    lb_date = nil;
    lb_staff = nil;
    lb_desc = nil;
    img_handle = nil;
    btn_handle = nil;
    lb_handle = nil;
}

+ (CGFloat) calCellHeight:(NSDictionary *)data
{
	return 80.0f;
}

- (void) setContent:(NSMutableDictionary *)data
{

    type = [[data objectForKey:@"type"] integerValue];
    switch (type)

    {
        case 0:
        case 1:
            img_handle.image = [UIImage imageNamed:@"unhandle.png"];
            break;
        case 2:
            img_handle.image = [UIImage imageNamed:@"finish.png"];
            btn_handle.alpha = 0;
            lb_handle.alpha = 0;
            break;
        case 3:
            img_handle.image = [UIImage imageNamed:@"close_order.png"];
            btn_handle.alpha = 0;
            lb_handle.alpha = 0;
            break;
        case 4:
            img_handle.image = [UIImage imageNamed:@"message_list.png"];
            btn_handle.alpha = 0;
            lb_handle.alpha = 0;
            
            break;
        default:
            break;
    }
    
    if (type==4) {
        NSString *staff = [NSString stringWithFormat:@"发送人:%@",[data objectForKey:@"author"]];
        NSString *desc = [data objectForKey:@"content"];
        NSString *date = [data objectForKey:@"addtime"];
        NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
        [date_formatter setDateFormat:@"yy-MM-dd"];
        NSString *post_date = [date_formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[date doubleValue]]];
        
        lb_desc.text = desc;
        lb_staff.text = staff;
        lb_date.text = post_date;
        
    }
    else
    {
        NSString *staff = [NSString stringWithFormat:@"处理人:%@",[data objectForKey:@"username"]];
        NSString *desc = [data objectForKey:@"appearance"];
        // 设置时间
        NSString *date = [data objectForKey:@"addtime"];
        NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
        [date_formatter setDateFormat:@"yy-MM-dd"];
        NSString *post_date = [date_formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[date doubleValue]]];
        lb_desc.text = desc;
        lb_staff.text = staff;
        lb_date.text = post_date;
        btn_handle.tag = [[data objectForKey:@"row"] integerValue] + 1;
    }

}

@end
