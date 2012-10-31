//
//  CropingArea.h
//  iCrop
//
//  Created by Chinthaka Kumarasiri on 25/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CropingArea : UIView

@property (nonatomic, assign) CGPoint firstTouch;
@property (nonatomic, assign) CGPoint lastTouch;
@property (nonatomic, assign) CGRect redrawRect;
@property (nonatomic, assign) CGRect currentRect;
@property (nonatomic, assign) CGRect rectPoints;
@property (nonatomic, strong) UIImage *imageForCrop;


- (CGRect)returnCurrentTouches;
- (void)setImageForCrop:(UIImage *)image;
@end
