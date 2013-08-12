//
//  GW2.h
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

#import "GW2API.h"
#import "GW2Timer.h"
#import "GW2Model.h"
#import "GW2Protocols.h"

typedef void (^GW2FetchCompletitionBlock)(id obj, NSError *error);
typedef void (^GW2ObjectCompletitionBlock)(GW2Object *obj, NSError *error);
typedef void (^GW2CollectionCompletitionBlock)(GW2Array *objCollection, NSError *error);
typedef void (^GW2ArrayIDCompletitionBlock)(NSArray *arrayID, NSError *error);

@interface GW2 : NSObject

extern NSString *const GW2ObjectUserInfoKey;
extern NSString *const GW2ObjectIDUserInfoKey;

extern NSString *const GW2WvWNotification;
extern NSString *const GW2WvWMatchNotification;
extern NSString *const GW2WvWMatchDetailsNotification;
extern NSString *const GW2WvWObjectiveNotification;

extern NSString *const GW2WorldNotification;
extern NSString *const GW2MapNotification;
extern NSString *const GW2PveNotification;
extern NSString *const GW2EventNotification;
extern NSString *const GW2RecipeNotification;
extern NSString *const GW2ItemNotification;

+ (GW2API *)api;

#pragma mark - Cache Methods -

+ (BOOL)hasCachedObjectForClass:(Class)objectClass byID:(NSString *)ID;

+ (void)removeObjectForKey:(NSString *)key;
+ (void)removeObjectsForKeys:(NSArray *)keys;
+ (void)clearCache;

#pragma mark - Asynchronous Methods -

+ (void)fetch:(id<GW2Fetching>)obj completitionBlock:(GW2FetchCompletitionBlock)completitionBlock;

#pragma mark - Map

+ (void)continentsWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock;
+ (void)continentByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;

+ (void)mapsWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock;
+ (void)mapByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;

+ (void)mapFloorByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;
+ (void)mapFloorContinentID:(NSString *)continentID floor:(NSInteger)floor completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;
+ (void)mapFloorContinent:(GW2Continent *)continent floor:(NSInteger)floor completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;

#pragma mark - Dynamic Events

+ (void)worldsWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock;
+ (void)worldByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;

+ (void)zonesWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock;
+ (void)zoneByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;

+ (void)eventsWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock;
+ (void)eventByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;

+ (void)eventStateByID:(NSString *)ID completitionBlock:(GW2CollectionCompletitionBlock)completitionBlock;
+ (void)eventStateEventID:(NSString *)eventID zoneID:(NSString *)zoneID worldID:(NSString *)worldID completitionBlock:(GW2CollectionCompletitionBlock)completitionBlock;
+ (void)eventStateEvent:(GW2Event *)event zone:(GW2Zone *)zone world:(GW2World *)world completitionBlock:(GW2CollectionCompletitionBlock)completitionBlock;

#pragma mark - WvW

+ (void)matchesWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock;
+ (void)matchByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;

+ (void)matchDetailsByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;
+ (void)matchDetailsForMatches:(GW2Array *)matches completitionBlock:(GW2CollectionCompletitionBlock)completitionBlock;

+ (void)objectivesWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock;
+ (void)objectiveByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;

#pragma mark - Item and Recipe

+ (void)recipesWithCompletitionBlock:(GW2ArrayIDCompletitionBlock)completitionBlock;
+ (void)recipeByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;

+ (void)itemsWithCompletitionBlock:(GW2ArrayIDCompletitionBlock)completitionBlock;
+ (void)itemByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock;

#pragma mark - Synchronous Methods -

+ (id)fetch:(id<GW2Fetching>)obj;
+ (id)fetch:(id<GW2Fetching>)obj error:(NSError **)error;

#pragma mark - Map

+ (GW2Array *)continents;
+ (GW2Array *)continentsWithError:(NSError **)error;
+ (GW2Continent *)continentByID:(NSString *)ID;
+ (GW2Continent *)continentByID:(NSString *)ID error:(NSError **)error;

+ (GW2Array *)maps;
+ (GW2Array *)mapsWithError:(NSError **)error;
+ (GW2Map *)mapByID:(NSString *)ID;
+ (GW2Map *)mapByID:(NSString *)ID error:(NSError **)error;

+ (GW2MapFloor *)mapFloorByID:(NSString *)ID error:(NSError **)error;
+ (GW2MapFloor *)mapFloorContinentID:(NSString *)continentID floor:(NSInteger)floor error:(NSError **)error;
+ (GW2MapFloor *)mapFloorContinent:(GW2Continent *)continent floor:(NSInteger)floor error:(NSError **)error;

#pragma mark - Dynamic Events

+ (GW2Array *)worlds;
+ (GW2Array *)worldsWithError:(NSError **)error;
+ (GW2World *)worldByID:(NSString *)ID;
+ (GW2World *)worldByID:(NSString *)ID error:(NSError **)error;

+ (GW2Array *)zones;
+ (GW2Array *)zonesWithError:(NSError **)error;
+ (GW2Zone *)zoneByID:(NSString *)ID;
+ (GW2Zone *)zoneByID:(NSString *)ID error:(NSError **)error;

+ (GW2Array *)events;
+ (GW2Array *)eventsWithError:(NSError **)error;
+ (GW2Event *)eventByID:(NSString *)ID;
+ (GW2Event *)eventByID:(NSString *)ID error:(NSError **)error;

+ (GW2Array *)eventStateByID:(NSString *)ID error:(NSError **)error;
+ (GW2Array *)eventStateEventID:(NSString *)eventID zoneID:(NSString *)zoneID worldID:(NSString *)worldID error:(NSError **)error;
+ (GW2Array *)eventStateEvent:(GW2Event *)event zone:(GW2Zone *)zone world:(GW2World *)world error:(NSError **)error;

#pragma mark - WvW

+ (GW2Array *)matches;
+ (GW2Array *)matchesWithError:(NSError **)error;
+ (GW2Match *)matchByID:(NSString *)ID;
+ (GW2Match *)matchByID:(NSString *)ID error:(NSError **)error;

+ (GW2MatchDetails *)matchDetailsByID:(NSString *)ID;
+ (GW2MatchDetails *)matchDetailsByID:(NSString *)ID error:(NSError **)error;
+ (GW2Array *)matchDetailsForMatches:(GW2Array *)matches;
+ (GW2Array *)matchDetailsForMatches:(GW2Array *)matches error:(NSError **)error;

+ (GW2Array *)objectives;
+ (GW2Array *)objectivesWithError:(NSError **)error;
+ (GW2Objective *)objectiveByID:(NSString *)ID;
+ (GW2Objective *)objectiveByID:(NSString *)ID error:(NSError **)error;

#pragma mark - Item and Recipe

+ (NSArray *)recipes;
+ (NSArray *)recipesWithError:(NSError **)error;
+ (GW2Recipe *)recipeByID:(NSString *)ID;
+ (GW2Recipe *)recipeByID:(NSString *)ID error:(NSError **)error;

+ (NSArray *)items;
+ (NSArray *)itemsWithError:(NSError **)error;
+ (GW2Item *)itemByID:(NSString *)ID;
+ (GW2Item *)itemByID:(NSString *)ID error:(NSError **)error;

@end