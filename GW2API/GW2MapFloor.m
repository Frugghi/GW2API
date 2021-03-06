//
//  GW2MapFloor.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 11/08/13.
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

#import "GW2MapFloor.h"
#import "GW2Protected.h"

@interface GW2MapPOI ()

+ (GW2POIType)string2type:(NSString *)type;

@end

#pragma mark - GW2MapFloor -

@implementation GW2MapFloor

- (void)setID:(NSString *)ID {
    NSArray *components = [ID componentsSeparatedByString:@"_"];
    _continentID = components[0];
    _floor = [components[1] integerValue];
}

- (NSString *)ID {
    return [NSString stringWithFormat:@"%@_%li", self.continentID, (long)self.floor];
}

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@-%li, textureDimensions: %@>",
            NSStringFromClass([self class]), self.continentID, (long)self.floor, NSStringFromCGSize(self.textureDimensions)];
}

#pragma mark - GW2Caching protocol

- (NSString *)cacheKey {
    return @"gw2_mapfloor";
}

- (NSTimeInterval)timeout {
    return 60 * 60 * 24 * 28; // 28 days
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 mapFloorByID:[self ID] error:error];
    };
}

#pragma mark - Protected


+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    NSArray *components = [ID componentsSeparatedByString:@"_"];
    
    return [api requestURL:@"map_floor.json" params:@{@"lang": [api langCode],
            @"continent_id": components[0],
            @"floor": components[1]}];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    GW2MapFloor *obj = [[[self class] alloc] init];
    [obj setTextureDimensions:CGSizeFromArray(json[@"texture_dims"])];
    
    for (NSString *param in [[requestURL query] componentsSeparatedByString:@"&"]) {
        NSArray *components = [param componentsSeparatedByString:@"="];
        if ([components count] < 2) {
            continue;
        } else if ([components[0] isEqualToString:@"continent_id"]) {
            [obj setContinentID:components[1]];
        } else if ([components[0] isEqualToString:@"floor"]) {
            [obj setFloor:[components[1] integerValue]];
        }
    }
    
    NSMutableArray *regions = [[NSMutableArray alloc] init];
    NSDictionary *regionsDict = json[@"regions"];
    for (NSString *regionID in regionsDict) {
        NSDictionary *regionDict = regionsDict[regionID];
        GW2Region *region = [[GW2Region alloc] init];
        [region setID:regionID];
        [region setName:regionDict[@"name"]];
        [region setLabelCenter:CGPointFromArray(regionDict[@"label_coord"])];
        
        NSMutableArray *maps = [[NSMutableArray alloc] init];
        NSDictionary *mapsDict = regionDict[@"maps"];
        for (NSString *mapID in mapsDict) {
            NSDictionary *mapDict = mapsDict[mapID];
            GW2RegionMap *regionMap = [[GW2RegionMap alloc] init];
            [regionMap setID:mapID];
            [regionMap setName:mapDict[@"name"]];
            [regionMap setMinLevel:[mapDict[@"min_level"] integerValue]];
            [regionMap setMaxLevel:[mapDict[@"max_level"] integerValue]];
            [regionMap setDefaultFloor:[mapDict[@"default_floor"] integerValue]];
            [regionMap setMapRect:CGRectFromArray(mapDict[@"map_rect"])];
            [regionMap setContinentRect:CGRectFromArray(mapDict[@"continent_rect"])];
            
            NSMutableArray *POIs = [[NSMutableArray alloc] init];
            for (NSDictionary *POIDict in mapDict[@"points_of_interest"]) {
                GW2MapPOI *POI = [[GW2MapPOI alloc] init];
                [POI setID:[POIDict[@"poi_id"] integerValue]];
                [POI setName:POIDict[@"name"]];
                [POI setType:[GW2MapPOI string2type:POIDict[@"type"]]];
                [POI setFloor:[POIDict[@"floor"] integerValue]];
                [POI setCoordinate:CGPointFromArray(POIDict[@"coord"])];
                [POIs addObject:POI];
            }
            [regionMap setPOIs:[POIs copy]];
            
            NSMutableArray *tasks = [[NSMutableArray alloc] init];
            for (NSDictionary *taskDict in mapDict[@"tasks"]) {
                GW2MapTask *task = [[GW2MapTask alloc] init];
                [task setID:[taskDict[@"task_id"] integerValue]];
                [task setObjective:taskDict[@"objective"]];
                [task setLevel:[taskDict[@"level"] integerValue]];
                [task setCoordinate:CGPointFromArray(taskDict[@"coord"])];
                [tasks addObject:task];
            }
            [regionMap setTasks:[tasks copy]];
            
            NSMutableArray *skills = [[NSMutableArray alloc] init];
            for (NSDictionary *skillDict in mapDict[@"skill_challenges"]) {
                GW2MapSkill *skill = [[GW2MapSkill alloc] init];
                [skill setCoordinate:CGPointFromArray(skillDict[@"coord"])];
                [skills addObject:skill];
            }
            [regionMap setSkillChallenges:[skills copy]];
            
            NSMutableArray *sectors = [[NSMutableArray alloc] init];
            for (NSDictionary *sectorDict in mapDict[@"sectors"]) {
                GW2MapSector *sector = [[GW2MapSector alloc] init];
                [sector setID:[sectorDict[@"sector_id"] integerValue]];
                [sector setName:sectorDict[@"name"]];
                [sector setLevel:[sectorDict[@"level"] integerValue]];
                [sector setCoordinate:CGPointFromArray(sectorDict[@"coord"])];
                [sectors addObject:sector];
            }
            [regionMap setSectors:[sectors copy]];
            
            [maps addObject:regionMap];
        }
        [region setMaps:[maps copy]];
        
        [regions addObject:region];
    }
    [obj setRegions:[regions copy]];
    
    return obj;
}

+ (NSArray *)notificationNames {
    return @[GW2PveNotification, GW2WvWNotification, GW2MapNotification];
}

@end

#pragma mark - GW2Region -

@implementation GW2Region

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@ %@, labelCenter: %@>",
            NSStringFromClass([self class]), self.ID, self.name, NSStringFromCGPoint(self.labelCenter)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2Region class]]) {
		return [self hash] == [object hash];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

@end

#pragma mark - GW2RegionMap -

@implementation GW2RegionMap

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@ %@, minLevel: %li, maxLevel: %li, defaultFloor: %li, mapRect: %@, continentRect: %@>",
            NSStringFromClass([self class]), self.ID, self.name, (long)self.minLevel, (long)self.maxLevel, (long)self.defaultFloor,
            NSStringFromCGRect(self.mapRect), NSStringFromCGRect(self.continentRect)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2RegionMap class]]) {
		return [self hash] == [object hash];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

@end

#pragma mark - GW2MapPOI -

@implementation GW2MapPOI

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %li, name: %@, type: %@, floor: %li, coordinate: %@>",
            NSStringFromClass([self class]), (long)self.ID, self.name, [self typeDescription], (long)self.floor, NSStringFromCGPoint(self.coordinate)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2MapPOI class]]) {
		return [self hash] == [object hash];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

+ (GW2POIType)string2type:(NSString *)type {
    if ([type compare:@"landmark" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return GW2POILandmark;
    } else if ([type compare:@"waypoint" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return GW2POIWaypoint;
    } else if ([type compare:@"vista" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return GW2POIVista;
    } else {
        return GW2POIUnknown;
    }
}

- (NSString *)typeDescription {
    switch (self.type) {
        case GW2POILandmark: return @"Landmark";
        case GW2POIWaypoint: return @"Waypoint";
        case GW2POIVista:    return @"Vista";
        default:             return @"Unknown";
    }
}

@end

#pragma mark - GW2MapTask -

@implementation GW2MapTask

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %li, objective: %@, level: %li, coordinate: %@>",
            NSStringFromClass([self class]), (long)self.ID, self.objective, (long)self.level, NSStringFromCGPoint(self.coordinate)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2MapTask class]]) {
		return [self hash] == [object hash];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

@end

#pragma mark - GW2MapSkill -

@implementation GW2MapSkill

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: coordinate: %@>",
            NSStringFromClass([self class]), NSStringFromCGPoint(self.coordinate)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2MapSkill class]]) {
		return [self hash] == [object hash];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

@end

#pragma mark - GW2MapSector -

@implementation GW2MapSector

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %li, name: %@, level: %li, coordinate: %@>",
            NSStringFromClass([self class]), (long)self.ID, self.name, (long)self.level, NSStringFromCGPoint(self.coordinate)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2MapSector class]]) {
		return [self hash] == [object hash];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

@end
