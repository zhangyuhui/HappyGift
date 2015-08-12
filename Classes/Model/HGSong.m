//
//  HGSong.m
//  HappyGift
//
//  Created by Zhang Yuhui on 12-7-9.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGSong.h"

NSString* const kSongName = @"song_name";
NSString* const kSongArtist = @"song_artist";
NSString* const kSongLink = @"song_link";

@implementation HGSong
@synthesize name;
@synthesize artist;
@synthesize link;

- (void)dealloc {
    [name release];
    [artist release];
    [link release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        name = [[coder decodeObjectForKey:kSongName] retain];
        artist = [[coder decodeObjectForKey:kSongArtist] retain];
        link = [[coder decodeObjectForKey:kSongLink] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:name forKey:kSongName]; 
    [encoder encodeObject:artist forKey:kSongArtist]; 
    [encoder encodeObject:link forKey:kSongLink];
}

@end