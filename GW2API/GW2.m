//
//  GW2.m
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

#import "GW2.h"
#import "GW2Protected.h"

@interface GW2 ()

@property (nonatomic, strong) GW2API *api;
@property (nonatomic, strong) NSMutableDictionary *cacheTable;
@property (nonatomic, strong) dispatch_queue_t fetchQueue;
@property (nonatomic, strong) dispatch_queue_t cacheQueue;
@property (nonatomic, strong) NSURL *cacheURL;
@property (nonatomic, strong) id<GW2APICache> cache;

@end

static GW2 *sharedInstance = nil;

@implementation GW2

NSString *const GW2APICachePlist = @"com.GW2API.Cache.plist";
NSString *const GW2APICacheBuildIDKey = @"com.GW2API.CacheBuildIDKey";

NSString *const GW2ObjectUserInfoKey = @"com.GW2.ObjectUserInfoKey";
NSString *const GW2ObjectIDUserInfoKey = @"com.GW2.ObjectIDUserInfoKey";

NSString *const GW2WvWNotification = @"com.GW2.WvWNotification";
NSString *const GW2WvWMatchNotification = @"com.GW2.WvWNotification.Match";
NSString *const GW2WvWMatchDetailsNotification = @"com.GW2.WvWNotification.MatchDetails";
NSString *const GW2WvWObjectiveNotification = @"com.GW2.WvWNotification.Objective";
NSString *const GW2WorldNotification = @"com.GW2.WorldNotification";
NSString *const GW2MapNotification = @"com.GW2.MapNotification";
NSString *const GW2PveNotification = @"com.GW2.PveNotification";
NSString *const GW2EventNotification = @"com.GW2.EventNotification";
NSString *const GW2RecipeNotification = @"com.GW2.RecipeNotification";
NSString *const GW2ItemNotification = @"com.GW2.ItemNotification";

#pragma mark - Init -

- (id)init {
    self = [super init];
    if (self) {
        _api = [[GW2API alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _cacheURL = [NSURL fileURLWithPathComponents:@[[paths objectAtIndex:0], GW2APICachePlist]];
        
        //[self.cache removeAllObjects];
        /*if ([[NSFileManager defaultManager] fileExistsAtPath:[self.cacheURL path]]) {
            [[NSFileManager defaultManager] removeItemAtURL:self.cacheURL error:nil];
        }*/
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.cacheURL path]]) {
            _cacheTable = [[NSMutableDictionary alloc] initWithContentsOfURL:self.cacheURL];
        } else {
            _cacheTable = [[NSMutableDictionary alloc] init];
            [_cacheTable writeToURL:self.cacheURL atomically:YES];
        }
        
        dispatch_barrier_async(self.cacheQueue, ^{
            NSString *cachedBuildID = [_cacheTable objectForKey:GW2APICacheBuildIDKey];
            NSString *currentBuildID = [_api buildID];
            
            if (currentBuildID && ![currentBuildID isEqualToString:cachedBuildID]) {
                [GW2 clearCache];
                [_cacheTable setObject:currentBuildID forKey:GW2APICacheBuildIDKey];
                [_cacheTable writeToURL:self.cacheURL atomically:YES];
            }
        });
    }
    
    return self;
}

+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GW2 alloc] init];
    });
    
    return sharedInstance;
}

- (dispatch_queue_t)fetchQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fetchQueue = dispatch_queue_create("com.GW2.fetchQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return _fetchQueue;
}

- (const char *)cacheQueueSpecific {
    static const char *kGW2CacheQueueSpecific = "GW2CacheQueueSpecific";
    return kGW2CacheQueueSpecific;
}

- (dispatch_queue_t)cacheQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cacheQueue = dispatch_queue_create("com.GW2.cacheQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(_cacheQueue, self.cacheQueueSpecific, (__bridge void *)self, NULL);
    });
    
    return _cacheQueue;
}

- (NSMutableDictionary *)cacheTable {
    __block NSMutableDictionary *cacheTable;
    if (dispatch_get_specific(self.cacheQueueSpecific)) {
        cacheTable = _cacheTable;
    } else {
        dispatch_sync(self.cacheQueue, ^{
            cacheTable = _cacheTable;
        });
    }
    
    return cacheTable;
}

- (id<GW2APICache>)cache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [[[self.api cacheClass] alloc] initWithName:@"GW2APICache"];
        //[_cache removeAllObjects];
        dispatch_barrier_async(self.cacheQueue, ^{
            [self clearExpiredCache];
        });
    });
    
    return _cache;
}

#pragma mark - Public -

+ (GW2API *)api {
    return [[self sharedInstance] api];
}

// Fetch

+ (id)fetch:(id<GW2Fetching>)obj {
    return [self fetch:obj error:nil];
}

+ (id)fetch:(id<GW2Fetching>)obj error:(NSError *__autoreleasing *)error {
    GW2FetchBlock fetchBlock = [obj fetchBlock];
    return fetchBlock(error);
}

+ (void)fetch:(id<GW2Fetching>)obj completitionBlock:(GW2FetchCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        id object = [self fetch:obj error:&error];
        completitionBlock(object, error);
    });
}

#pragma mark - Cache -

+ (void)removeObjectForKey:(NSString *)key {
    [[[GW2 sharedInstance] cache] removeObjectForKey:key];
    if (dispatch_get_specific([[GW2 sharedInstance] cacheQueueSpecific])) {
        [[[GW2 sharedInstance] cacheTable] removeObjectForKey:key];
    } else {
        dispatch_barrier_sync([[GW2 sharedInstance] cacheQueue], ^{
            [[[GW2 sharedInstance] cacheTable] removeObjectForKey:key];
            [[GW2 sharedInstance] writeCacheTableToDisk];
        });
    }
}

+ (void)removeObjectsForKeys:(NSArray *)keys {
    for (NSString *key in keys) {
        [[[GW2 sharedInstance] cache] removeObjectForKey:key];
    }
    if (dispatch_get_specific([[GW2 sharedInstance] cacheQueueSpecific])) {
        [[[GW2 sharedInstance] cacheTable] removeObjectsForKeys:keys];
    } else {
        dispatch_barrier_sync([[GW2 sharedInstance] cacheQueue], ^{
            [[[GW2 sharedInstance] cacheTable] removeObjectsForKeys:keys];
            [[GW2 sharedInstance] writeCacheTableToDisk];
        });
    }
}

+ (void)clearCache {
    [self removeObjectsForKeys:[[[GW2 sharedInstance] cacheTable] allKeys]];
}

+ (BOOL)hasCachedObjectForClass:(Class)class byID:(NSString *)ID {
    if ([class isSubclassOfClass:[GW2Object class]] && ID) {
        return [[self sharedInstance] cachedObjectForClass:class ID:ID] != nil;
    }
    
    return NO;
}

#pragma mark - Worlds -

+ (GW2Array *)worlds {
    return [self worldsWithError:nil];
}

+ (GW2Array *)worldsWithError:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] worldClass] ID:nil error:error];
}

+ (void)worldsWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Array *collection = [self worldsWithError:&error];
        completitionBlock(collection, error);
    });
}

+ (GW2World *)worldByID:(NSString *)ID {
    return [self worldByID:ID error:nil];
}

+ (GW2World *)worldByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return (GW2World *)[[self worldsWithError:error] objectWithID:ID];
}

+ (void)worldByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2World *object = [self worldByID:ID error:&error];
        completitionBlock(object, error);
    });
}

#pragma mark - Continents -

+ (GW2Array *)continents {
    return [self continentsWithError:nil];
}

+ (GW2Array *)continentsWithError:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] continentClass] ID:nil error:error];
}

+ (void)continentsWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Array *collection = [self continentsWithError:&error];
        completitionBlock(collection, error);
    });
}

+ (GW2Continent *)continentByID:(NSString *)ID {
    return [self continentByID:ID error:nil];
}

+ (GW2Continent *)continentByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return (GW2Continent *)[[self continentsWithError:error] objectWithID:ID];
}

+ (void)continentByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Continent *object = [self continentByID:ID error:&error];
        completitionBlock(object, error);
    });
}

#pragma mark - Maps -

+ (GW2Array *)maps {
    return [self mapsWithError:nil];
}

+ (GW2Array *)mapsWithError:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] mapClass] ID:nil error:error];
}

+ (void)mapsWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Array *collection = [self mapsWithError:&error];
        completitionBlock(collection, error);
    });
}

+ (GW2Map *)mapByID:(NSString *)ID {
    return [self mapByID:ID error:nil];
}

+ (GW2Map *)mapByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return (GW2Map *)[[self mapsWithError:error] objectWithID:ID];
}

+ (void)mapByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Map *object = [self mapByID:ID error:&error];
        completitionBlock(object, error);
    });
}

#pragma mark - Map Floor -

+ (GW2MapFloor *)mapFloorByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] mapFloorClass] ID:ID error:error];
}

+ (GW2MapFloor *)mapFloorContinentID:(NSString *)continentID floor:(NSInteger)floor error:(NSError *__autoreleasing *)error {
    return [self mapFloorByID:[NSString stringWithFormat:@"%@_%li", continentID, (long)floor] error:error];
}

+ (GW2MapFloor *)mapFloorContinent:(GW2Continent *)continent floor:(NSInteger)floor error:(NSError *__autoreleasing *)error {
    return [self mapFloorContinentID:[continent ID] floor:floor error:error];
}

+ (void)mapFloorByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Object *object = [self mapFloorByID:ID error:&error];
        completitionBlock(object, error);
    });
}

+ (void)mapFloorContinentID:(NSString *)continentID floor:(NSInteger)floor completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Object *object = [self mapFloorContinentID:continentID floor:floor error:&error];
        completitionBlock(object, error);
    });
}

+ (void)mapFloorContinent:(GW2Continent *)continent floor:(NSInteger)floor completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Object *object = [self mapFloorContinent:continent floor:floor error:&error];
        completitionBlock(object, error);
    });
}


#pragma mark - Zones -

+ (GW2Array *)zones {
    return [self zonesWithError:nil];
}

+ (GW2Array *)zonesWithError:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] zoneClass] ID:nil error:error];
}

+ (void)zonesWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Array *collection = [self zonesWithError:&error];
        completitionBlock(collection, error);
    });
}

+ (GW2Zone *)zoneByID:(NSString *)ID {
    return [self zoneByID:ID error:nil];
}

+ (GW2Zone *)zoneByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return (GW2Zone *)[[self zonesWithError:error] objectWithID:ID];
}

+ (void)zoneByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Zone *object = [self zoneByID:ID error:&error];
        completitionBlock(object, error);
    });
}

#pragma mark - Events -

+ (GW2Array *)events {
    return [self eventsWithError:nil];
}

+ (GW2Array *)eventsWithError:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] eventClass] ID:nil error:error];
}

+ (void)eventsWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Array *collection = [self eventsWithError:&error];
        completitionBlock(collection, error);
    });
}

+ (GW2Event *)eventByID:(NSString *)ID {
    return [self eventByID:ID error:nil];
}

+ (GW2Event *)eventByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return (GW2Event *)[[self eventsWithError:error] objectWithID:ID];
}

+ (void)eventByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Event *object = [self eventByID:ID error:&error];
        completitionBlock(object, error);
    });
}

#pragma mark - Event State -

+ (GW2Array *)eventStateByID:(NSString *)ID error:(NSError **)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] eventStateClass] ID:ID error:error];
}

+ (GW2Array *)eventStateEventID:(NSString *)eventID zoneID:(NSString *)zoneID worldID:(NSString *)worldID error:(NSError **)error {
    return [self eventStateByID:[NSString stringWithFormat:@"%@_%@_%@", worldID ? worldID : @"", zoneID ? zoneID : @"", eventID ? eventID : @""]
                          error:error];
}

+ (GW2Array *)eventStateEvent:(GW2Event *)event zone:(GW2Zone *)zone world:(GW2World *)world error:(NSError **)error {
    return [self eventStateEventID:event.ID zoneID:zone.ID worldID:world.ID error:error];
}

+ (void)eventStateByID:(NSString *)ID completitionBlock:(GW2CollectionCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Array *collection = [self eventStateByID:ID error:&error];
        completitionBlock(collection, error);
    });
}

+ (void)eventStateEventID:(NSString *)eventID zoneID:(NSString *)zoneID worldID:(NSString *)worldID completitionBlock:(GW2CollectionCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Array *collection = [self eventStateEventID:eventID zoneID:zoneID worldID:worldID error:&error];
        completitionBlock(collection, error);
    });
}

+ (void)eventStateEvent:(GW2Event *)event zone:(GW2Zone *)zone world:(GW2World *)world completitionBlock:(GW2CollectionCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Array *collection = [self eventStateEvent:event zone:zone world:world error:&error];
        completitionBlock(collection, error);
    });
}

#pragma mark - Matches -

+ (GW2Array *)matches {
    return [self matchesWithError:nil];
}

+ (GW2Array *)matchesWithError:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] matchClass] ID:nil error:error];
}

+ (void)matchesWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Array *collection = [self matchesWithError:&error];
        completitionBlock(collection, error);
    });
}

+ (GW2Match *)matchByID:(NSString *)ID {
    return [self matchByID:ID error:nil];
}

+ (GW2Match *)matchByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return (GW2Match *)[[self matchesWithError:error] objectWithID:ID];
}

+ (void)matchByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Match *object = [self matchByID:ID error:&error];
        completitionBlock(object, error);
    });
}

#pragma mark - MatchDetails -

+ (GW2MatchDetails *)matchDetailsByID:(NSString *)ID {
    return [self matchDetailsByID:ID error:nil];
}

+ (GW2MatchDetails *)matchDetailsByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] matchDetailsClass] ID:ID error:error];
}

+ (void)matchDetailsByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2MatchDetails *object = [self matchDetailsByID:ID error:&error];
        completitionBlock(object, error);
    });
}

+ (GW2Array *)matchDetailsForMatches:(GW2Array *)matches {
    return [self matchDetailsForMatches:matches error:nil];
}

+ (GW2Array *)matchDetailsForMatches:(GW2Array *)matches error:(NSError *__autoreleasing *)error {
    GW2Array *matchDetails = [[GW2Array alloc] init];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.GW2.matchDetailsQueue", DISPATCH_QUEUE_CONCURRENT);
    for (GW2Match *match in matches) {
        dispatch_group_async(group, queue, ^{
            GW2MatchDetails *matchDetail = [self matchDetailsByID:[match matchDetailsID] error:error];
            [matchDetails addObject:matchDetail];
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSDate *oldestDate = [[matchDetails lastObject] lastUpdate];
    for (GW2MatchDetails *matchDetail in matchDetails) {
        if ([[matchDetail lastUpdate] timeIntervalSinceDate:oldestDate] > 0) {
            oldestDate = [matchDetail lastUpdate];
        }
    }
    [matchDetails setLastUpdate:oldestDate];
    [matchDetails setTimeout:[[matchDetails lastObject] timeout]];

    return matchDetails;
}

+ (void)matchDetailsForMatches:(GW2Array *)matches completitionBlock:(GW2CollectionCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Array *collection = [self matchDetailsForMatches:matches error:&error];
        completitionBlock(collection, error);
    });
}

#pragma mark - Objectives -

+ (GW2Array *)objectives {
    return [self objectivesWithError:nil];
}

+ (GW2Array *)objectivesWithError:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] objectiveClass] ID:nil error:error];
}

+ (void)objectivesWithCompletitionBlock:(GW2CollectionCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Array *collection = [self objectivesWithError:&error];
        completitionBlock(collection, error);
    });
}

+ (GW2Objective *)objectiveByID:(NSString *)ID {
    return [self objectiveByID:ID error:nil];
}

+ (GW2Objective *)objectiveByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return (GW2Objective *)[[self objectivesWithError:error] objectWithID:ID];
}

+ (void)objectiveByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Objective *object = [self objectiveByID:ID error:&error];
        completitionBlock(object, error);
    });
}

#pragma mark - Recipes -

+ (NSArray *)recipes {
    return [self recipesWithError:nil];
}

+ (NSArray *)recipesWithError:(NSError *__autoreleasing *)error {
    return [[[self sharedInstance] fetchObjectForClass:[GW2RecipeID class] ID:nil error:error] arrayID];
}

+ (void)recipesWithCompletitionBlock:(GW2ArrayIDCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        NSArray *array = [self recipesWithError:&error];
        completitionBlock(array, error);
    });
}

+ (GW2Recipe *)recipeByID:(NSString *)ID {
    return [self recipeByID:ID error:nil];
}

+ (GW2Recipe *)recipeByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] recipeClass] ID:ID error:error];
}

+ (void)recipeByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Recipe *object = [self recipeByID:ID error:&error];
        completitionBlock(object, error);
    });
}

#pragma mark - Items -

+ (NSArray *)items {
    return [self recipesWithError:nil];
}

+ (NSArray *)itemsWithError:(NSError *__autoreleasing *)error {
    return [[[self sharedInstance] fetchObjectForClass:[GW2ItemID class] ID:nil error:error] arrayID];
}

+ (void)itemsWithCompletitionBlock:(GW2ArrayIDCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        NSArray *array = [self itemsWithError:&error];
        completitionBlock(array, error);
    });
}

+ (GW2Item *)itemByID:(NSString *)ID {
    return [self itemByID:ID error:nil];
}

+ (GW2Item *)itemByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] itemClass] ID:ID error:error];
}

+ (void)itemByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Item *object = [self itemByID:ID error:&error];
        completitionBlock(object, error);
    });
}

#pragma mark - Guilds -

+ (GW2Guild *)guildByID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] fetchObjectForClass:[[self api] guildClass] ID:ID error:error];
}

+ (void)guildByID:(NSString *)ID completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    dispatch_async([[self sharedInstance] fetchQueue], ^{
        NSError *error;
        GW2Guild *object = [self guildByID:ID error:&error];
        completitionBlock(object, error);
    });
}

+ (GW2Guild *)guildByName:(NSString *)name error:(NSError *__autoreleasing *)error {
    return [self guildByID:name error:error];
}

+ (void)guildByName:(NSString *)name completitionBlock:(GW2ObjectCompletitionBlock)completitionBlock {
    [self guildByID:name completitionBlock:completitionBlock];
}

#pragma mark - Private -

- (id<GW2Caching, NSCopying>)cachedObjectForClass:(Class)class ID:(NSString *)ID {
    NSString *cacheKey = [[[class alloc] initWithID:ID] cacheKey];
    id<GW2Caching, NSCopying> cachedObject = [self.cache objectForKey:cacheKey];
    if (cachedObject && ![cachedObject isExpired]) {
        if (ID && [cachedObject isKindOfClass:[GW2Array class]]) {
            return [(GW2Array *)cachedObject objectWithID:ID];
        }
        
        return cachedObject;
    }
    
    return nil;
}

- (id)fetchObjectForClass:(Class)class ID:(NSString *)ID error:(NSError *__autoreleasing *)error {
    id<GW2Caching, NSCopying> gw2Object = [self cachedObjectForClass:class ID:ID];

    if (!gw2Object) {
        NSError *error_;
        NSURL *requestURL = [class requestURL:self.api withID:ID];
        NSData *jsonData = [self dataForURL:requestURL error:&error_];
        if (error_) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, [error_ description]);
            if (error) {
                *error = error_;
            }
            return nil;
        }
        
        gw2Object = [class parseJSONData:jsonData requestURL:requestURL error:&error_];
        if (error_) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, [error_ description]);
            if (error) {
                *error = error_;
            }
            return nil;
        }
        
        [self cacheObject:gw2Object];
        [self writeCacheTableToDisk];
    }
    
    return [gw2Object copyWithZone:NULL];
}

- (void)cacheObject:(id<GW2Caching, NSCopying>)gw2Object {
    [self.cache setObject:gw2Object forKey:[gw2Object cacheKey]];
    dispatch_block_t cacheBlock = ^{
        [_cacheTable setObject:[[gw2Object lastUpdate] dateByAddingTimeInterval:[gw2Object timeout]]
                        forKey:[gw2Object cacheKey]];
    };
    if (dispatch_get_specific(self.cacheQueueSpecific)) {
        cacheBlock();
    } else {
        dispatch_barrier_sync(self.cacheQueue, cacheBlock);
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSObject *objCopy = [gw2Object copyWithZone:NULL];
        NSString *objID = @"";
        NSArray *notifications;
        if ([objCopy isKindOfClass:[GW2Object class]]) {
            objID = [(GW2Object *)objCopy ID];
            notifications = [[objCopy class] notificationNames];
        } else if ([objCopy isKindOfClass:[GW2Array class]]) {
            for (GW2Object *obj in (GW2Array *)objCopy) {
                if ([obj isKindOfClass:[GW2Object class]]) {
                    notifications = [[obj class] notificationNames];
                    break;
                }
            }
        }
        NSDictionary *userInfo = @{GW2ObjectUserInfoKey: objCopy,
                                   GW2ObjectIDUserInfoKey: objID};
        for (NSString *notificationName in notifications) {
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                                object:nil
                                                              userInfo:userInfo];
        }
    });
}

- (void)writeCacheTableToDisk {
    dispatch_barrier_async(self.cacheQueue, ^{
        [_cacheTable writeToURL:self.cacheURL atomically:YES];
    });
}

- (void)clearExpiredCache {
    dispatch_block_t cacheBlock = ^{
        NSDate *now = [NSDate date];
        NSMutableArray *expiredKeys = [[NSMutableArray alloc] init];
        for (NSString *key in _cacheTable) {
            if ([[_cacheTable objectForKey:key] isKindOfClass:[NSDate class]]
                && [now timeIntervalSinceDate:[_cacheTable objectForKey:key]] >= 0) {
                [expiredKeys addObject:key];
            }
        }
        
        for (NSString *key in expiredKeys) {
            [GW2 removeObjectForKey:key];
        }
        
        [self writeCacheTableToDisk];
    };
    if (dispatch_get_specific(self.cacheQueueSpecific)) {
        cacheBlock();
    } else {
        dispatch_barrier_sync(self.cacheQueue, cacheBlock);
    }
}

- (NSData *)dataForURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSData *jsonData = [self.api syncRequest:requestURL error:error];
    
    if (error && *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, [*error description]);
    }
    
    return jsonData;
}

@end
