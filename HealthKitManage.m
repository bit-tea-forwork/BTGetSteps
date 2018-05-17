//
//  HealthKitManage.m
//  GetStepsTest
//
//  Created by bit_tea on 14/05/2018.
//  Copyright © 2018 bit_tea. All rights reserved.
//

#import "HealthKitManage.h"

@implementation HealthKitManage

+ (id)shareInstance {
    static id manager ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
        [manager getPermissions];
    });
    return manager;
}

/*
 * @brief 检查是否支持获取健康数据
 */
- (void)getPermissions
{
    if ([HKHealthStore isHealthDataAvailable]) {
        
        if(self.healthStore == nil)
            self.healthStore = [[HKHealthStore alloc] init];
        /*
         组装需要读写的数据类型
         */
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesRead];
        
        /*
         注册需要读写的数据类型，也可以在“健康”APP中重新修改
         */
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (success)
            {
                NSLog(@"获取步数权限成功");
            }
            else
            {
                NSLog(@"获取步数权限失败");
                [self showTipsWindow];
            }
        }];
    }else{
        [self showTipsWindow];
    }
}

- (void)showTipsWindow
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"获取步数权限失败,请在“健康-数据来源”中允许您的App获取健康数据(iPad或者是iPhone系统版本低于iOS 8无法使用计步功能)" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

/*!
 * @brief 写权限
 * @return 集合
 */
- (NSSet *)dataTypesToWrite {
//    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
//    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
//    HKQuantityType *temperatureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
//    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
//    return [NSSet setWithObjects:heightType, temperatureType, weightType,activeEnergyType,nil];
    return [NSSet set];
    
}
/*!
 * @brief 读权限
 * @return 集合
 */
- (NSSet *)dataTypesRead {
//    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
//    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
//    HKQuantityType *temperatureType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
//    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
//    HKCharacteristicType *sexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    return [NSSet setWithObjects:stepCountType, distance, activeEnergyType,nil];
}

/**
 获取当天行走步数
 
 @param handler 返回值（步数，错误回调）
 */
- (void)getStepCount:(void(^)(double value, NSError *error))handler
{
    [self getStepCount:[HealthKitManage predicateForSamplesToday] completionHandler:handler];
}

/**
 获取时间段内行走步数

 @param predicate 时间段
 @param handler 返回值（公里值，错误回调）
 */
- (void)getStepCount:(NSPredicate *)predicate completionHandler:(void(^)(double value, NSError *error))handler
{
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:[HealthKitManage predicateForSamplesToday] limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if(error) {
            handler(0,error);
            
        } else {
            NSInteger totleSteps = 0;
            for(HKQuantitySample *quantitySample in results) {
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *heightUnit = [HKUnit countUnit];
                double usersHeight = [quantity doubleValueForUnit:heightUnit];
                totleSteps += usersHeight;
                
            }
            NSLog(@"当天行走步数 = %ld",(long)totleSteps);
            handler(totleSteps,error);
            
        }
        
    }];
    [self.healthStore executeQuery:query];
}

/**
 获取当天计步公里数

 @param handler 返回值（公里值，错误回调）
 */
- (void)getDistance:(void(^)(double value, NSError *error))handler
{
    [self getDistance:[HealthKitManage predicateForSamplesToday] completionHandler:handler];
}


/**
 获取时间段内计步公里数

 @param predicate 时间段
 @param handler 返回值（公里值，错误回调）
 */
- (void)getDistance:(NSPredicate *)predicate completionHandler:(void(^)(double value, NSError *error))handler
{
    HKQuantityType *distanceType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:distanceType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if(error) {
            handler(0,error);
            
        } else {
            double totleSteps = 0;
            for(HKQuantitySample *quantitySample in results) {
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *distanceUnit = [HKUnit meterUnitWithMetricPrefix:HKMetricPrefixKilo];
                double usersHeight = [quantity doubleValueForUnit:distanceUnit];
                totleSteps += usersHeight;
                
            }
            NSLog(@"当天行走距离 = %.2fkm",totleSteps); handler(totleSteps,error);
            
        }
        
    }];
    [self.healthStore executeQuery:query];
}


/**
 获取当天消耗卡路里

 @param handler 返回值（卡路里，错误回调）
 */
- (void)getKilocalorieUnit:(void(^)(double value, NSError *error))handler
{
    [self getKilocalorieUnit:[HealthKitManage predicateForSamplesToday] completionHandler:handler];
}

/**
 获取时间段内消耗卡路里

 @param predicate 时间段
 @param handler 返回值（卡路里，错误回调）
 */
- (void)getKilocalorieUnit:(NSPredicate *)predicate completionHandler:(void(^)(double value, NSError *error))handler
{
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        HKQuantity *sum = [result sumQuantity];
        
        double value = [sum doubleValueForUnit:[HKUnit kilocalorieUnit]];
        NSLog(@"%@卡路里 ---> %.2lf",quantityType.identifier,value);
        if(handler)
        {
            handler(value,error);
        }
    }];
    [self.healthStore executeQuery:query];
}


/*!
 * @brief 当天时间段 *
 * @return 时间段
 */
+ (NSPredicate *)predicateForSamplesToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
    
}

/**
 获取自定时间段
 @param fromDate 开始时间
 @param toDate   结束时间
 @return 时间段
 */
+ (NSPredicate *)predicateForFrom:(NSDate *)fromDate To:(NSDate *)toDate {
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:fromDate endDate:toDate options:HKQueryOptionNone];
    return predicate;
}

@end
