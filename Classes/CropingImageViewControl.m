    //
//  CropingImageViewControl.m
//  iCrop
//
//  Created by Chinthaka Kumarasiri on 25/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CropingImageViewControl.h"
#import "CropingArea.h"
#import <QuartzCore/QuartzCore.h>

@implementation CropingImageViewControl

@synthesize cropedImg;



-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Draw a rect";
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    
    _cropView = (CropingArea *)self.view;
    [_cropView setImageForCrop:_originalImg];
	
}


//This method is called when you press crop button on the toolbar
- (IBAction)selectForCrop:(id) sender{
	
	
	CGSize screenSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width , [[UIScreen mainScreen] bounds].size.height);
		
	UIGraphicsBeginImageContext(screenSize) ;
	[_cropView.layer renderInContext:UIGraphicsGetCurrentContext()];
	cropedImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
		
	CGRect rect = [_cropView returnCurrentTouches];
	//CGRect rect = CGRectMake(57.0, 90.0, 141.0, 220.0); 
	
    // Create bitmap image from original image data,
	// using rectangle to specify desired crop area
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([cropedImg CGImage], rect);
	UIImage *img = [UIImage imageWithCGImage:imageRef]; 
	CGImageRelease(imageRef);
	
    [_delegate resultingImage:img];
    [self dismissModalViewControllerAnimated:YES];
}




/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	
NSLog(@"initWithCoder.................");
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
