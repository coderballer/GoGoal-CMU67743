//
//  TopicService.swift
//  GoGoal
//
//  Created by Peng Zhao on 10/18/21.
//

import FirebaseFirestore
import SwiftUI

class TopicService: BaseRepository<Topic> {
  
  static let shared = TopicService()
    
  init() {
    let rootRef = Firestore.firestore().collection(.topics)
    super.init(rootRef)
  }
  
  private func loadIcon(_ topic: Topic) -> Topic {
    var topic = topic
    topic.icon = Image(topic.iconPath)
    return topic
  }
  
  override func getAll(_ completion: @escaping ([Topic]) -> Void) {
    super.getAll() { topicList in
      var topicList = topicList
      
      for i in 0..<topicList.count {
        let topic = self.loadIcon(topicList[i])
        topicList[i].icon = topic.icon
      }
      
      completion(topicList)
    }
  }
  
  override func getById(id: String, _ completion: @escaping (Topic?) -> Void) {
    super.getById(id: id) { topic in
      if let topic = topic {
        completion(self.loadIcon(topic))
      } else {
        completion(nil)
      }
    }
  }
  
  override func queryByFields(queries: [QueryCondition], orders: [OrderCondition]? = nil, limit: Int? = nil,
                              _ completion: @escaping ([Topic]) -> Void) {
    super.queryByFields(queries: queries, orders: orders, limit: limit) { topicList in
      var topicList = topicList
      
      for i in 0..<topicList.count {
        let topic = self.loadIcon(topicList[i])
        topicList[i].icon = topic.icon
      }
      
      completion(topicList)
    }
  }
  
  func getByName(name: String, _ completion: @escaping (Topic?) -> Void) {
    let query = QueryCondition(field: "name", predicate: .equal, value: name)
    
    queryByFields(queries: [query]) { topicList in
      let topic = topicList.count == 0 ? nil : topicList[0]
      completion(topic)
    }
  }
  
}
