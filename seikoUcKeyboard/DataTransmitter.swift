//
//  DataTransmitter.swift
//  seikoUcKeyboard
//
//  Created by Giulio Furlan on 03/02/24.
//

import Foundation
import AVFoundation

class DataTransmitter {
    let FREQUENCY: Double = 16384
    let SAMPLE_RATE: Double = AVAudioSession.sharedInstance().sampleRate
    let PERIODS: Double = 8
    let MULTIPLIER: Double
    let WORD_SIZE: Int = 11
    let SAMPLES_SIZE: Int
    private var engine = AVAudioEngine()
    private var player = AVAudioPlayerNode()
    
    init() {
        MULTIPLIER = SAMPLE_RATE / 2.0 / FREQUENCY
        let sampleSize = Double(WORD_SIZE) * PERIODS * 2 * MULTIPLIER
        SAMPLES_SIZE = Int(sampleSize)
        let format = AVAudioFormat(standardFormatWithSampleRate: SAMPLE_RATE, channels: 1)
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        do {
            try engine.start()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    func transmit(input: Int) {
        let buffer = AVAudioPCMBuffer(pcmFormat: player.outputFormat(forBus: 0), frameCapacity: AVAudioFrameCount(SAMPLES_SIZE))!
        buffer.frameLength = buffer.frameCapacity
        buffer.floatChannelData?.pointee.withMemoryRebound(to: Float.self, capacity: Int(buffer.frameLength)) { bufferPtr in
            let samples = generateSamples(input: input)
            for i in 0..<samples.count {
                bufferPtr[i] = Float(samples[i]) / Float(Int16.max)
            }
        }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
        player.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.player.stop()
            self.player.reset()
        }
    }

    private func generateSamples(input: Int) -> [Int16] {
        var parity = input ^ (input >> 4)
        parity ^= parity >> 2
        parity ^= parity >> 1
        parity &= 0x01
        var wordBuffer = [Int](repeating: 0, count: WORD_SIZE)
        wordBuffer[0] = 1
        for i in 1..<9 {
            wordBuffer[i] = ~(input >> (i - 1)) & 0x01
        }
        wordBuffer[9] = ~parity & 0x01
        wordBuffer[10] = 0
        var samples = [Int16](repeating: 0, count: SAMPLES_SIZE)
        for i in stride(from: 0, to: SAMPLES_SIZE, by: 1) {
            let doubleI = Double(i)
            let tmp = Int(doubleI/MULTIPLIER/(PERIODS*2))
            if wordBuffer[tmp % WORD_SIZE] == 1 {
                samples[i] = Int16(sin(Double(i) * Double.pi / MULTIPLIER) * Double(Int16.max))
            } else {
                samples[i] = 0
            }
        }
        return samples
    }
    
}
