//
//  BattleCrySpeaker.swift
//  TicTacTouch
//
//  Created by Janice C on 10/1/25.
//

import Foundation
import AVFoundation

/// A helper to speak battle cries and onboarding narration
final class BattleCrySpeaker {
    static let shared = BattleCrySpeaker()
    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    /// Speak a battle cry or motto text aloud
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.42         // slower, announcer-style pacing
        utterance.pitchMultiplier = 0.9
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }
}
