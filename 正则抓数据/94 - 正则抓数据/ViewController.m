//
//  ViewController.m
//  94 - 正则抓数据
//
//  Created by 董 尚先 on 15/2/20.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "ViewController.h"

#define kBaseURL        @"http://zhougongjiemeng.1518.com/"
@interface ViewController ()

@property(nonatomic,strong) NSMutableArray *bigCategorys;
@property(nonatomic,strong) NSMutableArray *smallTitles;

@property(nonatomic,strong) NSMutableDictionary *mdict;
@end

@implementation ViewController

- (NSMutableArray *)bigCategorys
{
    if (_bigCategorys == nil) {
        _bigCategorys = [NSMutableArray array];
    }
    return _bigCategorys;
}

- (NSMutableArray *)smallTitles
{
    if (_smallTitles == nil) {
        _smallTitles = [NSMutableArray array];
    }
    return _smallTitles;
}

- (NSMutableDictionary *)mdict
{
    if (_mdict == nil) {
        _mdict = [NSMutableDictionary dictionary];
    }
    return _mdict;
}

/**
 抓数据是偷东西，要准确，顺序，所有方法都用同步的
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self spider];
}

- (void)spider
{
    NSURL *url = [NSURL URLWithString:kBaseURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    NSString *html = [NSString UTF8StringWithHZGB2312Data:data];
    
    NSString *pattern = [NSString stringWithFormat:@"<ul class=\"cs_list\">(.*?)</ul>"];
    
    NSString *content = [html firstMatchWithPattern:pattern];
    
//    NSLog(@"%@",content);
    

    NSString *pattern2 = [NSString stringWithFormat:@"<li><a href=\"(.*?)\">(.*?)</a>\\((.*?)\\)</li>"];
    
    NSArray *array = [content matchesWithPattern:pattern2 keys:@[@"url",@"title",@"count"]];
    
    for (NSDictionary *dict in array) {
        [self spider2WithDict:dict];
        
        // 第一个分类内容就够多了
        break;
    }
    
//    NSLog(@"%@", array);
}

- (void)spider2WithDict:(NSDictionary *)dictionary
{
    // 拼接请求的url
    NSString *urlstr = [NSString stringWithFormat:@"%@%@",kBaseURL,dictionary[@"url"]];
    NSURL *url = [NSURL URLWithString:urlstr];
    
    // 发出请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 接收数据
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    // 把国标2312的网页转换格式
    NSString *html = [NSString UTF8StringWithHZGB2312Data:data];
    
    // 设置筛选条件
    NSString *pattern = [NSString stringWithFormat:@"<div class=\"listpage_content\">.*?<ul>(.*?)</ul>"];
    // 得到筛选后的内容
    NSString *content = [html firstMatchWithPattern:pattern];
    
    // 再次筛选
    NSString *pattern2 = [NSString stringWithFormat:@"<li><a href=\"(.*?)\" title=\".*?\">(.*?)</a></li>"];
    
    // 得到的内容如果是多块就要用数组存储
    NSArray *array = [content matchesWithPattern:pattern2 keys:@[@"url",@"title"]];
    
    // 循环抓取里面的子标题
    for (NSDictionary *dict in array) {
        
        [self spider3WithDict:dict];
        [self.mdict setValue:dict[@"title"] forKey:@"title"];
        [self.smallTitles addObject:self.mdict];
        
        self.mdict = nil;
        
        [NSThread sleepForTimeInterval:0.1];
    }
    // 写入磁盘
    NSLog(@"kaishi");
    [self.smallTitles writeToFile:@"/Users/dsx/Desktop/工具软件/123.plist" atomically:YES];
    NSLog(@"wancheng");
}

- (void)spider3WithDict:(NSDictionary *)dictionary
{
    NSString *urlstr = [NSString stringWithFormat:@"%@%@",kBaseURL,dictionary[@"url"]];
    
    NSURL *url = [NSURL URLWithString:urlstr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    NSString *html = [NSString UTF8StringWithHZGB2312Data:data];
    
    NSString *pattern = [NSString stringWithFormat:@"<dd>(.*?)</dd>"];
    
    NSString *content = [html firstMatchWithPattern:pattern];
    
    content = [content stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    
    [self.mdict setValue:content forKey:@"desc"];
    
    NSLog(@"正在抓取：%@...",dictionary[@"title"]);
    
//    NSLog(@"%@",content);
}
@end
