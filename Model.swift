//
//  File.swift
//  ParkingMaster
//
//  Created by 임영후 on 2022/04/22.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: {
                loadCompletion in print("DEBUG: Unable to load modelEntity for modelName: \(self.modelName)")}, receiveValue: {
                    modelEntity in self.modelEntity = modelEntity
                    print("DEBUG: Successfully loaded modelEntity for modelName: \(self.modelName)")
                    }
            )
    }
}
