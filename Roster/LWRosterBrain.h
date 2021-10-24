//
//  LWRosterBrain.h
//  Roster
//
//  Created by Lennart Wisbar on 29.09.12.
//  Copyright (c) 2012 Lewisoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWPerson.h"

@interface LWRosterBrain : NSObject
@property (nonatomic, strong) NSString *profilName;
@property (nonatomic, strong) NSMutableArray *personenListe;
@property (nonatomic, strong) NSMutableArray *aufgabenListe;
@property (nonatomic, strong) NSMutableArray *zuBesetzendeTermine;
@property (nonatomic, strong) NSMutableArray *aktivePersonen;
-(void)personHinzufuegen:(NSString *)name istAktiv:(BOOL)istAktiv mitAufgaben:(NSMutableArray *)aufgaben insgesamtSoOftEinteilen:(int)haeufigkeit kannAnDiesenTerminen:(NSMutableArray *)termine;
-(void)personEntfernen:(LWPerson *)person;
-(void)aufgabeHinzufuegen:(NSString *)aufgabe;
-(void)aufgabeEntfernen:(NSString *)aufgabe;
-(void)terminHinzufuegen:(NSString *)termin;
-(void)terminEntfernen:(NSString *)termin;
-(NSArray *)einteilungStarten;

@end