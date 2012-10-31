//
//  CropingArea.m
//  iCrop
//
//  Created by Chinthaka Kumarasiri on 25/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CropingArea.h"
#import <QuartzCore/QuartzCore.h>

@implementation CropingArea

@synthesize firstTouch;
@synthesize lastTouch;
@synthesize redrawRect;
@synthesize rectPoints;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder{
	if ((self = [super initWithCoder:coder])) {
		
	}
	return self;
}

-(CGRect)currentRect{
	CGRect rect = CGRectMake((firstTouch.x > lastTouch.x) ? lastTouch.x : firstTouch.x,
							 (firstTouch.y > lastTouch.y) ? lastTouch.y : firstTouch.y,
							 fabsf(firstTouch.x - lastTouch.x),
							 fabsf(firstTouch.y - lastTouch.y));
	
	rectPoints = rect;	
	return rect;
}

//This method returns the touches
- (CGRect)returnCurrentTouches{
	return rectPoints;
}


//Call this method to pass UIImage that you want to crop
- (void)setImageForCrop:(UIImage *)image
{
    _imageForCrop = image;
}

//Defind the image you want to crop here
- (void)drawRect:(CGRect)rect {
		
	CGContextRef context = UIGraphicsGetCurrentContext();		
	CGRect rectNew = CGRectMake(0, 30, _imageForCrop.size.width, _imageForCrop.size.height);
	[_imageForCrop drawInRect:rectNew];
	
	// Drawing the  rect
	CGContextSetLineWidth(context, 2.0);
	float length[2] = {4.0, 4.0};
	CGContextSetLineDash(context, 2.0, length, 1);
	CGContextAddRect(context, self.currentRect);
	CGContextDrawPath(context, kCGPathStroke);
	
		
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	firstTouch = [touch locationInView:self];
	lastTouch = [touch locationInView:self];
	[self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	lastTouch = [touch locationInView:self];
	redrawRect = CGRectUnion(redrawRect, self.currentRect);
	redrawRect = CGRectInset(redrawRect, -2.0, -2.0);
	[self setNeedsDisplayInRect:redrawRect];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	lastTouch = [touch locationInView:self];
	redrawRect = CGRectUnion(redrawRect, self.currentRect); 
	[self setNeedsDisplayInRect:redrawRect];
}




@end
