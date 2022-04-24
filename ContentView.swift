import SwiftUI
import RealityKit
import ARKit
import FocusEntity
import SpriteKit

struct ContentView: View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement : Model?
    private var models: [Model] = {
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try?
                filemanager.contentsOfDirectory(atPath: path) else {
                    return []
        }
        
        var availableModels: [Model] = []
        for filename in files where
        filename.hasSuffix("usdz") {
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availableModels.append(model)
        }
        return availableModels
    }()
    //["LunarRover_English", "toy_car"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            SpriteKitContainer(scene: SpriteScene())
        
            if self.isPlacementEnabled {
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            } else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
        }
    }
}





struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: Model?
    
    func makeUIView(context: Context) -> ARView {
        let arView = CustomARView(frame: .zero)
        
        
        
        
        
        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.modelConfirmedForPlacement {
            if let modelEntity = model.modelEntity {
                print("DEBUG: adding model to scene - \(model.modelName)")
                
                let anchorEntity = AnchorEntity(plane: .any)
                
                anchorEntity.addChild(modelEntity)
             
                uiView.scene.addAnchor(anchorEntity)
                
            } else {
                print("DEBUG: Unable to load modelEntity for \(model.modelName)")
            }

            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
}

//포커스 영역
class CustomARView: ARView, FEDelegate {
    let focusSquare = FESquare()
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        focusSquare.viewDelegate = self
        focusSquare.delegate = self
        focusSquare.setAutoUpdate(to: true)
        
        self.setupARView()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupARView() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        config.environmentTexturing = .automatic
        
        if
            ARWorldTrackingConfiguration
                .supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        self.session.run(config)     
    }
}

//자동차 선택 창
struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    var models: [Model]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) {
                    index in Button(action: {
                        print("DEBUG: selected model with name : \(self.models[index].modelName)")
                        
                        self.selectedModel = self.models[index]
                        self.isPlacementEnabled = true
                    }) {
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    var body: some View {
        HStack {
            // 취소 버튼
            Button(action: {
                print("DEBUG: Cancel Model placement.")
                self.resetPlacementParameters()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            //확인 버튼
            Button(action: {
                print("DEBUG: model placement confirmed.")
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetPlacementParameters()
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}


struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



//arView.session.delegate = self
//
//arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
//@objc
//func handleTap(recognizer: UITapGestureRecognizer) {
//    let location = recognizer.location(in: ARView)
//
//    let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
//
//    if let firstResult = results.first {
//        let anchor = ARAnchor(name: "ContemporaryFan", transform: firstResult.worldTransform)
//        arView.session.add(anchor: anchor)
//    } else {
//        print("Object placement failed - could't find surface.")
//    }
//}
//
//func placeObject(named entityName: String, for anchor:ARAnchor) {
//    let entity = try! ModelEntity.loadModel(named: entityName)
//
//    entity.generateCollisionShapes(recursive: true)
//    arView.installGestures([.rotation, .translation], for: entity)
//
//    let anchorEntity = AnchorEntity(anchor: anchor)
//    anchorEntity.addChild(entity)
//    arView.scene.addAnchor(anchorEntity)
//
//extension ViewController: ARSessionDelegate {
//    func session(session: ARSession, didAdd anchors: [ARAnchor]) {
//        for anchor in anchors {
//            if let anchorName = anchor.name, anchorName == "ContemporaryFan" {
//                placeObject(named: anchorName, for: anchor)
//            }
//        }
//    }
//}
