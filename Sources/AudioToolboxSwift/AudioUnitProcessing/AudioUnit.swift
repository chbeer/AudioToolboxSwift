//
//  File.swift
//  
//
//  Created by Christian Beer on 20.11.21.
//

import Foundation
import AudioToolbox

protocol AudioUnitParameter {
    var rawValue: AudioUnitParameterID { get }
}

public class AudioUnit {
    
    public enum Property: AudioUnitPropertyID {
        case classInfo = 0
        case makeConnection = 1
        case sampleRate = 2
        case parameterList = 3
        case parameterInfo = 4
        case cPULoad = 6
        case streamFormat = 8
        case elementCount = 11
        case latency = 12
        case supportedNumChannels = 13
        case maximumFramesPerSlice = 14
        case parameterValueStrings = 16
        case audioChannelLayout = 19
        case tailTime = 20
        case bypassEffect = 21
        case lastRenderError = 22
        case setRenderCallback = 23
        case factoryPresets = 24
        case renderQuality = 26
        case hostCallbacks = 27
        case inPlaceProcessing = 29
        case elementName = 30
        case supportedChannelLayoutTags = 32
        case presentPreset = 36
        case dependentParameters = 45
        case inputSamplesInOutput = 49
        case shouldAllocateBuffer = 51
        case frequencyResponse = 52
        case parameterHistoryInfo = 53
        case nickName = 54
        case offlineRender = 37
        case parameterIDName = 34
        case parameterStringFromValue = 33
        case parameterClumpName = 35
        case parameterValueFromString = 38
        case contextName = 25
        case presentationLatency = 40
        case classInfoFromDocument = 50
        case requestViewController = 56
        case parametersForOverview = 57
        case supportsMPE = 58
        case renderContextObserver = 60
        case lastRenderSampleTime = 61
        case loadedOutOfProcess = 62
    #if os(macOS)
        case fastDispatch = 5
        case setExternalBuffer = 15
        case getUIComponentList = 18
        case cocoaUI = 31
        case iconLocation = 39
        case aUHostIdentifier = 46
    #endif
        case midiOutputCallbackInfo = 47
        case midiOutputCallback = 48
        case midiOutputEventListCallback = 63
        case audioUnitMIDIProtocol = 64
        case hostMIDIProtocol = 65
    }
    public enum Scope {
        case global
        case input
        case output
        case group
        case part
        case note
        case layer
        case layerItem
    }
    
    let audioComponentDescription: AudioComponentDescription
    
    var graph: AudioUnitGraph?
    var node: AUNode?
    var unit: AudioToolbox.AudioUnit?

    internal init(audioComponentDescription: AudioComponentDescription) {
        self.audioComponentDescription = audioComponentDescription
    }
    
    open func didAddToGraph(_ graph: AudioUnitGraph, node: AUNode) throws {
        self.graph = graph
        self.node = node
    }
    open func didOpenGraph(_ graph: AudioUnitGraph) throws {
        guard let node = node else { return }
        try auAssert(AUGraphNodeInfo(graph.graph!, node, nil, &unit))
    }
    
    // MARK: - Property Management
    
    func getProperty<T>(_ property: Property, scope: Scope, element: Int = 0, default value: [T]) throws -> [T] {
        guard let unit = unit else { throw AudioUnitError.unitUnitialized }
        var size: UInt32 = UInt32(MemoryLayout<T>.size * value.count)
        var data: [T] = value
        try aqAssert(AudioUnitGetProperty(unit,
                                          property.rawValue,
                                          scope.rawValue,
                                          AudioUnitElement(element),
                                          &data,
                                          &size))
        return data
    }
    func getProperty<T>(_ property: Property, scope: Scope, element: Int = 0, default value: T) throws -> T {
        guard let unit = unit else { throw AudioUnitError.unitUnitialized }
        var size: UInt32 = UInt32(MemoryLayout<T>.size)
        var data: T = value
        try aqAssert(AudioUnitGetProperty(unit,
                                          property.rawValue,
                                          scope.rawValue,
                                          AudioUnitElement(element),
                                          &data,
                                          &size))
        return data
    }
    
    func setProperty<T>(_ property: Property, scope: Scope, element: Int = 0, value: T) throws {
        guard let unit = unit else { throw AudioUnitError.unitUnitialized }
        var value: T = value
        try auAssert(AudioUnitSetProperty(unit,
                                          property.rawValue,
                                          scope.rawValue,
                                          AudioUnitElement(element),
                                          &value,
                                          UInt32(MemoryLayout<T>.size)
        ))
    }
    func setProperty<T>(_ property: Property, scope: Scope, element: Int = 0, value: [T]) throws {
        guard let unit = unit else { throw AudioUnitError.unitUnitialized }
        var value = value
        try auAssert(AudioUnitSetProperty(unit,
                                          property.rawValue,
                                          scope.rawValue,
                                          AudioUnitElement(element),
                                          &value,
                                          UInt32(MemoryLayout<T>.size * value.count)))
    }
    
    func getParameter(_ parameter: AudioUnitParameter, scope: Scope, element: Int = 0) throws -> AudioUnitParameterValue {
        guard let unit = unit else { throw AudioUnitError.unitUnitialized }
        var value: AudioUnitParameterValue = 0
        try aqAssert(AudioUnitGetParameter(unit, parameter.rawValue, scope.rawValue, AudioUnitElement(element), &value))
        return value
    }
    func setParameter(_ parameter: AudioUnitParameter, scope: Scope, element: Int = 0, value: AudioUnitParameterValue) throws {
        guard let unit = unit else { throw AudioUnitError.unitUnitialized }
        try aqAssert(AudioUnitSetParameter(unit, parameter.rawValue, scope.rawValue, AudioUnitElement(element), value, 0))
    }
}
