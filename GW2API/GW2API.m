//
//  GW2API.m
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
#import "GW2Model.h"
#import "GW2Cache.h"

@interface GW2API ()

@property (nonatomic, strong) dispatch_semaphore_t urlSemaphore;
@property (nonatomic, strong) NSMutableDictionary *semaphoreDict;

@end

@implementation GW2API

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        [self setVersion:@"v1"];
        [self setLangCode:@"en"];
        [self setBaseURL:[NSURL URLWithString:@"https://api.guildwars2.com"]];
        [self setSemaphoreDict:[[NSMutableDictionary alloc] init]];
        
        [self setCacheClass:[GW2Cache class]];
        
        // Model
        [self setWorldClass:[GW2World class]];
        [self setContinentClass:[GW2Continent class]];
        [self setMapClass:[GW2Map class]];
        [self setZoneClass:[GW2Zone class]];
        [self setMatchClass:[GW2Match class]];
        [self setMatchDetailsClass:[GW2MatchDetails class]];
        [self setObjectiveClass:[GW2Objective class]];
        [self setEventClass:[GW2Event class]];
        [self setEventStateClass:[GW2EventState class]];
        [self setRecipeClass:[GW2Recipe class]];
        [self setItemClass:[GW2Item class]];
    }
    
    return self;
}

- (NSURL *)apiURL {
    return [[self baseURL] URLByAppendingPathComponent:[self version]];
}

- (dispatch_queue_t)serialQueue {
    static dispatch_queue_t _serialQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serialQueue = dispatch_queue_create("com.GW2.apiSerialQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return _serialQueue;
}

- (dispatch_semaphore_t)urlSemaphore {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _urlSemaphore = dispatch_semaphore_create(5);
    });
    
    return _urlSemaphore;
}

- (void)setCacheClass:(Class)cacheClass {
    if ([cacheClass conformsToProtocol:@protocol(GW2APICache)]) {
        _cacheClass = cacheClass;
    } else {
        NSLog(@"<%@> class doesn't conform to protocol <GW2APICache>", NSStringFromClass(cacheClass));
    }
}

#pragma mark - Public methods

- (NSString *)buildID {
    NSError *error;
    NSURL *requestURL = [self requestURL:@"build.json" params:nil];
    NSData *jsonData = [self syncRequest:requestURL error:&error];
    
    if (!error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        
        if (!error) {
            return [[json objectForKey:@"build_id"] stringValue];
        }
    }
    
    return nil;
}

+ (NSString *)regionName:(GW2Region)region {
    switch (region) {
        case GW2RegionUnknown:      return @"Unknown";
        case GW2RegionNorthAmerica: return @"North America";
        case GW2RegionEurope:       return @"Europe";
    }
}

+ (NSString *)languageName:(GW2Language)language {
    switch (language) {
        case GW2LanguageUnknown: return @"Unknown";
        case GW2LanguageEnglish: return @"English";
        case GW2LanguageFrench:  return @"French";
        case GW2LanguageGerman:  return @"German";
        case GW2LanguageSpanish: return @"Spanish";
    }
}

+ (NSString *)stateName:(GW2EventStateType)state {
    switch (state) {
        case GW2EventStateUnknown:      return @"Unknown";
        case GW2EventStateInactive:     return @"Inactive";
        case GW2EventStateWarmup:       return @"Warmup";
        case GW2EventStatePreparation:  return @"Preparation";
        case GW2EventStateActive:       return @"Active";
        case GW2EventStateSuccess:      return @"Success";
        case GW2EventStateFail:         return @"Failed";
    }
}

+ (NSDate *)nextWvWReset:(GW2Region)region {
    NSString *timezone = (region == GW2RegionEurope ? @"UTC" : @"PDT");
    NSUInteger hour = 18;
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone timeZoneWithAbbreviation:timezone]];
    
    NSDateComponents *weekdayComponents = [gregorian components:(NSWeekdayCalendarUnit | NSHourCalendarUnit) fromDate:today];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setDay:(13 - [weekdayComponents weekday]) % 7];
    if ([weekdayComponents weekday] == 6 && [weekdayComponents hour] >= hour) {
        [componentsToAdd setDay:7];
    }
    
    NSDate *friday = [gregorian dateByAddingComponents:componentsToAdd toDate:today options:0];
    
    NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate:friday];
    [components setHour:hour];
    
    friday = [gregorian dateFromComponents:components];
    
    return friday;
}

+ (NSTimeInterval)timeIntervalBeforeWvWReset:(GW2Region)region {
    return [[self nextWvWReset:region] timeIntervalSinceDate:[NSDate date]];
}

- (NSURL *)requestURL:(NSString *)relativeURL params:(NSDictionary *)params {
    NSMutableString *paramURL = [[NSMutableString alloc] init];
    if (params && [params count] > 0) {
        [paramURL appendString:@"?"];
        for (NSString *param in params) {
            [paramURL appendFormat:@"%@=%@&", param, [params objectForKey:param]];
        }
        [paramURL deleteCharactersInRange:NSMakeRange(paramURL.length - 1, 1)];
    }

    return [NSURL URLWithString:paramURL relativeToURL:[[self apiURL] URLByAppendingPathComponent:relativeURL]];
}

- (NSData *)syncRequest:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    __block dispatch_semaphore_t semaphore;
    __block NSData *(^block)(void);

    dispatch_sync([self serialQueue], ^{
        NSMutableDictionary *dict = [self.semaphoreDict objectForKey:requestURL];
        if (dict) {
            semaphore = [dict objectForKey:@"semaphore"];
            [dict setObject:@([[dict objectForKey:@"count"] intValue]+1) forKey:@"count"];
            block = ^{
                NSMutableDictionary *dict = [self.semaphoreDict objectForKey:requestURL];
                [dict setObject:@([[dict objectForKey:@"count"] intValue]-1) forKey:@"count"];
                return [[dict objectForKey:@"data"] copy];
            };
        } else {
            semaphore = self.urlSemaphore;
            [self.semaphoreDict setObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                           @"semaphore": dispatch_semaphore_create(0),
                                           @"count": @(0)}]
                                   forKey:requestURL];
            block = ^{
                #if TARGET_OS_IPHONE
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                    });
                #endif
                NSData *jsonData = [NSData dataWithContentsOfURL:requestURL
                                                         options:NSDataReadingUncached
                                                           error:error];
                #if TARGET_OS_IPHONE
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    });
                #endif
                
                if (!error) {
                    dispatch_sync([self serialQueue], ^{
                        NSMutableDictionary *dict = [self.semaphoreDict objectForKey:requestURL];
                        [dict setObject:[jsonData copy] forKey:@"data"];
                        dispatch_semaphore_signal([dict objectForKey:@"semaphore"]);
                    });
                }
                
                return jsonData;
            };
        }
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    NSData *jsonData = block();
    
    dispatch_sync([self serialQueue], ^{
        NSMutableDictionary *dict = [self.semaphoreDict objectForKey:requestURL];
        if ([[dict objectForKey:@"count"] intValue] == 0) {
            [self.semaphoreDict removeObjectForKey:requestURL];
        }
    });
    
    dispatch_semaphore_signal(semaphore);
    
    return jsonData;
}

@end
