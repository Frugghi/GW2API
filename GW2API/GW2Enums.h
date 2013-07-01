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

typedef enum {
    GW2RegionUnknown = 0,
    GW2RegionNorthAmerica = 1,
    GW2RegionEurope = 2
} GW2Region;

typedef enum {
    GW2LanguageUnknown = -1,
    GW2LanguageEnglish = 0,
    GW2LanguageFrench = 1,
    GW2LanguageGerman = 2,
    GW2LanguageSpanish = 3
} GW2Language;

typedef enum {
    GW2WvWTeamUnknown = 0,
    GW2WvWTeamRed,
    GW2WvWTeamBlue,
    GW2WvWTeamGreen
} GW2WvWTeam;

typedef enum {
    GW2WvWMapUnknown = 0,
    GW2WvWMapRed,
    GW2WvWMapBlue,
    GW2WvWMapGreen,
    GW2WvWMapCenter
} GW2WvWMapType;

typedef enum {
    GW2EventStateUnknown = 0,
    GW2EventStateInactive,
    GW2EventStateWarmup,
    GW2EventStatePreparation,
    GW2EventStateActive,
    GW2EventStateSuccess,
    GW2EventStateFail
} GW2EventStateType;

typedef enum {
    GW2ProfessionUnknown = 0,
    GW2ProfessionWeaponsmith,
    GW2ProfessionHuntsman,
    GW2ProfessionArtificer,
    GW2ProfessionChef,
    GW2ProfessionJeweler,
    GW2ProfessionArmorsmith,
    GW2ProfessionLeatherworking,
    GW2ProfessionTailor
} GW2Profession;

typedef enum {
    GW2ObjectiveUnknown = 0,
    GW2ObjectiveCamp,
    GW2ObjectiveTower,
    GW2ObjectiveKeep,
    GW2ObjectiveCastle
} GW2ObjectiveType;

#endif
