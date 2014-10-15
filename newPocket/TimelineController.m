//
//  TimelineController.m
//  newPocket
//
//  Created by 杜長城 on 9/1/14.
//  Copyright (c) 2014 杜長城. All rights reserved.
//

#import "TimelineController.h"

@interface TimelineController ()

@end

@implementation TimelineController
//@synthesize test;


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *audioString = [[mediaList objectAtIndex:indexPath.row] objectForKey:@"audio_path"];
    NSURL * audio_url = [NSURL URLWithString:audioString];
    //NSLog(@"%@", audio_url);
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:audio_url error:nil];
    [player setDelegate:self];
    [player play];
    
    //get path and filename
    NSString *thumbnail = [[mediaList objectAtIndex:indexPath.row] objectForKey:@"thumbnail_path"];
    NSString* theFileName = [thumbnail lastPathComponent];
    NSLog(theFileName);
    NSString *path = [thumbnail stringByReplacingOccurrencesOfString:theFileName
                                         withString:@""];
    NSString *original_path = [[mediaList objectAtIndex:indexPath.row] objectForKey:@"original_path"];
    NSLog(original_path);
    
    //upload picture to Dropbox
    [self uploadToDropbox:[[mediaList objectAtIndex:indexPath.row] objectForKey:@"original_path"]];
    
    //[self showFile];
   
    
}

-(void)uploadToDropbox:(NSString *)url
{
    //upload the file to dropbox
    NSString *destDir = @"/";
    
    //locate original picture path
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAsset *assetURL=[NSURL URLWithString:url];
    
    
    [library assetForURL:assetURL resultBlock:^(ALAsset *asset )
     {
         NSLog(@"Timelinecontroller: Original picture ALAsset located!");
         ALAssetRepresentation *rep = [asset defaultRepresentation];
         CGImageRef iref = [rep fullResolutionImage];
         if (iref) {
             
             //get original picture
             UIImage *original = [UIImage imageWithCGImage:iref];
             
             //Get the docs directory
             NSData *originalData = UIImagePNGRepresentation(original);
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             NSString *documentsPath = [paths objectAtIndex:0];
             
             // name original picture
             NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
             NSString *fileName = @"chosedFile.jpg";
             NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
             
             NSLog(@"Timelinecontroller: write a tmp original picture file");
             // save original picture
             [originalData writeToFile:filePath atomically:YES];
             
             //upload picture
             NSLog(@"Timelinecontroller: start to upload original picture");
             [[self restClient] uploadFile:fileName toPath:destDir withParentRev:nil fromPath:filePath];
             
             
         }
     } failureBlock:^(NSError *error )
     {
         NSLog(@"Timelinecontroller: Error loading asset");
     }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mediaList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indicator = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indicator];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indicator];
    }
    //cell.textLabel.text = @"picture";
    
    // show title about the media
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 320, 20)];
    titleLabel.text = [[mediaList objectAtIndex:indexPath.row] objectForKey:@"title"];
    [cell.contentView addSubview:titleLabel];

    // show media, each cell has its own media
    UIImageView *media = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, 320, 180)];
    //media.contentMode = UIViewContentModeScaleToFill;
    
    // show thumbnail
    NSData *thumbnailData = [NSData dataWithContentsOfFile:[[mediaList objectAtIndex:indexPath.row] objectForKey:@"thumbnail_path"]];
    media.image = [UIImage imageWithData:thumbnailData];
    
    
    // show original picture
    /*
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    //NSURL *url = [NSURL URLWithString:@"assets-library://asset/asset.JPG?id=FF014D89-29E6-42A4-AC78-07E6A9DD0793&ext=JPG"];
    NSURL *url;
    
    ALAsset *assetURL=[NSURL URLWithString:[[mediaList objectAtIndex:indexPath.row] objectForKey:@"thumbnail_path"]];
    
    [library assetForURL:assetURL resultBlock:^(ALAsset *asset )
     {
         NSLog(@"Timelinecontroller: ALAsset located!");
         ALAssetRepresentation *rep = [asset defaultRepresentation];
         CGImageRef iref = [rep fullResolutionImage];
         if (iref) {
             UIImage *original = [UIImage imageWithCGImage:iref]; //the image should be compress or memroy warning
             UIImage *small = [UIImage imageWithCGImage:original.CGImage scale:0.01 orientation:original.imageOrientation];
             media.image = small;
         }
     } failureBlock:^(NSError *error )
     {
         NSLog(@"Error loading asset");
     }];
    */
    
    [cell.contentView addSubview:media];
    
    
    return cell;
}

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
    NSLog(@"TimelineController: viewDidLoad");
    
    //initial a notification for reload tableview function
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ReloadMediaFunction:)
                                                 name:@"refreshMedia"
                                               object:nil];
    
    [self loadMediaFromDB];
    
}

-(void)ReloadMediaFunction:(NSNotification *)notification {
    
    [self loadMediaFromDB];
    
    NSLog(@"RecordController: reload");
    // 用迴圈取得位於ViewController上的每一個UIView類別
    for (UIView *view in self.view.subviews) {
        // 判斷取得的view是否屬於UITableView類別
        if ([view isKindOfClass:[UITableView class]]) {
            // 如果是就強制轉型為UITableView
            UITableView *tableView = (UITableView *)view;
            // 要求重新載入資料
            [tableView reloadData];
            break;
        }
    }
    
}

- (void)loadMediaFromDB
{
    
    // 取得已開啓的資料庫連線變數
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sqlite3 *db = [delegate getDB];
    
    if (db != nil) {
        // 準備好查詢的SQL command
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM medias"];
        const char *sql = [queryString UTF8String];
        
        sqlite3_stmt *statement;
        // 執行
        sqlite3_prepare(db, sql, -1, &statement, NULL);
        // statement用來儲存執行結果
        
        mediaList = [[NSMutableArray alloc] init];
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *time = (char *)sqlite3_column_text(statement, 3);
            //char *location = (char *)sqlite3_column_text(statement, 4);
            char *audio_path = (char *)sqlite3_column_text(statement, 4);
            char *original_path = (char *)sqlite3_column_text(statement, 5);
            char *thumbnail_path = (char *)sqlite3_column_text(statement, 6);
            
            NSMutableDictionary *mediaInfo = [[NSMutableDictionary alloc] init];
            [mediaInfo setObject:[NSString stringWithFormat:@"%s", thumbnail_path, nil] forKey:@"thumbnail_path"];
            [mediaInfo setObject:[NSString stringWithFormat:@"%s", original_path, nil] forKey:@"original_path"];
            [mediaInfo setObject:[NSString stringWithFormat:@"%s", audio_path, nil] forKey:@"audio_path"];
            [mediaInfo setObject:[NSString stringWithFormat:@"%s", time, nil] forKey:@"title"];
            [mediaList addObject:mediaInfo];
            
        }
        
        sqlite3_finalize(statement);
    }
    /*
    NSLog(@"################################");
    NSLog(@"%@", mediaList);
    NSLog(@"################################");
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    // 上傳成功後會呼叫此方法
    NSLog(@"檔案成功的上傳到此路徑: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    // 上傳失敗後會呼叫此方法
    NSLog(@"檔案上傳失敗 - %@", error);
}

-(void)restClient:(DBRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath
{
    // 取得上傳進度
    self.uploadProgress.progress = progress;
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
