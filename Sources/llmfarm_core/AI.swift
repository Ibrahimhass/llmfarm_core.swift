//
//  Model.swift
//  Mia
//
//  Created by Byron Everson on 12/25/22.
//

import Foundation

public enum ModelInference {
    case LLamaInference
    case GPTNeoxInference
    case GPT2
    case Replit
    case Starcoder
    case RWKV
}

public class AI {
    
    var aiQueue = DispatchQueue(label: "LLMFarm-Main", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    //var model: Model!
    public var model: Model!
    public var modelPath: String
    public var modelName: String
    public var chatName: String
    
    public var flagExit = false
    private(set) var flagResponding = false
    
    public init(_modelPath: String,_chatName: String) {
        self.modelPath = _modelPath
        self.modelName = NSURL(fileURLWithPath: _modelPath).lastPathComponent!
        self.chatName = _chatName
    }
    
    public func loadModel(_ aiModel: ModelInference, contextParams: ModelContextParams = .default) {
        print("AI init")
        do{
            switch aiModel {
            case .LLamaInference:
                model = try LLaMa(path: self.modelPath, contextParams: contextParams)
            case .GPTNeoxInference:
                model = try GPTNeoX(path: self.modelPath, contextParams: contextParams)
            case .GPT2:
                model = try GPT2(path: self.modelPath, contextParams: contextParams)
            case .Replit:
                model = try Replit(path: self.modelPath, contextParams: contextParams)
            case .Starcoder:
                model = try Starcoder(path: self.modelPath, contextParams: contextParams)
            case .RWKV:
                model = try RWKV(path: self.modelPath, contextParams: contextParams)
            }
        }
        catch {
            print(error)
        }
    }
    
    public func conversation(_ input: String,  _ tokenCallback: ((String, Double) -> ())?, _ completion: ((String) -> ())?) {
        flagResponding = true
        aiQueue.async {
            func mainCallback(_ str: String, _ time: Double) -> Bool {
                DispatchQueue.main.async {
                    tokenCallback?(str, time)
                }
                if self.flagExit {
                    // Reset flag
                    self.flagExit = false
                    // Alert model of exit flag
                    return true
                }
                return false
            }
            guard let completion = completion else { return }
            
            // Model output
            let output = try? self.model.predict(input, mainCallback)
            
            DispatchQueue.main.async {
                self.flagResponding = false
                completion(output ?? "[Error]")
            }
        }
    }
    
    
}




