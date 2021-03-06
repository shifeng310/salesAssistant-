//
//  RWShowView.m
//  RW
//
//  Created by 方鸿灏 on 12-2-27.
//  Copyright 2012 roadrover. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RWShowView.h"

static UILabel *label;

@implementation RWShowView

// 在等待数据的过程中，显示的小菊花图标
+ (void)show:(NSString *)text
{
	CGRect src_bounds = [UIScreen mainScreen].bounds;
	UIFont *fnt = [UIFont systemFontOfSize:13.5f];
	CGSize text_frm_size = [text sizeWithFont:fnt
							constrainedToSize:CGSizeMake(210.0f, 1000.0f)
								lineBreakMode:NSLineBreakByWordWrapping];

	if (label)
	{
		[label removeFromSuperview];
	}
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(src_bounds.origin.x + (src_bounds.size.width-50.0f) * 0.5f,
													  src_bounds.size.height*0.5f - 25.0f,
													  50.0f,
													  50.0f)];
	label.layer.cornerRadius = 5.0f;
	label.backgroundColor = [UIColor blackColor];
	label.alpha = 0.5f;
	label.numberOfLines = 0;
	label.font = fnt;
	label.textColor = [UIColor whiteColor];
	label.textAlignment = UITextAlignmentCenter;
	
	if ([text isEqualToString:@"loading"])
	{
		UIActivityIndicatorView *aiv =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		aiv.center = CGPointMake(label.bounds.size.width/2.0f, label.bounds.size.height/2.0f);
		[aiv startAnimating];
		[label addSubview:aiv];
	}
	else 
	{
		label.frame = CGRectMake(src_bounds.origin.x + (src_bounds.size.width-220.0f) * 0.5f,
														src_bounds.size.height*0.5f - 60.0f,
														text_frm_size.width + 10.0f,
														text_frm_size.height + 10.0f);
		label.center = CGPointMake(src_bounds.origin.x + src_bounds.size.width * 0.5f, src_bounds.size.height*0.5f - 60.0f);
		label.alpha = 0.5f;
		label.text = text;
	}
	UIWindow *w = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
	[w addSubview:label];
}


+ (void) closeAlert
{
	[label removeFromSuperview];
	label = nil;
}
@end
