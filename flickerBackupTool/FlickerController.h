//
//  FlickerController.h
//  flickerBackupTool
//
//  Created by Jason Lu on 11/3/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjectiveFlickr/ObjectiveFlickr.h>


@interface FlickerController : NSObject <OFFlickrAPIRequestDelegate>
{
    OFFlickrAPIRequest *request, *_flickrRequest;
    OFFlickrAPIContext *context, *_flickrContext;
    NSString *_frob;

}
extern NSString *const apiKey;
extern NSString *const apiSecret;
#define OBJECTIVE_FLICKR_SAMPLE_API_KEY             @"42b8daa9c251314e3737efd371dc7a4d"
#define OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET   @"0e702fcbf0e5224b"

- (IBAction)testLoginAction:(id)sender;

@end