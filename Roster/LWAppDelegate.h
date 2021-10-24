//
//  LWAppDelegate.h
//  Roster
//
//  Created by Lennart Wisbar on 29.09.12.
//  Copyright (c) 2012 Lewisoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LWAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *ergebnisFeld;

@end
