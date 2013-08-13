//
//  GW2Map.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 05/07/13.
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

#import "GW2Map.h"
#import "GW2Protected.h"

@implementation GW2Map

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self setName:[decoder decodeObjectForKey:@"name"]];
        [self setMinLevel:[decoder decodeIntegerForKey:@"minLevel"]];
        [self setMaxLevel:[decoder decodeIntegerForKey:@"maxLevel"]];
        [self setDefaultFloor:[decoder decodeObjectForKey:@"defaultFloor"]];
        [self setFloors:[decoder decodeObjectForKey:@"floors"]];
        [self setRegionID:[decoder decodeObjectForKey:@"region_id"]];
        [self setRegionName:[decoder decodeObjectForKey:@"region_name"]];
        [self setContinentID:[decoder decodeObjectForKey:@"continent_id"]];
        [self setContinentName:[decoder decodeObjectForKey:@"continent_name"]];
        [self setMapRect:[decoder decodeCGRectForKey:@"mapRect"]];
        [self setContinentRect:[decoder decodeCGRectForKey:@"continentRect"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeInteger:self.minLevel forKey:@"minLevel"];
    [coder encodeInteger:self.maxLevel forKey:@"maxLevel"];
    [coder encodeObject:self.defaultFloor forKey:@"defaultFloor"];
    [coder encodeObject:self.floors forKey:@"floors"];
    [coder encodeObject:self.regionID forKey:@"region_id"];
    [coder encodeObject:self.regionName forKey:@"region_name"];
    [coder encodeObject:self.continentID forKey:@"continent_id"];
    [coder encodeObject:self.continentName forKey:@"continent_name"];
    [coder encodeCGRect:self.mapRect forKey:@"mapRect"];
    [coder encodeCGRect:self.continentRect forKey:@"continentRect"];
}

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@, name: %@, minLevel: %i, maxLevel: %i, defaultFloor: %i, region: %@, continent: %@, mapRect: %@, continentRect: %@>",
            NSStringFromClass([self class]), self.ID, self.name, self.minLevel, self.maxLevel, [self.defaultFloor integerValue], self.regionName, self.continentName, NSStringFromCGRect(self.mapRect), NSStringFromCGRect(self.continentRect)];
}

#pragma mark - GW2Caching protocol

- (NSString *)cacheKey {
    return @"gw2_maps";
}

- (NSTimeInterval)timeout {
    return 60 * 60 * 24 * 28; // 28 days
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 mapByID:[self ID] error:error];
    };
}

#pragma mark - Protected

- (void)copyObject:(GW2Object *)object withZone:(NSZone *)zone {
    [super copyObject:object withZone:zone];
    if ([object isKindOfClass:[GW2Map class]]) {
        GW2Map *map = (GW2Map *)object;
        [self setName:[map.name copyWithZone:zone]];
        [self setMinLevel:map.minLevel];
        [self setMaxLevel:map.maxLevel];
        [self setDefaultFloor:[map.defaultFloor copyWithZone:zone]];
        [self setFloors:[map.floors copyWithZone:zone]];
        [self setRegionID:[map.regionID copyWithZone:zone]];
        [self setRegionName:[map.regionName copyWithZone:zone]];
        [self setContinentID:[map.continentID copyWithZone:zone]];
        [self setContinentName:[map.continentName copyWithZone:zone]];
        [self setMapRect:map.mapRect];
        [self setContinentRect:map.continentRect];
    }
}

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    NSDictionary *params;
    if (ID) {
        params = @{@"lang": [api langCode], @"map_id": ID};
    } else {
        params = @{@"lang": [api langCode]};
    }
    
    return [api requestURL:@"maps.json" params:params];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    NSDictionary *maps = [json objectForKey:@"maps"];
    NSDate *now = [NSDate date];
    GW2Array *gw2Array = [[GW2Array alloc] init];
    for (NSString *mapID in [maps allKeys]) {
        NSDictionary *map = [maps objectForKey:mapID];
        GW2Map *obj = [[[self class] alloc] initWithID:mapID];
        [obj setName:[map objectForKey:@"map_name"]];
        [obj setMinLevel:[[map objectForKey:@"min_level"] integerValue]];
        [obj setMaxLevel:[[map objectForKey:@"max_level"] integerValue]];
        [obj setDefaultFloor:[map objectForKey:@"default_floor"]];
        [obj setFloors:[map objectForKey:@"floors"]];
        [obj setRegionID:[[map objectForKey:@"region_id"] stringValue]];
        [obj setRegionName:[map objectForKey:@"region_name"]];
        [obj setContinentID:[[map objectForKey:@"continent_id"] stringValue]];
        [obj setContinentName:[map objectForKey:@"continent_name"]];
        NSArray *mapRect = [map objectForKey:@"map_rect"];
        [obj setMapRect:CGRectMake([mapRect[0][0] integerValue], [mapRect[0][1] integerValue],
                                   [mapRect[1][0] integerValue], [mapRect[1][1] integerValue])];
        NSArray *continentRect = [map objectForKey:@"continent_rect"];
        [obj setContinentRect:CGRectMake([continentRect[0][0] integerValue], [continentRect[0][1] integerValue],
                                         [continentRect[1][0] integerValue], [continentRect[1][1] integerValue])];
        [obj setLastUpdate:now];
        [gw2Array addObject:obj];
    }
    
    [gw2Array setLastUpdate:now];
    [gw2Array setTimeout:[[gw2Array lastObject] timeout]];
    [gw2Array setCacheKey:[[gw2Array lastObject] cacheKey]];
    
    return gw2Array;
}

+ (NSArray *)notificationNames {
    return @[GW2PveNotification, GW2WvWNotification, GW2MapNotification];
}

@end
