//
//  CHINViewController.m
//  CropImage
//
//  Created by Chinthaka Kumarasiri on 31/10/2012.
//  Copyright (c) 2012 Chinthaka Kumarasiri. All rights reserved.
//

#import "CHINViewController.h"

@interface CHINViewController ()

@end

@implementation CHINViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Button action in main view
-(IBAction)startToCrop:(id)sender
{
    //Instantiate the crop library
    _cropingImageViewCon = [[CropingImageViewControl alloc]initWithNibName:@"CropingImageView" bundle:nil];
    _cropingImageViewCon.delegate = self;
    _cropingImageViewCon.originalImg = [UIImage imageNamed:@"Apple"];
    
    [self.navigationController presentModalViewController:_cropingImageViewCon animated:YES];
    
}

//CropingImageViewController delegate method
- (void)resultingImage:(UIImage *)image
{
    [_imageView setImage:image];
}


@end
