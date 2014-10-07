//
//  NewJourneyController.m
//  newPocket
//
//  Created by 杜長城 on 9/1/14.
//  Copyright (c) 2014 杜長城. All rights reserved.
//

#import "NewJourneyController.h"

@interface NewJourneyController ()

@end

@implementation NewJourneyController

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
    journeyDetail = [[NSMutableDictionary alloc] init]; //initialized
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressDownButton:(id)sender {
    // 取得已開啓的資料庫連線變數
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sqlite3 *db = [delegate getDB];
    if (db != nil) {
        // 準備好插入資料的SQL command
        NSString *queryString = [NSString stringWithFormat:@"INSERT INTO journeys VALUES ( NULL, '%@','%@',NULL, NULL,NULL, NULL,NULL,0)", self.journeyNameField.text, self.JourneyLocationField.text];
        const char *sql = [queryString UTF8String];
        
        sqlite3_stmt *statement;
        // 執行
        sqlite3_prepare(db, sql, -1, &statement, NULL);
        
        // 檢查插入資料是否成功
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"NewJourneyController: 成功插入一筆資料");
        } else {
            NSLog(@"NewJourneyController: 插入一筆資料失敗");
        }
        
        // 使用完畢，釋放statement
        sqlite3_finalize(statement);
    }
    
    // reload tableview in ViewController
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshJourney" object:nil];
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (IBAction)pressCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
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
