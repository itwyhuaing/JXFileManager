//
//  JXFileManager.h
//  JXFileDemo
//
//  Created by hnbwyh on 2016/3/26.
//  Copyright © 2019 JiXia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kHttpCacheResponseData     = @"kHttpCacheResponseData";
static NSString *const kJXCacheCommonData         = @"kCacheCommonData";

/**< 文件路径枚举>*/
typedef enum : NSUInteger {
    JXFileFolderDocuments = 1000,                          // Documents
    JXFileFolderLibrary = 2000,                            // Library
    JXFileFolderCaches = 2001,                             // Library/Caches
    JXFileFolderSDWebImageCacheDefault = 2010,             // Library/Caches/default  (SDWebImageCache 图片)
    JXFileFolderCacheCommonData = 2020,                    // Library/Caches/kCacheCommonData (通用类数据存储 - 自定义文件夹路径)
    JXFileFolderHttpCacheResponseData = 2100,              // Library/Caches/kHttpCacheResponseData  (http 数据缓存文件 - 自定义文件夹路径)
    JXFileFolderWKWebKitfsCachedData = 2031,               // Library/Caches/(bundleid)/fsCachedData  (iOS8 之后WKWebkit , H5 页面自带缓存)
    JXFileFolderWKWebKitCachedData = 2032,                 // Library/Caches/(bundleid)/WebKit  (iOS8 之后 WKWebkit , H5 页面自带缓存)
    JXFileFolderLibUIWebKit = 2002,                        // Library/WebKit (iOS7 及之前 UIWeb , H5 页面自带缓存)
    JXFileFolderTmp = 3000,                                // Tmp
    JXFileFolderSystemData = 5000,                         // SystemData
    JXFileFoldersSet = 4000                                // 文件夹集合
} JXFileFolderDirectory;

/**< 文件操作回调>*/
typedef void(^JXFileManagerBlock)(NSString *info);

typedef void(^JXFileManagerOperateBlock)(BOOL status,NSString *info);

@interface JXFileManager : NSObject

+ (instancetype)defaultManager;

#pragma mark ================== 文件操作

/**
 * 计算文件夹大小 - 单位 MB
 */
- (void)calculateSizeAtFileFolder:(JXFileFolderDirectory)folderDir completeBlock:(JXFileManagerBlock)fileBlock;


/**
 * 清空文件夹
 */
- (BOOL)clearUpFileFolder:(JXFileFolderDirectory)folderDir;

#pragma mark ================== 数据读写

#pragma mark - http 网络数据
/**
 * 依据 URL 与 参数 存/取数据
 */
- (void)saveHttpCache:(id)httpData URL:(NSString *)URL parameters:(NSDictionary *_Nullable)parameters;
- (id)httpCacheForURL:(NSString *)URL parameters:(NSDictionary *_Nullable)parameters;

#pragma mark - 沙河数据
/**
 * 沙盒读取及清空操作 - 只支持 NSString、NSArray、NSDictionary 三类
 */
-(BOOL)sandBoxSaveInfo:(id)info forKey:(NSString *)key;
-(id)sandBoxGetInfo:(Class)cls forKey:(NSString *)key;
-(void)sandBoxClearAllInfoWithKey:(NSString *)key;

-(void)sandBoxSaveInfo:(id)info forKey:(NSString *)key operateBlock:(JXFileManagerOperateBlock)operateBlock;
-(void)sandBoxGetInfo:(Class)cls forKey:(NSString *)key operateBlock:(JXFileManagerOperateBlock)operateBlock;
-(void)sandBoxClearAllInfoWithKey:(NSString *)key operateBlock:(JXFileManagerOperateBlock)operateBlock;

#pragma mark - 解/归档
- (void)archiveRootObj:(id)obj toFileWithKey:(NSString *)key; // 归档
- (id)unarchiveObjWithFileKey:(NSString *)key;                // 解档

#pragma mark - 通用类数据读写 - 字符串 数组 字典 图片

/**
 * 字符串/数组/字典/NSData 读写
 */
- (BOOL)cacheCommonData:(id)data cacheKey:(NSString *)key;
- (id)dataWithClass:(Class)cls cacheKey:(NSString *)key;


@end

NS_ASSUME_NONNULL_END
