//
//  DMAppDelegate.h
//  Dungeon Master Tools
//
//  Created by Kevin Jorgensen on 4/3/12.
//  Copyright (c) 2012 Kevin Jorgensen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DMAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow *_window;
}

@property (assign) IBOutlet NSWindow *window;

@end
