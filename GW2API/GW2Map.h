//
//  GW2Map.h
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 05/07/13.
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

@interface GW2Map : GW2Object

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger minLevel;
@property (nonatomic, assign) NSInteger maxLevel;
@property (nonatomic, strong) NSNumber *defaultFloor;
@property (nonatomic, strong) NSArray *floors;
@property (nonatomic, strong) NSString *regionID;
@property (nonatomic, strong) NSString *regionName;
@property (nonatomic, strong) NSString *continentID;
@property (nonatomic, strong) NSString *continentName;
@property (nonatomic, assign) CGRect mapRect;
@property (nonatomic, assign) CGRect continentRect;

@end
