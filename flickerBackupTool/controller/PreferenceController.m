//
//  PreferenceController.m
//  flickerBackupTool
//
//  Created by Jason Lu on 11/6/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//




#import "PreferenceController.h"

@implementation PreferenceController

-(id)init{
    if (![super initWithWindowNibName:@"Preferences"])
        return nil;
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

@end