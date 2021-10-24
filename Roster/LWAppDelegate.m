//
//  LWAppDelegate.m
//  Roster
//
//  Created by Lennart Wisbar on 29.09.12.
//  Copyright (c) 2012 Lewisoft. All rights reserved.
//


// TO-DO:
// - Das mit der Tabreihenfolge hab ich noch nicht hingekriegt, also wenn man Tab drückt, dass dann immer zwischen der Personenliste und dem Wie-Oft-Textfeld gewechselt wird, die anderen aber übergangen werden (tab order). Es funktioniert irgendwie nicht so, wie ich es im Internet gefunden habe. Das könnte aber am TableView liegen. Im Internet war es mit Textfeldern. Vielleicht springt er innerhalb des TableViews erst noch ein paar mal, bevor er weiter geht.
// (- Beim Hinzufügen einer Person wird, wenn man den Namen nicht ändert und dann Enter drückt oder außerhalb klickt, nicht neu alphabetisch sortiert, d.h. es wir nicht die tableView:setObjectValue:forTableColumn:row:-Methode aufgerufen. Das Einfachste, das mir einfällt, ist, selber eine Methode zu erstellen, die in oben genannter aufgerufen wird und die ich auch programmatisch selber aufrufen kann. Da kommt dann alles rein, was jetzt in oben genannter Methode ist. Das Problem ist: Wo rufe ich die auf??????? Oder ist es vielleicht doch gut so? Das einzige Problem gibt es, wenn manche "Neue Person"en schon eingeordnet sind und andere nicht. Dann sieht es chaotisch aus. Aber das liegt wohl am Anwender. Hm.)


#import "LWAppDelegate.h"
#import "LWRosterBrain.h"
#import "LWPerson.h"

@interface LWAppDelegate()
@property (nonatomic, strong) LWRosterBrain *brain;
@property (weak) IBOutlet NSTabView *tabview;
@property (unsafe_unretained) IBOutlet NSWindow *hauptfenster;
@property (weak) IBOutlet NSTableView *personenTableViewImPersonenTab;
@property (weak) IBOutlet NSTableView *aufgabenTableViewImPersonenTab;
@property (weak) IBOutlet NSTableView *terminTableViewImPersonenTab;
@property (weak) IBOutlet NSTableView *aufgabenTableViewImAufgabenTab;
@property (weak) IBOutlet NSTableView *personenTableViewImAufgabenTab;
@property (weak) IBOutlet NSTableView *terminTableViewImTermineTab;
@property (weak) IBOutlet NSTableView *personenTableViewImTermineTab;
@property (weak) IBOutlet NSTextField *personenLabel;
@property (weak) IBOutlet NSTextField *aufgabenLabel;
@property (weak) IBOutlet NSTextField *terminLabel;
@property (weak) IBOutlet NSTextField *wieOftTextFeld;
@property (weak) IBOutlet NSStepper *wieOftStepper;
@property (weak) IBOutlet NSButton *personenPlusButton;
@property (weak) IBOutlet NSButton *personenMinusButton;
@property (weak) IBOutlet NSButton *aufgabenPlusButton;
@property (weak) IBOutlet NSButton *aufgabenMinusButton;
@property (weak) IBOutlet NSButton *terminPlusButton;
@property (weak) IBOutlet NSButton *terminMinusButton;
@property (nonatomic, strong) NSMutableArray *personenAktivListe;
@property (nonatomic, strong) NSMutableArray *aufgabenAktivListe;
@property (nonatomic, strong) NSMutableArray *terminAktivListe;
@property (nonatomic, strong) NSMutableArray *werMachtDieseAufgabeListe;
@property (nonatomic, strong) NSMutableArray *werKannAnDiesemTerminListe;
@property (nonatomic, strong) LWPerson *ausgewaehltePerson;
@property (nonatomic, strong) NSString *ausgewaehlteAufgabe;
@property (nonatomic, strong) NSString *ausgewaehlterTermin;
- (IBAction)plusButtonGeklickt:(NSButton *)sender;
- (IBAction)minusButtonGeklickt:(NSButton *)sender;
- (IBAction)fokusZurueckAufHauptlisteSetzen:(NSTableView *)sender;
- (IBAction)controlTextDidChange:(NSTextField *)sender;
- (IBAction)wieOftStepperGeklickt:(NSStepper *)sender;
- (IBAction)oeffnenMenueGeklickt:(NSMenuItem *)sender;
- (IBAction)speichernMenueGeklickt:(NSMenuItem *)sender;
@end

@implementation LWAppDelegate

@synthesize brain = _brain;
@synthesize window = _window;
@synthesize ergebnisFeld = _ergebnisFeld;
@synthesize personenTableViewImPersonenTab = _personenTableViewImPersonenTab;
@synthesize aufgabenTableViewImPersonenTab = _aufgabenTableViewImPersonenTab;
@synthesize terminTableViewImPersonenTab = _terminTableViewImPersonenTab;
@synthesize aufgabenTableViewImAufgabenTab = _aufgabenTableViewImAufgabenTab;
@synthesize personenTableViewImAufgabenTab = _personenTableViewImAufgabenTab;
@synthesize terminTableViewImTermineTab = _terminTableViewImTermineTab;
@synthesize personenTableViewImTermineTab = _personenTableViewImTermineTab;

@synthesize personenAktivListe = _personenAktivListe;
@synthesize aufgabenAktivListe = _aufgabenAktivListe;
@synthesize terminAktivListe = _terminAktivListe;
@synthesize werMachtDieseAufgabeListe = _werMachtDieseAufgabeListe;
@synthesize werKannAnDiesemTerminListe = _werKannAnDiesemTerminListe;
@synthesize ausgewaehltePerson = _ausgewaehltePerson;
@synthesize ausgewaehlteAufgabe = _ausgewaehlteAufgabe;
@synthesize ausgewaehlterTermin = _ausgewaehlterTermin;
@synthesize hauptfenster = _hauptfenster;
@synthesize wieOftTextFeld = _wieOftTextFeld;


#pragma mark - Programmstart
- (void)testCode // später löschen
{
    // Den Profilnamen festlegen:
    // self.brain.profilName = @"Hauptgodi-Musiker";   // Vielleicht brauche ich auch keinen Profilnamen ...
    
    
 }

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    // Testcode, später enfernen    
    // [self testCode];
    
    // Damit die richtige Ansicht aktualisiert wird (s.u. die Methode)
    [self tabView:self.tabview willSelectTabViewItem:[self.tabview selectedTabViewItem]];

}


#pragma mark - Der Getter für das Model
// Der Getter für das Model. Mit lazy instantiation. Wird gebraucht, weil das Brain nicht gesondert instantiiert wird, sondern gleich Personen hinzugefügt werden. Man könnte es natürlich auch anders machen, aber so ist es glaub ich eleganter.
- (LWRosterBrain *)brain
{
    if (!_brain) _brain = [[LWRosterBrain alloc] init];
    return _brain;
}

#pragma mark - Aktivlisten
// PersonenAktivListe: Enthält nicht die aktiven Personen (wie im Brain), sondern den Aktiv-Status aller Personen in ihrer Reihenfolge. Wird als Model (Delegate?) der Aktiv-Spalte im NSTableView gebraucht.
- (NSMutableArray *)personenAktivListe
{
    if (!_personenAktivListe)
    {
        _personenAktivListe = [[NSMutableArray alloc] init];
    }
    return _personenAktivListe;
}

- (void)personenAktivListeErstellen
{
    [self.personenAktivListe removeAllObjects];
    for (LWPerson *person in self.brain.personenListe)
    {
        [self.personenAktivListe addObject:[NSNumber numberWithBool:person.istAktiv]];
    }
}

//Aufgabenaktivliste
- (NSMutableArray *)aufgabenAktivListe
{
    if (!_aufgabenAktivListe)
    {
        _aufgabenAktivListe = [[NSMutableArray alloc] init];
    }
    return _aufgabenAktivListe;
}

- (void)aufgabenAktivListeErstellen:(LWPerson *)person
{
    [self.aufgabenAktivListe removeAllObjects];
    for (NSString *aufgabe in self.brain.aufgabenListe)
    {
        if ([person.machtDieseAufgaben containsObject:aufgabe])
        {
            [self.aufgabenAktivListe addObject:@(YES)];
        }
        else
        {
            [self.aufgabenAktivListe addObject:@(NO)];
        }
    }
}

//Terminaktivliste
- (NSMutableArray *)terminAktivListe
{
    if (!_terminAktivListe)
    {
        _terminAktivListe = [[NSMutableArray alloc] init];
    }
    return _terminAktivListe;
}

- (void)terminAktivListeErstellen:(LWPerson *)person
{
    [self.terminAktivListe removeAllObjects];
    for (NSString *termin in self.brain.zuBesetzendeTermine)
    {
        if ([person.kannAnDiesenTerminen containsObject:termin])
        {
            [self.terminAktivListe addObject:@(YES)];
        }
        else
        {
            [self.terminAktivListe addObject:@(NO)];
        }
    }
}

// werMachtDieseAufgabeListe
- (NSMutableArray *)werMachtDieseAufgabeListe
{
    if (!_werMachtDieseAufgabeListe)
    {
        _werMachtDieseAufgabeListe = [[NSMutableArray alloc] init];
    }
    return _werMachtDieseAufgabeListe;
}

- (void)werMachtDieseAufgabeListeErstellen:(NSString *)termin
{
    [self.werMachtDieseAufgabeListe removeAllObjects];
    for (LWPerson *person in self.brain.personenListe)
    {
        if ([person.machtDieseAufgaben containsObject:termin])
        {
            [self.werMachtDieseAufgabeListe addObject:@(YES)];
        }
        else
        {
            [self.werMachtDieseAufgabeListe addObject:@(NO)];
        }
    }
}

// werKannAnDiesemTerminListe
- (NSMutableArray *)werKannAnDiesemTerminListe
{
    if (!_werKannAnDiesemTerminListe)
    {
        _werKannAnDiesemTerminListe = [[NSMutableArray alloc] init];
    }
    return _werKannAnDiesemTerminListe;
}

- (void)werKannAnDiesemTerminListeErstellen:(NSString *)termin
{
    [self.werKannAnDiesemTerminListe removeAllObjects];
    for (LWPerson *person in self.brain.personenListe)
    {
        if ([person.kannAnDiesenTerminen containsObject:termin])
        {
            [self.werKannAnDiesemTerminListe addObject:@(YES)];
        }
        else
        {
            [self.werKannAnDiesemTerminListe addObject:@(NO)];
        }
    }
}


#pragma mark - Actions
- (IBAction)einteilungStarten:(NSButton *)sender
{
    NSArray *fertigeEinteilung = [self.brain einteilungStarten];
    [self einteilungAusgeben:fertigeEinteilung];
}


- (IBAction)plusButtonGeklickt:(NSButton *)sender
{
// Geht es um Personen, Aufgaben oder Termine?
    NSString *person = @"Neue Person";
    NSString *aufgabe = @"Neue Aufgabe";
    NSString *termin = @"Neuer Termin";
    
    NSString *worumGehts;
    NSTableView *tableView;
    NSMutableArray *mArray;
    
    if (sender == self.personenPlusButton)
    {
        worumGehts = person;
        tableView = self.personenTableViewImPersonenTab;
        mArray = self.brain.personenListe;
    }
    else if (sender == self.aufgabenPlusButton)
    {
        worumGehts = aufgabe;
        tableView = self.aufgabenTableViewImAufgabenTab;
        mArray = self.brain.aufgabenListe;
    }
    else if (sender == self.terminPlusButton)
    {
        worumGehts = termin;
        tableView = self.terminTableViewImTermineTab;
        mArray = self.brain.zuBesetzendeTermine;
    }
    else return;
    
    
    // Wenn gerade was editiert wird: Nichts machen
    if ([tableView editedRow] >= 0) return;
        
    NSString *neuerString = [self doppelungVerhindern:worumGehts inMutableArray:mArray];
    
    // Personen müssen auf besondere Art hinzugefügt werden:
    if ([worumGehts isEqual:person])
    {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [self.brain personHinzufuegen:neuerString
                             istAktiv:YES
                          mitAufgaben:tempArray
              insgesamtSoOftEinteilen:0
                 kannAnDiesenTerminen:self.brain.zuBesetzendeTermine];
        [self personenAktivListeErstellen];

    }
    else [mArray addObject:neuerString];
    
    // Standard ist, dass man an allen Terminen kann:
    if ([worumGehts isEqual:termin])
    {
        for (LWPerson *einePerson in self.brain.personenListe)
        {
            [einePerson.kannAnDiesenTerminen addObject:neuerString];
        }
    }
    
    [tableView reloadData];
    
    // Zeile auswählen und in den Editiermodus setzen
    int row = (int)[mArray count]-1;
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    [tableView editColumn:0 row:row withEvent:nil select:YES];
}


- (IBAction)minusButtonGeklickt:(NSButton *)sender
{
    NSString *tab;
    NSTableView *tempTableView;
    NSMutableArray *tempListe;
    
    if (sender == self.personenMinusButton)
    {
        tab = @"Personen";
        tempTableView = self.personenTableViewImPersonenTab;
        tempListe = self.brain.personenListe;
    }
    else if (sender == self.aufgabenMinusButton)
    {
        tab = @"Aufgaben";
        tempTableView = self.aufgabenTableViewImAufgabenTab;
        tempListe = self.brain.aufgabenListe;
    }
    else if (sender == self.terminMinusButton)
    {
        tab = @"Termine";
        tempTableView = self.terminTableViewImTermineTab;
        tempListe = self.brain.zuBesetzendeTermine;
    }
    else return;
    
    // 1. Wenn nichts ausgewählt ist oder gerade was editiert wird --> Nichts tun.
    if (([tempTableView selectedRow] == -1) || ([tempTableView editedRow] >= 0))
    {
        return;
    }
    // 2. Else --> Zeile löschen.
    else
    {
        int urspruenglicheLaenge = (int)[tempListe count];
        int row = (int)[tempTableView selectedRow];
        if ([tab isEqualToString:@"Aufgaben"]) [self erinnerungAnAufgabeLoeschen:[tempListe objectAtIndex:row]];
        if ([tab isEqualToString:@"Termine"]) [self erinnerungAnTerminLoeschen:[tempListe objectAtIndex:row]];

        [tempListe removeObjectAtIndex:row];
        if ([tab isEqualToString:@"Personen"]) [self.personenAktivListe removeObjectAtIndex:row];
        [tempTableView reloadData];
        
        // 2. a) Wenn die gelöschte Zeile die letzte Zeile der Liste war (aber die Liste noch nicht leer ist) --> Letzte Zeile auswählen.
        if ((row == urspruenglicheLaenge-1) && ([tempListe count] > 0))
        {
            [tempTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:urspruenglicheLaenge-2] byExtendingSelection:NO];
        }
        
        // Aufräumen
        [self ansichtAktualisieren:tab auchHauptliste:NO];
    }
}

// Die zweite und dritte Tabelle sollen nicht den Fokus kriegen, damit man gleich mit den Pfeiltasten weiter Personen wechseln kann:
- (IBAction)fokusZurueckAufHauptlisteSetzen:(NSTableView *)sender
{
    NSTableView *hauptliste;
    int tabnr = (int)[self.tabview indexOfTabViewItem:[self.tabview selectedTabViewItem]];
    
    if (tabnr == 0)
        hauptliste = self.personenTableViewImPersonenTab;
    else if (tabnr == 1)
        hauptliste = self.aufgabenTableViewImAufgabenTab;
    else if (tabnr == 2)
        hauptliste = self.terminTableViewImTermineTab;
    
    [self.hauptfenster makeFirstResponder:hauptliste];
}


// Zu den Wie-oft-Controls
- (IBAction)controlTextDidChange:(NSTextField *)sender
{
    if (sender == self.wieOftTextFeld)
    {
        // Eingabe filtern
        NSString *origString = [self.wieOftTextFeld stringValue];
        
            // Nur bestimmte Zeichen erlauben:
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.,"];
        NSString *newString = [[origString componentsSeparatedByCharactersInSet:[myCharSet invertedSet]] componentsJoinedByString:@""];
        newString = [newString stringByReplacingOccurrencesOfString:@"," withString:@"."];
        
            // Ist der Wert zu hoch, auf Maximalwert setzen:
        double maxWert = (double)[self.brain.zuBesetzendeTermine count];
        double wert = [newString doubleValue];
        if (wert > maxWert)
        {
            newString = [NSString stringWithFormat:@"%f", maxWert];
        }
        else
        {
            newString = [NSString stringWithFormat:@"%f", wert];
        }
        
            // Zahl formatieren (lokales Komma, Verkürzen auf zwei Nachkommastellen, Runden usw.):
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumFractionDigits:2];
        [numberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
        NSDecimalNumber *dec = [NSDecimalNumber decimalNumberWithString:newString];
        newString = [numberFormatter stringFromNumber:dec];
        
//            // Einen komischen Fehler ausmerzen, der 0,0 anzeigt, wenn man mit dem Stepper auf 0 runtergeht (funktioniert nicht):
//        if ([newString isEqualToString:@"0,0"])
//        {
//            newString = @"0";
//        }
        
            // Wenn sich was geändert hat, das Textfeld aktualisieren:
        if (![origString isEqualToString:newString])
        {
            [self.wieOftTextFeld setStringValue:newString];
        }
        
        
        self.ausgewaehltePerson.haeufigkeitswunsch = [newString floatValue];
        [self.wieOftStepper setFloatValue:[newString floatValue]];
        
    }
}

- (IBAction)wieOftStepperGeklickt:(NSStepper *)sender
{
    self.ausgewaehltePerson.haeufigkeitswunsch = [sender floatValue];
    [self.wieOftTextFeld setFloatValue:[sender floatValue]];
}

- (void)wieOftControlsAktivieren
{
    [self.wieOftTextFeld setEnabled:YES];
    [self.wieOftStepper setEnabled:YES];
}

- (void)wieOftControlsDeaktivieren
{
    [self.wieOftTextFeld setEnabled:NO];
    [self.wieOftStepper setEnabled:NO];
}

- (IBAction)oeffnenMenueGeklickt:(NSMenuItem *)sender
{
    [self laden];
}

- (IBAction)speichernMenueGeklickt:(NSMenuItem *)sender
{
    [self speichern:self.brain];
}


#pragma mark - Speichern und laden

- (void)speichern:(LWRosterBrain *)profil
{
    NSSavePanel *aSavePanel = [NSSavePanel savePanel];
    [aSavePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"roster", nil]];
    [aSavePanel setTitle:@"Profil speichern"];
    [aSavePanel setPrompt:@"Speichern"];
    
    if ([aSavePanel runModal] == NSOKButton)
    {
        NSURL *url = [aSavePanel URL];
        NSData *speicherDaten = [NSKeyedArchiver archivedDataWithRootObject:self.brain];
        [speicherDaten writeToURL:url atomically:YES];
    }
}

- (void)laden
{
    NSOpenPanel *aOpenPanel = [NSOpenPanel openPanel];
    [aOpenPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"roster", nil]];
    [aOpenPanel setTitle:@"Profil laden"];
    [aOpenPanel setPrompt:@"Laden"];
    
    if ([aOpenPanel runModal] == NSOKButton)
    {
        NSURL *url = [aOpenPanel URL];
        NSData *ladeDaten = [[NSData alloc] initWithContentsOfURL:url];
        self.brain = [NSKeyedUnarchiver unarchiveObjectWithData: ladeDaten];
        // Das Laden sichtbar machen
        [self ansichtAktualisieren:@"Personen" auchHauptliste:YES];
        [self ansichtAktualisieren:@"Aufgaben" auchHauptliste:YES];
        [self ansichtAktualisieren:@"Termine" auchHauptliste:YES];
        
        // Ins Open-Recent-Menü damit
        [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:url];
    }
}

-(NSURL *)ladeOrtAussuchen
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    if ([panel runModal] != NSFileHandlingPanelOKButton) return nil;
    return [[panel URLs] lastObject];
}

// Open Recent
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    //NSURL *url = [NSURL URLWithString:filename];
    NSData *ladeDaten = [[NSData alloc] initWithContentsOfFile:filename];
    self.brain = [NSKeyedUnarchiver unarchiveObjectWithData: ladeDaten];
    // Das Laden sichtbar machen
    [self ansichtAktualisieren:@"Personen" auchHauptliste:YES];
    [self ansichtAktualisieren:@"Aufgaben" auchHauptliste:YES];
    [self ansichtAktualisieren:@"Termine" auchHauptliste:YES];
    return YES;
}


#pragma mark - zum NSTabView
- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if (tabViewItem == [self.tabview tabViewItemAtIndex:0])
    {        
        [self ansichtAktualisieren:@"Personen" auchHauptliste:YES];
    }
    else if (tabViewItem == [self.tabview tabViewItemAtIndex:1])
    {        
        [self ansichtAktualisieren:@"Aufgaben" auchHauptliste:YES];
    }
    else if (tabViewItem == [self.tabview tabViewItemAtIndex:2])
    {
        [self ansichtAktualisieren:@"Termine" auchHauptliste:YES];
    }
}


#pragma mark - Alles zu den NSTableViews

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    // Personentab
    if (tableView == self.personenTableViewImPersonenTab)
    {
        return (int)[self.brain.personenListe count];
    }
    else if ((tableView == self.aufgabenTableViewImPersonenTab) && ([self.personenTableViewImPersonenTab selectedRow] != -1))
    {
        return (int)[self.brain.aufgabenListe count];
    }
    else if ((tableView == self.terminTableViewImPersonenTab) && ([self.personenTableViewImPersonenTab selectedRow] != -1))
    {
        return (int)[self.brain.zuBesetzendeTermine count];
    }
    
    // Aufgabentab
    else if (tableView == self.aufgabenTableViewImAufgabenTab)
    {
        return (int)[self.brain.aufgabenListe count];
    }
    else if ((tableView == self.personenTableViewImAufgabenTab) && ([self.aufgabenTableViewImAufgabenTab selectedRow] != -1))
    {
        return (int)[self.brain.personenListe count];
    }
    
    // Termintab
    else if (tableView == self.terminTableViewImTermineTab)
    {
        return (int)[self.brain.zuBesetzendeTermine count];
    }
    else if ((tableView == self.personenTableViewImTermineTab) && ([self.terminTableViewImTermineTab selectedRow] != -1))
    {
        return (int)[self.brain.personenListe count];
    }
    else return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    // Personentab
    if ((tableView == self.personenTableViewImPersonenTab) && ([self.brain.personenListe count] > 0))
    {
        if ([[tableColumn identifier] isEqualToString:@"Personen"])
        {
            return [[self.brain.personenListe objectAtIndex:row] name];
        }
        else if ([[tableColumn identifier] isEqualToString:@"Aktiv"])
        {
            return [self.personenAktivListe objectAtIndex:row];
        }
        else return 0;
    }
    else if ((tableView == self.aufgabenTableViewImPersonenTab) && ([self.brain.aufgabenListe count] > 0) && ([self.personenTableViewImPersonenTab selectedRow] != -1))
    {
        if ([[tableColumn identifier] isEqualToString:@"Aufgaben"])
        {
            return [self.brain.aufgabenListe objectAtIndex:row];
        }
        else if ([[tableColumn identifier] isEqualToString:@"Aktiv"])
        {
            return [self.aufgabenAktivListe objectAtIndex:row];
        }
        else return 0;
    }
    else if ((tableView == self.terminTableViewImPersonenTab) && ([self.brain.zuBesetzendeTermine count] > 0) && ([self.personenTableViewImPersonenTab selectedRow] != -1))
    {
        if ([[tableColumn identifier] isEqualToString:@"Termine"])
        {
            return [self.brain.zuBesetzendeTermine objectAtIndex:row];
        }
        else if ([[tableColumn identifier] isEqualToString:@"Aktiv"])
        {
            return [self.terminAktivListe objectAtIndex:row];
        }
        else return 0;
    }
    
    // Aufgabentab
    else if ((tableView == self.aufgabenTableViewImAufgabenTab) && ([self.brain.aufgabenListe count] > 0))
    {
        return [self.brain.aufgabenListe objectAtIndex:row];
    }
    else if ((tableView == self.personenTableViewImAufgabenTab) && ([self.brain.personenListe count] > 0) && ([self.aufgabenTableViewImAufgabenTab selectedRow] != -1))
    {
        if ([[tableColumn identifier] isEqualToString:@"Personen"])
        {
            return [[self.brain.personenListe objectAtIndex:row] name];
        }
        else if ([[tableColumn identifier] isEqualToString:@"Aktiv"])
        {
            return [self.werMachtDieseAufgabeListe objectAtIndex:row];
        }
        else return 0;
    }
    
    // Termintab
    else if ((tableView == self.terminTableViewImTermineTab) && ([self.brain.zuBesetzendeTermine count] > 0))
    {
        return [self.brain.zuBesetzendeTermine objectAtIndex:row];
    }
    else if ((tableView == self.personenTableViewImTermineTab) && ([self.brain.personenListe count] > 0) && ([self.terminTableViewImTermineTab selectedRow] != -1))
    {
        if ([[tableColumn identifier] isEqualToString:@"Personen"])
        {
            return [[self.brain.personenListe objectAtIndex:row] name];
        }
        else if ([[tableColumn identifier] isEqualToString:@"Aktiv"])
        {
            return [self.werKannAnDiesemTerminListe objectAtIndex:row];
        }
        else return 0;
    }
    else return 0;
}

- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
    if ([notification object] == self.personenTableViewImPersonenTab)
    {
        [self ansichtAktualisieren:@"Personen" auchHauptliste:NO];
    }
    else if ([notification object] == self.aufgabenTableViewImAufgabenTab)
    {
        [self ansichtAktualisieren:@"Aufgaben" auchHauptliste:NO];
    }
    else if ([notification object] == self.terminTableViewImTermineTab)
    {
        [self ansichtAktualisieren:@"Termine" auchHauptliste:NO];
    }
}

// Wenn was editiert wird (auch wenn eine Checkbox geklickt wird)
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
    // Personentab
    if (tableView == self.personenTableViewImPersonenTab)
    {
        if ([[column identifier] isEqualToString:@"Aktiv"])
        {
            [self.personenAktivListe replaceObjectAtIndex:row withObject:value];
            if ([value isEqual: @(NO)])
            {
                [[self.brain.personenListe objectAtIndex:row] setIstAktiv:NO];
            }
            else
            {
                [[self.brain.personenListe objectAtIndex:row] setIstAktiv:YES];
            }
        }
        else if ([[column identifier] isEqualToString:@"Personen"])
        {
            LWPerson* editiertePerson = [self.brain.personenListe objectAtIndex:row];
                        
            value = [self doppelungVerhindern:value inMutableArray:self.brain.personenListe];
            
            editiertePerson.name = value;
            [self.personenLabel setStringValue:value];
            
            // Neu alphabetisch ordnen
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            [self.brain.personenListe sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            // Nach dem alphabetisch ordnen muss neu der richtige Eintrag ausgewählt werden:
            int index = (int)[self.brain.personenListe indexOfObject:editiertePerson];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
            [self.personenTableViewImPersonenTab selectRowIndexes:indexSet byExtendingSelection:NO];
            [self.personenTableViewImPersonenTab scrollRowToVisible:[self.personenTableViewImPersonenTab selectedRow]];
            
            [self personenAktivListeErstellen];
        }
        [self.personenTableViewImPersonenTab reloadData];
    }
    else if ([self.tabview indexOfTabViewItem:[self.tabview selectedTabViewItem]] == 0) // Immer noch Personentab (noch nicht so elegant gelöst)
    {
        NSMutableArray *aktivListe;
        NSMutableArray *aufgabenOderTerminListe;
        NSMutableArray *zuVeraenderndeListe;
        
        if (tableView == self.aufgabenTableViewImPersonenTab)
        {
            aktivListe = self.aufgabenAktivListe;
            aufgabenOderTerminListe = self.brain.aufgabenListe;
            zuVeraenderndeListe = self.ausgewaehltePerson.machtDieseAufgaben;
        }
        else if (tableView == self.terminTableViewImPersonenTab)
        {
            aktivListe = self.terminAktivListe;
            aufgabenOderTerminListe = self.brain.zuBesetzendeTermine;
            zuVeraenderndeListe = self.ausgewaehltePerson.kannAnDiesenTerminen;
        }
        
        [aktivListe replaceObjectAtIndex:row withObject:value];
        NSString *aufgabeOderTermin = [aufgabenOderTerminListe objectAtIndex:row];
        if ([value isEqual: @(NO)])
        {
            [zuVeraenderndeListe removeObjectIdenticalTo:aufgabeOderTermin];
        }
        else
        {
            [zuVeraenderndeListe addObject:aufgabeOderTermin];
        }
        [tableView reloadData];
    }
    
    // Aufgabentab
    else if (tableView == self.aufgabenTableViewImAufgabenTab)
    {
        value = [self doppelungVerhindern:value inMutableArray:self.brain.aufgabenListe];
        
        // Die alte Bezeichnung bei allen Personen durch die neue ersetzen
        NSString *urspruenglicheBezeichnung = [self.brain.aufgabenListe objectAtIndex:row];
        for (LWPerson *einePerson in self.brain.personenListe)
        {
            if ([einePerson.machtDieseAufgaben containsObject:urspruenglicheBezeichnung])
                [einePerson.machtDieseAufgaben replaceObjectAtIndex:[einePerson.machtDieseAufgaben indexOfObjectIdenticalTo:urspruenglicheBezeichnung] withObject:value];
        }
        
        [self.brain.aufgabenListe replaceObjectAtIndex:row withObject:value];
        NSString* editierteAufgabe = [self.brain.aufgabenListe objectAtIndex:row];
        [self.aufgabenLabel setStringValue:editierteAufgabe];
        [self.aufgabenTableViewImAufgabenTab reloadData];
    }
    else if (tableView == self.personenTableViewImAufgabenTab)
    {
        [self.werMachtDieseAufgabeListe replaceObjectAtIndex:row withObject:value];
        NSString *aufgabe = [self.brain.aufgabenListe objectAtIndex:[self.aufgabenTableViewImAufgabenTab selectedRow]];
        LWPerson *person = [self.brain.personenListe objectAtIndex:row];
        if ([value isEqual: @(NO)])
        {
            [person.machtDieseAufgaben removeObjectIdenticalTo:aufgabe];
        }
        else if ([value isEqual:@(YES)])
        {
            [person.machtDieseAufgaben addObject:aufgabe];
        }
        [self werMachtDieseAufgabeListeErstellen:aufgabe];
        [self.personenTableViewImAufgabenTab reloadData];
    }

    // Termintab
    else if (tableView == self.terminTableViewImTermineTab)
    {
        value = [self doppelungVerhindern:value inMutableArray:self.brain.zuBesetzendeTermine];

        // Die alte Bezeichnung bei allen Personen durch die neue ersetzen
        NSString *urspruenglicheBezeichnung = [self.brain.zuBesetzendeTermine objectAtIndex:row];
        for (LWPerson *einePerson in self.brain.personenListe)
        {
            if ([einePerson.kannAnDiesenTerminen containsObject:urspruenglicheBezeichnung])
                [einePerson.kannAnDiesenTerminen replaceObjectAtIndex:[einePerson.kannAnDiesenTerminen indexOfObjectIdenticalTo:urspruenglicheBezeichnung] withObject:value];
        }
        
        [self.brain.zuBesetzendeTermine replaceObjectAtIndex:row withObject:value];
        NSString* editierterTermin = [self.brain.zuBesetzendeTermine objectAtIndex:row];
        [self.terminLabel setStringValue:editierterTermin];
        [self.terminTableViewImTermineTab reloadData];
    }
    else if (tableView == self.personenTableViewImTermineTab)
    {
        [self.werKannAnDiesemTerminListe replaceObjectAtIndex:row withObject:value];
        NSString *termin = [self.brain.zuBesetzendeTermine objectAtIndex:[self.terminTableViewImTermineTab selectedRow]];
        LWPerson *person = [self.brain.personenListe objectAtIndex:row];
        if ([value isEqual: @(NO)])
        {
            [person.kannAnDiesenTerminen removeObjectIdenticalTo:termin];
        }
        else if ([value isEqual:@(YES)])
        {
            [person.kannAnDiesenTerminen addObject:termin];
        }
        [self werKannAnDiesemTerminListeErstellen:termin];
        [self.personenTableViewImTermineTab reloadData];
    }
}


// Die jeweilige im personenTableViewImPersonenTab ausgewählte Person
- (LWPerson *)ausgewaehltePerson
{
    if (!_ausgewaehltePerson) _ausgewaehltePerson = [[LWPerson alloc] init];
    return _ausgewaehltePerson;
}

// Die jeweilige im aufgabenTableViewImAufgabenTab ausgewählte Aufgabe
- (NSString *)ausgewaehlteAufgabe
{
    if (!_ausgewaehlteAufgabe) _ausgewaehlteAufgabe = [[NSString alloc] init];
    return _ausgewaehlteAufgabe;
}

// Der jeweilige im terminTableViewImTermineTab ausgewählte Termin
- (NSString *)ausgewaehlterTermin
{
    if (!_ausgewaehlterTermin) _ausgewaehlterTermin = [[NSString alloc] init];
    return _ausgewaehlterTermin;
}


#pragma mark Drag and Drop
#define BasicTableViewDragAndDropDataType @"BasicTableViewDragAndDropDataType"

- (void)awakeFromNib
{
    [self.aufgabenTableViewImAufgabenTab registerForDraggedTypes:[NSArray arrayWithObject:BasicTableViewDragAndDropDataType]];
    [self.terminTableViewImTermineTab registerForDraggedTypes:[NSArray arrayWithObject:BasicTableViewDragAndDropDataType]];
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:BasicTableViewDragAndDropDataType] owner:self];
    [pboard setData:data forType:BasicTableViewDragAndDropDataType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op{
    // Add code here to validate the drop
    
    return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)to dropOperation:(NSTableViewDropOperation)operation{
    
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:BasicTableViewDragAndDropDataType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    int from = (int)[rowIndexes firstIndex];
    
    // Geht es um Aufgaben oder Termine?
    NSMutableArray *mArray;
    if (aTableView == self.aufgabenTableViewImAufgabenTab) mArray = self.brain.aufgabenListe;
    else if (aTableView == self.terminTableViewImTermineTab) mArray = self.brain.zuBesetzendeTermine;
    
    // Markierte Zeile merken (*)
    NSString *markiert = @"Nichts ausgewählt";
    if ([aTableView selectedRow] != -1) markiert = [mArray objectAtIndex:[aTableView selectedRow]];
    
    // Zeile verschieben
    NSString *traveller = [mArray objectAtIndex:from];
    [mArray removeObjectAtIndex:from];
    if (from < to) to--;
    [mArray insertObject:traveller atIndex:to];
    [aTableView reloadData];
    
    // (*) Ursprüngliche Markierung wiederherstellen
    if (![markiert isEqualToString:@"Nichts ausgewählt"])
    {
        int index = (int)[mArray indexOfObject:markiert];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        [aTableView selectRowIndexes:indexSet byExtendingSelection:NO];
        [aTableView scrollRowToVisible:[aTableView selectedRow]];
    }
    
    return YES;
}


#pragma mark - Hilfsmethoden
- (void) ansichtAktualisieren:(NSString *)tab auchHauptliste:(BOOL)auchHauptliste
{
    if ([tab isEqualToString:@"Personen"])
    {
        if (auchHauptliste)
        {
            [self personenAktivListeErstellen];
            [self.personenTableViewImPersonenTab reloadData];
        }
        
        int row = (int)[self.personenTableViewImPersonenTab selectedRow];
        
        if (row == -1)  // Keine Zeile ausgewählt
        {
            self.ausgewaehltePerson = nil;
            [self.personenLabel setStringValue:@""];
            [self.wieOftTextFeld setStringValue:@""];
            [self.wieOftTextFeld setEnabled:NO];
            [self.wieOftStepper setEnabled:NO];
        }
        else
        {
            self.ausgewaehltePerson = [self.brain.personenListe objectAtIndex:row];
            [self.personenLabel setStringValue:self.ausgewaehltePerson.name];
            [self.wieOftTextFeld setFloatValue:self.ausgewaehltePerson.haeufigkeitswunsch];
            [self.wieOftStepper setFloatValue:self.ausgewaehltePerson.haeufigkeitswunsch];
            [self.wieOftStepper setMaxValue:[self.brain.zuBesetzendeTermine count]];
            [self.wieOftTextFeld setEnabled:YES];
            [self.wieOftStepper setEnabled:YES];
            // Diese beiden Listen werden jedesmal neu erstellt, wenn die Person wechselt:
            [self aufgabenAktivListeErstellen:self.ausgewaehltePerson];
            [self terminAktivListeErstellen:self.ausgewaehltePerson];
        }
        [self.aufgabenTableViewImPersonenTab reloadData];
        [self.terminTableViewImPersonenTab reloadData];
    }
    else if ([tab isEqualToString:@"Aufgaben"])
    {
        if (auchHauptliste) [self.aufgabenTableViewImAufgabenTab reloadData];
        
        int row = (int)[self.aufgabenTableViewImAufgabenTab selectedRow];
        
        if (row == -1)  // Keine Zeile ausgewählt
        {
            self.ausgewaehlteAufgabe = nil;
            [self.aufgabenLabel setStringValue:@""];
        }
        else
        {
            self.ausgewaehlteAufgabe = [self.brain.aufgabenListe objectAtIndex:row];
            [self.aufgabenLabel setStringValue:self.ausgewaehlteAufgabe];
            // Diese Liste wird jedesmal neu erstellt, wenn die Aufgabe wechselt:
            [self werMachtDieseAufgabeListeErstellen:self.ausgewaehlteAufgabe];
        }
        [self.personenTableViewImAufgabenTab reloadData];
    }
    else if ([tab isEqualToString:@"Termine"])
    {
        if (auchHauptliste) [self.terminTableViewImTermineTab reloadData];
        
        int row = (int)[self.terminTableViewImTermineTab selectedRow];
        
        if (row == -1)  // Keine Zeile ausgewählt
        {
            self.ausgewaehlterTermin = nil;
            [self.terminLabel setStringValue:@""];
        }
        else
        {
            self.ausgewaehlterTermin = [self.brain.zuBesetzendeTermine objectAtIndex:row];
            [self.terminLabel setStringValue:self.ausgewaehlterTermin];
            // Diese Liste wird jedesmal neu erstellt, wenn die Aufgabe wechselt:
            [self werKannAnDiesemTerminListeErstellen:self.ausgewaehlterTermin];
        }
        [self.personenTableViewImTermineTab reloadData];
    }
}

- (NSString *) doppelungVerhindern:(NSString *)gewuenschterString inMutableArray:(NSMutableArray *)mArray
{
    int suffixInt = 1;
    NSString *zuPruefenderString = gewuenschterString;
    NSArray *tempArray;
    
    if (mArray == self.brain.personenListe) tempArray = [self tempPersonenNamenListeErstellen];
    else tempArray = mArray;
    
    while ([tempArray containsObject:zuPruefenderString])
    {
        NSString *suffixString = [NSString stringWithFormat:@" (%d)", suffixInt];
        zuPruefenderString = [gewuenschterString stringByAppendingString:suffixString];
        suffixInt++;
    }
    
    return zuPruefenderString;
}

- (NSArray *) tempPersonenNamenListeErstellen
{
    NSMutableArray *tempPersonenNamenListe = [[NSMutableArray alloc] init];
    for (LWPerson *einePerson in self.brain.personenListe)
    {
        [tempPersonenNamenListe addObject:einePerson.name];
    }
    
    return tempPersonenNamenListe;
}

- (void) erinnerungAnAufgabeLoeschen:(NSString *)geloeschteAufgabe
{
    for (LWPerson *einePerson in self.brain.personenListe)
    {
        [einePerson.machtDieseAufgaben removeObjectIdenticalTo:geloeschteAufgabe];
    }
}

- (void) erinnerungAnTerminLoeschen:(NSString *)geloeschterTermin
{
    for (LWPerson *einePerson in self.brain.personenListe)
    {
        [einePerson.kannAnDiesenTerminen removeObjectIdenticalTo:geloeschterTermin];
    }
}

-(void) einteilungAusgeben:(NSArray *)fertigeEinteilung
{
    NSArray *termin;
    LWPerson *eingeteiltePerson;
    int aufgabe, datum;
    datum = 0;
    [self.ergebnisFeld setString:@""];
    for (termin in fertigeEinteilung)
    {
        [self.ergebnisFeld insertText:[self.brain.zuBesetzendeTermine objectAtIndex:datum]];
        [self.ergebnisFeld insertText:@"\n"];
        aufgabe = 0;
        for (eingeteiltePerson in termin)
        {
            if (![eingeteiltePerson.name hasPrefix:@"STROHPUPPE"] && (eingeteiltePerson.name != nil))  // Sauberer wäre es wohl, das irgendwie schon im Brain zu machen ... Aber hier ist es viel leichter. Hm, im Brain ist es schwierig, weil zur fertigen Einteilung die Personen nicht mit Aufgaben verknüpft hinzugefügt werden, sondern in der Reihenfolge der Aufgaben. Lässt man also zwischendurch eine Person weg, gibt es Chaos. Ich glaube zumindest, dass es so ist. Ist schon etwas her, dass ich das programmiert habe ...
            {
                [self.ergebnisFeld insertText:eingeteiltePerson.name];
                [self.ergebnisFeld insertText:@": "];
                [self.ergebnisFeld insertText:[self.brain.aufgabenListe objectAtIndex:aufgabe]];
                [self.ergebnisFeld insertText:@"\n"];
            }
            aufgabe ++;
        }
        [self.ergebnisFeld insertText:@"\n"];
        datum ++;
    }
}

@end
