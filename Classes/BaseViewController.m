    //
//  BaseViewController.m
//  GenericTownHall
//
//  Created by David Ang on 3/11/11.
//  Copyright 2011 n/a. All rights reserved.
//

#import "BaseViewController.h"


@implementation BaseViewController

@synthesize headerView;
@synthesize toolbar;
@synthesize tableView;
@synthesize items;
@synthesize currentPage;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	NSLog(@"BaseViewController %@: %@", NSStringFromSelector(_cmd), self);
	
	GenericTownHallAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	items = [[NSMutableArray alloc] init];
	
	self.view = [[UIView alloc] initWithFrame: CGRectMake(.0f, 44.f, appDelegate.appWidth, appDelegate.appHeight)];
	[self.view setBackgroundColor:[UIColor clearColor]];	

	
	// Listen to orientaton changes
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:@"OrientationChange" object:nil]; 
	
	[self makeHttpRequest];
}

- (void) addHeader {
	headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, UIAppDelegate.appWidth, 100.f)];
	[headerView setBackgroundColor:[UIColor blackColor]];
	
	// add toolbar
	toolbar = [UIToolbar new];
	[toolbar setBarStyle:UIBarStyleBlack];
	[toolbar sizeToFit];
	[toolbar setFrame: CGRectMake(0, 100.f, UIAppDelegate.appWidth, 50.f)];	
	
	[self.view addSubview:headerView];
	[self.view addSubview:toolbar];
}

- (void) addTableView:(UITableViewStyle)aStyle {
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(.0f, 100.f, UIAppDelegate.appWidth, UIAppDelegate.appHeight) style:aStyle];

	[tableView setDataSource:self];
	[tableView setDelegate:self];
	[tableView setBackgroundView:nil];
	[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	
	//[tableView setAlpha:0.5f];
	//tableView.backgroundColor = [UIColor blackColor];
	//tableView.opaque = NO;	
	
	if (aStyle == UITableViewStylePlain) {
		[tableView setSeparatorColor: UIColorFromRGB(0x3e5021)];
		[tableView setBackgroundColor:UIColorFromRGB(0x3e5021)];
	}       	
	
	[self.view addSubview:tableView];
}


-(void)orientationChange:(NSNotification *)orientation { 
	CGRect tableViewFrame = tableView.frame;
	tableViewFrame.size.width = UIAppDelegate.appWidth;
	
	
	
	CGFloat rootViewWidth = self.view.superview.frame.size.width;	
	
	// See if this view controller is showing up on the root view pane
	if(rootViewWidth < 400.f) {
		[tableView setFrame:CGRectMake(0.f, 0.f, rootViewWidth, UIAppDelegate.appHeight - 50.f)];
	} else {
		// Adjust the table view height if we're on a plain style
		if (tableView.style == UITableViewStylePlain) {
			if(UIAppDelegate.currentOrientation == UIInterfaceOrientationPortrait || UIAppDelegate.currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
				tableViewFrame.size.height = UIAppDelegate.appHeight - 200.f;	
			} else {
				tableViewFrame.size.height = UIAppDelegate.appHeight - 200.f;	
			}
		}
		tableView.frame = tableViewFrame;		
	}

	[tableView reloadData];
	
	// Also adjust the header if its set
	if (headerView != nil) {
		[headerView setFrame: CGRectMake(0, 0.f, UIAppDelegate.appWidth, 150.f)];
		[toolbar setFrame: CGRectMake(0, 100.f, UIAppDelegate.appWidth, 50.f)];		
	}		
}

-(void)makeHttpRequest{
	NSString *serviceUrl = [self getServiceUrl];
	NSString *extraParams = [self getExtraParams];
	NSString *url = nil;
	
	if (extraParams) {
		url = [NSString stringWithFormat:@"%@/%@?%@&format=json&ApiKey=%@", UIAppDelegate.serverDataUrl, serviceUrl, extraParams, UIAppDelegate.serverApiKey];
	} else {
		url = [NSString stringWithFormat:@"%@/%@?format=json&ApiKey=%@", UIAppDelegate.serverDataUrl, serviceUrl, UIAppDelegate.serverApiKey];
	}
	
	NSURL *nsUrl = [NSURL URLWithString: url];
	NSLog(@"Making HTTP request: %@", nsUrl);	
	
	// Create a request
	// You don't normally need to retain a synchronous request, but we need to in this case because we'll need it later if we reload the table data
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:nsUrl];
	[request setDelegate:self];	
	[request setValidatesSecureCertificate:NO];
	[request startAsynchronous];
	
	GenericTownHallAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	[appDelegate.progressHUD showUsingAnimation:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	GenericTownHallAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	[appDelegate.progressHUD hideUsingAnimation:YES];
	
	// Use when fetching text data
	NSString *responseString = [request responseString];
	
	// Create an array out of the returned json string
	id *results = [responseString JSONValue];
	
	if ([results isKindOfClass:[NSArray class]] || [results isKindOfClass:[NSDictionary class]])  { 
		
		NSLog(@"Http request succeeded: %@ Count: %d", responseString, [results count]);

		[items removeAllObjects];
		
		[self handleHttpResponse:responseString];
		
		[tableView reloadData];			
	} else {
		NSLog(@"Http request result bad data: %@", responseString);
	    
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message: @"We apologize but there has been an error on our server. Would you try again a little later our programmers are working hard to fix the error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];            
//		[alert show];
//		[alert release];
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];

	NSLog(@"Http request failed: %@ Count: %d", error);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message: @"We apologize but there has been a problem connecting with our server. Would you try again a little later?." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];            
	[alert show];
	[alert release];	
}


// Adjust the frame sizes of the various UI controls
- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"%@: %@", NSStringFromSelector(_cmd), self);	
	
	
	if (headerView != nil) {
		CGFloat rootViewWidth = self.view.superview.frame.size.width;	
		
		// See if this view controller is showing up on the root view pane
		if(rootViewWidth < 400.f) {
			[headerView setHidden:YES];
			[toolbar setHidden:YES];

			[tableView setFrame:CGRectMake(0.f, 0.f, rootViewWidth, UIAppDelegate.appHeight - 50.f)];
		}
		// Otherwise set correct frame size for the details pane
		else {
			[headerView setHidden:NO];
			[toolbar setHidden:NO];

			if(UIAppDelegate.currentOrientation == UIInterfaceOrientationPortrait || UIAppDelegate.currentOrientation == UIInterfaceOrientationPortraitUpsideDown) {
				[tableView setFrame:CGRectMake(.0f, 150.f, UIAppDelegate.appWidth, UIAppDelegate.appHeight - 200.f)];
			} else {
				[tableView setFrame:CGRectMake(.0f, 150.f, UIAppDelegate.appWidth, UIAppDelegate.appHeight - 200.f)];
			}
		}
	}
	
	[tableView reloadData];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Polymorphic methods
- (NSString*) getServiceUrl {
	return nil;
}

- (NSString*) getExtraParams {
	return nil;
}

- (void)handleHttpResponse:(NSString*)responseString {	
}

#pragma mark Table view data source (override on child classes if need)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (currentPage != 0) {
		// show an extra row at the bottom for the pagination
		NSInteger count = [items count];
		if( count < currentPage * 10 ) {
			return count;
		} else {
			return count + 1;
		}
	} else {
		return [items count];
	}

}

// Customize the appearance of table view cells.
- (UITableViewCell *)aTableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}

// Show no entries
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {   
   
	if (tableView.style == UITableViewStyleGrouped) {
		return nil;
	}
	
	// create the parent view that will hold Label
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.f,0.f, UIAppDelegate.appWidth, 50.f)] autorelease];
	[customView setBackgroundColor:[UIColor blackColor]];

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(UIAppDelegate.appWidth / 2.f - 50.f, 15.f, 100.f, 35.f)];
	[label setText:@"No entries"];
	[label setFont:[UIFont systemFontOfSize:20]];
	[label setTextColor:[UIColor whiteColor]];
	[label setBackgroundColor:[UIColor clearColor]];

	//add the button to the view
	[customView addSubview:label];

	if ([items count] == 0) {
		return customView;
	}

	return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
   return 50.0;
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 return 100.0f;
}

#pragma mark Helper methods

- (NSDate*) getDateFromJSON:(NSString *)dateString
{
    // Expect date in this format "/Date(1268123281843)/"
    int startPos = [dateString rangeOfString:@"("].location+1;
    int endPos = [dateString rangeOfString:@")"].location;
    NSRange range = NSMakeRange(startPos,endPos-startPos);
    unsigned long long milliseconds = [[dateString substringWithRange:range] longLongValue];
    //NSLog(@"%llu",milliseconds);
    NSTimeInterval interval = milliseconds/1000;
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

- (void)dealloc {
	NSLog(@"BaseViewController %@: %@", NSStringFromSelector(_cmd), self);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];		  
	[items dealloc];
	
    [super dealloc];
}


@end
