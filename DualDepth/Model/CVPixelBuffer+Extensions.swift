//
//  CVPixelBuffer+Extensions.swift
//  DualDepth
//
//  Created by MacBook Pro M1 on 2021/10/26.
//

import Foundation
import CoreVideo
import CoreImage
import UIKit
import ARKit

var globalDepthValue: Float = 0.0
let phoneScreenWidth = UIScreen.main.bounds.width
let phoneScreenHeight = UIScreen.main.bounds.width

extension CVPixelBuffer {
    // convert CVPixelBuffer to UIImage
    var uiImage: UIImage? {
        let ciImage = CIImage(cvPixelBuffer: self)
        let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)
        guard let image = cgImage else { return nil }
        let uiImage = UIImage(cgImage: image, scale: 0, orientation: .right)
        return uiImage
    }
    
    // normalize CVPixelBuffer
    /// https://www.raywenderlich.com/8246240-image-depth-maps-tutorial-for-ios-getting-started
    /// ChatGPT prompted code for ARKit
//    func getDepthReading(sceneView: ARSCNView, cgPt: CGPoint, disparity: Float) -> CVPixelBuffer {
//        // Assuming `self` is a CVPixelBuffer
//        var cvPixelBuffer = self
//        
//        let width = CVPixelBufferGetWidth(cvPixelBuffer)
//        let height = CVPixelBufferGetHeight(cvPixelBuffer)
//        
//        CVPixelBufferLockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(cvPixelBuffer), to: UnsafeMutablePointer<Float>.self)
//        
//        // Calculate depth from disparity
//        let depth = 1 / disparity
//        
//        // Project a point at this depth to screen space
//        let vScreen = sceneView.projectPoint(SCNVector3Make(0, 0, -depth))
//        
//        // Unproject the screen point back to the 3D world
//        let worldPoint = sceneView.unprojectPoint(SCNVector3Make(Float(cgPt.x), Float(cgPt.y), Float(vScreen.z)))
//        
//        // Convert worldPoint.z to Float
//        let depthValue = Float(worldPoint.z)
//        
//        // Save the depth value at the specific location (cgPt)
//        let targetY = Int(cgPt.y)
//        let targetX = Int(cgPt.x)
//        
//        // Calculate the index corresponding to the target location
//        let index = (targetY * width + targetX)
//        
//        // Save the depth value at the calculated index
//        floatBuffer[index] = depthValue
//        globalDepthValue = depthValue
//
//        CVPixelBufferUnlockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//        return cvPixelBuffer
//    }
    // End of ChatGPT prompted code for ARKit
    
    func getDepthReading() -> CVPixelBuffer {
        var cvPixelBuffer = self // Assuming `self` is a CVPixelBuffer
        
        let width = CVPixelBufferGetWidth(cvPixelBuffer)
        let height = CVPixelBufferGetHeight(cvPixelBuffer)
        
        CVPixelBufferLockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(cvPixelBuffer), to: UnsafeMutablePointer<Float>.self)
        
//        var minDepth: Float = Float.greatestFiniteMagnitude
//        var maxDepth: Float = -Float.greatestFiniteMagnitude
//
        // Finding the minimum and maximum depth values
//        for y in 0..<height {
//            for x in 0..<width {
//                let depth = floatBuffer[y * width + x]
//                minDepth = min(depth, minDepth)
//                maxDepth = max(depth, maxDepth)
//            }
//        }

        // Saving a depth value at a specific location
        let targetY = height / 3
        let targetX = width / 2

        // Test
//        let targetY = phoneScreenHeight / 2
//        let targetX = phoneScreenWidth / 2
        //end test

        // Calculate the index corresponding to the target location
        let index = Int(targetY + targetX)
        
        // Save the depth value at the calculated index
        globalDepthValue = floatBuffer[index]
        
        CVPixelBufferUnlockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return cvPixelBuffer
    }

    
    // convert CVPixelBuffer to Array
    var array: Array<Array<Float32>> {
        let cvPixelBuffer = self
        
        CVPixelBufferLockBaseAddress(cvPixelBuffer, .readOnly)
        
        let base = CVPixelBufferGetBaseAddress(cvPixelBuffer)
        let width = CVPixelBufferGetWidth(cvPixelBuffer)
        let height = CVPixelBufferGetHeight(cvPixelBuffer)
        
        let bindPointer = base?.bindMemory(to: Float32.self, capacity: width * height)
        let bufPointer = UnsafeBufferPointer(start: bindPointer, count: width * height)
        let array = Array(bufPointer)
        
        CVPixelBufferUnlockBaseAddress(cvPixelBuffer, .readOnly)
        
        let fixedArray = array.map({ $0.isNaN ? 0 : $0 })
        let reshapedArray = reshape(from: fixedArray, width: width, height: height)
        return reshapedArray
    }
}

// MARK: -

// reshape 1D array to 2D array, like numpy
// https://stackoverflow.com/questions/59823900/turn-1d-array-into-2d-array-in-swift
private func reshape(from array: [Float32], width: Int, height: Int) -> [[Float32]] {
    let mask = Array(repeating: Array(repeating: 0.0, count: width), count: height)
    var iter = array.makeIterator()
    let reshapedArray = mask.map { $0.compactMap { _ in iter.next() } }
    return reshapedArray
}


//    func normalize() -> CVPixelBuffer {
//        let cvPixelBuffer = self
//
//        let width = CVPixelBufferGetWidth(cvPixelBuffer)
//        let height = CVPixelBufferGetHeight(cvPixelBuffer)
//
//        CVPixelBufferLockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(cvPixelBuffer), to: UnsafeMutablePointer<Float>.self)
//
//        var minPixel: Float = 1.0
//        var maxPixel: Float = 0.0
//
//        for y in stride(from: 0, to: height, by: 1) {
//          for x in stride(from: 0, to: width, by: 1) {
//            let pixel = floatBuffer[y * width + x]
//            minPixel = min(pixel, minPixel)
//            maxPixel = max(pixel, maxPixel)
//          }
//        }
//
//        let range = maxPixel - minPixel
//        for y in stride(from: 0, to: height, by: 1) {
//          for x in stride(from: 0, to: width, by: 1) {
//            let pixel = floatBuffer[y * width + x]
//            floatBuffer[y * width + x] = (pixel - minPixel) / range
//          }
//        }
//
//        CVPixelBufferUnlockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//        return cvPixelBuffer
//    }
//    /////////////////////////////////////////////////////////////////////
//    func normalize() -> CVPixelBuffer {
//        let cvPixelBuffer = self
//
//        let width = CVPixelBufferGetWidth(cvPixelBuffer)
//        let height = CVPixelBufferGetHeight(cvPixelBuffer)
//
//        CVPixelBufferLockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(cvPixelBuffer), to: UnsafeMutablePointer<Float>.self)
//
//        var minPixel: Float = 1.0
//        var maxPixel: Float = 0.0
//
//        // beginning of saving here
//
//        let targetY = height / 3
//        let targetX = width / 2
//
//        let pixel = floatBuffer[targetY * width + targetX]
//
//        // end of saving here
//
//        CVPixelBufferUnlockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//        return cvPixelBuffer
//    }
