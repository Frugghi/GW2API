//
//  GW2MapFloor.h
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

#import "GW2Object.h"

@interface GW2MapFloor : GW2Object

@property (nonatomic, strong) NSString *continentID;
@property (nonatomic, assign) NSInteger floor;
@property (nonatomic, assign) CGSize textureDimensions;
@property (nonatomic, strong) NSArray *regions;

@end

@interface GW2Region : NSObject <NSCopying, NSCoding>

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) CGPoint labelCenter;
@property (nonatomic, strong) NSArray *maps;

@end

@interface GW2RegionMap : NSObject <NSCopying, NSCoding>

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger minLevel;
@property (nonatomic, assign) NSInteger maxLevel;
@property (nonatomic, assign) NSInteger defaultFloor;
@property (nonatomic, assign) CGRect mapRect;
@property (nonatomic, assign) CGRect continentRect;
@property (nonatomic, strong) NSArray *POIs;
@property (nonatomic, strong) NSArray *tasks;
@property (nonatomic, strong) NSArray *skillChallenges;
@property (nonatomic, strong) NSArray *sectors;

@end

@interface GW2MapPOI : NSObject <NSCopying, NSCoding>

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) GW2POIType type;
@property (nonatomic, assign) NSInteger floor;
@property (nonatomic, assign) CGPoint coordinate;

- (NSString *)typeDescription;

@end

@interface GW2MapTask : NSObject <NSCopying, NSCoding>

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, strong) NSString *objective;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) CGPoint coordinate;

@end

@interface GW2MapSkill : NSObject <NSCopying, NSCoding>

@property (nonatomic, assign) CGPoint coordinate;

@end

@interface GW2MapSector : NSObject <NSCopying, NSCoding>

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) CGPoint coordinate;

@end