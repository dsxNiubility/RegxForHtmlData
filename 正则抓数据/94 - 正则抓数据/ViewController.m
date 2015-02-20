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

@end

@implementation ViewController

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
        
        // 第一个就断掉
        break;
    }
    
//    NSLog(@"%@", array);
}

- (void)spider2WithDict:(NSDictionary *)dictionary
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
    
    NSString *pattern = [NSString stringWithFormat:@"<div class=\"listpage_content\">.*?<ul>(.*?)</ul>"];
    
    NSString *content = [html firstMatchWithPattern:pattern];
    
    NSString *pattern2 = [NSString stringWithFormat:@"<li><a href=\"(.*?)\" title=\".*?\">(.*?)</a></li>"];
    
    NSArray *array = [content matchesWithPattern:pattern2 keys:@[@"url",@"title"]];
    
//    NSLog(@"%@",array);
    
    for (NSDictionary *dict in array) {
        [self spider3WithDict:dict];
        
        [NSThread sleepForTimeInterval:0.2];
    }
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
    
    NSLog(@"%@",content);
}
@end
