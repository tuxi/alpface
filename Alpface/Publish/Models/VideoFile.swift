//
//  VideoFile.swift
//  Alpface
//
//  Created by swae on 2018/4/16.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPVideoFile)
class VideoFile: NSObject {
    fileprivate var filepath: String?
    fileprivate var data: Data?
    public var fileSize: Int64 = 0
    public var fileModifyTime: TimeInterval = 0
    fileprivate var file: FileHandle?
    public var displayName: String?
    
    convenience init(path: String) {
        self.init()
        self.filepath = path
        do {
            let fileAttr = try FileManager.default.attributesOfItem(atPath: path)
            let size = fileAttr[FileAttributeKey.size] as! Int64
            fileSize = size
            
            let modifyTime = fileAttr[FileAttributeKey.modificationDate] as? Date
            
            let displayName = path as NSString
            self.displayName = displayName.lastPathComponent
            
            var t: TimeInterval = 0
            if let m = modifyTime {
                t = m.timeIntervalSince1970
            }
            fileModifyTime = t
        
            //[NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error] 不能用在大于 200M的文件上，改用filehandle
            // 参见 https://issues.apache.org/jira/browse/CB-5790
            if fileSize > 16 * 1024 * 1024 {
                if let f = FileHandle(forReadingAtPath: path) {
                    self.file = f
                }
            } else {
                let fileURL = URL(fileURLWithPath: path)
                do {
                    let d = try Data(contentsOf: fileURL, options: Data.ReadingOptions.dataReadingMapped)
                    self.data = d
                }
            }
        } catch  {
            print("error :\(error)")
        }
    
    }
    
    public func read(offset: Int64, size: Int64) -> Data? {
        if let d = self.data {
            let range:Range<Data.Index> = Range(Int(offset)..<Int(size))
            return d.subdata(in: range)
        }
        self.file?.seek(toFileOffset: UInt64(offset))
        if  let data = self.file?.readData(ofLength: Int(size)) {
            return data
        }
        return nil
    }
    
    public func readAll() -> Data? {
        return self.read(offset: 0, size: self.fileSize)
    }
    
    public func close() {
        if let fileHandle = self.file {
            fileHandle.closeFile()
        }
    }

}
