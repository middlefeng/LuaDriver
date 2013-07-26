//
//  LDUtilities.h
//  LuaDriver
//
//  Created by Middleware on 7/12/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "lua.h"



struct lua_State;





@interface LDUtilities : NSObject



+ (BOOL) initializeLDClass:(NSString*)className;



+ (NSString*) luaSourcePath:(NSString*)name;



+ (void) error:(NSString*)errorText, ...;



+ (int) luaTableKeyCount:(struct lua_State*)L at:(int)index;


+ (void) newLuaObject:(struct lua_State*)L fromRect:(NSRect)rect;
+ (NSRect) nsRectFromLuaObject:(struct lua_State*)L atIndex:(int)index;



+ (void) commonGC:(struct lua_State*)L;
+ (void) newMetatable:(struct lua_State*)L name:(NSString*)name
				 gcmt:(lua_CFunction)gcmt;
+ (void) prepMetatable:(struct lua_State*)L name:(NSString*)name
				  gcmt:(lua_CFunction)gcmt;
+ (int) newLuaObject:(struct lua_State*)L fromObject:(id)obj;
+ (id) userDataFromLuaTable:(struct lua_State*)L atIndex:(int)index;




@end
