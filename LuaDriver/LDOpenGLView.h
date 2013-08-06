//
//  LDOpenGLView.h
//  LuaDriver
//
//  Created by Middleware on 7/19/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//




#import <Cocoa/Cocoa.h>




@interface LDOpenGLView : NSOpenGLView



struct lua_State;



@property int userDataRef;


- (void)createUserData:(struct lua_State*)L;
- (IBAction)drawObjectType:(id)sender;


@end
