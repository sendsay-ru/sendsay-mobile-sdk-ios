//
//  InitConfigCache.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 23.07.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

final class InitConfigCache {
    
    static let initConfigFolder = "sendsaysdk_init_config"
    static let initConfigFileName = "init_config.json"
    // we should use our own instance of filemanager, host app can implement delegate on default one
    private let fileManager: FileManager = FileManager()


    private func getCacheDirectoryURL() -> URL? {
        guard let documentsDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = documentsDir.appendingPathComponent(InitConfigCache.initConfigFolder, isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            do {
                try fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }
        return dir
    }

    func saveConfig(config: ConfigItem) {
        guard let jsonData = try? JSONEncoder().encode(config),
            let jsonString = String(data: jsonData, encoding: .utf8),
            let directory = getCacheDirectoryURL() else {
                Sendsay.logger.log(.warning, message: "Unable to serialize config item data.")
                return
        }
        do {
            try jsonString.write(
                to: directory.appendingPathComponent(InitConfigCache.initConfigFileName),
                atomically: true,
                encoding: .utf8
            )
        } catch {
            Sendsay.logger.log(.warning, message: "Saving config item to file failed.")
        }
    }
    
    func getConfig() -> ConfigItem? {
        if let directory = getCacheDirectoryURL(),
           let data = try? Data(contentsOf: directory.appendingPathComponent(InitConfigCache.initConfigFileName)) {
            do {
                return try JSONDecoder().decode(ConfigItem.self, from: data)
            } catch {
                return nil
            }
        }
        return nil
    }

    func getInitConfigTimestamp() -> TimeInterval {
        guard let directory = getCacheDirectoryURL(),
              let attributes = try? fileManager.attributesOfItem(
                atPath: directory.appendingPathComponent(InAppMessagesCache.inAppMessagesFileName).path
              ),
              let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date
        else {
            return 0
        }
        return modificationDate.timeIntervalSince1970
    }
    
}
