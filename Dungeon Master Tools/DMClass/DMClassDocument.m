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



@interface DMClassDocument ()
{
    NSMutableIndexSet *_selectedSkills;
    NSArray *_skillNames;
    
    /* UI elements */
    NSTextField *_nameLabel;
    NSSegmentedControl *_hitDieSegment;
    NSSegmentedControl *_skillPointsSegment;
    NSSegmentedControl *_classTypeSegment;
    NSTextField *_casterTypeLabel;
    NSSegmentedControl *_casterTypeSegment;
    NSTableView *_skillTable;
    
    NSTableView *_levelUpChart;
    NSSlider *_levelCapSlider;
    NSSegmentedControl *_baseAttackSegment;
}

@end



@implementation DMClassDocument

@synthesize nameLabel = _nameLabel;
@synthesize hitDieSegment = _hitDieSegment;
@synthesize skillPointsSegment = _skillPointsSegment;
@synthesize classTypeSegment = _classTypeSegment;
@synthesize casterTypeLabel = _casterTypeLabel;
@synthesize casterTypeSegment = _casterTypeSegment;
@synthesize skillTable = _skillTable;
@synthesize levelUpChart = _levelUpChart;
@synthesize levelCapSlider = _levelCapSlider;
@synthesize baseAttackSegment = _baseAttackSegment;


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
    
    [_nameLabel release];
    [_hitDieSegment release];
    [_skillPointsSegment release];
    [_classTypeSegment release];
    [_casterTypeLabel release];
    [_casterTypeSegment release];
    
    [_skillTable release];
    [_levelUpChart release];
    
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
    }
    else
    {
        [_casterTypeSegment setHidden: YES];
        [_casterTypeLabel setHidden: YES];
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
    }
}


#pragma mark - Slider handler

- (void) sliderChanged: (NSSlider *) sender
{
    [self setLevelCap: [sender integerValue]];
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
            
            switch (attack)
            {
                case 0: case 1: case 2: case 3: case 4: case 5:
                    return [NSString stringWithFormat: @"+%d", attack];

                case 6: case 7: case 8: case 9: case 10:
                    return [NSString stringWithFormat: @"+%d/+%d", attack, attack - 5];
                    
                case 11: case 12: case 13: case 14: case 15:
                    return [NSString stringWithFormat: @"+%d/+%d/+%d", attack, attack - 5, attack - 10];
                    
                case 16: case 17: case 18: case 19: case 20:
                    return [NSString stringWithFormat: @"+%d/+%d/+%d/+%d", attack, attack - 5, attack - 10, attack - 15];

                default:
                    return nil;
            }
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


#pragma mark - NSTableViewDelegate

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
    }
    else
    {
        [_casterTypeSegment setHidden: YES];
        [_casterTypeLabel setHidden: YES];
    }
    
    index = [[NSArray arrayWithObjects: kDMPreparedLabel, kDMSpontaneousLabel, kDMPrestigeLabel, nil] indexOfObject: _casterType];
    [_casterTypeSegment setSelectedSegment: index];
    
    [_levelCapSlider setIntegerValue: _levelCap];
    [_baseAttackSegment setSelectedSegment: _attackProgression];
}


- (NSData *) dataOfType: (NSString *) typeName error: (NSError **) outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.    
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
    
    [archiver finishEncoding];
    [archiver release];
    
    return [data autorelease];
}


- (BOOL) readFromData: (NSData *) data ofType: (NSString *) typeName error: (NSError **) outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
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
    
    [unarchiver finishDecoding];
    [unarchiver release];
    
    return YES;
}


+ (BOOL) autosavesInPlace
{
    return YES;
}

@end
