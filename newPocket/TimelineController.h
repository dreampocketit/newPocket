//
//  TimelineController.h
//  newPocket
//
//  Created by 杜長城 on 9/1/14.
//  Copyright (c) 2014 杜長城. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface TimelineController : ViewController
{
    NSMutableArray *mediaList;
    UIImageView *media;
    int rowNo;
    AVAudioPlayer *player;
}

@end
