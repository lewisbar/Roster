//
//  LWPerson.m
//  Roster
//
//  Created by Lennart Wisbar on 29.09.12.
//  Copyright (c) 2012 Lewisoft. All rights reserved.
//

#import "LWPerson.h"

@implementation LWPerson
@synthesize name = _name;
@synthesize machtDieseAufgaben = _machtDieseAufgaben;
@synthesize kannAnDiesenTerminen = _kannAnDiesenTerminen;
@synthesize haeufigkeitswunsch = _haeufigkeitswunsch;
@synthesize heruntergerechneterHaeufigkeitswunsch = _heruntergerechneterHaeufigkeitswunsch;
@synthesize schonSoOftEingeteilt = _schonSoOftEingeteilt;
// @synthesize gerechtikeitsWert = _gerechtikeitsWert;
@synthesize istAktiv = _istAktiv;
// @synthesize anteiligInsgesamtSoOftEinteilen = _anteiligInsgesamtSoOftEinteilen;
// @synthesize bisherigerAnteilAmZielanteil = _bisherigerAnteilAmZielanteil;


- (void)setHaeufigkeitswunsch:(double)haeufigkeit
{
    _haeufigkeitswunsch = haeufigkeit;
    self.heruntergerechneterHaeufigkeitswunsch = haeufigkeit;
}


+(LWPerson *)neuePersonMitNamen:(NSString *)name istAktiv:(BOOL)istAktiv machtdieseAufgaben:(NSArray *)aufgaben insgesamtSoOftEinteilen:(double)haeufigkeit kannAnDiesenTerminen:(NSArray *)termine
{
    LWPerson *person = [[LWPerson alloc] init];
    person.name = name;
    person.istAktiv = istAktiv;
    person.machtDieseAufgaben = [aufgaben mutableCopy];
    person.haeufigkeitswunsch = haeufigkeit;
    person.kannAnDiesenTerminen = [termine mutableCopy];
    return person;
}


#pragma mark - Zum Speichern und Laden
// Zum Speichern und Laden nötig
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.machtDieseAufgaben forKey:@"machtDieseAufgaben"];
    [coder encodeObject:self.kannAnDiesenTerminen forKey:@"kannAnDiesenTerminen"];
    [coder encodeFloat:self.haeufigkeitswunsch forKey:@"insgesamtSoOftEinteilen"];
    [coder encodeBool:self.istAktiv forKey:@"istAktiv"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    self.name = [coder decodeObjectForKey:@"name"];
    self.machtDieseAufgaben = [coder decodeObjectForKey:@"machtDieseAufgaben"];
    self.kannAnDiesenTerminen = [coder decodeObjectForKey:@"kannAnDiesenTerminen"];
    self.haeufigkeitswunsch = [coder decodeFloatForKey:@"insgesamtSoOftEinteilen"];
    self.istAktiv = [coder decodeBoolForKey:@"istAktiv"];
    
    return self;
}

- (NSString *)description
{
    return self.name;
}

//- (NSString *)name
//{
//    if (!_name)
//    {
//        _name = [[NSString alloc] init];
//    }
//    return _name;
//}
//
//- (NSArray *)machtDieseAufgaben
//{
//    if (!_machtDieseAufgaben)
//    {
//        _machtDieseAufgaben = [[NSArray alloc] init];
//    }
//    return _machtDieseAufgaben;
//}
//
//- (NSArray *)kannAnDiesenTerminen
//{
//    if (!_kannAnDiesenTerminen)
//    {
//        _kannAnDiesenTerminen = [[NSArray alloc] init];
//    }
//    return _kannAnDiesenTerminen;
//}
//
//- (float)gerechtikeitsWert
//{
//    if (!_gerechtikeitsWert)
//    {
//        _gerechtikeitsWert = 0;
//    }
//    return _gerechtikeitsWert;
//}
//
//- (float)insgesamtSoOftEinteilen
//{
//    if (!_insgesamtSoOftEinteilen)
//    {
//        _insgesamtSoOftEinteilen = 0;
//    }
//    return _insgesamtSoOftEinteilen;
//}

@end
