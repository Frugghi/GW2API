//
//  GW2MapTilesSource.m
//  GW2API for Objc
//
//  Created by Tommaso Madonia on 01/07/13.
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

#import "GW2MapTilesSource.h"

@implementation GW2MapTilesSource

- (id)init
{
    self = [super init];
	if (self) {
        [self setContinent:2];
        [self setFloor:3];
        [self setMinZoom:0];
        [self setMaxZoom:6];
    }
    
	return self;
}

- (NSURL *)URLForTile:(RMTile)tile
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"https://tiles.guildwars2.com/%d/%d/%d/%d/%d.jpg",
                                 self.continent, self.floor, tile.zoom, tile.x, tile.y]];
}

- (NSString *)uniqueTilecacheKey
{
	return [NSString stringWithFormat:@"Gw2Map_%d_%d", self.continent, self.floor];
}

- (NSString *)shortName
{
	return @"GW2 Map";
}

- (NSString *)longDescription
{
	return @"Guild Wars 2 map.";
}

- (NSString *)shortAttribution
{
	return @"© ArenaNet, LLC. All rights reserved.";
}

- (NSString *)longAttribution
{
	return @"Guild Wars 2 API © ArenaNet, LLC. All rights reserved.";
}

@end
