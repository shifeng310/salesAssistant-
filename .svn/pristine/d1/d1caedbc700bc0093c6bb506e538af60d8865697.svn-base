//
//  RRScrollView.m
//  RR
//
//  Created by lyq on 8/3/11.
//  Copyright 2011 RoadRover Inc. All rights reserved.
//

#import "RRScrollView.h"


@implementation RRScrollView


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self)
	{
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/


#pragma mark -
#pragma mark touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(!self.dragging)
	{
		[[self nextResponder] touchesBegan:touches withEvent:event];
	}
	
	[super touchesBegan:touches withEvent:event];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewTouchesBegan:)])
	{
		[self.delegate performSelector:@selector(scrollViewTouchesBegan:) withObject:self];
	}
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(!self.dragging)
	{
		[[self nextResponder] touchesEnded:touches withEvent:event];
	}
	
	[super touchesEnded:touches withEvent:event];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewTouchesEnded:)])
	{
		[self.delegate performSelector:@selector(scrollViewTouchesEnded:) withObject:self];
	}
}


@end



