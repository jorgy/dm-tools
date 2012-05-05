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


@implementation DMClassDocument

@synthesize nameLabel = _nameLabel;


#pragma mark - Memory lifecycle

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _name = [@"" retain];
    }
    
    return self;
}


- (void) dealloc
{
    [_name release];
    [_nameLabel release];
    
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


#pragma mark - 

- (void) segmentedControlChanged: (NSSegmentedControl *) sender
{
    switch ([sender tag])
    {
        case kDMHitDieTag:
            NSLog(@"Hit Die");
            break;
            
        case kDMSkillPointsTag:
            NSLog(@"Skill Points");
            break;
            
        case kDMClassTypeTag:
            NSLog(@"Class Type");
            break;
            
        case kDMCasterTypeTag:
            NSLog(@"Caster Type");
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
}


- (NSData *) dataOfType: (NSString *) typeName error: (NSError **) outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData: data];
    [archiver encodeObject: _name forKey: @"classname"];
    [archiver finishEncoding];
    [archiver release];
    
    return [data autorelease];
}


- (BOOL) readFromData: (NSData *) data ofType: (NSString *) typeName error: (NSError **) outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
    
    NSString *name = [[unarchiver decodeObjectForKey: @"classname"] retain];
    
    [unarchiver finishDecoding];
    [unarchiver release];
    
    NSLog(@"%@", name);
    
    [name release];
    
    return YES;
}


+ (BOOL) autosavesInPlace
{
    return YES;
}

@end
