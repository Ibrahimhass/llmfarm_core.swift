//
//  Model.swift
//  Mia
//
//  Created by Byron Everson on 4/28/23.
//

import Foundation
import llmfarm_core_cpp

private typealias _ModelProgressCallback = (_ progress: Float, _ userData: UnsafeMutableRawPointer?) -> Void

public typealias ModelProgressCallback = (_ progress: Float, _ model: Model) -> Void

public func get_model_sample_param_by_config(_ model_config:Dictionary<String, AnyObject>) -> ModelSampleParams{
    var tmp_param = ModelSampleParams.default
    if (model_config["n_batch"] != nil){
        tmp_param.n_batch = model_config["n_batch"] as! Int32
    }
    if (model_config["temp"] != nil){
        tmp_param.temp = Float(model_config["temp"] as! Double)
    }
    if (model_config["top_k"] != nil){
        tmp_param.top_k = model_config["top_k"] as! Int32
    }
    if (model_config["top_p"] != nil){
        tmp_param.top_p = Float(model_config["top_p"] as! Double)
    }
    if (model_config["tfs_z"] != nil){
        tmp_param.tfs_z = Float(model_config["tfs_z"] as! Double)
    }
    if (model_config["typical_p"] != nil){
        tmp_param.typical_p = Float(model_config["typical_p"] as! Double)
    }
    if (model_config["repeat_penalty"] != nil){
        tmp_param.repeat_penalty = Float(model_config["repeat_penalty"] as! Double)
    }
    if (model_config["repeat_last_n"] != nil){
        tmp_param.repeat_last_n = model_config["repeat_last_n"] as! Int32
    }
    if (model_config["frequence_penalty"] != nil){
        tmp_param.frequence_penalty = Float(model_config["frequence_penalty"] as! Double)
    }
    if (model_config["presence_penalty"] != nil){
        tmp_param.presence_penalty = Float(model_config["presence_penalty"] as! Double)
    }
    if (model_config["mirostat"] != nil){
        tmp_param.mirostat = model_config["mirostat"] as! Int32
    }
    if (model_config["mirostat_tau"] != nil){
        tmp_param.mirostat_tau = Float(model_config["mirostat_tau"] as! Double)
    }
    if (model_config["mirostat_eta"] != nil){
        tmp_param.mirostat_eta = Float(model_config["mirostat_tau"] as! Double)
    }
    
    return tmp_param
}

public func get_model_context_param_by_config(_ model_config:Dictionary<String, AnyObject>) -> ModelContextParams{
    var tmp_param = ModelContextParams.default
    if (model_config["context"] != nil){
        tmp_param.context = model_config["context"] as! Int32
    }
    if (model_config["numberOfThreads"] != nil && model_config["numberOfThreads"] as! Int32 != 0){
        tmp_param.numberOfThreads = model_config["numberOfThreads"] as! Int32
    }
    
    return tmp_param
}

public struct ModelContextParams {
    public var context: Int32 = 512    // text context
    public var parts: Int32 = -1   // -1 for default
    public var seed: UInt32 = 0xFFFFFFFF      // RNG seed, 0 for random
    public var numberOfThreads: Int32 = 1

    public var f16Kv = true         // use fp16 for KV cache
    public var logitsAll = false    // the llama_eval() call computes all logits, not just the last one
    public var vocabOnly = false    // only load the vocabulary, no weights
    public var useMlock = false     // force system to keep model in RAM
    public var embedding = false    // embedding mode only
    public var processorsConunt  = Int32(ProcessInfo.processInfo.processorCount)
    public var use_metal = false
    
    public var warm_prompt = "\n\n\n"

    public static let `default` = ModelContextParams()

    public init(context: Int32 = 2048 /*512*/, parts: Int32 = -1, seed: UInt32 = 0xFFFFFFFF, numberOfThreads: Int32 = 0, f16Kv: Bool = true, logitsAll: Bool = false, vocabOnly: Bool = false, useMlock: Bool = false, embedding: Bool = false) {
        self.context = context
        self.parts = parts
        self.seed = seed
        // Set numberOfThreads to processorCount, processorCount is actually thread count of cpu
        self.numberOfThreads = Int32(numberOfThreads) == Int32(0) ? processorsConunt : numberOfThreads
//        self.numberOfThreads = processorsConunt
        self.f16Kv = f16Kv
        self.logitsAll = logitsAll
        self.vocabOnly = vocabOnly
        self.useMlock = useMlock
        self.embedding = embedding
    }
}

public struct ModelSampleParams {
    public var n_batch: Int32
    public var temp: Float
    public var top_k: Int32
    public var top_p: Float
    public var tfs_z: Float
    public var typical_p: Float
    public var repeat_penalty: Float
    public var repeat_last_n: Int32
    public var frequence_penalty: Float
    public var presence_penalty: Float
    public var mirostat: Int32
    public var mirostat_tau: Float
    public var mirostat_eta: Float
    public var penalize_nl: Bool
    
    public static let `default` = ModelSampleParams(
        n_batch: 512,
        temp: 0.9,
        top_k: 40,
        top_p: 0.95,
        tfs_z: 1.0,
        typical_p: 1.0,
        repeat_penalty: 1.1,
        repeat_last_n: 64,
        frequence_penalty: 0.0,
        presence_penalty: 0.0,
        mirostat: 0,
        mirostat_tau: 5.0,
        mirostat_eta: 0.1,
        penalize_nl: true
    )
    
    public init(n_batch: Int32 = 512,
                temp: Float = 0.8,
                top_k: Int32 = 40,
                top_p: Float = 0.95,
                tfs_z: Float = 1.0,
                typical_p: Float = 1.0,
                repeat_penalty: Float = 1.1,
                repeat_last_n: Int32 = 64,
                frequence_penalty: Float = 0.0,
                presence_penalty: Float = 0.0,
                mirostat: Int32 = 0,
                mirostat_tau: Float = 5.0,
                mirostat_eta: Float = 0.1,
                penalize_nl: Bool = true,
                use_metal:Bool = false) {
        self.n_batch = n_batch
        self.temp = temp
        self.top_k = top_k
        self.top_p = top_p
        self.tfs_z = tfs_z
        self.typical_p = typical_p
        self.repeat_penalty = repeat_penalty
        self.repeat_last_n = repeat_last_n
        self.frequence_penalty = frequence_penalty
        self.presence_penalty = presence_penalty
        self.mirostat = mirostat
        self.mirostat_tau = mirostat_tau
        self.mirostat_eta = mirostat_eta
        self.penalize_nl = penalize_nl
    }
}

public enum ModelError: Error {
    case modelNotFound(String)
    case inputTooLong
    case failedToEval
}

public enum ModelPromptStyle {
    case None
    case Custom
    case ChatBase
    case OpenAssistant
    case StableLM_Tuned
    case LLaMa
    case LLaMa_QA
    case Dolly_b3
    case RedPajama_chat
}

public typealias ModelToken = Int32

public class Model {
    
    public var context: OpaquePointer?
    public var contextParams: ModelContextParams
    public var sampleParams: ModelSampleParams = .default
    public var promptFormat: ModelPromptStyle = .None
    public var custom_prompt_format = ""
    public var core_resourses = get_core_bundle_path()
    public var reverse_prompt: [String] = []
    
    
    // Init
    public init(path: String = "", contextParams: ModelContextParams = .default) throws {
        self.contextParams = contextParams
        self.context = nil
    }
    
    public func load_model(path: String = "", contextParams: ModelContextParams = .default, params:gpt_context_params ) throws -> Bool{
        return false
    }
    
    // Predict
    public func predict(_ input: String, _ callback: ((String, Double) -> Bool) ) throws -> String {
        return ""
    }
    
    public func llm_tokenize(_ input: String, bos: Bool = false, eos: Bool = false) -> [ModelToken] {
        return []
    }
    
    

    
    public func tokenizePrompt(_ input: String, _ style: ModelPromptStyle) -> [ModelToken] {
        switch style {
        case .None:
            return llm_tokenize(input)
        case .Custom:
            var formated_input = self.custom_prompt_format.replacingOccurrences(of: "{{prompt}}", with: input)
            formated_input = formated_input.replacingOccurrences(of: "\\n", with: "\n")
            return llm_tokenize(formated_input, bos: true)
        case .ChatBase:
            return llm_tokenize("<human>: " + input + "\n<bot>:")
        case .OpenAssistant:
            let inputTokens = llm_tokenize("<|prompter|>" + input + "<|endoftext|>" + "<|assistant|>")
            return inputTokens
        case .RedPajama_chat:            
            return llm_tokenize("<human>:\n" + input + "\n<bot>:")
        case .Dolly_b3:
            let  INSTRUCTION_KEY = "### Instruction:";
            let  RESPONSE_KEY    = "### Response:";
            let  INTRO_BLURB     = "Below is an instruction that describes a task. Write a response that appropriately completes the request.";
            let inputTokens = llm_tokenize(INTRO_BLURB + INSTRUCTION_KEY + input + RESPONSE_KEY)
            return inputTokens
        case .StableLM_Tuned:
            let inputTokens = llm_tokenize("<|USER|>" + input + "<|ASSISTANT|>")
            return inputTokens
        case .LLaMa:
            let input = " " + input
            return llm_tokenize(input, bos: true)
        case .LLaMa_QA:
            let input = " Question: " + input + "\n\nAnswer: "
            return llm_tokenize(input, bos: true)
        }
    }
    
}
