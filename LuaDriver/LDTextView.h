//
//  LDTextView.h
//  LuaDriver
//
//  Created by Middleware on 7/17/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//



#import <Cocoa/Cocoa.h>



struct lua_State;




@interface LDTextView : NSTextView



@property int userDataRef;



- (void) createUserData:(struct lua_State*)L;



@end
