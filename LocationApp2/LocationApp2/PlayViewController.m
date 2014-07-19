//
//  PlayViewController.m
//  LocationApp2
//
//  Created by 三井 由登 on 2014/05/08.
//  Copyright (c) 2014年 mitsui yoshito. All rights reserved.
//

#import "PlayViewController.h"

@interface PlayViewController ()

@end

@implementation PlayViewController

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
    
    storyId = 1;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //DBチェック
    [self dbCheck];
    
    [self create1stLevCourse];
    
    [self createGameId];
    
    
    //下準備
    nextRunCourseId = 1;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *dir   = [paths objectAtIndex:0];
    FMDatabase *db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"file.db"]];
    NSString *sql=@"select nextId,targetSpeed from run_course where id = ?;";
    [db open];
    queryResult = [db executeQuery:sql,[NSNumber numberWithDouble:nextRunCourseId]];
    while ([queryResult next]) {
        nextRunCourseId = [queryResult intForColumnIndex:0];
        runCourseSpeed = [queryResult doubleForColumnIndex:1];
    };
    
    targetSpeedLabel.text = [NSString stringWithFormat:@"%g",runCourseSpeed];
    
    
    //ゲームスタート処理
    lm = [[CLLocationManager alloc] init];
    lm.delegate = self;
    lm.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    lm.distanceFilter = kCLDistanceFilterNone;
    [lm startUpdatingLocation];
    [lm startUpdatingHeading];
    
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(speedCheck) userInfo:nil repeats:YES];
    courseTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(changeNextCourse) userInfo:nil repeats:YES];
    
    //音を鳴らす
    //AVAudioPlayer* audioPlayer;
    //helicopter.mp3ってファイルを読み込んでます。
    NSString* path = [[NSBundle mainBundle]pathForResource:@"helicopter" ofType:@"mp3"];
    NSURL* url = [NSURL fileURLWithPath:path];
    audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    audioPlayer.numberOfLoops = -1;
    audioPlayer.volume = 0.5f;
    [audioPlayer play];
    level = 3;
    levelLabel.text = [NSString stringWithFormat:@"%d",3];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)
newLocation fromLocation:(CLLocation *)oldLocation{
    latLabel.text = [NSString stringWithFormat:@"%g",newLocation.coordinate.latitude];
    lngLabel.text = [NSString stringWithFormat:@"%g",newLocation.coordinate.longitude];
    speedLabel.text = [NSString stringWithFormat:@"%g",newLocation.speed];
    
    //dbに保存
    [self saveRunLogDb:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude speed:newLocation.speed];
    
}

- (void)dbCheck{
    //DBファイルのパス
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *dir   = [paths objectAtIndex:0];
    
    //DBテーブルがあるかどうか確認
    FMDatabase *db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"file.db"]];
    [db open]; //DB開く
    
    //    NSString *checkRunLogTableSql = @"select count(*) from sqlite_master where type='table' and name='run_log'";
    //    BOOL results = [db executeQuery:checkRunLogTableSql]; //SQL実行
    
    NSString *sql = @"CREATE TABLE IF NOT EXISTS run_log (id INTEGER PRIMARY KEY AUTOINCREMENT,GAME_ID INTEGER, latitude REAL,longitude REAL, speed REAL);";
    NSString *createRunCourseSql = @"CREATE TABLE IF NOT EXISTS run_course (id INTEGER PRIMARY KEY AUTOINCREMENT, storyId INTEGER,targetSpeed REAL, nextId INTEGER);";
    NSString *createGameSql = @"CREATE TABLE IF NOT EXISTS play_game_log (GAME_ID INTEGER PRIMARY KEY AUTOINCREMENT, STORY_ID INTEGER);";
    [db executeUpdate:sql]; //SQL実行
    [db executeUpdate:createRunCourseSql];
    [db executeUpdate:createGameSql];
    [db close];
    
}


- (void)create1stLevCourse {
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *dir   = [paths objectAtIndex:0];
    FMDatabase *db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"file.db"]];
    NSString *sql=@"insert into run_course (storyId,targetSpeed,nextId) values (?,?,?);";
    NSString *checkSql=@"select count(*) as count from run_course where storyId=?;";
    
    
    [db open];
    queryResult = [db executeQuery:checkSql,[NSNumber numberWithDouble:storyId]];
    int count = 0;
    while ([queryResult next]) {
        count = [queryResult intForColumn:@"count"];
    }
    
    if (count == 0) {
        [db executeUpdate:sql,[NSNumber numberWithDouble:storyId],[NSNumber numberWithDouble:3],[NSNumber numberWithDouble:2]];
        [db executeUpdate:sql,[NSNumber numberWithDouble:storyId],[NSNumber numberWithDouble:4],[NSNumber numberWithDouble:3]];
        [db executeUpdate:sql,[NSNumber numberWithDouble:storyId],[NSNumber numberWithDouble:5],[NSNumber numberWithDouble:4]];
        [db executeUpdate:sql,[NSNumber numberWithDouble:storyId],[NSNumber numberWithDouble:3],nil];
    }
    
    [db close];
}

-(void)createGameId {
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *dir   = [paths objectAtIndex:0];
    FMDatabase *db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"file.db"]];
    NSString *insertGameIdSql=@"insert into play_game_log (STORY_ID) values (?);";
    NSString *getGameIdSql=@"select GAME_ID from play_game_log order by GAME_ID desc limit 1;";
    
    
    [db open];
    [db executeUpdate:insertGameIdSql,[NSNumber numberWithDouble:storyId]];
    queryResult = [db executeQuery:getGameIdSql];
    while ([queryResult next]) {
        gameId = [queryResult intForColumn:@"GAME_ID"];
    }
    
    [db close];
}

- (void)saveRunLogDb:(double)latitude longitude:(double)longitude speed:(double)speed{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *dir   = [paths objectAtIndex:0];
    FMDatabase *db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"file.db"]];
    NSString *sql=@"insert into run_log (GAME_ID, latitude, longitude, speed) values (?,?,?,?);";
    [db open];
    [db executeUpdate:sql,[NSNumber numberWithDouble:gameId], [NSNumber numberWithDouble:latitude],[NSNumber numberWithDouble:longitude],[NSNumber numberWithDouble:speed]];
    [db close];
}

-(void)speedCheck {
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *dir   = [paths objectAtIndex:0];
    FMDatabase *db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"file.db"]];
    NSString *sql=@"select * from run_log where GAME_ID = ? order by id desc limit 10;";
    [db open];
    queryResult = [db executeQuery:sql,[NSNumber numberWithDouble:gameId]];
    
    double averageSpeed = 0;
    while ([queryResult next]) {
        averageSpeed += [queryResult doubleForColumn:@"speed"];
    };
    [db close];
    
    averageSpeed = averageSpeed / 5;
    
    averageLabel.text = [NSString stringWithFormat:@"%g",averageSpeed];
    
    
    if (averageSpeed >= runCourseSpeed) {
        statusLabel.text = [NSString stringWithFormat:@"早い"];
        if (level < 5) {
            level++;
            levelLabel.text = [NSString stringWithFormat:@"%d",level];
            [self downVolume];
        }
    } else {
        statusLabel.text = [NSString stringWithFormat:@"遅い"];
        if (level > 1) {
            level--;
            levelLabel.text = [NSString stringWithFormat:@"%d",level];
            [self upVolume];
        } else if (level == 1) {
            //終了　ゲームオーバー
            //効果音出す
            
            [self endGame];
            
            //画面遷移
            ResultViewController *resultView = [self.storyboard instantiateViewControllerWithIdentifier:@"resultView"];
            //アニメーションの指定
            resultView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:resultView animated:YES completion:nil];
            
        }
    }
}


-(void)changeNextCourse {
    //nextRunCourseIdが0なら終了
    if(nextRunCourseId == 0) {
        [self endGame];
        //ゴール画面表示
        ResultViewController *goalView = [self.storyboard instantiateViewControllerWithIdentifier:@"goalView"];
        //アニメーションの指定
        goalView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:goalView animated:YES completion:nil];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *dir   = [paths objectAtIndex:0];
    FMDatabase *db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"file.db"]];
    NSString *sql=@"select nextId,targetSpeed from run_course where id = ?;";
    [db open];
    queryResult = [db executeQuery:sql,[NSNumber numberWithDouble:nextRunCourseId]];
    while ([queryResult next]) {
        nextRunCourseId = [queryResult intForColumnIndex:0];
        runCourseSpeed = [queryResult doubleForColumnIndex:1];
    };
    
    targetSpeedLabel.text = [NSString stringWithFormat:@"%g",runCourseSpeed];
    
    NSLog(@"changeNextCourse() nextRunCourseId = : %d",nextRunCourseId);
    NSLog(@"changeNextCourse() runCourseSpeed = : %f",runCourseSpeed);
    [db close];
}

/*
 ボリュームダウン
*/
-(void)downVolume {
    float targetVolume = audioPlayer.volume - 0.2;
    while (true) {
        [NSThread sleepForTimeInterval:0.2];
        audioPlayer.volume-=0.01;
        if (audioPlayer.volume <= targetVolume) {
            break;
        }
    };
}

/*
 ボリュームアップ
*/
-(void)upVolume {
    float targetVolume = audioPlayer.volume + 0.2;
    while (true) {
        [NSThread sleepForTimeInterval:0.2];
        audioPlayer.volume+=0.01;
        if (audioPlayer.volume >= targetVolume) {
            break;
        }
    };
}

/*
 endButtonが押された時に呼び出される処理
*/
-(IBAction)endButton_down:(id)sender {
    [self endGame];
    //モーダルを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
ゲーム終了時に呼び出す処理
*/
-(void)endGame {
    //音楽止める
    [audioPlayer stop];
    //LocationManagerを止める
    [lm stopUpdatingLocation];
    //updateTimerを止める
    [updateTimer invalidate];
    //courseTimerを止める
    [courseTimer invalidate];
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
