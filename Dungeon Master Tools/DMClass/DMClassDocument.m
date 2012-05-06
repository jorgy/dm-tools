//
//  DMClassDocument.m
//  Dungeon Master Tools
//
//  Created by Kevin Jorgensen on 4/4/12.
//  Copyright (c) 2012 Kevin Jorgensen. All rights reserved.
//

#import "DMClassDocument.h"


#define kDMHitDieTag      (1000)
#define kDMSkillPointsTag (1001)
#define kDMClassTypeTag   (1002)
#define kDMCasterTypeTag  (1003)

#define kDMCasterLabel @"Caster"
#define kDMNonCasterLabel @"Non-Caster"
#define kDMMonsterLabel @"Monster"
#define kDMPreparedLabel @"Prepared"
#define kDMSpontaneousLabel @"Spontaneous"


@implementation DMClassDocument

@synthesize nameLabel = _nameLabel;
@synthesize hitDieSegment = _hitDieSegment;
@synthesize skillPointsSegment = _skillPointsSegment;
@synthesize classTypeSegment = _classTypeSegment;
@synthesize casterTypeLabel = _casterTypeLabel;
@synthesize casterTypeSegment = _casterTypeSegment;


#pragma mark - Memory lifecycle

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _name = [@"" retain];
        _hitDie = 4;
        _skillPoints = 2;
        _classType = [@"Caster" retain];
        _casterType = [@"Prepared" retain];
    }
    
    return self;
}


- (void) dealloc
{
    [_name release];
    [_classType release];
    
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
    
    NSInteger index = [[NSArray arrayWithObjects: @"Caster", @"Non-Caster", @"Monster", nil] indexOfObject: classType];
    [_classTypeSegment setSelectedSegment: index];
    
    if (_casterTypeSegment == nil)
        NSLog(@"Huh?");
    
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
    
    NSInteger index = [[NSArray arrayWithObjects: @"Prepared", @"Spontaneous", @"Prestige Class", nil] indexOfObject: casterType];
    [_casterTypeSegment setSelectedSegment: index];
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
    }
}


#pragma mark - NSTextFieldDelegate

- (void) controlTextDidChange: (NSNotification *) obj
{
    [self setClassName: [_nameLabel stringValue]];
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
    
    NSInteger index = [[NSArray arrayWithObjects: @"Caster", @"Non-Caster", @"Monster", nil] indexOfObject: _classType];
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
    
    index = [[NSArray arrayWithObjects: @"Prepared", @"Spontaneous", @"Prestige Class", nil] indexOfObject: _casterType];
    [_casterTypeSegment setSelectedSegment: index];
}


- (NSData *) dataOfType: (NSString *) typeName error: (NSError **) outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData: data];
    
    [archiver encodeObject: _name forKey: @"classname"];
    [archiver encodeInteger: _hitDie forKey: @"hitdie"];
    [archiver encodeInteger: _skillPoints forKey: @"skillpoints"];
    [archiver encodeObject: _classType forKey: @"classtype"];
    
    if ([_classType isEqualToString: @"Caster"])
        [archiver encodeObject: _casterType forKey: @"castertype"];
    else
        [archiver encodeObject: @"N/A" forKey: @"castertype"];
    
    [archiver finishEncoding];
    [archiver release];
    
    return [data autorelease];
}


- (BOOL) readFromData: (NSData *) data ofType: (NSString *) typeName error: (NSError **) outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
    
    [_name release];
    _name = [[unarchiver decodeObjectForKey: @"classname"] retain];
    
    _hitDie = [unarchiver decodeIntegerForKey: @"hitdie"];
    _skillPoints = [unarchiver decodeIntegerForKey: @"skillpoints"];
    
    [_classType release];
    _classType = [[unarchiver decodeObjectForKey: @"classtype"] retain];
    
    [_casterType release];
    NSString *type = [unarchiver decodeObjectForKey: @"castertype"];
    if ([type isEqualToString: @"N/A"])
        type = @"Prepared";
    _casterType = [type retain];
    
    [unarchiver finishDecoding];
    [unarchiver release];
    
    return YES;
}


+ (BOOL) autosavesInPlace
{
    return YES;
}

@end
