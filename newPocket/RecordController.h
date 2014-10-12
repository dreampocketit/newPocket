//
//  RecordController.h
//  newPocket
//
//  Created by 杜長城 on 9/3/14.
//  Copyright (c) 2014 杜長城. All rights reserved.
//

#import "ViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordController : ViewController
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
    UIImage *tmpImage;
    NSString *audiopath;
    NSString *audioName;
}

- (IBAction)selfie:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *frameForCapture;

- (IBAction)takePhoto:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *startRecordButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *retakeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveImageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIImageView *showMedia;
@property (weak, nonatomic) IBOutlet UIButton *startCameraButton;

@end
