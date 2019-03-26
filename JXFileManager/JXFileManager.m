//
//  JXFileManager.m
//  JXFileDemo
//
//  Created by JXwyh on 2016/3/26.
//  Copyright © 2019 JiXia. All rights reserved.
//

#import "JXFileManager.h"
#import <WebKit/WebKit.h>

@implementation JXFileManager

#pragma mark ------ outer method

+ (instancetype)defaultManager {
    static JXFileManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JXFileManager alloc] init];
    });
    return instance;
}

- (void)calculateSizeAtFileFolder:(JXFileFolderDirectory)folderDir completeBlock:(JXFileManagerBlock)fileBlock {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        NSString *TMPString = [self returnSizeAtFileFolder:folderDir];
        dispatch_async(dispatch_get_main_queue(), ^{
            fileBlock(TMPString);
        });
    });
}

- (BOOL)clearUpFileFolder:(JXFileFolderDirectory)folderDir {
        
    BOOL isClear = TRUE; // 默认值
    switch (folderDir) {
        case JXFileFolderDocuments:
            isClear = [self removeItemAtFilePath:[self documentPath]];
            NSLog(@"JXFileFolderDocuments");
            break;
        case JXFileFolderLibrary:
            isClear = [self removeItemAtFilePath:[self libraryPath]];
            NSLog(@"JXFileFolderLibrary");
            break;
        case JXFileFolderCaches:
            isClear = [self removeItemAtFilePath:[self cachePath]];
            NSLog(@"JXFileFolderCaches");
            break;
        case JXFileFolderSDWebImageCacheDefault:
            isClear = [self removeItemAtFilePath:[self sdWebImageCacheDefaultPath]];
            NSLog(@"JXFileFolderSDWebImageCacheDefault");
            break;
        case JXFileFolderWKWebKitfsCachedData:
            isClear = [self removeItemAtFilePath:[self wkWebKitfsCachedDataPath]];
            NSLog(@"JXFileFolderWKWebKitfsCachedData");
            break;
        case JXFileFolderCacheCommonData:
            isClear = [self removeItemAtFilePath:[self cacheCommonDataCachePath]];
            NSLog(@"JXFileFolderCacheCommonData");
            break;
        case JXFileFolderTmp:
            isClear = [self removeItemAtFilePath:[self tmpPath]];
            NSLog(@"JXFileFolderTmp");
            break;
        case JXFileFolderLibUIWebKit:
            isClear = [self removeItemAtFilePath:[self libUIWebKitPath]];
            NSLog(@"JXFileFolderTmp");
            break;
        case JXFileFoldersSet:
        {
            isClear =
            [self removeItemAtFilePath:[self cacheCommonDataCachePath]] &&
            [self removeItemAtFilePath:[self sdWebImageCacheDefaultPath]] &&
            [self removeWKWebAllCache] &&
            [self removeItemAtFilePath:[self wkWebKitCachePath]] &&
            [self removeItemAtFilePath:[self libUIWebKitPath]];
        }
            break;
        default:
            break;
    }
    return isClear;
}

- (void)saveHttpCache:(id)httpData URL:(NSString *)URL parameters:(NSDictionary *_Nullable)parameters{
    
    if (httpData) {
        NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
        //异步缓存,不会阻塞主线程
//        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_async(globalQueue, ^{
//
//        });
        [self saveHttpCacheResponseData:httpData cacheKey:cacheKey];
    }
    
}

- (id)httpCacheForURL:(NSString *)URL parameters:(NSDictionary *_Nullable)parameters {
    id rlt;
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    rlt = [self httpCacheResponseDataWithCacheKey:cacheKey];
    return rlt;
}

-(BOOL)sandBoxSaveInfo:(id)info forKey:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:info forKey:key];
    BOOL isSaved = [userDefaults synchronize];
    return isSaved;
}


-(id)sandBoxGetInfo:(Class)cls forKey:(NSString *)key{
    NSString *ClsString = NSStringFromClass(cls);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([ClsString isEqualToString:NSStringFromClass([NSString class])]) {
        NSString *str = [userDefaults stringForKey:key];
        return str;
    }else if ([ClsString isEqualToString:NSStringFromClass([NSArray class])]){
        NSArray *arr = [userDefaults arrayForKey:key];
        return arr;
    }else if ([ClsString isEqualToString:NSStringFromClass([NSDictionary class])]){
        NSDictionary *dic = [userDefaults dictionaryForKey:key];
        return dic;
    }else{
        id rls = [userDefaults valueForKey:key];
        return rls;
    }
}


-(void)sandBoxClearAllInfoWithKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)archiveRootObj:(id)obj toFileWithKey:(NSString *)key{
    if (obj) {
        NSString *archivePath = [[self cacheCommonDataCachePath] stringByAppendingString:key];
        [NSKeyedArchiver archiveRootObject:obj toFile:archivePath];
    }
}


- (id)unarchiveObjWithFileKey:(NSString *)key{
    NSString *archivePath = [[self cacheCommonDataCachePath] stringByAppendingString:key];
    id rltObj;
    if (archivePath) {
        rltObj = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    }
    return rltObj;
}

- (BOOL)cacheCommonData:(id)data cacheKey:(NSString *)key {
    BOOL rlt = FALSE;
    NSString *dataCachePath = [[self cacheCommonDataCachePath] stringByAppendingPathComponent:key];
    rlt = [data writeToFile:dataCachePath atomically:NO];
    return rlt;
}

- (id)dataWithClass:(Class)cls cacheKey:(NSString *)key {
    NSString *dataCachePath = [[self cacheCommonDataCachePath] stringByAppendingPathComponent:key];
    id rlt;
    if ([cls isSubclassOfClass:[NSString class]]) {
        rlt = [NSString stringWithContentsOfFile:dataCachePath encoding:NSUTF8StringEncoding error:nil];
    }else if ([cls isSubclassOfClass:[NSArray class]]) {
        rlt = [NSArray arrayWithContentsOfFile:dataCachePath];
    }else if ([cls isSubclassOfClass:[NSDictionary class]]) {
        rlt = [NSDictionary dictionaryWithContentsOfFile:dataCachePath];
    }else if ([cls isSubclassOfClass:[NSData class]]) {
        rlt = [NSData dataWithContentsOfFile:dataCachePath];
    }
    return rlt;
}


#pragma mark ------ private method

// 私有方法 - 计算1
- (NSString *)returnSizeAtFileFolder:(JXFileFolderDirectory)folderDir {
    CGFloat folderSize = 0.00; // 默认值
    switch (folderDir) {
        case JXFileFolderDocuments:
            folderSize += [self caculateSizeAtSingleFolder:[self documentPath]];
            NSLog(@"JXFileFolderDocuments");
            break;
        case JXFileFolderLibrary:
            folderSize += [self caculateSizeAtSingleFolder:[self libraryPath]];
            NSLog(@"JXFileFolderLibrary");
            break;
        case JXFileFolderCaches:
            folderSize += [self caculateSizeAtSingleFolder:[self cachePath]];
            NSLog(@"JXFileFolderCaches");
            break;
        case JXFileFolderSDWebImageCacheDefault:
            folderSize += [self caculateSizeAtSingleFolder:[self sdWebImageCacheDefaultPath]];
            NSLog(@"JXFileFolderSDWebImageCacheDefault");
            break;
        case JXFileFolderWKWebKitfsCachedData:
            folderSize += [self caculateSizeAtSingleFolder:[self wkWebKitfsCachedDataPath]];
            NSLog(@"JXFileFolderWKWebKitfsCachedData");
            break;
        case JXFileFolderCacheCommonData:
            folderSize += [self caculateSizeAtSingleFolder:[self cacheCommonDataCachePath]];
            NSLog(@"JXFileFolderCacheCommonData");
            break;
        case JXFileFolderTmp:
            folderSize += [self caculateSizeAtSingleFolder:[self tmpPath]];
            NSLog(@"JXFileFolderTmp");
            break;
        case JXFileFolderLibUIWebKit:
            folderSize += [self caculateSizeAtSingleFolder:[self libUIWebKitPath]];
            NSLog(@"JXFileFolderTmp");
            break;
        case JXFileFoldersSet:
            folderSize += [self caculateSizeAtSingleFolder:[self cacheCommonDataCachePath]];
            folderSize += [self caculateSizeAtSingleFolder:[self httpCacheResponseDataPath]];
            folderSize += [self caculateSizeAtSingleFolder:[self sdWebImageCacheDefaultPath]];
            folderSize += [self caculateSizeAtSingleFolder:[self wkWebKitfsCachedDataPath]];
            folderSize += [self caculateSizeAtSingleFolder:[self wkWebKitCachePath]];
            folderSize += [self caculateSizeAtSingleFolder:[self libUIWebKitPath]];
            NSLog(@"JXFileFoldersSet");
            break;
        default:
            break;
    }
    
    if (folderSize/(1024 * 1024) < 0.01) {
        return @"0.00 MB";
    }
    return [NSString stringWithFormat:@"%.2f MB",folderSize/(1024 * 1024)];
    
}

// 私有方法 - 计算2 - 单个文件夹大小
- (CGFloat)caculateSizeAtSingleFolder:(NSString *)folderPath{
    
    CGFloat folderSize = 0.0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]){
        NSEnumerator *childFilesEnumertor = [[[NSFileManager defaultManager] subpathsAtPath:folderPath] objectEnumerator];
        NSString *fileName = nil;
        while ((fileName = [childFilesEnumertor nextObject]) != nil) {
            NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
            folderSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
            //NSLog(@" 文件：%@ < ====== > 大小 ：%llu",fileAbsolutePath,[[[NSFileManager defaultManager] attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize]);
        }
        //NSLog(@"文件件大小：%f ---- 换算：%f",folderSize,folderSize/(1024 * 1024));
    }
    return folderSize;
    
}

- (BOOL)removeWKWebAllCache{
    
    BOOL rlt = TRUE;
    rlt = [self removeItemAtFilePath:[self wkWebKitfsCachedDataPath]];
    
    
    
    // 经测试 iOS 12 之前系统执行此移除方式之后可清楚本地磁盘缓存 ， 其中 cookie session 保留
    NSSet *types = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache,
                                         WKWebsiteDataTypeOfflineWebApplicationCache,
                                         WKWebsiteDataTypeMemoryCache,
                                         WKWebsiteDataTypeLocalStorage,
                                         WKWebsiteDataTypeIndexedDBDatabases,
                                         WKWebsiteDataTypeWebSQLDatabases]];
    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:types modifiedSince:dt completionHandler:^{

    }];
    
    return rlt;
}

- (BOOL)removeItemAtFilePath:(NSString *)filePath{
    BOOL rlt = TRUE;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        rlt = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    return rlt;
}


// Documents
- (NSString *)documentPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

// Tmp
- (NSString *)tmpPath{
    return nil;
}

// Library
- (NSString *)libraryPath{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

// Library/WebKit
- (NSString *)libUIWebKitPath{
    return [[self libraryPath] stringByAppendingPathComponent:@"WebKit"];
}

// Library/Caches
- (NSString *)cachePath{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

// Library/Caches/kCacheCommonData (通用类数据存储 - 自定义文件夹路径)
- (NSString *)cacheCommonDataCachePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dataCachePath = [[self cachePath] stringByAppendingPathComponent:kJXCacheCommonData];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataCachePath]) {
        [fileManager createDirectoryAtPath:dataCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dataCachePath;
}

// Library/Caches/kHttpCacheResponseData  (http 数据缓存文件 - 自定义文件夹路径)
- (NSString *)httpCacheResponseDataPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dataCachePath = [[self cachePath] stringByAppendingPathComponent:kHttpCacheResponseData];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataCachePath]) {
        [fileManager createDirectoryAtPath:dataCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dataCachePath;
}

// Library/Caches/default  (SDWebImageCache 图片)
- (NSString *)sdWebImageCacheDefaultPath{
    return [[self cachePath] stringByAppendingPathComponent:@"default"];
}

// Library/Caches/(bundleid)/fsCachedData  (iOS8 之后WKWebkit , H5 页面自带缓存)
- (NSString *)wkWebKitfsCachedDataPath{
    return [NSString stringWithFormat:@"%@/%@/fsCachedData",[self cachePath],[self bundleid]];
}

// Library/Caches/(bundleid)/WebKit  (iOS8 之后WKWebkit , H5 页面自带缓存)
- (NSString *)wkWebKitCachePath{
    return [NSString stringWithFormat:@"%@/%@/WebKit",[self cachePath],[self bundleid]];
}

- (NSString *)bundleid{
    
    NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]
                            objectForKey:@"CFBundleIdentifier"];
    
    return bundleId;
}


- (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    if(!parameters || parameters.count == 0){return URL;};
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@",URL,paraString];
    
    return [NSString stringWithFormat:@"%ld",cacheKey.hash];
}


- (BOOL)saveHttpCacheResponseData:(id)data cacheKey:(NSString *)key{
    BOOL rlt = FALSE;
    NSString *dataCachePath = [[self httpCacheResponseDataPath] stringByAppendingPathComponent:key];
    rlt = [data writeToFile:dataCachePath atomically:NO];
    return TRUE;
}

- (id)httpCacheResponseDataWithCacheKey:(NSString *)key {
    id rlt;
    NSString *dataCachePath = [[self httpCacheResponseDataPath] stringByAppendingPathComponent:key];
    rlt = [NSDictionary dictionaryWithContentsOfFile:dataCachePath];
    return rlt;
}

@end
