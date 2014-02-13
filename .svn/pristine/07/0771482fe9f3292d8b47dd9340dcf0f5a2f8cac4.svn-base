//
//  RRViewPhotoController.h
//  RR
//
//  Created by lyq on 7/25/11.
//  Copyright 2011 RoadRover Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RRScrollView;

@interface RRViewPhotoController : UIViewController <UIScrollViewDelegate>
{
	RRScrollView		*scroll_view;
	
	UIImage				*__unsafe_unretained im_image;
	UIImageView			*iv_image;
	
	UIBarButtonItem		*btn_clear_photo;
	
	id					__unsafe_unretained delegate;
}

@property (nonatomic) IBOutlet RRScrollView *scroll_view;
@property (nonatomic, unsafe_unretained) UIImage *im_image;
@property (nonatomic) IBOutlet UIBarButtonItem *btn_clear_photo;
@property (nonatomic, unsafe_unretained) IBOutlet id delegate;

- (IBAction) didClearPhoto:(id)sender;


@end
