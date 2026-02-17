//
//  DMDocumentWindowController.m
//  documentTest
//
//  Created by Shanzi on 12-7-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DMDocumentWindowController.h"
#import "DMDocument.h"
#import "NSImage+AsyncLoadImage.h"

@implementation DMDocumentWindowController

- (id)init {
    self = [super initWithWindowNibName:@"DMDocumentWindow"];
    if (self) {
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self setupWindowForDocument:self.document];
    if ([self.document isInViewingMode]) {
        [revertButton setEnabled:NO];
    }
}

- (void)windowDidExpose:(NSNotification *)notification {
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)setupWindowForDocument:(NSDocument *)doc {

    NSDictionary *dict = [doc performSelector:@selector(baseSongInfo)];

    NSString *picture_url = [dict valueForKey:@"picture"];
    [NSImage AsyncLoadImageWithURLString:picture_url andCallBackBlock:^(NSImage *image) {
        if (image) {
            albumCoverButton.image = image;
        } else {
            albumCoverButton.image = [NSImage imageNamed:@"albumfail"];
        }
    }];

    artist.stringValue = [dict valueForKey:@"artist"];
    songTitle.stringValue = [dict valueForKey:@"title"];

    albumTitle = [[dict valueForKey:@"albumtitle"] copy];
    aid = [[dict valueForKey:@"aid"] copy];
    albumLocation = [[dict valueForKey:@"url"] copy];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {

    return [NSString stringWithFormat:NSLocalizedString(@"ALBUM_DOCUMENT_TITLE", @"专辑:《%@》"), albumTitle];
}

- (NSSize)window:(NSWindow *)w willResizeForVersionBrowserWithMaxPreferredSize:(NSSize)maxPreferredFrameSize maxAllowedSize:(NSSize)maxAllowedFrameSize {
    NSSize maxWindowSize = self.window.maxSize;
    if (maxAllowedFrameSize.width > (maxWindowSize.width * 2) && maxAllowedFrameSize.height > (maxWindowSize.height * 2)) {
        return self.window.maxSize;
    }
    return self.window.minSize;
}

- (void)windowWillEnterVersionBrowser:(NSNotification *)notification {
    [revertButton setEnabled:NO];
}

- (void)windowDidExitVersionBrowser:(NSNotification *)notification {
    [revertButton setEnabled:YES];
}

- (void)playAlbum:(id)sender {
    NSString *type = @"album";
    NSString *typestring = @"专辑";
    NSString *artisttitle = [@"艺术家 : " stringByAppendingString:[artist stringValue]];
    NSDictionary *userinfo = @{@"aid": aid,
            @"title": albumTitle,
            @"artist": artisttitle,
            @"type": type,
            @"typestring": typestring,
            @"album_location": albumLocation};

    [[NSNotificationCenter defaultCenter] postNotificationName:@"playspecial"
                                                        object:self
                                                      userInfo:userinfo];
}

- (void)openAlbumLocation:(id)sender {
    NSURL *albumurl = [NSURL URLWithString:albumLocation];
    [[NSWorkspace sharedWorkspace] openURL:albumurl];
}

@end
