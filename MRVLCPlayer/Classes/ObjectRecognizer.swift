//
//  ObjectRecognizer.swift
//  MRVLCPlayer
//
//  Created by DOM QIU on 2017/10/24.
//  Copyright © 2017年 Alloc. All rights reserved.
//

import UIKit
import CoreMedia
import Vision

@objc class ObjectRecognizer: NSObject {
    @objc public static func handlePixelBufferWithInceptionv3(imageBuffer: CVPixelBuffer?, model: Inceptionv3) -> Inceptionv3Output? {
//        NSLog("#ML# imageBuffer = \(imageBuffer)");
        guard let pixelBuffer = imageBuffer else {
//            NSLog("#ML# return nil");
            return nil
        }
//        NSLog("#ML# handleImageBufferWithInceptionv3");
        do {
            let prediction = try model.prediction(fromImage: ObjectRecognizer.resize(pixelBuffer: pixelBuffer)!)
            NSLog("#ML# %@\n", prediction.classLabel);
            return prediction
        }
        catch let error as NSError {
            fatalError("#ML# Unexpected error ocurred: \(error.localizedDescription).")
        }
    }
    
    @objc public static func resize(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let imageSide = 299
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        let transform = CGAffineTransform(scaleX: CGFloat(imageSide) / CGFloat(CVPixelBufferGetWidth(pixelBuffer)), y: CGFloat(imageSide) / CGFloat(CVPixelBufferGetHeight(pixelBuffer)))
        ciImage = ciImage.transformed(by: transform).cropped(to: CGRect(x: 0, y: 0, width: imageSide, height: imageSide))
        let ciContext = CIContext()
        var resizeBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, imageSide, imageSide, CVPixelBufferGetPixelFormatType(pixelBuffer), nil, &resizeBuffer)
        ciContext.render(ciImage, to: resizeBuffer!)
        return resizeBuffer
    }
    
    let inceptionv3model = Inceptionv3()

}
