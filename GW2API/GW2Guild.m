//
//  GW2Guild.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 14/08/13.
//  Copyright (c) 2013 Tommaso Madonia. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "GW2Guild.h"
#import "GW2Protected.h"

@implementation GW2Guild

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@, name: %@ tag: %@, emblem: %@>",
            NSStringFromClass([self class]), self.ID, self.name, self.tag, self.emblem];
}

#pragma mark - GW2Caching protocol

- (NSTimeInterval)timeout {
    return 60 * 60 * 24; // 1 day
}

- (NSString *)cacheKey {
    return [NSString stringWithFormat:@"gw2_guild_%@", self.ID];
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 guildByID:[self ID] error:error];
    };
}

#pragma mark - Protected

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    BOOL isGuildID = [[NSPredicate predicateWithFormat:@"SELF MATCHES '[0-9A-F]{8}(-[0-9A-F]{4}){3}-[0-9A-F]{12}'"] evaluateWithObject:ID];
    NSString *key = (isGuildID ? @"guild_id" : @"guild_name");
        
    return [api requestURL:@"guild_details.json" params:@{key: ID}];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    GW2Guild *obj = [[[self class] alloc] initWithID:json[@"guild_id"]];
    [obj setName:json[@"guild_name"]];
    [obj setTag:json[@"tag"]];
        
    NSDictionary *emblemDict = json[@"emblem"];
    GW2Emblem *emblem = [[GW2Emblem alloc] init];
    [emblem setBackgroundID:emblemDict[@"background_id"]];
    [emblem setForegroundID:emblemDict[@"foreground_id"]];
    [emblem setFlags:emblemDict[@"flags"]];
    [emblem setBackgroundColorID:emblemDict[@"background_color_id"]];
    [emblem setForegroundPrimaryColorID:emblemDict[@"foreground_primary_color_id"]];
    [emblem setForegroundSecondaryColorID:emblemDict[@"foreground_secondary_color_id"]];
        
    return obj;
}

+ (NSArray *)notificationNames {
    return @[GW2PveNotification];
}

@end

#pragma mark - GW2Emblem -

@implementation GW2Emblem

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: backgroundID: %@, foregroundID: %@, backgroundColorID: %@, foregroundPrimaryColorID: %@, foregroundSecondaryColorID: %@, flags: %@>",
            NSStringFromClass([self class]), self.backgroundID, self.foregroundID, self.backgroundColorID, self.foregroundPrimaryColorID, self.foregroundSecondaryColorID, self.flags];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2Emblem class]]) {
		return [self hash] == [object hash];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

@end
