//
//  LDURL.h
//  LuaDriver
//
//  Created by Middleware on 7/30/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import <Foundation/Foundation.h>



struct lua_State;


extern void newLuaObjectOfURL(struct lua_State* L, NSURL* url);