//
//  LDMainWindow.h
//  LuaDriver
//
//  Created by Middleware on 7/12/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//



#import <Cocoa/Cocoa.h>




struct lua_State;




@interface LDMainWindow : NSWindow



@property int userDataRef;



- (void) createUserdata:(struct lua_State*)L;



@end
