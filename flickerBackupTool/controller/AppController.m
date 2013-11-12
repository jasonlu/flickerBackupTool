//
//  AppController.m
//  flickerBackupTool
//
//  Created by Jason Lu on 11/6/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//

#import "AppController.h"

@implementation AppController

@synthesize mainWindow, preferenceController;

-(IBAction)showPreferences:(id)sender{
    if(!self.preferenceController)
        self.preferenceController = [[PreferenceController alloc] init];
    //NSLog(@"pregerence ctrl: %@ ", self.preferenceController);
    [self.preferenceController showWindow:self];
}
- (id)init {
    self = [super init];
    //NSLog(@"app ctrl init");
    return self;
}


@end
