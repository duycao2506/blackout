/*
 * Copyright (C) 2010 Michael Dippery <mdippery@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "BOPreferencePane.h"


@interface BOPreferencePane ()
- (void)launchBlackout;
- (void)terminateBlackout;
- (void)checkBlackoutIsRunning;
@end


@implementation BOPreferencePane

- (void)awakeFromNib
{
    if ([self isBlackoutRunning]) {
        [runningLabel setStringValue:NSLocalizedString(@"Blackout is running.", nil)];
        [startButton setTitle:NSLocalizedString(@"Stop Blackout", nil)];
        [startButton setAction:@selector(stopBlackout:)];
    } else {
        [runningLabel setStringValue:NSLocalizedString(@"Blackout is stopped.", nil)];
        [startButton setTitle:NSLocalizedString(@"Start Blackout", nil)];
        [startButton setAction:@selector(startBlackout:)];
    }
}

- (NSString *)blackoutHelperPath
{
    return [[NSBundle bundleForClass:[self class]] pathForResource:@"Blackout" ofType:@"app"];
}

- (BOOL)isBlackoutRunning
{
    ProcessSerialNumber psn = {0, kNoProcess };
    
    while (GetNextProcess(&psn) == noErr) {
        NSDictionary *info = [NSMakeCollectable(ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask)) autorelease];
        if (info) {
            NSString *bundlePath = [info objectForKey:@"BundlePath"];
            NSString *bundleID = [info objectForKey:(NSString *) kCFBundleIdentifierKey];
            if (bundlePath && bundleID) {
                if ([bundleID isEqualToString:@"com.monkey-robot.Blackout"]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (IBAction)startBlackout:(id)sender
{
    [startButton setEnabled:NO];
    [launchIndicator startAnimation:self];
    [runningLabel setStringValue:NSLocalizedString(@"Launching Blackout...", nil)];
    [self launchBlackout];
    [self performSelector:@selector(checkBlackoutIsRunning) withObject:nil afterDelay:4.0];
}

- (IBAction)stopBlackout:(id)sender
{
    [startButton setEnabled:NO];
    [launchIndicator startAnimation:self];
    [runningLabel setStringValue:NSLocalizedString(@"Stopping Blackout...", nil)];
    [self terminateBlackout];
    [self performSelector:@selector(checkBlackoutIsRunning) withObject:nil afterDelay:4.0];
}

- (void)launchBlackout
{
    static NSWorkspaceLaunchOptions opts = NSWorkspaceLaunchWithoutAddingToRecents | NSWorkspaceLaunchWithoutActivation | NSWorkspaceLaunchAsync;
    NSURL *url = [NSURL fileURLWithPath:[self blackoutHelperPath]];
    [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:url]
                    withAppBundleIdentifier:nil
                                    options:opts
             additionalEventParamDescriptor:nil
                          launchIdentifiers:NULL];
}

- (void)terminateBlackout
{
    NSString *obj = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"BOApplicationShouldTerminate" object:obj];
}

- (void)checkBlackoutIsRunning
{
    if ([self isBlackoutRunning]) {
        [runningLabel setStringValue:NSLocalizedString(@"Blackout is running.", nil)];
        [launchIndicator stopAnimation:self];
        [startButton setTitle:NSLocalizedString(@"Stop Blackout", nil)];
        [startButton setAction:@selector(stopBlackout:)];
        [startButton setEnabled:YES];
    } else {
        [runningLabel setStringValue:NSLocalizedString(@"Blackout is stopped.", nil)];
        [launchIndicator stopAnimation:self];
        [startButton setTitle:NSLocalizedString(@"Start Blackout", nil)];
        [startButton setAction:@selector(startBlackout:)];
        [startButton setEnabled:YES];
    }
}

- (IBAction)addToLoginItems:(id)sender
{
    NSLog(@"Adding to Login items: %@", [sender state] == NSOnState ? @"Yes" : @"No");
}

@end
