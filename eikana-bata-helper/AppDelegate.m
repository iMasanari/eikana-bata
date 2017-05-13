//
//  AppDelegate.m
//  eikana-bata-helper
//
//  Created by 岩田将成 on 2017/03/18.
//  Copyright © 2017年 iMasanari. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Check whether the main application is running and active
    BOOL running = NO;
    BOOL active = NO;
    
    NSArray *applications = [NSRunningApplication runningApplicationsWithBundleIdentifier: @"io.github.imasanari.eikana-bata"];
    if (applications.count > 0) {
        NSRunningApplication *application = [applications firstObject];
        
        running = YES;
        active = [application isActive];
    }
    
    if (!running && !active) {
        // Launch main application
        NSURL *applicationURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", @"io.github.imasanari.eikana-bata"]];
        [[NSWorkspace sharedWorkspace] openURL:applicationURL];
    }
    
    // Quit
    [NSApp terminate:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
