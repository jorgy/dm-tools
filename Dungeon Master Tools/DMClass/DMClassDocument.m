//
//  DMClassDocument.m
//  Dungeon Master Tools
//
//  Created by Kevin Jorgensen on 4/4/12.
//  Copyright (c) 2012 Kevin Jorgensen. All rights reserved.
//

#import "DMClassDocument.h"


/* UI tags */
#define kDMHitDieTag      (1000)
#define kDMSkillPointsTag (1001)
#define kDMClassTypeTag   (1002)
#define kDMCasterTypeTag  (1003)
#define kDMBaseAttackTag  (2001)
#define kDMFortSaveTag    (2002)
#define kDMReflexSaveTag  (2003)
#define kDMWillSaveTag    (2004)

/* Segmented control labels */
#define kDMCasterLabel      @"Caster"
#define kDMNonCasterLabel   @"Non-Caster"
#define kDMMonsterLabel     @"Monster"
#define kDMPreparedLabel    @"Prepared"
#define kDMSpontaneousLabel @"Spontaneous"
#define kDMPrestigeLabel    @"Prestige Class"

/* Document keys */
#define kDMClassNameKey   @"ClassName"
#define kDMHitDieKey      @"HitDie"
#define kDMSkillPointsKey @"SkillPoints"
#define kDMClassTypeKey   @"ClassType"
#define kDMCasterTypeKey  @"CasterType"
#define kDMClassSkillsKey @"ClassSkills"
#define kDMLevelCapKey    @"LevelCap"
#define kDMBaseAttackKey  @"BaseAttack"
#define kDMFortitudeKey   @"FortitudeSave"
#define kDMReflexKey      @"ReflexSave"
#define kDMWillKey        @"WillSave"



@interface DMClassDocument ()
{
    NSMutableIndexSet *_selectedSkills;
    NSArray *_skillNames;
    
    /* UI elements */
    NSTabView *_tabView;
    NSTabViewItem *_spellsTab;
    NSTabViewItem *_spellsKnownTab;
    
    NSTextField *_nameLabel;
    NSSegmentedControl *_hitDieSegment;
    NSSegmentedControl *_skillPointsSegment;
    NSSegmentedControl *_classTypeSegment;
    NSTextField *_casterTypeLabel;
    NSSegmentedControl *_casterTypeSegment;
    NSTextField *_casterTypeInfoLabel;
    NSTableView *_skillTable;
    
    NSTableView *_levelUpChart;
    NSSlider *_levelCapSlider;
    NSSegmentedControl *_baseAttackSegment;
    NSSegmentedControl *_fortitudeSegment;
    NSSegmentedControl *_reflexSegment;
    NSSegmentedControl *_willSegment;
}

@end



@implementation DMClassDocument

@synthesize tabView = _tabView;
@synthesize spellsTab = _spellsTab;
@synthesize spellsKnownTab = _spellsKnownTab;
@synthesize nameLabel = _nameLabel;
@synthesize hitDieSegment = _hitDieSegment;
@synthesize skillPointsSegment = _skillPointsSegment;
@synthesize classTypeSegment = _classTypeSegment;
@synthesize casterTypeLabel = _casterTypeLabel;
@synthesize casterTypeSegment = _casterTypeSegment;
@synthesize casterTypeInfoLabel = _casterTypeInfoLabel;
@synthesize skillTable = _skillTable;
@synthesize levelUpChart = _levelUpChart;
@synthesize levelCapSlider = _levelCapSlider;
@synthesize baseAttackSegment = _baseAttackSegment;
@synthesize fortitudeSegment = _fortitudeSegment;
@synthesize reflexSegment = _reflexSegment;
@synthesize willSegment = _willSegment;


#pragma mark - Memory lifecycle

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _name = [@"" retain];
        _hitDie = 4;
        _skillPoints = 2;
        _classType = [kDMCasterLabel retain];
        _casterType = [kDMPreparedLabel retain];
        
        _selectedSkills = [[NSMutableIndexSet alloc] init];
        
        _levelCap = 20;
        _attackProgression = DM_FAST;
        _fortitudeProgression = DM_GOOD;
        _reflexProgression = DM_GOOD;
        _willProgression = DM_GOOD;
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *skillsPlistPath = [mainBundle pathForResource: @"ClassSkills" ofType: @"plist"];
        _skillNames = [[NSArray alloc] initWithContentsOfFile: skillsPlistPath];
    }
    
    return self;
}


- (void) dealloc
{
    [_name release];
    [_classType release];
    [_casterType release];
    [_selectedSkills release];
    [_skillNames release];
    
    [_tabView release];
    [_spellsTab release];
    [_spellsKnownTab release];
    
    [_nameLabel release];
    [_hitDieSegment release];
    [_skillPointsSegment release];
    [_classTypeSegment release];
    [_casterTypeLabel release];
    [_casterTypeSegment release];
    [_casterTypeInfoLabel release];
    
    [_skillTable release];
    [_levelUpChart release];
    [_baseAttackSegment release];
    [_fortitudeSegment release];
    [_reflexSegment release];
    [_willSegment release];
    
    [super dealloc];
}


#pragma mark - Document primitives

- (void) setClassName: (NSString *) name
{
    [[[self undoManager] prepareWithInvocationTarget: self] setClassName: _name];
    
    [name retain];
    [_name release];
    
    _name = name;
    
    [_nameLabel setStringValue: _name];
}


- (void) setHitDie: (NSInteger) dieSize
{
    [[[self undoManager] prepareWithInvocationTarget: self] setHitDie: _hitDie];
    
    _hitDie = dieSize;
    
    [_hitDieSegment setSelectedSegment: (_hitDie - 4) / 2];
}


- (void) setSkillPoints: (NSInteger) skillPoints
{
    [[[self undoManager] prepareWithInvocationTarget: self] setSkillPoints: _skillPoints];
    
    _skillPoints = skillPoints;
    
    [_skillPointsSegment setSelectedSegment: (_skillPoints - 2) / 2];
}


- (void) setClassType: (NSString *) classType
{
    [[[self undoManager] prepareWithInvocationTarget: self] setClassType: _classType];
    
    [classType retain];
    [_classType release];
    
    _classType = classType;
    
    NSInteger index = [[NSArray arrayWithObjects: kDMCasterLabel, kDMNonCasterLabel, kDMMonsterLabel, nil] indexOfObject: classType];
    [_classTypeSegment setSelectedSegment: index];
    
    if (index == 0)
    {
        [_casterTypeSegment setHidden: NO];
        [_casterTypeLabel setHidden: NO];
        [_casterTypeInfoLabel setHidden: NO];
        
        if (![[_tabView tabViewItems] containsObject: _spellsTab])
            [_tabView addTabViewItem: _spellsTab];
        
        if (![[_tabView tabViewItems] containsObject: _spellsKnownTab] && [_casterType isEqualToString: kDMSpontaneousLabel])
            [_tabView addTabViewItem: _spellsKnownTab];
    }
    else
    {
        [_casterTypeSegment setHidden: YES];
        [_casterTypeLabel setHidden: YES];
        [_casterTypeInfoLabel setHidden: YES];
        
        if ([[_tabView tabViewItems] containsObject: _spellsTab])
            [_tabView removeTabViewItem: _spellsTab];
        
        if ([[_tabView tabViewItems] containsObject: _spellsKnownTab])
            [_tabView removeTabViewItem: _spellsKnownTab];
    }
}


- (void) setCasterType: (NSString *) casterType
{
    [[[self undoManager] prepareWithInvocationTarget: self] setCasterType: _casterType];
    
    [casterType retain];
    [_casterType release];
    
    _casterType = casterType;
    
    NSInteger index = [[NSArray arrayWithObjects: kDMPreparedLabel, kDMSpontaneousLabel, kDMPrestigeLabel, nil] indexOfObject: casterType];
    [_casterTypeSegment setSelectedSegment: index];
    
    if (![[_tabView tabViewItems] containsObject: _spellsKnownTab] && [_casterType isEqualToString: kDMSpontaneousLabel])
        [_tabView addTabViewItem: _spellsKnownTab];
    
    if ([[_tabView tabViewItems] containsObject: _spellsKnownTab] && ![_casterType isEqualToString: kDMSpontaneousLabel])
        [_tabView removeTabViewItem: _spellsKnownTab];
}


- (void) addSkillAtIndex: (NSUInteger) index
{
    [[[self undoManager] prepareWithInvocationTarget: self] removeSkillAtIndex: index];
    
    [_selectedSkills addIndex: index];
    
    [_skillTable reloadDataForRowIndexes: [NSIndexSet indexSetWithIndex: index] 
                           columnIndexes: [NSIndexSet indexSetWithIndex: 0]];
}


- (void) removeSkillAtIndex: (NSUInteger) index
{
    [[[self undoManager] prepareWithInvocationTarget: self] addSkillAtIndex: index];
    
    [_selectedSkills removeIndex: index];
    
    [_skillTable reloadDataForRowIndexes: [NSIndexSet indexSetWithIndex: index] 
                           columnIndexes: [NSIndexSet indexSetWithIndex: 0]];
}


- (void) setLevelCap: (NSInteger) levelCap
{
    [[[self undoManager] prepareWithInvocationTarget: self] setLevelCap: _levelCap];
    
    _levelCap = levelCap;
    
    [_levelUpChart reloadData];
    [_levelCapSlider setIntegerValue: _levelCap];
}


- (void) setBaseAttackProgression: (DMBaseAttackProgession) progression
{
    [[[self undoManager] prepareWithInvocationTarget: self] setBaseAttackProgression: _attackProgression];
    
    _attackProgression = progression;
    
    [_levelUpChart reloadData];
    [_baseAttackSegment setSelectedSegment: _attackProgression];
}


- (void) setFortitudeProgression: (DMSaveProgression) progression
{
    [[[self undoManager] prepareWithInvocationTarget: self] setFortitudeProgression: _fortitudeProgression];
    
    _fortitudeProgression = progression;

    [_levelUpChart reloadData];
    [_fortitudeSegment setSelectedSegment: _fortitudeProgression];
}


- (void) setReflexProgression: (DMSaveProgression) progression
{
    [[[self undoManager] prepareWithInvocationTarget: self] setReflexProgression: _reflexProgression];
    
    _reflexProgression = progression;
    
    [_levelUpChart reloadData];
    [_reflexSegment setSelectedSegment: _reflexProgression];
}


- (void) setWillProgression: (DMSaveProgression) progression
{
    [[[self undoManager] prepareWithInvocationTarget: self] setWillProgression: _willProgression];
    
    _willProgression = progression;
    
    [_levelUpChart reloadData];
    [_willSegment setSelectedSegment: _willProgression];
}


#pragma mark - Segmented control handler

- (void) segmentedControlChanged: (NSSegmentedControl *) sender
{
    NSInteger index = [sender selectedSegment];
    switch ([sender tag])
    {
        case kDMHitDieTag:
            [self setHitDie: (index * 2) + 4];
            break;
            
        case kDMSkillPointsTag:
            [self setSkillPoints: (index * 2) + 2];
            break;
            
        case kDMClassTypeTag:
            [self setClassType: [sender labelForSegment: index]];
            break;
            
        case kDMCasterTypeTag:
            [self setCasterType: [sender labelForSegment: index]];
            break;
            
        case kDMBaseAttackTag:
            [self setBaseAttackProgression: index];
            break;
            
        case kDMFortSaveTag:
            [self setFortitudeProgression: index];
            break;
            
        case kDMReflexSaveTag:
            [self setReflexProgression: index];
            break;
            
        case kDMWillSaveTag:
            [self setWillProgression: index];
            break;
    }
}


#pragma mark - Slider handler

- (void) sliderChanged: (NSSlider *) sender
{
    [self setLevelCap: [sender integerValue]];
}


#pragma mark - Spell table button handlers

- (void) spellsPerDayButtonTapped: (NSMatrix *) sender
{
    int newValue;
    if ([[[sender selectedCell] title] isEqualToString: @"-"])
        newValue = 0;
    else
        newValue = [[[sender selectedCell] title] intValue] + 1;
    
    if (newValue > 9)
        return;
    
    for (NSUInteger i = [sender selectedRow]; i < [sender numberOfRows]; i += 1)
    {
        [[sender cellAtRow: i column: [sender selectedColumn]] setTitle: [NSString stringWithFormat: @"%d", newValue]];
    }
}


#pragma mark - NSTextFieldDelegate

- (void) controlTextDidChange: (NSNotification *) obj
{
    [self setClassName: [_nameLabel stringValue]];
}


#pragma mark - NSTableViewDataSource

- (NSInteger) numberOfRowsInTableView: (NSTableView *) tableView
{
    if (tableView == _skillTable)
        return [_skillNames count];
    else if (tableView == _levelUpChart)
        return _levelCap;
    else
        return 0;
}


- (id) tableView: (NSTableView *) tableView objectValueForTableColumn: (NSTableColumn *) tableColumn row: (NSInteger) row
{
    if (tableView == _skillTable)
    {
        if ([[tableColumn identifier] isEqualToString: @"check"])
        {
            if ([_selectedSkills containsIndex: row])
                return [NSNumber numberWithInt: NSOnState];
            else
                return [NSNumber numberWithInt: NSOffState];
        }
        else if ([[tableColumn identifier] isEqualToString: @"name"])
        {
            NSString *name = [_skillNames objectAtIndex: row];
            NSRange bracketRange = [name rangeOfString: @" ["];
            if (bracketRange.location != NSNotFound)
                return [name substringToIndex: bracketRange.location];
            
            return name;
        }
        else
        {
            return nil;
        }
    }
    else if (tableView == _levelUpChart)
    {
        if ([[tableColumn identifier] isEqualToString: @"level"])
        {
            return [NSNumber numberWithInt: row + 1];
        }
        else if ([[tableColumn identifier] isEqualToString: @"attack"])
        {
            int attack;
            switch (_attackProgression)
            {
                case DM_FAST:
                    attack = row + 1;
                    break;
                
                case DM_MEDIUM:
                    attack = (row + 1) * 3 / 4;
                    break;
                    
                case DM_SLOW:
                    attack = (row + 1) / 2;
                    break;
                    
                default:
                    attack = 0;
                    break;
            }
            
            NSString *attackString = [NSString stringWithFormat: @"+%d", attack];
            attack -= 5;
            while (attack > 0)
            {
                attackString = [attackString stringByAppendingFormat: @"/+%d", attack];
                attack -= 5;
            }
            
            return attackString;
        }
        else if ([[tableColumn identifier] isEqualToString: @"fort"])
        {
            int fort;
            if (_fortitudeProgression == DM_GOOD)
                fort = ((row + 1) / 2) + 2;
            else
                fort = (row + 1) / 3;
            
            return [NSString stringWithFormat: @"+%d", fort];
        }
        else if ([[tableColumn identifier] isEqualToString: @"ref"])
        {
            int ref;
            if (_reflexProgression == DM_GOOD)
                ref = ((row + 1) / 2) + 2;
            else
                ref = (row + 1) / 3;
            
            return [NSString stringWithFormat: @"+%d", ref];
        }
        else if ([[tableColumn identifier] isEqualToString: @"will"])
        {
            int will;
            if (_willProgression == DM_GOOD)
                will = ((row + 1) / 2) + 2;
            else
                will = (row + 1) / 3;
            
            return [NSString stringWithFormat: @"+%d", will];
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}


- (void) tableView: (NSTableView *) tableView setObjectValue: (id) object forTableColumn: (NSTableColumn *) tableColumn row: (NSInteger) row
{
    if (tableView == _skillTable)
    {
        if ([_selectedSkills containsIndex: row])
            [self removeSkillAtIndex: row];
        else
            [self addSkillAtIndex: row];
    }
}


#pragma mark - NSDocument methods

- (NSString *) windowNibName
{
    return @"DMClassDocument";
}


- (void) windowControllerDidLoadNib: (NSWindowController *) aController
{
    [super windowControllerDidLoadNib: aController];
    
    [_nameLabel setDelegate: self];
    
    [_nameLabel setStringValue: _name];
    [_hitDieSegment setSelectedSegment: (_hitDie - 4) / 2];
    [_skillPointsSegment setSelectedSegment: (_skillPoints - 2) / 2];
    
    NSInteger index = [[NSArray arrayWithObjects: kDMCasterLabel, kDMNonCasterLabel, kDMMonsterLabel, nil] indexOfObject: _classType];
    [_classTypeSegment setSelectedSegment: index];
    
    if (index == 0)
    {
        [_casterTypeSegment setHidden: NO];
        [_casterTypeLabel setHidden: NO];
        [_casterTypeInfoLabel setHidden: NO];
    }
    else
    {
        [_casterTypeSegment setHidden: YES];
        [_casterTypeLabel setHidden: YES];
        [_casterTypeInfoLabel setHidden: YES];
        
        [_tabView removeTabViewItem: _spellsTab];
    }
    
    index = [[NSArray arrayWithObjects: kDMPreparedLabel, kDMSpontaneousLabel, kDMPrestigeLabel, nil] indexOfObject: _casterType];
    [_casterTypeSegment setSelectedSegment: index];
    
    [_levelCapSlider setIntegerValue: _levelCap];
    [_baseAttackSegment setSelectedSegment: _attackProgression];
    [_fortitudeSegment setSelectedSegment: _fortitudeProgression];
    [_reflexSegment setSelectedSegment: _reflexProgression];
    [_willSegment setSelectedSegment: _willProgression];
    
    if (![_classType isEqualToString: kDMCasterLabel])
    {
        [_tabView removeTabViewItem: _spellsTab];
        [_tabView removeTabViewItem: _spellsKnownTab];
    }
    else if (![_casterType isEqualToString: kDMSpontaneousLabel])
    {
        [_tabView removeTabViewItem: _spellsKnownTab];
    }
}


- (NSData *) dataOfType: (NSString *) typeName error: (NSError **) outError
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData: data];
    
    [archiver encodeObject: _name forKey: kDMClassNameKey];
    [archiver encodeInteger: _hitDie forKey: kDMHitDieKey];
    [archiver encodeInteger: _skillPoints forKey: kDMSkillPointsKey];
    [archiver encodeObject: _classType forKey: kDMClassTypeKey];
    
    if ([_classType isEqualToString: kDMCasterLabel])
        [archiver encodeObject: _casterType forKey: kDMCasterTypeKey];
    else
        [archiver encodeObject: @"N/A" forKey: kDMCasterTypeKey];
    
    NSMutableArray *skills = [[NSMutableArray alloc] initWithCapacity: [_skillNames count]];
    NSUInteger index = [_selectedSkills firstIndex];
    while (index != NSNotFound)
    {
        [skills addObject: [_skillNames objectAtIndex: index]];
        index = [_selectedSkills indexGreaterThanIndex: index];
    }
    [archiver encodeObject: skills forKey: kDMClassSkillsKey];
    [skills release];
    
    [archiver encodeInt: _levelCap forKey: kDMLevelCapKey];
    [archiver encodeInt: _attackProgression forKey: kDMBaseAttackKey];
    [archiver encodeInt: _fortitudeProgression forKey: kDMFortitudeKey];
    [archiver encodeInt: _reflexProgression forKey: kDMReflexKey];
    [archiver encodeInt: _willProgression forKey: kDMWillKey];
    
    [archiver finishEncoding];
    [archiver release];
    
    return [data autorelease];
}


- (BOOL) readFromData: (NSData *) data ofType: (NSString *) typeName error: (NSError **) outError
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
    
    [_name release];
    _name = [[unarchiver decodeObjectForKey: kDMClassNameKey] retain];
    
    _hitDie = [unarchiver decodeIntegerForKey: kDMHitDieKey];
    _skillPoints = [unarchiver decodeIntegerForKey: kDMSkillPointsKey];
    
    [_classType release];
    _classType = [[unarchiver decodeObjectForKey: kDMClassTypeKey] retain];
    
    [_casterType release];
    NSString *type = [unarchiver decodeObjectForKey: kDMCasterTypeKey];
    if ([type isEqualToString: @"N/A"])
        type = kDMPreparedLabel;
    _casterType = [type retain];
    
    [_selectedSkills removeAllIndexes];
    NSArray *skills = [unarchiver decodeObjectForKey: kDMClassSkillsKey];
    for (NSString *skill in skills)
        [_selectedSkills addIndex: [_skillNames indexOfObject: skill]];
    
    _levelCap = [unarchiver decodeIntForKey: kDMLevelCapKey];
    _attackProgression = [unarchiver decodeIntForKey: kDMBaseAttackKey];
    _fortitudeProgression = [unarchiver decodeIntForKey: kDMFortitudeKey];
    _reflexProgression = [unarchiver decodeIntForKey: kDMReflexKey];
    _willProgression = [unarchiver decodeIntForKey: kDMWillKey];
    
    [unarchiver finishDecoding];
    [unarchiver release];
    
    return YES;
}


+ (BOOL) autosavesInPlace
{
    return YES;
}

@end
