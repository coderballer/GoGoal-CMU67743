//
//  FileStorage.swift
//  GoGoal
//
//  Created by Peng Zhao on 10/29/21.
//

import FirebaseStorage

class FileStorage {
  
  // the maximum photo size the app could load on frontend
  private static let MAX_SIZE: Int64 = 20 * 1024 * 1024
  
  let storage = Storage.storage()
  let prefixPath: String
  
  init(_ storageEnum: StorageEnum) {
    self.prefixPath = "\(storageEnum.rawValue)_\(EnvironmentConfig.getEnv().lowercased())"
  }
  
  func uploadFile(subPath: String, file: Data, type: ContentType, _ completion: @escaping (String) -> Void) {
    let fullPath = "\(prefixPath)/\(subPath)"
    let fileRef = storage.reference(withPath: fullPath)
    
    let metadata = StorageMetadata()
    metadata.contentType = type.rawValue
    
    fileRef.putData(file, metadata: metadata) { (metadata, err) in
      guard err == nil else {
        print("Error upload file: \(String(describing: err))")
        return
      }
      completion(fullPath)
    }
  }
  
  func uploadFolderFiles(subPath: String, files: [Data], type: ContentType, _ completion: @escaping (String) -> Void) {
    let dispatchGroup = DispatchGroup()
    
    for i in 0..<files.count {
      dispatchGroup.enter()
      let filePath = "\(subPath)/file_\(i)"
      self.uploadFile(subPath: filePath, file: files[i], type: type) { _ in
        dispatchGroup.leave()
      }
    }
    
    let fullPath = "\(prefixPath)/\(subPath)/"
    dispatchGroup.notify(queue: .main) { completion(fullPath) }
  }
  
  func downloadFile(fullPath: String, _ completion: @escaping (Data?) -> Void) {
    let fileRef = storage.reference(withPath: fullPath)
    
    fileRef.getData(maxSize: FileStorage.MAX_SIZE) { data, err in
      if let err = err {
        print("Error download file: \(err)")
      } else {
        completion(data)
      }
    }
  }
  
  func downloadFolderFiles(fullPath: String, _ completion: @escaping ([Data]) -> Void) {
    let folderRef = storage.reference(withPath: fullPath)
    
    folderRef.listAll() { files, err in
      guard err == nil else {
        print("Error list all files: \(String(describing: err))")
        return
      }
      
      var dataList = [Data]()
      let dispatchGroup = DispatchGroup()
      
      for fileRef in files.items {
        dispatchGroup.enter()
        self.downloadFile(fullPath: fileRef.fullPath) { data in
          if let data = data {
            dataList.append(data)
          }
          dispatchGroup.leave()
        }
      }
      
      dispatchGroup.notify(queue: .main) { completion(dataList) }
    }
  }
  
  func deleteFile(fullPath: String, _ completion: @escaping () -> Void = {}) {
    let fileRef = storage.reference(withPath: fullPath)
    
    fileRef.delete() { err in
      if let err = err {
        print("Error delete file: \(err)")
      }
      completion()
    }
  }
  
  func deleteFolderFiles(fullPath: String, _ completion: @escaping () -> Void = {}) {
    let folderRef = storage.reference(withPath: fullPath)
    
    folderRef.listAll() { files, err in
      guard err == nil else {
        print("Error list all files: \(String(describing: err))")
        return
      }
      
      let dispatchGroup = DispatchGroup()
      
      for fileRef in files.items {
        dispatchGroup.enter()
        fileRef.delete() {_ in
          dispatchGroup.leave()
        }
      }
      
      dispatchGroup.notify(queue: .main) { completion() }
    }
  }
  
}
