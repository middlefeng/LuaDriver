//
//  LDAppDelegate.h
//  LuaDriver
//
//  Created by Middleware on 7/12/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//


#import <Cocoa/Cocoa.h>



struct lua_State;



@class LDMainWindow;




@interface LDAppDelegate : NSObject <NSApplicationDelegate>




@property (assign) IBOutlet LDMainWindow *window;
@property int userDataRef;




- (void) createUserData:(struct lua_State*)L;



@end
