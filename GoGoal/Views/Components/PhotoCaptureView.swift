//
//  PhotoCaptureView.swift
//  GoGoal
//
//  Created by Sihan Chen on 11/4/21.
//

import SwiftUI

struct PhotoCaptureView: View {
  
  @Binding var showImagePicker: Bool
  @Binding var image: UIImage?
  
  var body: some View {
    ImagePicker(isShown: $showImagePicker, image: $image)
  }
  
}
