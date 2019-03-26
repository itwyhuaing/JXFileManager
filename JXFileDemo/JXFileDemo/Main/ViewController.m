//
//  ViewController.m
//  JXFileDemo
//
//  Created by hnbwyh on 2016/3/26.
//  Copyright © 2019 JiXia. All rights reserved.
//

#import "ViewController.h"
#import "JXFileManager.h"


@interface ViewController ()

@property (nonatomic,strong)    UILabel     *showLabel;
@property (nonatomic,strong)    UIButton    *updateBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self func];
}

- (void)setUpUI {
    [self.view addSubview:self.showLabel];
    [self.view addSubview:self.updateBtn];
}

- (void)func {
    
    NSString *budlePath = [[NSBundle mainBundle] pathForResource:@"jsondata.json" ofType:nil];
    NSString *image8Path= [[NSBundle mainBundle] pathForResource:@"8.jpg" ofType:nil];
    NSString *image9Path= [[NSBundle mainBundle] pathForResource:@"9.jpg" ofType:nil];
    NSString        *testString = @"88";
    NSArray         *testArr    = @[@"测试"];
    NSDictionary    *testDic    = @{@"key":@"value数据"};
    NSData *data                = [NSData dataWithContentsOfFile:budlePath];
    UIImage *img1               = [UIImage imageNamed:@"8.jpg"];
    UIImage *img2               = [UIImage imageNamed:@"9.jpg"];
    
    BOOL rlt    = [[JXFileManager defaultManager] cacheCommonData:testString cacheKey:@"testString"];
    BOOL rlt2   = [[JXFileManager defaultManager] cacheCommonData:testArr cacheKey:@"testArr"];
    BOOL rlt3   = [[JXFileManager defaultManager] cacheCommonData:testDic cacheKey:@"testDic"];
    BOOL rlt4   = [[JXFileManager defaultManager] cacheCommonData:data cacheKey:@"data"];
    BOOL rlt51  = [[JXFileManager defaultManager] cacheCommonData:[NSData dataWithContentsOfFile:image8Path] cacheKey:@"img1"];
    BOOL rlt52  = [[JXFileManager defaultManager] cacheCommonData:[NSData dataWithContentsOfFile:image9Path] cacheKey:@"img2"];
    
    id rlt6 = [[JXFileManager defaultManager] dataWithClass:[NSString class] cacheKey:@"testString"];
    id rlt7 = [[JXFileManager defaultManager] dataWithClass:[NSArray class] cacheKey:@"testArr"];
    id rlt8 = [[JXFileManager defaultManager] dataWithClass:[NSDictionary class] cacheKey:@"testDic"];
    id rlt9 = [[JXFileManager defaultManager] dataWithClass:[NSData class] cacheKey:@"data"];
    
    
    id rltJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    [[JXFileManager defaultManager] saveHttpCache:rltJson URL:@"http:test" parameters:nil];
    id res = [[JXFileManager defaultManager] httpCacheForURL:@"http:test" parameters:nil];
    
    [self updateShow];
    
}

- (void)clickBtn:(UIButton *)btn{
    [[JXFileManager defaultManager] clearUpFileFolder:JXFileFoldersSet];
    [self updateShow];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[JXFileManager defaultManager] clearUpFileFolder:JXFileFoldersSet];
}

- (void)updateShow{
    __weak typeof(self) weakSelf = self;
    [[JXFileManager defaultManager] calculateSizeAtFileFolder:JXFileFoldersSet completeBlock:^(NSString * _Nonnull info) {
        weakSelf.showLabel.text = info;
    }];
}

-(UILabel *)showLabel{
    if (!_showLabel) {
        _showLabel                  = [[UILabel alloc] init];
        [_showLabel setFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 20)];
        _showLabel.textAlignment    = NSTextAlignmentCenter;
        _showLabel.textColor        = [UIColor blackColor];
    }
    return _showLabel;
}

-(UIButton *)updateBtn{
    if (!_updateBtn) {
        _updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _updateBtn.backgroundColor = [UIColor grayColor];
        [_updateBtn setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2.0-80.0, 150, 160, 50)];
        [_updateBtn setTitle:@"清空所有数据" forState:UIControlStateNormal];
        [_updateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_updateBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _updateBtn;
}

@end
