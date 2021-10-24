//
//  LWRosterBrain.m
//  Roster
//
//  Created by Lennart Wisbar on 29.09.12.
//  Copyright (c) 2012 Lewisoft. All rights reserved.
//

#import "LWRosterBrain.h"

//@interface Settings : NSObject<NSCoding> {  // Damit man speichern und laden kann
//}
//@end

@implementation LWRosterBrain

@synthesize profilName = _profilName;
@synthesize personenListe = _personenListe;
@synthesize aufgabenListe = _aufgabenListe;
@synthesize zuBesetzendeTermine = _zuBesetzendeTermine;
@synthesize aktivePersonen = _aktivePersonen;

#pragma mark - Getter
- (NSString *)profilName
{
    if (!_profilName)
    {
        _profilName = [[NSString alloc]init];
    }
    return _profilName;
}

// Enthält alle (LWPerson)Personen der Brain-Instanz (d.h. des Profils)
- (NSMutableArray *)personenListe
{
    if (!_personenListe)
    {
        _personenListe = [[NSMutableArray alloc] init];
    }
    return _personenListe;
}

// Enthält alle (NSString *)Aufgaben der Brain-Instanz
- (NSMutableArray *)aufgabenListe
{
    if (!_aufgabenListe)
    {
        _aufgabenListe = [[NSMutableArray alloc] init];
    }
    return _aufgabenListe;
}

// Enthält alle Termine der Brain-Instanz. (Ein Termin ist ein Array aus den an ihm eingeteilten Personen. An der Reihenfolge der Personen erkennt man, wer für welche Aufgabe eingeteilt ist.) <--Das stimmt so nicht mehr.
- (NSMutableArray *)zuBesetzendeTermine
{
    if (!_zuBesetzendeTermine)
    {
        _zuBesetzendeTermine = [[NSMutableArray alloc] init];
    }
    return _zuBesetzendeTermine;
}

#pragma mark - Die Hilfliste "Aktive Personen"
-(NSMutableArray *)aktivePersonen
{
    if (!_aktivePersonen)
    {
        _aktivePersonen = [[NSMutableArray alloc] init];
    }
    return _aktivePersonen;
}

-(void)aktivePersonenZusammenstellen
{
    [self.aktivePersonen removeAllObjects];
    // Liste der aktiven Personen zusammenstellen
    for (LWPerson *person in self.personenListe)
    {
        if (person.istAktiv == YES)
        {
            [self.aktivePersonen addObject:person];
        }
    }
}

#pragma mark - Das Model verwalten
// Kann von außen aufgerufen werden, um eine Person mit ihren Parametern hinzuzufügen.
-(void)personHinzufuegen:(NSString *)name istAktiv:(BOOL)istAktiv mitAufgaben:(NSMutableArray *)aufgaben insgesamtSoOftEinteilen:(int)haeufigkeit kannAnDiesenTerminen:(NSMutableArray *)termine
{
    [self.personenListe addObject:[LWPerson
                                   neuePersonMitNamen:name
                                   istAktiv:istAktiv
                                   machtdieseAufgaben:aufgaben
                                   insgesamtSoOftEinteilen:haeufigkeit
                                   kannAnDiesenTerminen:termine]];
}


// TO-DO. Einfach nach Person mit dem Namen suchen und löschen. Vielleicht auch lieber NSString übergeben statt LWPerson.
-(void)personEntfernen:(LWPerson *)person
{
    [self.personenListe removeObject:person];
}

// Kann benutzt werden, um einzelne Aufgaben zur Aufgabenliste hinzuzufügen.
-(void)aufgabeHinzufuegen:(NSString *)aufgabe
{
    [self.aufgabenListe addObject:aufgabe];
}

-(void)aufgabeEntfernen:(NSString *)aufgabe
{
    [self.aufgabenListe removeObjectIdenticalTo:aufgabe];
}

// Damit kann man einzelne Termine hinzufügen.
-(void)terminHinzufuegen:(NSString *)termin
{
    [self.zuBesetzendeTermine addObject:termin];
}

-(void)terminEntfernen:(NSString *)termin
{
    [self.zuBesetzendeTermine removeObjectIdenticalTo:termin];
}


#pragma mark - Die eigentliche Einteilung
// Führt die Einteilung durch.
- (NSArray *)einteilungStarten
{
    [self aktivePersonenZusammenstellen];
    self.aktivePersonen = [self personenAufsteigendNachVerfuegbarkeitOrdnen:self.aktivePersonen];
    [self haeufigkeitAusgleichen];
    [self schonSoOftEingeteiltAufNullSetzen];
    NSArray *vorlaeufigeEinteilung = [self einteilungsSchleife];
    return [self einteilungOptimieren:vorlaeufigeEinteilung];
}

- (NSArray *)einteilungsSchleife
{
    // NSMutableArray *einteilung enthält eine Liste der (NS Array)Terminobjekte. Diese wiederum enthalten Listen der eingeteilten (LWPerson)Personen, deren Index für die Aufgaben an dem jeweiligen Termin steht. Die Person an Index 3 macht also Aufgabe 3.
    NSMutableArray *einteilung = [[NSMutableArray alloc] init];
    NSString *aktuellerTermin = [[NSString alloc] init];;
    NSString *aktuelleAufgabe = [[NSString alloc] init];;
    LWPerson *aktuellePerson = [[LWPerson alloc] init];
    NSMutableArray *besetzungFuerDiesenTermin = [[NSMutableArray alloc] init];
    NSMutableArray *infrageKommendePersonen = [[NSMutableArray alloc] init];
    
    for (aktuellerTermin in self.zuBesetzendeTermine)
    {
        [besetzungFuerDiesenTermin removeAllObjects];
        for (aktuelleAufgabe in self.aufgabenListe)
        {
            [infrageKommendePersonen removeAllObjects];
            for (aktuellePerson in self.aktivePersonen)
            {
                if (([aktuellePerson.machtDieseAufgaben containsObject:aktuelleAufgabe]) && ([aktuellePerson.kannAnDiesenTerminen containsObject:aktuellerTermin]) && (aktuellePerson.schonSoOftEingeteilt < aktuellePerson.heruntergerechneterHaeufigkeitswunsch) &&
                (![besetzungFuerDiesenTermin containsObject:aktuellePerson]))  // Man sollte nicht für zwei Aufgaben auf einmal eingeteilt werden.
                {
                    [infrageKommendePersonen addObject:aktuellePerson];
                }
            }
            // Aus den jeweils in Frage kommenden Personen wird diejenige ausgewählt und für den aktuellen Termin eingeteilt, die aufgrund verschiedener Kriterien am Besten geeignet ist.
            [besetzungFuerDiesenTermin addObject:[self werSollteJetztAmBestenEingeteiltWerden:infrageKommendePersonen]];
            [[besetzungFuerDiesenTermin lastObject] setSchonSoOftEingeteilt:[[besetzungFuerDiesenTermin lastObject] schonSoOftEingeteilt] +1];
            NSLog(@"%@", [besetzungFuerDiesenTermin lastObject]);
        }
        [einteilung addObject:[besetzungFuerDiesenTermin copy]];
    }
    return [einteilung copy]; //Gibt eine unveränderbare Kopie zurück.
}

// Wird aufgerufen, nachdem die Personen aussortiert wurden, die nicht in Frage kommen. Findet heraus, welche Person von den in Frage Kommenden am Besten für die gerade zur Frage stehende Aufgabe eingeteilt werden sollte, anhand verschiedener Kriterien...
- (LWPerson *)werSollteJetztAmBestenEingeteiltWerden:(NSArray *)inFrageKommendePersonen
{
    LWPerson *result = [[LWPerson alloc] init];
    
    if (inFrageKommendePersonen.count)  //checkt, ob der Array leer ist
    {
        int indexDerFuehrendenPerson = 0;
        int indexDerAktuellenTestperson = 1;
        while (indexDerAktuellenTestperson < inFrageKommendePersonen.count)
        {
            LWPerson *fuehrendePerson = [inFrageKommendePersonen objectAtIndex:indexDerFuehrendenPerson];
            LWPerson *aktuelleTestperson = [inFrageKommendePersonen objectAtIndex:indexDerAktuellenTestperson];
            float anteilDerFuehrendenPerson = fuehrendePerson.schonSoOftEingeteilt / fuehrendePerson.heruntergerechneterHaeufigkeitswunsch;
            float anteilDerAktuellenTestperson = aktuelleTestperson.schonSoOftEingeteilt / fuehrendePerson.heruntergerechneterHaeufigkeitswunsch;
            
            if (anteilDerFuehrendenPerson > anteilDerAktuellenTestperson)
            {
                indexDerFuehrendenPerson = indexDerAktuellenTestperson;
            }
            indexDerAktuellenTestperson++;
        }
        result = [inFrageKommendePersonen objectAtIndex:indexDerFuehrendenPerson];
    }
    
    return result;
}


#pragma mark Optimierung
- (NSArray *)einteilungOptimieren:(NSArray *)vorlaeufigeEinteilung
{
    // Wenn Leute aufgrund ungünstiger Termine weniger eingeteilt wurden, als sie könnten, so dass unnötige Lücken entstehen, wird versucht zu tauschen.
    vorlaeufigeEinteilung = [self zuWenigOptimieren:vorlaeufigeEinteilung];
    // Wenn Leute mehrmals direkt hintereinander dran sind, wird versucht zu tauschen.
    vorlaeufigeEinteilung = [self zuOftHintereinanderOptimieren:vorlaeufigeEinteilung];
    // Wenn Leute zu lange am Stück nicht dran sind, wird versucht zu tauschen.
    return [self zuLangeNichtOptimieren:vorlaeufigeEinteilung];
}

// Problem 1: Zu selten eingeteilt durch ungünstige Verteilungs-Terminkonstellation
- (NSArray *)zuWenigOptimieren:(NSArray *)vorlaeufigeEinteilung
{
    for (LWPerson *einePerson in self.aktivePersonen)
    {
        double differenz = einePerson.heruntergerechneterHaeufigkeitswunsch - einePerson.schonSoOftEingeteilt;
        if (differenz >= 1)
        {
            vorlaeufigeEinteilung = [self personDurchTauschenMehrEinteilen:einePerson inEinteilung:vorlaeufigeEinteilung mitDifferenz:differenz];
        }
    }
    return vorlaeufigeEinteilung;
}
- (NSArray *)personDurchTauschenMehrEinteilen:(LWPerson *)person inEinteilung:(NSArray *)vorlaeufigeEinteilung mitDifferenz:(double)differenz
{
    // Wo sind Aufgaben frei, die die Person macht (außer an den Terminen, wo die Person schon eingeteilt ist)?
    for (NSString *eineAufgabe in person.machtDieseAufgaben)
    {
        for (NSArray *einTermin in vorlaeufigeEinteilung)
        {
            LWPerson *eingeteiltePerson = [einTermin objectAtIndex:[self.aufgabenListe indexOfObject:eineAufgabe]];
            if ([eingeteiltePerson.name hasPrefix:@"STROHPUPPE"] || (eingeteiltePerson.name == nil)) // Niemand (echtes) ist für die Aufgabe eingeteilt
            {
                // Aus den Terminen, an denen person kann, ausprobieren, woher jemand auf den freien Termin rutschen kann
                vorlaeufigeEinteilung = [self versuchenDurchBesetzungVonFreiemTerminMehrEinzuteilen:person inEinteilung:vorlaeufigeEinteilung mitFreiemTermin:einTermin mitAufgabe:eineAufgabe mitDifferenz:&differenz];
                if (differenz < 1)
                {
                    return vorlaeufigeEinteilung;   // Wenn oft genug eingeteilt, dann Schluss.
                }
            }
        }
    }
    return vorlaeufigeEinteilung;   // Wenn nicht oft genug eingeteilt, aber alles versucht, dann trotzdem Schluss.
}
- (NSArray *)versuchenDurchBesetzungVonFreiemTerminMehrEinzuteilen:(LWPerson *)person inEinteilung:(NSArray *)vorlaeufigeEinteilung mitFreiemTermin:(NSArray *)freierTermin mitAufgabe:(NSString *)aufgabe mitDifferenz:(double *)differenz
{
    NSMutableArray *mutableVorlaeufigeEinteilung = [vorlaeufigeEinteilung mutableCopy];
    NSMutableArray *mutableFreierTermin = [freierTermin mutableCopy];
    NSString *freierTerminAlsString = [self.zuBesetzendeTermine objectAtIndex:[vorlaeufigeEinteilung indexOfObject:freierTermin]];
    
    // Wenn die Person an dem freien Termin kann: Einteilen. Sonst versuchen einen Tauschpartner zu finden.
    if ([person.kannAnDiesenTerminen containsObject:freierTerminAlsString] && ![freierTermin containsObject:person])
    {
            [mutableFreierTermin replaceObjectAtIndex:[self.aufgabenListe indexOfObject:aufgabe] withObject:person];
            [mutableVorlaeufigeEinteilung replaceObjectAtIndex:[vorlaeufigeEinteilung indexOfObject:freierTermin] withObject:[mutableFreierTermin copy]];
            *differenz = *differenz - 1;
    }
    else
    {
        for (NSArray *einTermin in vorlaeufigeEinteilung)
        {
            if (*differenz > 0)
            {
                NSMutableArray *mutableEinTermin = [einTermin mutableCopy];
                NSString *einTerminAlsString = [self.zuBesetzendeTermine objectAtIndex:[vorlaeufigeEinteilung indexOfObject:einTermin]];
                NSUInteger *aufgabenIndex =[self.aufgabenListe indexOfObject:aufgabe];
                LWPerson *tauschpartner = [einTermin objectAtIndex:aufgabenIndex];
                // Wenn person an dem Termin kann und die an dem Termin zu der Aufgabe eingeteilte Person an dem freien Termin kann, und beide an ihrem Zieltermin noch nicht eingeteilt sind: Tauschen!
                if ([person.kannAnDiesenTerminen containsObject:einTerminAlsString]
                    && [tauschpartner.kannAnDiesenTerminen containsObject:freierTerminAlsString]
                    && ![einTermin containsObject:person]
                    && ![freierTermin containsObject:tauschpartner])
                {
                    // Tauschen
                    [mutableEinTermin replaceObjectAtIndex:aufgabenIndex withObject:person];
                    [mutableFreierTermin replaceObjectAtIndex:aufgabenIndex withObject:tauschpartner];
                    [mutableVorlaeufigeEinteilung replaceObjectAtIndex:[vorlaeufigeEinteilung indexOfObject:einTermin] withObject:[mutableEinTermin copy]];
                    [mutableVorlaeufigeEinteilung replaceObjectAtIndex:[vorlaeufigeEinteilung indexOfObject:freierTermin] withObject:[mutableFreierTermin copy]];
                    // Wenn es klappt, dann differenz einen runtersetzen.
                    *differenz = *differenz - 1;
                }
            }
        }
    }
    return [mutableVorlaeufigeEinteilung copy];
}

// Problem 2: Zu oft am Stück eingeteilt
- (NSArray *)zuOftHintereinanderOptimieren:(NSArray *)vorlaeufigeEinteilung
{
    for (LWPerson *einePerson in self.aktivePersonen)
    {
        int direktHintereinander = 0;
        for (NSArray *einTermin in vorlaeufigeEinteilung)
        {
            if ([einTermin containsObject:einePerson])
            {
                direktHintereinander++;
            }
            else
            {
                direktHintereinander = 0;
            }
            if (direktHintereinander > 1)   // Hier kann man justieren. 1 bedeutet, dass versucht wird, dass man nicht mal 2x hintereinander dran ist.
            {
                // Wenn es klappt, direktHintereinander wieder auf 0 setzen, sonst nicht. Vorlaeufige Einteilung als Pointer übergeben und als Rückgabewert BOOL.
                if ([self personAusZuLangerSerieHeraustauschen:einePerson inEinteilung:&vorlaeufigeEinteilung anTermin:einTermin])
                {
                    direktHintereinander = 0;
                }

                
            }
        }
    }
    return vorlaeufigeEinteilung;
}
- (BOOL)personAusZuLangerSerieHeraustauschen:(LWPerson *)person inEinteilung:(NSArray **)vorlaeufigeEinteilung anTermin:(NSArray *)ausgangstermin
{
    // Hier muss unbedingt schon geguckt werden, ob der Tausch eine Verbesserung bringt. Sonst wird alles so gelassen. D.h. der Tausch darf nicht bewirken, dass eine Person zu oft hintereinander (d.h. ist sie direkt vor oder nach dem Termin schon eingeteilt?) oder zu lange nicht (d.h. ist sie soundso lange vor und nach dem Zieltermin nicht dran? Das muss natürlich im Verhältnis zur gewünschten Häufigkeit stehen, kann kein absoluter Wert sein) eingeteilt wird, weder die einePerson, noch die, mit der getauscht wird. Außerdem wird natürlich vor dem Tausch geguckt, ob beide Personen an dem neuen ihnen zugedachten Termin können. BIS JETZT WIRD NUR GEGUCKT, OB DER TAUSCH VON DEN TERMINEN HER MÖGLICH IST, NICHT OB ER EINE VERBESSERUNG BRINGT!
    
    NSMutableArray *mutableVorlaeufigeEinteilung = [*vorlaeufigeEinteilung mutableCopy];
    NSMutableArray *mutableAusgangstermin = [ausgangstermin mutableCopy];
    NSString *ausgangsterminAlsString = [self.zuBesetzendeTermine objectAtIndex:[*vorlaeufigeEinteilung indexOfObject:ausgangstermin]];
    for (NSArray *einTermin in *vorlaeufigeEinteilung)
    {
        NSMutableArray *mutableEinTermin = [einTermin mutableCopy];
        NSString *einTerminAlsString = [self.zuBesetzendeTermine objectAtIndex:[*vorlaeufigeEinteilung indexOfObject:einTermin]];
        NSUInteger *aufgabenIndex =[ausgangstermin indexOfObject:person];
        LWPerson *tauschpartner = [einTermin objectAtIndex:aufgabenIndex];
        // Wenn person an dem Termin kann und die an dem Termin zu der Aufgabe eingeteilte Person an dem Ausgangstermin kann, und beide an ihrem Zieltermin noch nicht eingeteilt sind: Tauschen!
        if ([person.kannAnDiesenTerminen containsObject:einTerminAlsString]
            && [tauschpartner.kannAnDiesenTerminen containsObject:ausgangsterminAlsString]
            && ![einTermin containsObject:person]
            && ![ausgangstermin containsObject:tauschpartner])
        {
            // Tauschen - NEIN, HIER MÜSSEN ERSTMAL DIE METHODEN AUFGERUFEN WERDEN, DIE PRÜFEN, OB DER TAUSCH EINE VERBESSERUNG BRINGT
            [mutableEinTermin replaceObjectAtIndex:aufgabenIndex withObject:person];
            [mutableAusgangstermin replaceObjectAtIndex:aufgabenIndex withObject:tauschpartner];
            [mutableVorlaeufigeEinteilung replaceObjectAtIndex:[*vorlaeufigeEinteilung indexOfObject:einTermin] withObject:[mutableEinTermin copy]];
            [mutableVorlaeufigeEinteilung replaceObjectAtIndex:[*vorlaeufigeEinteilung indexOfObject:ausgangstermin] withObject:[mutableAusgangstermin copy]];
        }
    }
    // WENN DER TAUSCH GEKLAPPT HAT: YES, SONST: NO.
    return YES;
}

// Problem 3: Zu lange am Stück nicht eingeteilt (zu lange Pause)
- (NSArray *)zuLangeNichtOptimieren:(NSArray *)vorlaeufigeEinteilung
{
    for (LWPerson *einePerson in self.aktivePersonen)
    {
        int toleranz = 3;   // Hier muss man vielleicht noch justieren.
        int hoechstabstand = [self.zuBesetzendeTermine count] / einePerson.heruntergerechneterHaeufigkeitswunsch + toleranz;
        int hintereinanderNichtEingeteilt = 0;
        for (NSArray *einTermin in vorlaeufigeEinteilung)
        {
            if (![einTermin containsObject:einePerson])
            {
                hintereinanderNichtEingeteilt++;
                
                // Sonderfall: Wenn die Lücke bis zum letzten Termin geht, muss auf besondere Weise verfahren werden, d.h. der Index ist einen niedriger als normal, weil die Lücke nicht mit einem besetzten Termin enden kann, sondern der Array einfach zu Ende ist.
                if ([vorlaeufigeEinteilung indexOfObject:einTermin] == ([vorlaeufigeEinteilung count] -1))
                {
                    unsigned long indexDesLetztenTerminsDerLuecke = [vorlaeufigeEinteilung indexOfObject:einTermin];
                    if (hintereinanderNichtEingeteilt > hoechstabstand)
                    {
                        vorlaeufigeEinteilung = [self personInZuLangePauseHineintauschen:einePerson inEinteilung:vorlaeufigeEinteilung mitLetztemTerminIndex:indexDesLetztenTerminsDerLuecke undLueckenlaenge:hintereinanderNichtEingeteilt];
                    }
                    hintereinanderNichtEingeteilt = 0;
                }
            }
            // Wenn nach der Luecke das erste Mal wieder ein besetzter Termin kommt, wird ausgewertet, wie lang die Luecke war
            else
            {
                if (hintereinanderNichtEingeteilt > hoechstabstand)
                {
                    unsigned long indexDesLetztenTerminsDerLuecke = [vorlaeufigeEinteilung indexOfObject:einTermin] -1;
                    vorlaeufigeEinteilung = [self personInZuLangePauseHineintauschen:einePerson inEinteilung:vorlaeufigeEinteilung mitLetztemTerminIndex:indexDesLetztenTerminsDerLuecke undLueckenlaenge:hintereinanderNichtEingeteilt];
                }
                hintereinanderNichtEingeteilt = 0;
            }
        }
    }
    return vorlaeufigeEinteilung;
}
- (NSArray *)personInZuLangePauseHineintauschen:(LWPerson *)einePerson inEinteilung:(NSArray *)vorlaeufigeEinteilung mitLetztemTerminIndex:(unsigned long)terminIndex undLueckenlaenge:(int)laenge
{
    
    return vorlaeufigeEinteilung;
}


#pragma mark Häufigkeit ausgleichen
// TODO: Häufigkeit zu allgemein
// Hat jemand mehrere Aufgaben und eine davon ist überbesetzt, wird seine gesamte Häufigkeit runtergerechnet. Im Extremfall wird jemand daher nur einmal eingeteilt, obwohl er viel öfter könnte, und sein eines Instrument bleibt an allen anderen Terminen unnötigerweise unbesetzt!
// Runterrechnen oder freie Plätze mit Strohpuppen füllen
// Außerdem stimmt was mit den Checkboxen nicht.
- (void) haeufigkeitAusgleichen
{
    int strohpuppennummer = 1;
    int plaetze = (int)[self.zuBesetzendeTermine count];
    
    for (NSString *eineAufgabe in self.aufgabenListe)
    {
        double addierteGewuenschteHaeufigkeitAllerPersonen = 0;
        for (LWPerson *einePerson in self.aktivePersonen)	// Wie oft wird diese Aufgabe besetzt?
        {
            if ([einePerson.machtDieseAufgaben containsObject:eineAufgabe])
            {
                addierteGewuenschteHaeufigkeitAllerPersonen = addierteGewuenschteHaeufigkeitAllerPersonen + (einePerson.haeufigkeitswunsch / [einePerson.machtDieseAufgaben count]);
            }
        }
        
        double unbesetzbareTermine = plaetze - addierteGewuenschteHaeufigkeitAllerPersonen;	  // Wie viele Termine werden unbesetzt bleiben bzw. gibt es einen Überschuss?
        
        if (unbesetzbareTermine >= 1)       // Bleiben Plätze übrig? -> Mit Strohpuppen auffüllen
        {
            NSString *strohpuppenName = [self namensGenerator:@"STROHPUPPE" nummer:strohpuppennummer];
            [self.aktivePersonen addObject:[LWPerson neuePersonMitNamen:strohpuppenName istAktiv:YES machtdieseAufgaben:[NSMutableArray arrayWithObject:eineAufgabe] insgesamtSoOftEinteilen:unbesetzbareTermine kannAnDiesenTerminen:self.zuBesetzendeTermine]];
            strohpuppennummer ++;
        }
        else if (unbesetzbareTermine <= -1)      // Zu wenige Plätze -> runterrechnen
        {
            double divisor = addierteGewuenschteHaeufigkeitAllerPersonen / plaetze;
            for (LWPerson *einePerson in self.aktivePersonen)
            {
                if ([einePerson.machtDieseAufgaben containsObject:eineAufgabe])
                {
                    einePerson.heruntergerechneterHaeufigkeitswunsch = einePerson.haeufigkeitswunsch / divisor;
                }
            }
        }
    }
}


// Namengenerator, erzeugt einen Namen mit Nummer für die Strohpuppen. Benutzt in -(void)haeufigkeitAusgleichen.
- (NSString *)namensGenerator:(NSString *)grundString nummer:(int)nummer
{    
    NSString* endString = [grundString stringByAppendingString:[@(nummer) description]];
    return endString;
}

#pragma mark Personen vorbereiten
- (void)schonSoOftEingeteiltAufNullSetzen
{
    for (LWPerson *einePerson in self.aktivePersonen)
    {
        einePerson.schonSoOftEingeteilt = 0;
    }
}

#pragma mark Aktive Personen danach ordnen, wer am seltensten kann
- (NSMutableArray *)personenAufsteigendNachVerfuegbarkeitOrdnen:(NSMutableArray *)zuOrdnendePersonen
{
    NSMutableArray *geordneterPersonenArray = [[NSMutableArray alloc] init];
    
    while ([zuOrdnendePersonen count] > 0)
    {
        LWPerson *fuehrendePerson = [zuOrdnendePersonen objectAtIndex:0];
        NSUInteger geringsteVerfuegbarkeit = [fuehrendePerson.kannAnDiesenTerminen count];

        for (LWPerson *einePerson in zuOrdnendePersonen)
        {
            if ([einePerson.kannAnDiesenTerminen count] < geringsteVerfuegbarkeit)
            {
                geringsteVerfuegbarkeit = [einePerson.kannAnDiesenTerminen count];
                fuehrendePerson = einePerson;
            }
        }
        [geordneterPersonenArray addObject:fuehrendePerson];
        [zuOrdnendePersonen removeObject:fuehrendePerson];
    }
    
    return geordneterPersonenArray;
}


//    // 3. An wie wenigen Terminen können die Leute?            -  Je weniger, desto höher der Wert
//    // testpersonen = [self anJeWenigerTerminenManKannDestoGerechter:testpersonen];
//
//    // 5. Nicht immer für die gleiche Aufgabe einteilen. Wenn die Person schon an mehr Terminen für diese Aufgabe eingeteilt wurde als für eine andere, dann lieber auf die nächste warten. Das sollte man aber später am Besten prozentual einstellen können.
//    testpersonen = [self nichtImmerFuerDieselbeAufgabeEinteilen:testpersonen mitBisherigerEinteilung:einteilung undAktuellemAufgabenIndex:aufgabenIndex];



//// ALTE GERECHTIGKEITSMETHODEN:

//
//// 3. An je weniger Terminen eine Person kann, desto gerechter
//- (NSArray *)anJeWenigerTerminenManKannDestoGerechter:(NSArray *)testpersonen
//{
//    for (LWPerson *jedeTestperson in testpersonen)
//    {
//        jedeTestperson.gerechtikeitsWert -= [jedeTestperson.kannAnDiesenTerminen count] / 3; //wird zu 1/3 gewertet
//    }
//    return testpersonen;
//}

//
//// 5. Personen mit mehreren Aufgaben sollen nicht immer für dieselbe Aufgabe eingeteilt werden
//- (NSArray *)nichtImmerFuerDieselbeAufgabeEinteilen:(NSArray *)testpersonen mitBisherigerEinteilung:(NSArray *)einteilung undAktuellemAufgabenIndex:(int)aufgabenIndex
//{
//    for (LWPerson *jedeTestperson in testpersonen)
//    {
//        BOOL wurdeNochNichtZuOftFuerDieselbeAufgabeEingeteilt = NO;
//        int soOftFuerDieAktuelleAufgabeeingeteilt = 0;
//        for (NSArray *jederTermin in einteilung)
//        {
//            if ([[jederTermin objectAtIndex:aufgabenIndex] isEqualTo:jedeTestperson])
//            {
//                soOftFuerDieAktuelleAufgabeeingeteilt ++;
//            }
//        }
//        for (NSString *jedeAufgabe in jedeTestperson.machtDieseAufgaben)
//        {
//            int soOftFuerEineAndereAufgabeEingeteilt = 0;
//            NSUInteger indexDerAnderenAufgabe = [self.aufgabenListe indexOfObject:jedeAufgabe];
//            for (NSArray *jederTermin in einteilung)
//            {
//                if ([[jederTermin objectAtIndex:indexDerAnderenAufgabe] isEqualTo:jedeTestperson])
//                {
//                    soOftFuerEineAndereAufgabeEingeteilt ++;
//                }
//            }
//            if (soOftFuerEineAndereAufgabeEingeteilt > soOftFuerDieAktuelleAufgabeeingeteilt)  // Ich versteh nicht, warum es nur mit >, aber nicht mit >= klappt
//            {
//                wurdeNochNichtZuOftFuerDieselbeAufgabeEingeteilt = YES;
//                break;
//            }
//        }
//        if (!wurdeNochNichtZuOftFuerDieselbeAufgabeEingeteilt)
//        {
//            jedeTestperson.gerechtikeitsWert -= [self.zuBesetzendeTermine count] /3;
//        }
//    }
//    return testpersonen;
//}



#pragma mark - Zum Speichern und Laden
// Zum Speichern und Laden nötig
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.profilName forKey:@"profilName"];
    [coder encodeObject:self.personenListe forKey:@"personenListe"];    // Enthält custom objects, LWPerson muss also auch zum NSCoding protocol conformen
    [coder encodeObject:self.aufgabenListe forKey:@"aufgabenListe"];
    [coder encodeObject:self.zuBesetzendeTermine forKey:@"zuBesetzendeTermine"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    
    self.profilName = [coder decodeObjectForKey:@"profilName"];
    self.personenListe = [coder decodeObjectForKey:@"personenListe"];
    self.aufgabenListe = [coder decodeObjectForKey:@"aufgabenListe"];
    self.zuBesetzendeTermine = [coder decodeObjectForKey:@"zuBesetzendeTermine"];
 	
    return self;
}

@end
