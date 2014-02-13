//
//  RRLoginModel.h
//  lib_net
//
//  Created by lyq on 11-6-10.
//  Copyright 2011 RoadRover Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RRLoginModel : NSObject
{
	BOOL		is_loading;
	id			view_ctrl;
}

- (id) initWithViewController: (id)aController;

- (void) login: (NSString *)login_name password:(NSString *)password;

- (void) onLoaded: (NSNotification *)notify;

- (void) onLoadFail: (NSNotification *)notify;

@end
