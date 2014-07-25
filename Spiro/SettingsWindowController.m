//
//  SettingsWindowController.m
//  Spiro
//
//  Created by Daniel van Hoesel on 24-07-14.
//  Copyright (c) 2014 Zilverline. All rights reserved.
//

#import "SettingsWindowController.h"
#import <ScreenSaver/ScreenSaver.h>

@interface SettingsWindowController ()

@end

@implementation SettingsWindowController

- (IBAction)ok:(id)sender
{
    ScreenSaverDefaults *defaults;
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:[NSBundle bundleForClass:[self class]].bundleIdentifier];

    [defaults setFloat:[self.speed floatValue] forKey:@"speed"];
    [defaults setFloat:[self.smoothness floatValue] forKey:@"smoothness"];
    [defaults setBool:[self.singleColor state] forKey:@"singleColor"];
    [defaults setObject:[NSArchiver archivedDataWithRootObject:[self.color color]] forKey:@"color"];
    
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotification: [NSNotification notificationWithName:NSUserDefaultsDidChangeNotification object:nil]];
    
    [NSApp endSheet:self.window];
}

- (IBAction)cancel:(id)sender
{    
    [NSApp endSheet:self.window];
}

- (IBAction)singleColorClick:(id)sender
{
    [self.color setEnabled:[sender state]];
}

- (void)windowDidLoad {
    ScreenSaverDefaults *defaults;
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:[NSBundle bundleForClass:[self class]].bundleIdentifier];
    
    [self.speed setFloatValue:[defaults floatForKey:@"speed"]];
    [self.smoothness setFloatValue:[defaults floatForKey:@"smoothness"]];
    [self.singleColor setState:[defaults boolForKey:@"singleColor"]];
    [self.color setEnabled:[defaults boolForKey:@"singleColor"]];
    if ([defaults valueForKey:@"color"] == nil) {
        [self.color setColor:[NSColor redColor]];
    } else {
        [self.color setColor:[NSUnarchiver unarchiveObjectWithData:[defaults dataForKey:@"color"]]];
    }
}

@end
