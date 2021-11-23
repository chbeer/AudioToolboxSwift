//
//  AudioUnitGraph.swift
//  
//
//  Created by Christian Beer on 19.11.21.
//

import Foundation
import AudioToolbox

public class AudioUnitGraph {
    
    var graph: AUGraph?
    let sampleRate: Double
    
    var nodes: [AudioUnit] = []
    
    public init(sampleRate: Double = 44100.0) throws {
        self.sampleRate = sampleRate
        try auAssert(NewAUGraph(&graph))
    }
    
    public func open() throws {
        guard let graph = graph else { throw AudioQueueError.queueUnitialized }
        try auAssert(AUGraphOpen(graph))
        
        try nodes.forEach({ try $0.didOpenGraph(self) })
    }
    
    public func initialize() throws {
        guard let graph = graph else { throw AudioQueueError.queueUnitialized }
        try auAssert(AUGraphInitialize(graph))
    }

    public func addNode(_ unit: AudioUnit) throws {
        guard let graph = graph else { throw AudioQueueError.queueUnitialized }
        var description = unit.audioComponentDescription
        var node: AUNode = 0
        try auAssert(AUGraphAddNode(graph, &description, &node))
        
        try unit.didAddToGraph(self, node: node)
        nodes.append(unit)
    }
    
    public func connectNode(source: AudioUnit, outputNumber: Int, destination: AudioUnit, inputNumber: Int) throws {
        guard let graph = graph else { throw AudioQueueError.queueUnitialized }
        try auAssert(AUGraphConnectNodeInput(graph, source.node!, UInt32(outputNumber),
                                             destination.node!, UInt32(inputNumber)))
    }
}
