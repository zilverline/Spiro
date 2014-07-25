//
//  SpiroView.m
//  Spiro
//
//  Created by Daniel van Hoesel on 23-07-14.
//  Copyright (c) 2014 Zilverline. All rights reserved.
//

#import "SpiroView.h"
#import "SettingsWindowController.h"

@interface SpiroView ()

@property double t, a, b, h, s, tInc, lineWidth;
@property long startX, startY;
@property BOOL needsReset, preview;
@property NSColor *color;
@property ScreenSaverDefaults *defaults;
@property SettingsWindowController *settingsWindow;

@end

@implementation SpiroView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        self.defaults = [ScreenSaverDefaults defaultsForModuleWithName:[NSBundle bundleForClass:[self class]].bundleIdentifier];
        
        [self.defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                    @"NO", @"singleColor",
                                    @"20.0", @"speed",
                                    @"1.0", @"smoothness",
                                    nil]];
        
        [self setAnimationTimeInterval:1/30.0];
        [self reset];
        self.preview = isPreview;

        if (self.preview) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
        }
    }
    return self;
}

- (void)defaultsChanged:(NSNotification *)notification
{
    [self reset];
}

- (void)animateOneFrame
{
    // s determines how many increments we need to draw at once
    for (int i = 1; i <= self.s; i++) {
        [self drawPointForT:self.t += self.tInc];
    }
}

-(void) reset
{
    int max = self.preview ? 20.0 : MIN(500.0, self.frame.size.height);
    int min = self.preview ? -10.0 : -100.0;
    
    self.lineWidth = self.preview ? 1.0 : 3.0;
    
    self.h = SSRandomFloatBetween(1.0, max);// 90;
    self.a = SSRandomFloatBetween(min, max);// 30;
    self.b = SSRandomFloatBetween(min, max);// -20;
    
    self.t = 0.0;
    self.tInc = [self.defaults floatForKey:@"smoothness"] / 100; // smoothnes (lower is smoother)
    self.s = [self.defaults floatForKey:@"speed"]; // speed (lower is slower, 1 is slowest)
    
    if ([self.defaults boolForKey:@"singleColor"] && [self.defaults valueForKey:@"color"] != nil) {
        self.color = [NSUnarchiver unarchiveObjectWithData:[self.defaults dataForKey:@"color"]];
    } else {
        double red = SSRandomFloatBetween( 0.0, 1.0 );
        double green = SSRandomFloatBetween( 0.0, 1.0 );
        double blue = SSRandomFloatBetween( 0.0, 1.0 );
        
        if (red == 0.0 && green == 0.0 && blue == 0.0) {
            // make sure we don't get black, it's hard to see on a black background
            red = green = blue = 1.0;
        }
        
        self.color = [NSColor colorWithDeviceRed:red green:green blue:blue alpha: 1.0];
    }
    
    self.startX = 0;
    self.startY = 0;

    self.needsReset = false;
}

- (void)drawPointForT:(double)t
{
    if (self.needsReset) {
        // clear drawing
        CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
        CGContextClearRect(context, self.frame);
        
        [self reset];
        return;
    }
    
    [self.color set];
    NSBezierPath* path = [NSBezierPath bezierPath];
    CGSize size = [self bounds].size;
    int xOffset = size.width / 2;
    int yOffset = size.height / 2;
    
    long x = [self calcX:(t - self.tInc)];
    long y = [self calcY:(t - self.tInc)];

    if (x == self.startX && y == self.startY) { // reset when we're back at the start
        self.needsReset = true;
        return;
    } else if (t - self.tInc <= 0) { // cache the start position so we can check when it's finished drawing
        self.startX = x;
        self.startY = y;
    } else if (t > 2000) { // start a new one when it takes too long, get's boring
        self.needsReset = true;
        return;
    }
    
    [path moveToPoint:NSMakePoint(x + xOffset, y + yOffset)];
    [path lineToPoint:NSMakePoint([self calcX:t] + xOffset, [self calcY:t] + yOffset)];
    [path setLineWidth:self.lineWidth];
    [path stroke];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSString* keysPressed = [theEvent characters];
    if ( [keysPressed isEqualToString:@" "] ) {
        self.needsReset = true;
    } else {
        [super keyDown: theEvent];
    }
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    self.settingsWindow = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindowController"];
    return self.settingsWindow.window;
}

- (long)calcX:(double)t
{
    double x = (self.a - self.b) * cos(t) + self.h * cos((self.a - self.b) * t / self.b);
    return lroundf(x);
}

- (long)calcY:(double)t
{
    double y = (self.a - self.b) * sin(t) - self.h * sin((self.a - self.b) * t / self.b);
    return lroundf(y);
}

@end
