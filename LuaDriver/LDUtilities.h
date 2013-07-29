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
+ (int) newLuaObject:(struct lua_State*)L fromObject:(id)obj;
+ (id) userDataFromLuaTable:(struct lua_State*)L atIndex:(int)index;



/****
 *		Setup metatable
 *		============================================
 *		newMetatable:... create a new metatable:
 *			1. Only accessiable from C code.
 *			2. Used by classes not derivable.
 *			3. Leave the metatable on the stack.
 *		prepMetatable:... take an existing global Lua table and set it up
 *		as a metatable:
 *			1. Accessible both from Lua and from C.
 *			2. Used by classes meant for subclassing.
 */
+ (void) newMetatable:(struct lua_State*)L name:(NSString*)name;
+ (void) prepMetatable:(struct lua_State*)L name:(NSString*)name;



/****
 *		Leave the function name and the Lua object on the stack
 *		for a following invocation to Lua object (for a derived class).
 */
+ (void) prepCall:(struct lua_State*)L onMethod:(NSString*)methodName
									   onObject:(id)obj;




@end



extern int ld_nsobject_release_gc(struct lua_State* L);

