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
	return [NSString stringWithFormat:@"<%@: %@, %@ Tier %li, redScore: %li blueScore: %li greenScore: %li>",
            NSStringFromClass([self class]), self.ID, [GW2API regionName:self.region], (long)self.tier, (long)self.redScore, (long)self.blueScore, (long)self.greenScore];
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

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return [api requestURL:@"wvw/match_details.json" params:@{@"match_id": ID}];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    GW2MatchDetails *obj = [[[self class] alloc] initWithID:json[@"match_id"]];
    [obj setLastUpdate:[NSDate date]];
    
    NSArray *scores = json[@"scores"];
    [obj setRedScore:[scores[0] integerValue]];
    [obj setBlueScore:[scores[1] integerValue]];
    [obj setGreenScore:[scores[2] integerValue]];
    
    NSMutableSet *maps = [[NSMutableSet alloc] initWithCapacity:4];
    for (NSDictionary *map in json[@"maps"]) {
        GW2WvWMap *currentMap = [[GW2WvWMap alloc] init];
        
        NSString *mapType = [map[@"type"] lowercaseString];
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
        
        NSArray *scores = map[@"scores"];
        [currentMap setRedScore:[scores[0] integerValue]];
        [currentMap setBlueScore:[scores[1] integerValue]];
        [currentMap setGreenScore:[scores[2] integerValue]];
        
        NSMutableSet *objectives = [[NSMutableSet alloc] initWithCapacity:[map[@"objectives"] count]];
        for (NSDictionary *objective in map[@"objectives"]) {
            GW2Objective *currentObjective = [[GW2 objectiveByID:[objective[@"id"] stringValue]] copy];
            
            NSString *owner = [objective[@"owner"] lowercaseString];
            if ([owner isEqualToString:@"red"]) {
                [currentObjective setOwnerTeam:GW2WvWTeamRed];
            } else if ([owner isEqualToString:@"blue"]) {
                [currentObjective setOwnerTeam:GW2WvWTeamBlue];
            } else if ([owner isEqualToString:@"green"]) {
                [currentObjective setOwnerTeam:GW2WvWTeamGreen];
            } else if ([owner isEqualToString:@"neutral"]) {
                [currentObjective setOwnerTeam:GW2WvWTeamNeutral];
            } else {
                [currentObjective setOwnerTeam:GW2WvWTeamUnknown];
            }
            
            [currentObjective setOwnerGuild:objective[@"owner_guild"]];
            
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

@interface GW2WvWMap ()

@property (nonatomic, readwrite, assign) NSInteger redPotentialPoints;
@property (nonatomic, readwrite, assign) NSInteger bluePotentialPoints;
@property (nonatomic, readwrite, assign) NSInteger greenPotentialPoints;

@end

@implementation GW2WvWMap

#pragma mark - Properties

- (void)setMapObjectives:(NSSet *)mapObjectives {
    _mapObjectives = [mapObjectives copy];
    
    _redPotentialPoints = -1;
    _bluePotentialPoints = -1;
    _greenPotentialPoints = -1;
}

- (NSInteger)redPotentialPoints {
    if (_redPotentialPoints >= 0) {
        return _redPotentialPoints;
    }
    
    _redPotentialPoints = 0;
    for (GW2Objective *objective in _mapObjectives) {
        if ([objective ownerTeam] == GW2WvWTeamRed) {
            _redPotentialPoints += [objective points];
        }
    }
    
    return _redPotentialPoints;
}

- (NSInteger)bluePotentialPoints {
    if (_bluePotentialPoints >= 0) {
        return _bluePotentialPoints;
    }
    
    _bluePotentialPoints = 0;
    for (GW2Objective *objective in _mapObjectives) {
        if ([objective ownerTeam] == GW2WvWTeamBlue) {
            _bluePotentialPoints += [objective points];
        }
    }
    
    return _bluePotentialPoints;
}

- (NSInteger)greenPotentialPoints {
    if (_greenPotentialPoints >= 0) {
        return _greenPotentialPoints;
    }
    
    _greenPotentialPoints = 0;
    for (GW2Objective *objective in _mapObjectives) {
        if ([objective ownerTeam] == GW2WvWTeamGreen) {
            _greenPotentialPoints += [objective points];
        }
    }
    
    return _greenPotentialPoints;
}

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %li, redScore: %li blueScore: %li greenScore: %li>",
            NSStringFromClass([self class]), (long)self.type, (long)self.redScore, (long)self.blueScore, (long)self.greenScore];
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

#pragma mark - NSCopying protocol

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
