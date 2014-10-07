//
//  JourneyController.m
//  newPocket
//
//  Created by 杜長城 on 8/31/14.
//  Copyright (c) 2014 杜長城. All rights reserved.
//

#import "JourneyController.h"
#import "JourneyController.h"

@interface JourneyController ()

@end

@implementation JourneyController
@synthesize editJourneyStateButton;

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
    NSNumber *traveling = [receiveJourney objectForKey:@"onGoing"];
    NSInteger travelingCheck = [traveling integerValue];
    
    NSNumber *yes = [NSNumber numberWithInteger:1];
    NSInteger yesCheck = [yes integerValue];
    
    self.navigationItem.rightBarButtonItem = self.editJourneyStateButton;

    
    if (travelingCheck==yesCheck) {
        NSLog(@"JourneyController: this journey is on going, redirect to record tab");
        [self setSelectedIndex: 0];
        self.navigationItem.rightBarButtonItem.title = @"on";
    } else{
        NSLog(@"JourneyController: this journey is not on going, redirect to timeline tab");
        [self setSelectedIndex: 1];
        self.navigationItem.rightBarButtonItem.title = @"off";

    }

    [super viewDidLoad];
    
    // show journey name on title
    self.navigationItem.title = [receiveJourney objectForKey:@"name"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setJourneyState:(NSMutableDictionary *)state {
    
    receiveJourney = state;
    
}

- (IBAction)clikeEditJourneyStateButton:(id)sender {
    // 取得已開啓的資料庫連線變數
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sqlite3 *db = [delegate getDB];
    
    NSNumber *iid = [receiveJourney objectForKey:@"iid"];
    NSInteger *iidInt = [iid integerValue];
    
    NSString *updateSQL;
    
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"on"])
    {
        self.navigationItem.rightBarButtonItem.title= @"off";
        
        if (db != nil) {
            // 準備好查詢的SQL command
            updateSQL = [NSString stringWithFormat:@"UPDATE journeys SET traveling=0 WHERE ID=%d;", (int *)iidInt];
        }
        
    } else{
        self.navigationItem.rightBarButtonItem.title= @"on";
        
        if (db != nil) {
            // 準備好查詢的SQL command
            updateSQL = [NSString stringWithFormat:@"UPDATE journeys SET traveling=1 WHERE ID=%d;", (int *)iidInt];
            
        }
        
    }
    
    // code sql query
    const char *sql = [updateSQL UTF8String];
    // statement用來儲存執行結果
    sqlite3_stmt *statement;
    sqlite3_prepare(db, sql, -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"JourneyController: edit success");
    } else {
        NSLog(@"JourneyController: edit fail");
    }
    
    // 使用完畢，釋放statement
    sqlite3_finalize(statement);
    
    // edit receiveJourney for the edition of journey data
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"on"]) {
        [receiveJourney setObject:@"1" forKey:@"onGoing"];
    } else{
        [receiveJourney setObject:@"0" forKey:@"onGoing"];
    }
    

    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];
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
