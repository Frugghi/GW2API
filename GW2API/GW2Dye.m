//
//  GW2Dye.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 15/08/13.
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

#import "GW2Dye.h"
#import "GW2Protected.h"

@implementation GW2Dye

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@, name: %@, baseRGB: [%li, %li, %li]>", NSStringFromClass([self class]), self.ID, self.name, (long)[self.baseRGB[0] integerValue], (long)[self.baseRGB[1] integerValue], (long)[self.baseRGB[2] integerValue]];
}

#pragma mark - GW2Caching protocol

- (NSString *)cacheKey {
    return @"gw2_dyes";
}

- (NSTimeInterval)timeout {
    return 60 * 60 * 24 * 28; // 28 days
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 dyeByID:[self ID] error:error];
    };
}

#pragma mark - Protected

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return [api requestURL:@"colors.json" params:@{@"lang": [api langCode]}];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    NSDate *now = [NSDate date];
    GW2Array *gw2Array = [[GW2Array alloc] init];
    NSDictionary *dyes = json[@"colors"];
    for (NSString *dyeID in dyes) {
        NSDictionary *dye = dyes[dyeID];
        GW2Dye *obj = [[[self class] alloc] initWithID:dyeID];
        [obj setName:dye[@"name"]];
        [obj setBaseRGB:dye[@"base_rgb"]];
        
        NSDictionary *clothDict = dye[@"cloth"];
        GW2Color *cloth = [[GW2Color alloc] init];
        [cloth setBrightness:clothDict[@"brightness"]];
        [cloth setContrast:clothDict[@"contrast"]];
        [cloth setHue:clothDict[@"hue"]];
        [cloth setSaturation:clothDict[@"saturation"]];
        [cloth setLightness:clothDict[@"lightness"]];
        [cloth setRGB:clothDict[@"rgb"]];
        [obj setCloth:cloth];
        
        NSDictionary *leatherhDict = dye[@"leather"];
        GW2Color *leather = [[GW2Color alloc] init];
        [leather setBrightness:leatherhDict[@"brightness"]];
        [leather setContrast:leatherhDict[@"contrast"]];
        [leather setHue:leatherhDict[@"hue"]];
        [leather setSaturation:leatherhDict[@"saturation"]];
        [leather setLightness:leatherhDict[@"lightness"]];
        [leather setRGB:leatherhDict[@"rgb"]];
        [obj setLeather:leather];
        
        NSDictionary *metalDict = dye[@"metal"];
        GW2Color *metal = [[GW2Color alloc] init];
        [metal setBrightness:metalDict[@"brightness"]];
        [metal setContrast:metalDict[@"contrast"]];
        [metal setHue:metalDict[@"hue"]];
        [metal setSaturation:metalDict[@"saturation"]];
        [metal setLightness:metalDict[@"lightness"]];
        [metal setRGB:metalDict[@"rgb"]];
        [obj setMetal:metal];
        
        [obj setLastUpdate:now];
        [gw2Array addObject:obj];
    }
    
    [gw2Array setLastUpdate:now];
    [gw2Array setTimeout:[[gw2Array lastObject] timeout]];
    [gw2Array setCacheKey:[[gw2Array lastObject] cacheKey]];
    
    return gw2Array;
}

+ (NSArray *)notificationNames {
    return @[GW2PveNotification];
}

@end

#pragma mark - GW2Color -

@implementation GW2Color

- (id)color {
    float red   = [self.RGB[0] floatValue] / 255.0f;
    float green = [self.RGB[1] floatValue] / 255.0f;
    float blue  = [self.RGB[2] floatValue] / 255.0f;
    
#if TARGET_OS_IPHONE
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
#else
    return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0f];
#endif
}

- (NSString *)materialDescription {
    switch (self.material) {
        case GW2ColorMaterialUnknown: return @"unknown";
        case GW2ColorMaterialCloth:   return @"cloth";
        case GW2ColorMaterialLeather: return @"leather";
        case GW2ColorMaterialMetal:   return @"metal";
    }
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: [%li, %li, %li], material: %@, brightness: %f, contrast: %f, hue: %f, saturation: %f, lightness: %f>",
            NSStringFromClass([self class]), (long)[self.RGB[0] integerValue], (long)[self.RGB[1] integerValue], (long)[self.RGB[2] integerValue], [self materialDescription], [self.brightness floatValue], [self.contrast floatValue], [self.hue floatValue], [self.saturation floatValue], [self.lightness floatValue]];
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
