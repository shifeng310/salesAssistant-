//
//  RRViewPhotoController.m
//  RR
//
//  Created by lyq on 7/25/11.
//  Copyright 2011 RoadRover Inc. All rights reserved.
//

#import "RRViewPhotoController.h"
#import "RRScrollView.h"


@implementation RRViewPhotoController

@synthesize scroll_view;
@synthesize im_image;
@synthesize btn_clear_photo;
@synthesize delegate;


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationController setToolbarHidden:YES animated:YES];
	
	self.navigationItem.rightBarButtonItem = btn_clear_photo;
	
	iv_image = [[UIImageView alloc] initWithImage:im_image];
	
	CGFloat scale_rate = 1.0f;
	if (im_image.size.width > im_image.size.height)
	{
		if (im_image.size.width > 320)
		{
			scale_rate = 320 / im_image.size.width;
		}
	}
	else
	{
		if (im_image.size.height > 480)
		{
			scale_rate = 480 / im_image.size.height;
		}
	}
	
	scroll_view.minimumZoomScale = scale_rate;
	scroll_view.maximumZoomScale = im_image.size.width * 1.3 / iv_image.frame.size.width;
	
	scroll_view.zoomScale = scale_rate;
	
	CGPoint start_point = CGPointMake(0.0f, 0.0f);
	
	if (320 >= iv_image.frame.size.width)
	{
		start_point.x = (320 - iv_image.frame.size.width) / 2;
	}
	
	if (480 >= iv_image.frame.size.height)
	{
		start_point.y = (480 - iv_image.frame.size.height) / 2;
	}
	
	iv_image.frame = CGRectMake(start_point.x,
								start_point.y,
								iv_image.frame.size.width, 
								iv_image.frame.size.height);
	
	[scroll_view addSubview:iv_image];
	scroll_view.contentSize = iv_image.frame.size;
	
	scroll_view.showsVerticalScrollIndicator = NO;
	scroll_view.showsHorizontalScrollIndicator = NO;
	scroll_view.bouncesZoom = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma mark -
#pragma mark RRScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return iv_image;
}

- (void) scrollViewTouchesEnded:(RRScrollView *)scrollView
{
}

#pragma mark -

- (IBAction) didClearPhoto:(id)sender
{
	if (delegate && [delegate respondsToSelector:@selector(didCleanPhoto)])
	{
		[delegate performSelector:@selector(didCleanPhoto)];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}


@end


@implementation UIScrollView (new)

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (1 != self.tag)
	{
		return;
	}
	
	UIView *img_view = [self viewWithTag:99];
	CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = img_view.frame;
    
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    img_view.frame = frameToCenter;
}

@end
