//
//  GW2Enums.h
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 27/05/13.
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

#ifndef GW2_GW2Enums_h
#define GW2_GW2Enums_h

typedef NS_ENUM(NSInteger, GW2RegionServer) {
    GW2RegionUnknown = 0,
    GW2RegionNorthAmerica = 1,
    GW2RegionEurope = 2
};

typedef NS_ENUM(NSInteger, GW2Language) {
    GW2LanguageUnknown = -1,
    GW2LanguageEnglish = 0,
    GW2LanguageFrench = 1,
    GW2LanguageGerman = 2,
    GW2LanguageSpanish = 3
};

typedef NS_ENUM(NSInteger, GW2WvWTeam) {
    GW2WvWTeamUnknown = 0,
    GW2WvWTeamRed,
    GW2WvWTeamBlue,
    GW2WvWTeamGreen
};

typedef NS_ENUM(NSInteger, GW2WvWMapType) {
    GW2WvWMapUnknown = 0,
    GW2WvWMapRed,
    GW2WvWMapBlue,
    GW2WvWMapGreen,
    GW2WvWMapCenter
};

typedef NS_ENUM(NSInteger, GW2EventStateType) {
    GW2EventStateUnknown = 0,
    GW2EventStateInactive,
    GW2EventStateWarmup,
    GW2EventStatePreparation,
    GW2EventStateActive,
    GW2EventStateSuccess,
    GW2EventStateFail
};

typedef NS_ENUM(NSInteger, GW2CraftingDiscipline) {
    GW2CraftUnknown = 0,
    GW2CraftWeaponsmith,
    GW2CraftHuntsman,
    GW2CraftArtificer,
    GW2CraftChef,
    GW2CraftJeweler,
    GW2CraftArmorsmith,
    GW2CraftLeatherworker,
    GW2CraftTailor
};

typedef NS_ENUM(NSInteger, GW2ObjectiveType) {
    GW2ObjectiveUnknown = 0,
    GW2ObjectiveCamp,
    GW2ObjectiveTower,
    GW2ObjectiveKeep,
    GW2ObjectiveCastle
};

typedef NS_ENUM(NSInteger, GW2POIType) {
    GW2POIUnknown = 0,
    GW2POILandmark,
    GW2POIWaypoint,
    GW2POIVista
};

typedef NS_ENUM(NSInteger, GW2ColorMaterial) {
    GW2ColorMaterialUnknown = 0,
    GW2ColorMaterialCloth,
    GW2ColorMaterialLeather,
    GW2ColorMaterialMetal
};

#endif
