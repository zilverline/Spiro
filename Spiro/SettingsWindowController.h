//
//  SettingsWindowController.h
//  Spiro
//
//  Created by Daniel van Hoesel on 24-07-14.
//  Copyright (c) 2014 Zilverline. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingsWindowController : NSWindowController

@property (strong) IBOutlet NSSlider *speed;
@property (strong) IBOutlet NSSlider *smoothness;
@property (strong) IBOutlet NSButton *singleColor;
@property (strong) IBOutlet NSColorWell *color;

@end
