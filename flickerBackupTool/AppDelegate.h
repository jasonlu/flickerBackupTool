//
//  AppDelegate.h
//  flickerBackupTool
//
//  Created by Jason Lu on 11/3/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FlickerController.h"
//#import <ObjectiveFlickr/ObjectiveFlickr.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSString *kCallbackURLBaseString;
    OFFlickrAPIRequest *_flickrRequest;
    OFFlickrAPIContext *_flickrContext;
    IBOutlet FlickerController *flickrController;
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
