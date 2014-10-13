//
//  RecordController.m
//  newPocket
//
//  Created by 杜長城 on 9/3/14.
//  Copyright (c) 2014 杜長城. All rights reserved.
//

#import "RecordController.h"

@interface RecordController ()

@end

@implementation RecordController
@synthesize frameForCapture;
@synthesize playButton;
@synthesize startRecordButton;
@synthesize retakeButton;
@synthesize saveImageButton;
@synthesize takePhotoButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //self.showMedia.contentMode = UIViewContentModeScaleToFill;
    [self startCamera];
    
    // Disable Stop/Play button when application launches
    [playButton setEnabled:NO];
    [saveImageButton setEnabled:NO];
    [retakeButton setEnabled:NO];
    [startRecordButton setEnabled:NO];
    
    [playButton setHidden:YES];
    [startRecordButton setHidden:YES];
}

/*
- (IBAction)clickStartCameraButton:(id)sender {
    
    // 先檢查裝置是否配備相機
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        // 設定相片來源為裝置上的相機
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        // 設定imagePicker的delegate為ViewController
        imagePicker.delegate = self;
        // 開啟相機拍照界面
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    // Apple limited file authority http://stackoverflow.com/questions/3837115/display-image-from-url-retrieved-from-alasset-in-iphone
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if( [picker sourceType] == UIImagePickerControllerSourceTypeCamera )
    {
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        
        // 取得已開啓的資料庫連線變數
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        sqlite3 *db = [delegate getDB];
        
        // save original image to picture library
        [library writeImageToSavedPhotosAlbum:originalImage.CGImage orientation:(ALAssetOrientation)originalImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error )
         {
             // compress image
             CGSize destinationSize = CGSizeMake(320,200);
             UIGraphicsBeginImageContext(destinationSize);
             [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
             UIImage *compressedImage = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
             
             // save thumbnail image to document
             NSData *thumbnailData = UIImagePNGRepresentation(compressedImage);
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
             
             // name thumbnail as date
             NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
             [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
             NSString *thumbnailName = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:[NSDate date]]];
             NSString *filePath = [documentsPath stringByAppendingPathComponent:thumbnailName];
             
             // save
             [thumbnailData writeToFile:filePath atomically:YES];
             

             
             
             NSLog(@"RecordController: IMAGE SAVED TO PHOTO ALBUM");
             [library assetForURL:assetURL resultBlock:^(ALAsset *asset )
              {
                  NSLog(@"RecordController: ALAsset located!");
                  NSLog(@"RecordController: path= %@", [asset valueForProperty:ALAssetPropertyAssetURL]);
                  
                  
                  if (db != nil) {
                      // 準備好查詢的SQL command
                      NSString *queryString = [NSString stringWithFormat:@"insert into medias values(NULL, NULL, 'picture', '2014-01-01 10:00:00', 'Bali', '%@', '%@', NULL, 1)", [asset valueForProperty:ALAssetPropertyAssetURL], filePath];
                      const char *sql = [queryString UTF8String];
                      
                      sqlite3_stmt *statement;
                      // 執行
                      sqlite3_prepare(db, sql, -1, &statement, NULL);
                      // statement用來儲存執行結果
                      
                      // 檢查插入資料是否成功
                      if (sqlite3_step(statement) == SQLITE_DONE) {
                          NSLog(@"TimelineController: picture path save to database");
                      } else {
                          NSLog(@"TimelineController: picture saving failed");
                      }
                      
                      sqlite3_finalize(statement);
                  }
                  // refresh timeline view
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMedia" object:nil];
            
              }
              failureBlock:^(NSError *error )
              {
                  NSLog(@"Error loading asset");
              }];
         }];
    }

    // [library release];
    // 關閉拍照程式
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // 當使用者按下取消按鈕後關閉拍照程式
    [self dismissViewControllerAnimated:YES completion:nil];
}
*/

//start a camera
- (void)startCamera
{
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    
    
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    // for preview the photo
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer]; //add rootLayer on the view
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.frameForCapture.frame;
    
    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSetting = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSetting];
    
    [session addOutput:stillImageOutput];
    [session startRunning];
    
}

//voicerecording function
- (void)startVoiceRecod
{
    // Set the audio file
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    audioName = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:[NSDate date]]];
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               audioName,
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    NSLog(@"%@",pathComponents);
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//take photo function
- (IBAction)takePhoto:(id)sender
{
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break;}
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error){
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            // get photo
            UIImage *image = [UIImage imageWithData:imageData];
            tmpImage = image;
            
        }
    }];
    
    [session stopRunning];
    
    [retakeButton setEnabled:YES];
    [startRecordButton setEnabled:YES];
    [saveImageButton setEnabled:YES];
    [takePhotoButton setEnabled:NO];
    [startRecordButton setHidden:NO];
    [playButton setHidden:NO];
    
    [self startVoiceRecod];
    
}


//selfie function
- (IBAction)selfie:(id)sender
{
    //Change camera source
    if(session)
    {
        //Indicate that some changes will be made to the session
        [session beginConfiguration];
        
        //Remove existing input
        AVCaptureInput* currentCameraInput = [session.inputs objectAtIndex:0];
        [session removeInput:currentCameraInput];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        
        //Add input to session
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        [session addInput:newVideoInput];
        
        //Commit all the configuration changes at once
        [session commitConfiguration];
    }
}

// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return nil;
}

- (IBAction)retake:(id)sender
{
    [session startRunning];
    [playButton setEnabled:NO];
    [saveImageButton setEnabled:NO];
    [retakeButton setEnabled:NO];
    [startRecordButton setEnabled:NO];
    [takePhotoButton setEnabled:YES];
    [playButton setHidden:YES];
    [startRecordButton setHidden:YES];
}

- (IBAction)startRecordTapped:(id)sender {
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        // Start recording
        [recorder record];
        [startRecordButton setTitle:@"Done" forState:UIControlStateNormal];
        
    } else {
        // Stop recording
        [recorder stop];
    }
    
    [playButton setEnabled:NO];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [startRecordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [playButton setEnabled:YES];
}


- (IBAction)playTapped:(id)sender {
    if (!recorder.recording){
        // get audio file
        // play with path format-> /var/mobile/Applications/00E43168-08E3-4EC2-8A9E-80BF6A2C7C17/Documents/audioFile.ext
        
        // Set the audio file
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   audioName,
                                   nil];
        NSURL *fileURL = [NSURL fileURLWithPathComponents:pathComponents];
        NSLog(@"%@", fileURL);
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        [player setDelegate:self];
        [player play];
        
    }
}

- (IBAction)savePhotoTapped:(id)sender {
    
    // 取得已開啓的資料庫連線變數
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sqlite3 *db = [delegate getDB];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:tmpImage.CGImage orientation:(ALAssetOrientation)tmpImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error )
     {
         if (!recorder.recording){
             // get audio file
             // play with path format-> /var/mobile/Applications/00E43168-08E3-4EC2-8A9E-80BF6A2C7C17/Documents/audioFile.ext
             
             // Set the audio file
             NSArray *pathComponents = [NSArray arrayWithObjects:
                                        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                        audioName,
                                        nil];
             NSURL *fileURL = [NSURL fileURLWithPathComponents:pathComponents];
             audiopath = [fileURL absoluteString];
         }
         // compress image
         CGSize destinationSize = CGSizeMake(320,200);
         UIGraphicsBeginImageContext(destinationSize);
         [tmpImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
         UIImage *compressedImage = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         
         // save thumbnail image to document
         NSData *thumbnailData = UIImagePNGRepresentation(compressedImage);
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
         
         // name thumbnail as date
         NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
         [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
         NSString *thumbnailName = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:[NSDate date]]];
         NSString *filePath = [documentsPath stringByAppendingPathComponent:thumbnailName];
         
         // save thu
         [thumbnailData writeToFile:filePath atomically:YES];
         
         NSLog(@"RecordController: IMAGE SAVED TO PHOTO ALBUM");
         [library assetForURL:assetURL resultBlock:^(ALAsset *asset )
          {
              NSLog(@"RecordController: ALAsset located!");
              NSLog(@"RecordController: path= %@", [asset valueForProperty:ALAssetPropertyAssetURL]);
              
              
              if (db != nil) {
                  // insert SQL command
                  NSString *queryString = [NSString stringWithFormat:@"insert into medias values(NULL, NULL, 'picture', '2014-01-01 10:00:00', '%@', '%@', '%@', NULL, 1)", audiopath, [asset valueForProperty:ALAssetPropertyAssetURL], filePath];
                  const char *sql = [queryString UTF8String];
                  
                  sqlite3_stmt *statement;
                  // 執行
                  sqlite3_prepare(db, sql, -1, &statement, NULL);
                  // statement用來儲存執行結果
                  
                  // 檢查插入資料是否成功
                  if (sqlite3_step(statement) == SQLITE_DONE) {
                      NSLog(@"TimelineController: picture path save to database");
                  } else {
                      NSLog(@"TimelineController: picture saving failed");
                  }
                  
                  sqlite3_finalize(statement);
              }
              // refresh timeline view
              [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMedia" object:nil];
              
          }
                 failureBlock:^(NSError *error )
          {
              NSLog(@"Error loading asset");
          }];
     }];
    
    
    [self showFile];
    
}

- (void)showFile
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *arr = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *url = arr[0];
    
    // includingPropertiesForKey: 表示要列出具備哪些屬性的檔案，nil表示所有屬性都要的意思
    // option: 目前可以使用的參數是 NSDirectoryEnumerationSkipsHiddenFiles 代表不要列出隱藏檔
    //         如果要連隱藏檔都列出，則使用 ~NSDirectoryEnumerationSkipsHiddenFiles
    //         UNIX 的隱藏檔是以「.」開頭的檔案
    NSArray *fileList = [fm contentsOfDirectoryAtURL:url
                          includingPropertiesForKeys:nil
                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                               error:nil
                         ];
    
    BOOL isDir;
    for (NSURL *p in fileList) {
        // NSURL 類別包含了檔案的絕對路徑（以URI的格式呈現）
        // .lastPathComponent 則是URI中檔名的部分
        if ([fm fileExistsAtPath:p.path isDirectory:&isDir] && isDir)
            NSLog(@"%@ 是目錄.", p.lastPathComponent);
        else
            NSLog(@"%@ 是檔案.", p.lastPathComponent);
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
