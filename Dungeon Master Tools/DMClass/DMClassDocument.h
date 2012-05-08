//
//  DMClassDocument.h
//  Dungeon Master Tools
//
//  Created by Kevin Jorgensen on 4/4/12.
//  Copyright (c) 2012 Kevin Jorgensen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum { DM_FAST = 0, DM_MEDIUM = 1, DM_SLOW = 2 } DMBaseAttackProgession;
typedef enum { DM_GOOD = 0, DM_BAD = 1 } DMSaveProgression;

@interface DMClassDocument : NSDocument <NSTextFieldDelegate>
{
    NSString *_name;
    NSUInteger _hitDie;
    NSUInteger _skillPoints;
    NSString *_classType;
    NSString *_casterType;
    
    NSInteger _levelCap;
    DMBaseAttackProgession _attackProgression;
    DMSaveProgression _fortitudeProgression;
    DMSaveProgression _reflexProgression;
    DMSaveProgression _willProgression;
}

/* UI properties for IB */
@property (nonatomic, retain) IBOutlet NSTabView *tabView;
@property (nonatomic, retain) IBOutlet NSTabViewItem *spellsTab;
@property (nonatomic, retain) IBOutlet NSTabViewItem *spellsKnownTab;

@property (nonatomic, retain) IBOutlet NSTextField *nameLabel;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *hitDieSegment;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *skillPointsSegment;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *classTypeSegment;
@property (nonatomic, retain) IBOutlet NSTextField *casterTypeLabel;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *casterTypeSegment;
@property (nonatomic, retain) IBOutlet NSTextField *casterTypeInfoLabel;
@property (nonatomic, retain) IBOutlet NSTableView *skillTable;

@property (nonatomic, retain) IBOutlet NSTableView *levelUpChart;
@property (nonatomic, retain) IBOutlet NSSlider *levelCapSlider;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *baseAttackSegment;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *fortitudeSegment;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *reflexSegment;
@property (nonatomic, retain) IBOutlet NSSegmentedControl *willSegment;


/** Segmented control callback */
- (IBAction) segmentedControlChanged: (NSSegmentedControl *) sender;

/** Slider callback */
- (IBAction) sliderChanged: (NSSlider *) sender;

/** Spell table button handlers */
- (IBAction) spellsPerDayButtonTapped: (id) sender;

@end
