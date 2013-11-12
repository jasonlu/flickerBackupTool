//
//  FlickrSession.h
//  flickerBackupTool
//
//  Created by Jason Lu on 11/7/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrSession : NSObject {
    
}

@property (assign) SEL complete;
@property (assign) SEL error;
@property (assign) id delegate;

@end
