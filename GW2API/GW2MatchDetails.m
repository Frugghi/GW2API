//
//  GW2MatchDetail.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 21/05/13.
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

#import "GW2MatchDetails.h"
#import "GW2Protected.h"

@implementation GW2MatchDetails

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self setRedScore:[[decoder decodeObjectForKey:@"redscore"] integerValue]];
        [self setBlueScore:[[decoder decodeObjectForKey:@"bluescore"] integerValue]];
        [self setGreenScore:[[decoder decodeObjectForKey:@"greenscore"] integerValue]];
        [self setMaps:[decoder decodeObjectForKey:@"maps"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(self.redScore) forKey:@"redscore"];
    [coder encodeObject:@(self.blueScore) forKey:@"bluescore"];
    [coder encodeObject:@(self.greenScore) forKey:@"greenscore"];
    [coder encodeObject:self.maps forKey:@"maps"];
}

#pragma mark - Properties

- (GW2RegionServer)region {
    @try {
        switch ([[[self ID] substringToIndex:1] intValue]) {
            case 1: return GW2RegionNorthAmerica;
            case 2: return GW2RegionEurope;
            default: return GW2RegionUnknown;
        }
    }
    @catch (NSException *exception) {
        return GW2RegionUnknown;
    }
}

- (NSInteger)tier {
    return [[[[self ID] componentsSeparatedByString:@"-"] lastObject] integerValue];
}

- (GW2WvWMap *)map:(GW2WvWMapType)mapType {
    for (GW2WvWMap *map in self.maps) {
        if ([map type] == mapType) {
            return map;
        }
    }
    
    return nil;
}

- (NSInteger)redPotentialPoints {
    NSInteger potentialPoints = 0;
    for (GW2WvWMap *map in _maps) {
        potentialPoints += [map redPotentialPoints];
    }
    
    return potentialPoints;
}

- (NSInteger)bluePotentialPoints {
    NSInteger potentialPoints = 0;
    for (GW2WvWMap *map in _maps) {
        potentialPoints += [map bluePotentialPoints];
    }
    
    return potentialPoints;
}

- (NSInteger)greenPotentialPoints {
    NSInteger potentialPoints = 0;
    for (GW2WvWMap *map in _maps) {
        potentialPoints += [map greenPotentialPoints];
    }
    
    return potentialPoints;
}

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"[%@, %@ Tier %li] R:%li B:%li G:%li", self.ID, [GW2API regionName:self.region], (long)self.tier, (long)self.redScore, (long)self.blueScore, (long)self.greenScore];
}

#pragma mark - GW2Caching protocol

- (NSTimeInterval)timeout {
    return 30; // 30 sec
}

- (NSString *)cacheKey {
    return [NSString stringWithFormat:@"gw2_wvwmatchdetails_%@", self.ID];
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 matchDetailsByID:[self ID] error:error];
    };
}

#pragma mark - Protected

- (void)copyObject:(GW2Object *)object withZone:(NSZone *)zone {
    [super copyObject:object withZone:zone];
    if ([object isKindOfClass:[GW2MatchDetails class]]) {
        GW2MatchDetails *matchDetails = (GW2MatchDetails *)object;
        [self setRedScore:matchDetails.redScore];
        [self setBlueScore:matchDetails.blueScore];
        [self setGreenScore:matchDetails.greenScore];
        [self setMaps:[matchDetails.maps copyWithZone:zone]];
    }
}

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return [api requestURL:@"wvw/match_details.json" params:@{@"match_id": ID}];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    GW2MatchDetails *obj = [[[self class] alloc] initWithID:[json objectForKey:@"match_id"]];
    [obj setLastUpdate:[NSDate date]];
    
    NSArray *scores = [json objectForKey:@"scores"];
    [obj setRedScore:[[scores objectAtIndex:0] integerValue]];
    [obj setBlueScore:[[scores objectAtIndex:1] integerValue]];
    [obj setGreenScore:[[scores objectAtIndex:2] integerValue]];
    
    NSMutableSet *maps = [[NSMutableSet alloc] initWithCapacity:4];
    for (NSDictionary *map in [json objectForKey:@"maps"]) {
        GW2WvWMap *currentMap = [[GW2WvWMap alloc] init];
        
        NSString *mapType = [[map objectForKey:@"type"] lowercaseString];
        if ([mapType isEqualToString:@"redhome"]) {
            [currentMap setType:GW2WvWMapRed];
        } else if ([mapType isEqualToString:@"bluehome"]) {
            [currentMap setType:GW2WvWMapBlue];
        } else if ([mapType isEqualToString:@"greenhome"]) {
            [currentMap setType:GW2WvWMapGreen];
        } else if ([mapType isEqualToString:@"center"]) {
            [currentMap setType:GW2WvWMapCenter];
        } else {
            [currentMap setType:GW2WvWMapUnknown];
        }
        
        NSArray *scores = [map objectForKey:@"scores"];
        [currentMap setRedScore:[[scores objectAtIndex:0] integerValue]];
        [currentMap setBlueScore:[[scores objectAtIndex:1] integerValue]];
        [currentMap setGreenScore:[[scores objectAtIndex:2] integerValue]];
        
        NSMutableSet *objectives = [[NSMutableSet alloc] initWithCapacity:[[map objectForKey:@"objectives"] count]];
        for (NSDictionary *objective in [map objectForKey:@"objectives"]) {
            GW2Objective *currentObjective = [[GW2 objectiveByID:[[objective objectForKey:@"id"] stringValue]] copy];
            
            NSString *owner = [[objective objectForKey:@"owner"] lowercaseString];
            if ([owner isEqualToString:@"red"]) {
                [currentObjective setOwnerTeam:GW2WvWTeamRed];
            } else if ([owner isEqualToString:@"blue"]) {
                [currentObjective setOwnerTeam:GW2WvWTeamBlue];
            } else if ([owner isEqualToString:@"green"]) {
                [currentObjective setOwnerTeam:GW2WvWTeamGreen];
            } else {
                [currentObjective setOwnerTeam:GW2WvWTeamUnknown];
            }
            
            [currentObjective setOwnerGuild:[objective objectForKey:@"owner_guild"]];
            
            [objectives addObject:currentObjective];
        }
        [currentMap setMapObjectives:objectives];
        
        [maps addObject:currentMap];
    }
    
    [obj setMaps:[maps copy]];
    
    return obj;
}

+ (NSArray *)notificationNames {
    return @[GW2WvWNotification, GW2WvWMatchDetailsNotification];
}

@end

#pragma mark - GW2WvWMap implementation

@implementation GW2WvWMap

#pragma mark - NSCoding protocol -

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        [self setType:[[decoder decodeObjectForKey:@"type"] integerValue]];
        [self setRedScore:[[decoder decodeObjectForKey:@"redscore"] integerValue]];
        [self setBlueScore:[[decoder decodeObjectForKey:@"bluescore"] integerValue]];
        [self setGreenScore:[[decoder decodeObjectForKey:@"greenscore"] integerValue]];
        [self setMapObjectives:[decoder decodeObjectForKey:@"mapobjectives"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@(self.type) forKey:@"type"];
    [coder encodeObject:@(self.redScore) forKey:@"redscore"];
    [coder encodeObject:@(self.blueScore) forKey:@"bluescore"];
    [coder encodeObject:@(self.greenScore) forKey:@"greenscore"];
    [coder encodeObject:self.mapObjectives forKey:@"mapobjectives"];
}

#pragma mark - Properties -

- (NSInteger)redPotentialPoints {
    NSInteger potentialPoints = 0;
    for (GW2Objective *objective in _mapObjectives) {
        if ([objective ownerTeam] == GW2WvWTeamRed) {
            potentialPoints += [objective points];
        }
    }
    
    return potentialPoints;
}

- (NSInteger)bluePotentialPoints {
    NSInteger potentialPoints = 0;
    for (GW2Objective *objective in _mapObjectives) {
        if ([objective ownerTeam] == GW2WvWTeamBlue) {
            potentialPoints += [objective points];
        }
    }
    
    return potentialPoints;
}

- (NSInteger)greenPotentialPoints {
    NSInteger potentialPoints = 0;
    for (GW2Objective *objective in _mapObjectives) {
        if ([objective ownerTeam] == GW2WvWTeamGreen) {
            potentialPoints += [objective points];
        }
    }
    
    return potentialPoints;
}

#pragma mark - NSObject protocol -

- (NSString *)description {
	return [NSString stringWithFormat:@"[%i] R:%li B:%li G:%li", self.type, (long)self.redScore, (long)self.blueScore, (long)self.greenScore];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[GW2WvWMap class]]) {
		return [self type] == [(GW2WvWMap *)object type];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

#pragma mark - NSCopying protocol -

- (id)copyWithZone:(NSZone *)zone {
    GW2WvWMap *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
		[copy setType:self.type];
        [copy setRedScore:self.redScore];
        [copy setBlueScore:self.blueScore];
        [copy setGreenScore:self.greenScore];
        [copy setMapObjectives:[self.mapObjectives copyWithZone:zone]];
    }
	
    return copy;
}

@end
