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

@interface TimelineController : ViewController <DBRestClientDelegate>
{
    NSMutableArray *mediaList;
    UIImageView *media;
    int rowNo;
    AVAudioPlayer *player;
    DBRestClient *restClient;
}

@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgress;
//@property (weak, nonatomic) IBOutlet UIImageView *test;

- (DBRestClient *)restClient;

@end
