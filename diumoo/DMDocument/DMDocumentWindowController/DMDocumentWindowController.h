//
//  DMDocumentWindowController.h
//  documentTest
//
//  Created by Shanzi on 12-7-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DMDocumentWindowController : NSWindowController <NSWindowDelegate> {

    IBOutlet NSButton *revertButton;
    IBOutlet NSButton *albumCoverButton;
    IBOutlet NSTextField *songTitle;
    IBOutlet NSTextField *artist;

    NSString *albumTitle;
    NSString *aid;
    NSString *albumLocation;
}

- (id)init;

- (void)setupWindowForDocument:(NSDocument *)doc;

- (IBAction)playAlbum:(id)sender;

- (IBAction)openAlbumLocation:(id)sender;
@end
