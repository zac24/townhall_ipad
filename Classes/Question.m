//
//  Nugget.m
//  TownHallServiceClient
//
//  Created by Marc Mercuri on 5/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Question.h"

@implementation Question

@synthesize nuggetId = _nuggetId;
@synthesize subject= _subject;
@synthesize subjectSlug = _subjectSlug;
@synthesize category  = _category;
@synthesize categoryName  = _categoryName;
@synthesize body  = _body;
@synthesize nuggetOriginator = _nuggetOriginator;
@synthesize votes = _votes;
@synthesize topNuggetVoteCount = _topNuggetVoteCount;
@synthesize nuggetFlags = _nuggetFlags;
@synthesize dateCreated = _dateCreated;
@synthesize dateModified = _dateModified;
@synthesize userSpecificTags = _userSpecificTags;
@synthesize responseCount = _responseCount;
@synthesize responses = _responses;

-(id)init {
    if (self = [super init]) {		
		_votes = [[Votes alloc]init];
		_nuggetOriginator= [[Originator alloc]init];
		_responses = [[NSMutableArray alloc] init];
    }
    return self;
}

// does not work 12/29/10
-(NSString*)dateStringFromString:(NSString*)sourceString
					  sourceFormat:(NSString *)sourceFormat
				 destinationFormat:(NSString *)destinationFormat
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	
    [dateFormatter setDateFormat:sourceFormat];
//    NSDate *date = [dateFormatter dateFromString:sourceString];
    [dateFormatter setDateFormat:destinationFormat];
    return [dateFormatter stringFromDate:sourceString];
}

-(NSString*)dateCreatedFormatted {
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMM dd, yyyy h:mm a"];
	return [format stringFromDate:self.dateCreated];
}
 

-(void)dealloc{
	
	/*
	self.nuggetId = nil;
	self.subject = nil;
	self.subjectSlug = nil;
	self.category = nil;
	self.categoryName = nil;
	self.body = nil;
	self.nuggetOriginator = nil;
	self.votes = nil;
	self.topNuggetVoteCount = nil;
	self.nuggetFlags = nil;
	self.dateCreated = nil;
	self.dateModified = nil;
	self.userSpecificTags = nil;
	self.responses = nil;
	*/
	[super dealloc];
}
@end