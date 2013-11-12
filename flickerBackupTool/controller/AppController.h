//
//  AppController.h
//  flickerBackupTool
//
//  Created by Jason Lu on 11/6/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreferenceController.h"

@interface AppController : NSObject {
    IBOutlet NSArrayController *arrayController;
}

@property (assign) IBOutlet NSWindow *mainWindow;
@property (strong) PreferenceController *preferenceController;
-(IBAction)showPreferences:(id)sender;

@end
