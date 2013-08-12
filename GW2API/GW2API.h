//
//  GW2API.h
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

#import "GW2Enums.h"

@interface GW2API : NSObject

#pragma mark - Properties -

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *langCode;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, readonly) NSString *buildID;

#pragma mark - Classes -

@property (nonatomic, assign) Class cacheClass;

@property (nonatomic, assign) Class worldClass;
@property (nonatomic, assign) Class continentClass;
@property (nonatomic, assign) Class mapClass;
@property (nonatomic, assign) Class mapFloorClass;
@property (nonatomic, assign) Class zoneClass;
@property (nonatomic, assign) Class matchClass;
@property (nonatomic, assign) Class matchDetailsClass;
@property (nonatomic, assign) Class objectiveClass;
@property (nonatomic, assign) Class eventClass;
@property (nonatomic, assign) Class eventStateClass;
@property (nonatomic, assign) Class recipeClass;
@property (nonatomic, assign) Class itemClass;

#pragma mark - Public methods -

+ (NSString *)regionName:(GW2RegionServer)region;
+ (NSString *)languageName:(GW2Language)language;
+ (NSString *)stateName:(GW2EventStateType)state;
+ (NSDate *)nextWvWReset:(GW2RegionServer)region;
+ (NSTimeInterval)timeIntervalBeforeWvWReset:(GW2RegionServer)region;

- (NSURL *)requestURL:(NSString *)relativeURL params:(NSDictionary *)params;
- (NSData *)syncRequest:(NSURL *)requestURL error:(NSError **)error;

@end
