//
//  LWPerson.h
//  Roster
//
//  Created by Lennart Wisbar on 29.09.12.
//  Copyright (c) 2012 Lewisoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWPerson : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *machtDieseAufgaben;
@property (nonatomic, strong) NSMutableArray *kannAnDiesenTerminen;
@property (nonatomic) double haeufigkeitswunsch;
@property (nonatomic) double heruntergerechneterHaeufigkeitswunsch;
@property (nonatomic) int schonSoOftEingeteilt;
// @property (nonatomic) float gerechtikeitsWert;
@property (nonatomic) BOOL istAktiv;
// @property (nonatomic) double anteiligInsgesamtSoOftEinteilen;
// @property (nonatomic) double bisherigerAnteilAmZielanteil;
+(LWPerson *)neuePersonMitNamen:(NSString *)name istAktiv:(BOOL)istAktiv machtdieseAufgaben:(NSArray *)aufgaben insgesamtSoOftEinteilen:(double)haeufigkeit kannAnDiesenTerminen:(NSArray *)termine;
@end
