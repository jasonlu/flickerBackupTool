//
//  FlickerController.h
//  flickerBackupTool
//
//  Created by Jason Lu on 11/3/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//
#define OBJECTIVE_FLICKR_SAMPLE_API_KEY             @"42b8daa9c251314e3737efd371dc7a4d"
#define OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET   @"0e702fcbf0e5224b"
#define OBJECTIVE_FLICKR_CALLBACK_BASE              @"flickrbktl://callback"
#define OBJECTIVE_FLICKR_AUTH_TYPE                  @"OAuth"

#import <Foundation/Foundation.h>
#import <ObjectiveFlickr/ObjectiveFlickr.h>
#import "FlickrSession.h"
#import "FlickrPhotoSet.h"


@interface FlickerController : NSObject <OFFlickrAPIRequestDelegate>
{
    NSString *_frob;
    IBOutlet NSPanel *authPromtSheet;
    IBOutlet NSWindow *_window;
    IBOutlet NSProgressIndicator *_authProgress;
    IBOutlet NSCollectionView *_collection;
    IBOutlet NSArrayController *arrayController;
}
// @property will help to generate getter and setter for us.
@property (strong, nonatomic) OFFlickrAPIRequest *flickrRequest;
@property (strong, nonatomic) OFFlickrAPIContext *flickrContext;

@property (strong) NSMutableArray *photosets;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)startAuth:(id)sender;
- (IBAction)checkAuth:(id)sender;

@end