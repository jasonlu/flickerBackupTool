//
//  FlickrPhotoSet.m
//  flickerBackupTool
//
//  Created by Jason Lu on 11/6/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//

#import "FlickrPhotoSet.h"

@implementation FlickrPhotoSet

@synthesize title = _title;
@synthesize count = _count;
@synthesize desc = _desc;
@synthesize coverUrl = _coverUrl;
@synthesize photosetSecret = _photosetSecret;
@synthesize photosetId = _photosetId;

- (id) init {
    self = [super init];
    _title = @"";
    _count = 0;
    _desc = @"";
    _coverUrl = @"";
    return self;
}

- (id) initWithPhotoSet: (NSDictionary *) set {
    self = [super init];
    self.title = [set valueForKeyPath:@"title._text"];
    self.count = [[set valueForKeyPath:@"photos"] intValue];
    self.coverUrl = [set valueForKeyPath:@"primary_photo_extras.url_m"];
    self.desc = [set valueForKeyPath:@"description._text"];
    self.photosetId = [set valueForKeyPath:@"id"];
    self.photosetSecret = [set valueForKeyPath:@"secret"];
    return self;
}

- (void) mysetDesc: (NSString *)desc {
    if(desc == nil) {
        _desc = @"";
    } else {
        _desc = @"OFF: ";
    }
    return;
}

- (NSString *) description {
    NSString *res;
    res = [NSString stringWithFormat:@"Title: %@,\rCount: %ld,\rDesc: %@,\rphotosetId: %@", _title, (long)_count, _desc, _photosetId ];
    return res;
}
@end
