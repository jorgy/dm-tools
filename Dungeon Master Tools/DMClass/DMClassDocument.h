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
    
    NSTextField *_nameLabel;
}

@property (nonatomic, retain) IBOutlet NSTextField *nameLabel;

- (IBAction) segmentedControlChanged: (NSSegmentedControl *) sender;

- (void) setClassName: (NSString *) name;

@end
