//
//  SendsaySharedExports.swift
//  SendsaySDK
//
//  Created by Panaxeo on 12/01/2021.
//  Copyright © 2021 Sendsay. All rights reserved.
//

/**
 When using Cocoapods, we'll just include all files from SendsaySDKShared.
 When using Carthage/SPM, we'll depend on module/framework SendsaySDKShared.
 */
#if canImport(SendsaySDKShared)
import SendsaySDKShared

/**
 We need to re-export some types from SendsaySDKShared to general public when using SPM/Carthage
 */
public typealias Sendsay = SendsaySDKShared.Sendsay
public typealias Constants = SendsaySDKShared.Constants
public typealias Configuration = SendsaySDKShared.Configuration
public typealias Logger = SendsaySDKShared.Logger
public typealias LogLevel = SendsaySDKShared.LogLevel
public typealias JSONValue = SendsaySDKShared.JSONValue
public typealias JSONConvertible = SendsaySDKShared.JSONConvertible
public typealias Authorization = SendsaySDKShared.Authorization
public typealias SendsayNotificationAction = SendsaySDKShared.SendsayNotificationAction
public typealias SendsayNotificationActionType = SendsaySDKShared.SendsayNotificationActionType
public typealias Result = SendsaySDKShared.Result
public typealias SendsayProject = SendsaySDKShared.SendsayProject
public typealias SendsayError = SendsaySDKShared.SendsayError
public typealias NonSendableBox = SendsaySDKShared.NonSendableBox
public typealias EventType = SendsaySDKShared.EventType
public typealias TokenTrackFrequency = SendsaySDKShared.TokenTrackFrequency
public typealias NotificationData = SendsaySDKShared.NotificationData
public typealias GdprTracking = SendsaySDKShared.GdprTracking
public typealias AuthorizationProviderType = SendsaySDKShared.AuthorizationProviderType

/*
 Instead of including SendsaySDKShared in every file and conditionally
 turning it of when using cocoapods, we'll do it here
 */

typealias DataType = SendsaySDKShared.DataType
typealias TrackingRepository = SendsaySDKShared.TrackingRepository
typealias EmptyResult = SendsaySDKShared.EmptyResult
typealias TrackingObject = SendsaySDKShared.TrackingObject
typealias CampaignData = SendsaySDKShared.CampaignData
typealias RepositoryError = SendsaySDKShared.RepositoryError
typealias ServerRepository = SendsaySDKShared.ServerRepository
typealias EventTrackingObject = SendsaySDKShared.EventTrackingObject
typealias CustomerTrackingObject = SendsaySDKShared.CustomerTrackingObject
typealias RequestFactory = SendsaySDKShared.RequestFactory
typealias RequestParametersType = SendsaySDKShared.RequestParametersType

#endif
