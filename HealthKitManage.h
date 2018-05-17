//
//  HealthKitManage.h
//  GetStepsTest
//
//  Created by bit_tea on 14/05/2018.
//  Copyright © 2018 bit_tea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <UIKit/UIKit.h>

@interface HealthKitManage : NSObject

@property (nonatomic, strong) HKHealthStore *healthStore;

+ (id)shareInstance;

/**
 获取当天行走步数

 @param completion 返回值（步数，错误回调）
 */
- (void)getStepCount:(void(^)(double value, NSError *error))completion;

/**
 获取时间段内行走步数

 @param predicate 时间段
 @param handler 返回值（公里值，错误回调）
 */
- (void)getStepCount:(NSPredicate *)predicate completionHandler:(void(^)(double value, NSError *error))handler;

/**
 获取当天计步公里数

 @param completion 返回值（公里值，错误回调）
 */
- (void)getDistance:(void(^)(double value, NSError *error))completion;

/**
 获取时间段内计步公里数

 @param predicate 时间段
 @param handler 返回值（公里值，错误回调）
 */
- (void)getDistance:(NSPredicate *)predicate completionHandler:(void(^)(double value, NSError *error))handler;

/**
 获取当天消耗卡路里

 @param handler 返回值（卡路里，错误回调）
 */
- (void)getKilocalorieUnit:(void(^)(double value, NSError *error))handler;

/**
 获取时间段内消耗卡路里

 @param predicate 时间段
 @param handler 返回值（卡路里，错误回调）
 */
- (void)getKilocalorieUnit:(NSPredicate *)predicate completionHandler:(void(^)(double value, NSError *error))handler;


/*!
 * @brief 当天时间段 *
 * @return 时间段
 */
+ (NSPredicate *)predicateForSamplesToday;

/**
 获取自定时间段
 @param fromDate 开始时间
 @param toDate   结束时间
 @return 时间段
 */
+ (NSPredicate *)predicateForFrom:(NSDate *)fromDate To:(NSDate *)toDate;

@end
