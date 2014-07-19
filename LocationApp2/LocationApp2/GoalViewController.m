//
//  GoalViewController.m
//  LocationApp2
//
//  Created by 三井 由登 on 2014/05/18.
//  Copyright (c) 2014年 mitsui yoshito. All rights reserved.
//

#import "GoalViewController.h"

@interface GoalViewController ()

@end

@implementation GoalViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)returnToTopButton_down:(id)sender {
    ViewController *topView = [self.storyboard instantiateViewControllerWithIdentifier:@"topView"];
    //アニメーションの指定
    topView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:topView animated:YES completion:nil];
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
