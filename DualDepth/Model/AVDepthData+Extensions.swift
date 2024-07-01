//
//  AVDepthData+Extensions.swift
//  DualDepth
//
//  Created by MacBook Pro M1 on 2021/10/27.
//

import Foundation
import AVFoundation
import UIKit
import ARKit

//extension AVDepthData {
//    // convert to AVDepthData (kCVPixelFormatType_DisparityFloat32)
//    var asDisparityFloat32: AVDepthData {
//        var convertedDepthData: AVDepthData
//
//        // Convert 16 bit floats up to 32 bit
//        // https://stackoverflow.com/questions/55009162/filtering-depth-data-on-ios-12-appears-to-be-rotated
//        if self.depthDataType != kCVPixelFormatType_DisparityFloat32 {
//            convertedDepthData = self.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
//        } else {
//            convertedDepthData = self
//        }
//
//        return convertedDepthData
//    }
//
//    // convert AVDepthData to UIImage
//    var asDepthMapImage: UIImage? {
//        let convertedDepthData = self.asDisparityFloat32
////        let normalizedDepthMap = convertedDepthData.depthDataMap.normalize()
//        let normalizedDepthMap = convertedDepthData.depthDataMap
//        return normalizedDepthMap.uiImage
//    }
//}


// working vvvv
//extension AVDepthData {
//    // Convert to AVDepthData with kCVPixelFormatType_DepthFloat32
//    var asDepthFloat32: AVDepthData {
//        var convertedDepthData: AVDepthData
//                
//        // Convert to kCVPixelFormatType_DepthFloat32
//        if self.depthDataType != kCVPixelFormatType_DepthFloat32 {
//            convertedDepthData = self.converting(toDepthDataType: kCVPixelFormatType_DepthFloat32)
//        } else {
//            convertedDepthData = self
//        }
//        
//        return convertedDepthData
//    }
//    
//    // Convert AVDepthData to UIImage
//    var asDepthMapImage: UIImage? {
//        let convertedDepthData = self.asDepthFloat32 // Convert to DepthFloat32
//        let depthMap = convertedDepthData.depthDataMap.getDepthReading() // Get depth map
//        return depthMap.uiImage // Convert depth map to UIImage
//    }
//}
// end of working

extension AVDepthData {
    var asDepthFloat32: AVDepthData {
        return self.converting(toDepthDataType: kCVPixelFormatType_DepthFloat32)
    }
    
    var asDepthMapImage: UIImage? {
        // Create a temporary ARSCNView
        let sceneView = ARSCNView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        // Example cgPt and disparity values; these should be derived from your specific use case
        let cgPt = CGPoint(x: 100, y: 100) // Example point
        let disparity: Float = 0.1 // Example disparity
        
        // Convert depth data to DepthFloat32
        let convertedDepthData = self.asDepthFloat32
        let depthMap = convertedDepthData.depthDataMap
        
        // Call getDepthReading on the depth map
//        ChatGPT prompted ARKit code function call
//        let modifiedDepthMap = depthMap.getDepthReading(sceneView: sceneView, cgPt: cgPt, disparity: disparity)
        let modifiedDepthMap = depthMap.getDepthReading()
        
        // Convert the resulting depth map to UIImage
        return modifiedDepthMap.uiImage
    }
}
