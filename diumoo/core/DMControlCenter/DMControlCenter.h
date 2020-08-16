//
//  DMControlCenter.h
//  diumoo-core
//
//  Created by Shanzi on 12-6-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <IOKit/pwr_mgt/IOPMLib.h>

#import "diumoo-Swift.h"
#import "DMPanelWindowController.h"
#import "DMPlayRecordHandler.h"
#import "NSDictionary+UrlEncoding.h"
#import "DMService.h"
#import "DMSearchPanelController.h"


typedef enum {
    PAUSE_PASS = 0,
    PAUSE_PAUSE,
    PAUSE_SKIP,
    PAUSE_NEW_PLAYLIST,
    PAUSE_SPECIAL,
    PAUSE_EXIT,
} PAUSE_OPERATION_TYPE;

@interface DMControlCenter : NSObject <DMPlayableItemDelegate, DMPlaylistFetcherDelegate, DMPanelWindowDelegate, DMPlayRecordHandlerDelegate>

@property(strong, nonatomic) DMPlayableItem *playingItem;
@property(strong, nonatomic) DMPlayableItem *waitingItem;
@property(strong, nonatomic) DMPanelWindowController *diumooPanel;
@property(strong, nonatomic) DMNotificationCenter *notificationCenter;
@property(strong, nonatomic) DMPlayRecordHandler *recordHandler;
@property(strong, nonatomic) DMPlaylistFetcher *fetcher;
@property(assign, nonatomic) BOOL canPlaySpecial;
@property(copy, nonatomic) NSString *channel;

//self methods
- (void)fireToPlayDefault;

- (void)stopForExit;

- (void)qualityChanged;

- (void)volumeChange:(float)volume;

//methods in DMPlayableItemDelegate
- (void)playableItem:(DMPlayableItem *)item logStateChanged:(NSInteger)logStateChanged;
@end
