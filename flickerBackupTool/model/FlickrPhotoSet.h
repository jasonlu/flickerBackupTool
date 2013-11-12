//
//  FlickrPhotoSet.h
//  flickerBackupTool
//
//  Created by Jason Lu on 11/6/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrPhotoSet : NSObject {
    
}


- (id) initWithPhotoSet: (NSDictionary *) set;

@property (strong) NSString *title;
@property NSInteger count;
@property (strong) NSString *desc;
@property (strong) NSString *coverUrl;
@property (strong) NSString *photosetId;
@property (strong) NSString *photosetSecret;


@end
