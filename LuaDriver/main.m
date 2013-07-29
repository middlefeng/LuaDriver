//
//  main.m
//  LuaDriver
//
//  Created by Middleware on 7/12/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"

#import "LDScreen.h"
#import "LDFileManager.h"
#import "LDBundle.h"
#import "LDOpenGL.h"
#import "LDEvent.h"

#import "LDUtilities.h"


int main_lua(int argc, char *argv[]);
int pmain(lua_State* L);



lua_State* g_L = 0;
const char* k_userData = "__userData";



const char* luaClassFiles[] = {
	"LuaAppDelegate",
	"LuaMainWindow",
	"LuaTextView",
	"LuaOpenGLView",
	0,
};



int main(int argc, char *argv[])
{
	return main_lua(argc, argv);
}




int pmain(lua_State* L)
{
	int argc = (int)lua_tointeger(L, 1);
	const char **argv = (const char **)lua_touserdata(L, 2);
	int result;
	
	/* open standard libraries */
	luaL_checkversion(L);
	lua_gc(L, LUA_GCSTOP, 0);  /* stop collector during initialization */
	luaL_openlibs(L);  /* open libraries */
	lua_gc(L, LUA_GCRESTART, 0);
	
	/* initialize Cocoa APIs (non-callaback ones) */
	init_LDScreen(L);
	init_LDFileManager(L);
	init_LDBundle(L);
	init_LDOpenGL(L);
	init_LDEvent(L);
	
	const char** luaClass = luaClassFiles;
	while (*luaClass) {
		if (![LDUtilities initializeLDClass:[NSString stringWithUTF8String:*luaClass]]) {
			lua_pushvalue(L, EXIT_FAILURE);
			return 1;
		}
		++luaClass;
	}
	
	result = NSApplicationMain(argc, argv);
	
	lua_pushinteger(L, result);
	return 1;
}




int main_lua(int argc, char *argv[])
{
	int status, result;
	lua_State *L = luaL_newstate();  /* create state */
	if (L == NULL) {
		NSLog(@"cannot create state: not enough memory");
		return EXIT_FAILURE;
	}
	g_L = L;

	/* call 'pmain' in protected mode */
	lua_pushcfunction(L, &pmain);
	lua_pushinteger(L, argc);  /* 1st argument */
	lua_pushlightuserdata(L, argv); /* 2nd argument */
	status = lua_pcall(L, 2, 1, 0);
	result = (int)lua_tointeger(L, -1);  /* get result */

	if (status != LUA_OK) {
		const char *msg = (lua_type(L, -1) == LUA_TSTRING) ? lua_tostring(L, -1) : NULL;
		if (msg == NULL) msg = "(error object is not a string)";
		NSLog(@"%s", msg);
		lua_pop(L, 1);
	}
	
	lua_close(L);
	return (status == LUA_OK) ? result : EXIT_FAILURE;
}


