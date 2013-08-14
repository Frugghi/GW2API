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

#pragma mark - GW2Region -

#define GW2RegionName        @"name"
#define GW2RegionLabelCenter @"label_coord"
#define GW2RegionMaps        @"maps"

@implementation GW2Region

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        [self setID:[decoder decodeObjectForKey:@"ID"]];
        [self setName:[decoder decodeObjectForKey:GW2RegionName]];
        [self setLabelCenter:[decoder decodeCGPointForKey:GW2RegionLabelCenter]];
        [self setMaps:[decoder decodeObjectForKey:GW2RegionMaps]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.ID forKey:@"ID"];
    [coder encodeObject:self.name forKey:GW2RegionName];
    [coder encodeCGPoint:self.labelCenter forKey:GW2RegionLabelCenter];
    [coder encodeObject:self.maps forKey:GW2RegionMaps];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@ %@, labelCenter: %@>",
            NSStringFromClass([self class]), self.ID, self.name, NSStringFromCGPoint(self.labelCenter)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2Region class]]) {
		return [[self ID] isEqualToString:[(GW2Region *)object ID]] && [[self name] isEqualToString:[(GW2Region *)object name]];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

- (id)copyWithZone:(NSZone *)zone {
    GW2Region *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
		[copy setName:[self.name copyWithZone:zone]];
        [copy setLabelCenter:self.labelCenter];
        [copy setMaps:[self.maps copyWithZone:zone]];
    }
	
    return copy;
}

@end

#pragma mark - GW2RegionMap -

#define GW2RegionMapName     @"name"
#define GW2RegionMapMinLevel @"min_level"
#define GW2RegionMapMaxLevel @"max_level"
#define GW2RegionMapDefFloor @"default_floor"
#define GW2RegionMapMapRect  @"map_rect"
#define GW2RegionMapContRect @"continent_rect"
#define GW2RegionMapPOIs     @"points_of_interest"
#define GW2RegionMapTasks    @"tasks"
#define GW2RegionMapSkills   @"skill_challenges"
#define GW2RegionMapSectors  @"sectors"

@implementation GW2RegionMap

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@ %@, minLevel: %li, maxLevel: %li, defaultFloor: %li, mapRect: %@, continentRect: %@>",
            NSStringFromClass([self class]), self.ID, self.name, (long)self.minLevel, (long)self.maxLevel, (long)self.defaultFloor,
            NSStringFromCGRect(self.mapRect), NSStringFromCGRect(self.continentRect)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2RegionMap class]]) {
		return [[self ID] isEqualToString:[(GW2RegionMap *)object ID]] && [[self name] isEqualToString:[(GW2RegionMap *)object name]];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

@end

#pragma mark - GW2MapPOI -

#define GW2MapPOIID    @"poi_id"
#define GW2MapPOIName  @"name"
#define GW2MapPOIType  @"type"
#define GW2MapPOIFloor @"floor"
#define GW2MapPOICoord @"coord"

@interface GW2MapPOI ()

+ (GW2POIType)string2type:(NSString *)type;

@end

@implementation GW2MapPOI

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %li, name: %@, type: %@, floor: %li, coordinate: %@>",
            NSStringFromClass([self class]), (long)self.ID, self.name, [self typeDescription], (long)self.floor, NSStringFromCGPoint(self.coordinate)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2MapPOI class]]) {
		return [self ID] == [(GW2MapPOI *)object ID];
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
        return GW2POIUnkown;
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

#define GW2MapTaskID    @"task_id"
#define GW2MapTaskObj   @"objective"
#define GW2MapTaskLevel @"level"
#define GW2MapTaskCoord @"coord"

@implementation GW2MapTask

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %li, objective: %@, level: %li, coordinate: %@>",
            NSStringFromClass([self class]), (long)self.ID, self.objective, (long)self.level, NSStringFromCGPoint(self.coordinate)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2MapTask class]]) {
		return [self ID] == [(GW2MapTask *)object ID];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

@end

#pragma mark - GW2MapSkill -

#define GW2MapSkillCoord @"coord"

@implementation GW2MapSkill

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: coordinate: %@>",
            NSStringFromClass([self class]), NSStringFromCGPoint(self.coordinate)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2MapSkill class]]) {
		return CGPointEqualToPoint([self coordinate], [(GW2MapSkill *)object coordinate]);
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

@end

#pragma mark - GW2MapSector -

#define GW2MapSectorID    @"sector_id"
#define GW2MapSectorName  @"name"
#define GW2MapSectorLevel @"level"
#define GW2MapSectorCoord @"coord"

@implementation GW2MapSector

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %li, name: %@, level: %li, coordinate: %@>",
            NSStringFromClass([self class]), (long)self.ID, self.name, (long)self.level, NSStringFromCGPoint(self.coordinate)];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2MapSector class]]) {
		return [self ID] == [(GW2MapSector *)object ID];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

@end

#pragma mark - GW2MapFloor -

#define GW2MapFloorContinent   @"continent_id"
#define GW2MapFloorFloor       @"floor"
#define GW2MapFloorTextureDims @"texture_dims"
#define GW2MapFloorRegions     @"regions"

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
                                                      GW2MapFloorContinent: components[0],
                                                      GW2MapFloorFloor: components[1]}];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    GW2MapFloor *obj = [[[self class] alloc] init];
    [obj setTextureDimensions:CGSizeFromArray([json objectForKey:GW2MapFloorTextureDims])];
    
    for (NSString *param in [[requestURL query] componentsSeparatedByString:@"&"]) {
        NSArray *components = [param componentsSeparatedByString:@"="];
        if ([components count] < 2) {
            continue;
        } else if ([components[0] isEqualToString:GW2MapFloorContinent]) {
            [obj setContinentID:components[1]];
        } else if ([components[0] isEqualToString:GW2MapFloorFloor]) {
            [obj setFloor:[components[1] integerValue]];
        }
    }
    
    NSMutableArray *regions = [[NSMutableArray alloc] init];
    NSDictionary *regionsDict = json[GW2MapFloorRegions];
    for (NSString *regionID in regionsDict) {
        NSDictionary *regionDict = regionsDict[regionID];
        GW2Region *region = [[GW2Region alloc] init];
        [region setID:regionID];
        [region setName:regionDict[GW2RegionName]];
        [region setLabelCenter:CGPointFromArray(regionDict[GW2RegionLabelCenter])];
        
        NSMutableArray *maps = [[NSMutableArray alloc] init];
        NSDictionary *mapsDict = regionDict[GW2RegionMaps];
        for (NSString *mapID in mapsDict) {
            NSDictionary *mapDict = mapsDict[mapID];
            GW2RegionMap *regionMap = [[GW2RegionMap alloc] init];
            [regionMap setID:mapID];
            [regionMap setName:mapDict[GW2RegionMapName]];
            [regionMap setMinLevel:[mapDict[GW2RegionMapMinLevel] integerValue]];
            [regionMap setMaxLevel:[mapDict[GW2RegionMapMaxLevel] integerValue]];
            [regionMap setDefaultFloor:[mapDict[GW2RegionMapDefFloor] integerValue]];
            [regionMap setMapRect:CGRectFromArray(mapDict[GW2RegionMapMapRect])];
            [regionMap setContinentRect:CGRectFromArray(mapDict[GW2RegionMapContRect])];
            
            NSMutableArray *POIs = [[NSMutableArray alloc] init];
            for (NSDictionary *POIDict in mapDict[GW2RegionMapPOIs]) {
                GW2MapPOI *POI = [[GW2MapPOI alloc] init];
                [POI setID:[POIDict[GW2MapPOIID] integerValue]];
                [POI setName:POIDict[GW2MapPOIName]];
                [POI setType:[GW2MapPOI string2type:POIDict[GW2MapPOIType]]];
                [POI setFloor:[POIDict[GW2MapPOIFloor] integerValue]];
                [POI setCoordinate:CGPointFromArray(POIDict[GW2MapPOICoord])];
                [POIs addObject:POI];
            }
            [regionMap setPOIs:[POIs copy]];
            
            NSMutableArray *tasks = [[NSMutableArray alloc] init];
            for (NSDictionary *taskDict in mapDict[GW2RegionMapTasks]) {
                GW2MapTask *task = [[GW2MapTask alloc] init];
                [task setID:[taskDict[GW2MapTaskID] integerValue]];
                [task setObjective:taskDict[GW2MapTaskObj]];
                [task setLevel:[taskDict[GW2MapTaskLevel] integerValue]];
                [task setCoordinate:CGPointFromArray(taskDict[GW2MapTaskCoord])];
                [tasks addObject:task];
            }
            [regionMap setTasks:[tasks copy]];
            
            NSMutableArray *skills = [[NSMutableArray alloc] init];
            for (NSDictionary *skillDict in mapDict[GW2RegionMapSkills]) {
                GW2MapSkill *skill = [[GW2MapSkill alloc] init];
                [skill setCoordinate:CGPointFromArray(skillDict[GW2MapSkillCoord])];
                [skills addObject:skill];
            }
            [regionMap setSkillChallenges:[skills copy]];
            
            NSMutableArray *sectors = [[NSMutableArray alloc] init];
            for (NSDictionary *sectorDict in mapDict[GW2RegionMapSectors]) {
                GW2MapSector *sector = [[GW2MapSector alloc] init];
                [sector setID:[sectorDict[GW2MapSectorID] integerValue]];
                [sector setName:sectorDict[GW2MapSectorName]];
                [sector setLevel:[sectorDict[GW2MapSectorLevel] integerValue]];
                [sector setCoordinate:CGPointFromArray(sectorDict[GW2MapSectorCoord])];
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
