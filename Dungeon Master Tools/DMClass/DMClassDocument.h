//
//  DMClassDocument.h
//  Dungeon Master Tools
//
//  Created by Kevin Jorgensen on 4/4/12.
//  Copyright (c) 2012 Kevin Jorgensen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DMClassDocument : NSDocument <NSTextFieldDelegate>
{
    NSString *_name;
    NSUInteger _hitDie;
    NSUInteger _skillPoints;
    NSString *_classType;
    NSString *_casterType;
    
    NSTextField *_nameLabel;
    NSSegmentedControl *_hitDieSegment;
    NSSegmentedControl *_skillPointsSegment;
    NSSegmentedControl *_classTypeSegment;
    NSTextField *_casterTypeLabel;
    NSSegmentedControl *_casterTypeSegment;
}

@property (nonatomic, retain) IBOutlet NSTextField *nameLabel;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *hitDieSegment;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *skillPointsSegment;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *classTypeSegment;
@property (nonatomic, retain) IBOutlet NSTextField *casterTypeLabel;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *casterTypeSegment;

- (IBAction) segmentedControlChanged: (NSSegmentedControl *) sender;

- (void) setClassName: (NSString *) name;

@end
