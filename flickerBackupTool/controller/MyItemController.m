//
//  CollectionViewController.m
//  flickerBackupTool
//
//  Created by Jason Lu on 11/11/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//

#import "MyItemController.h"

@implementation MyItemController


-(id)copyWithZone:(NSZone *)zone {
    /*This might not be the best place for LoadFromNib:. If it was place in setRepresentObject: we could load different views depending on the class of the representedObject.*/
    id result = [super copyWithZone:zone];
    NSLog(@"Copy with zone called, view: %@", [result view]);
    //we can configure other aspects of result too
    //[result setPopupMenuDelegate: [self popupMenuDelegate];
//    [result setDelegate:self];
    return result;
}
- (void)mouseDown:(NSEvent *)theEvent  {
    
    NSLog(@"colelciton view mouse clicked, %@", theEvent);

}

- (id)init {
    self = [super init];
    NSLog(@"init called");
    return self;
}

- (void)setSelected:(BOOL)flag {
    
}

- (void) awakeFromNib {
    //NSLog(@"View: %@", [self view]);

}

/*

- (void) setupBorder {
    NSBox *view = self;
    [view setTitlePosition:NSNoTitle];
    [view setBoxType:NSBoxCustom];
    [view setCornerRadius:8.0];
    [view setBorderType:NSLineBorder];
}

- (void) drawBorder:(BOOL) flag {
    NSBox *view = self;
    NSColor *color;
    NSColor *lineColor;
    
    if (flag) {
        color       = [NSColor selectedControlColor];
        lineColor   = [NSColor blackColor];
    } else {
        color       = [NSColor controlBackgroundColor];
        lineColor   = [NSColor controlBackgroundColor];
    }
    
    [view setBorderColor:lineColor];
    [view setFillColor:color];
}
 */
@end
