import Foundation
import AVFoundation
import Speech
import EventKit

// MARK: - Spoken prayer transcription — on-device speech recognition (free, private).

@MainActor
final class PrayerTranscriber: ObservableObject {
    @Published var transcript = ""
    @Published var listening = false
    @Published var errorMessage: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func start() {
        errorMessage = nil
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                guard status == .authorized else {
                    self?.errorMessage = "Speech permission needed — enable it in Settings."
                    return
                }
                AVAudioApplication.requestRecordPermission { granted in
                    Task { @MainActor in
                        guard granted else {
                            self?.errorMessage = "Microphone permission needed — enable it in Settings."
                            return
                        }
                        self?.beginRecognition()
                    }
                }
            }
        }
    }

    private func beginRecognition() {
        guard let recognizer, recognizer.isAvailable else {
            errorMessage = "Speech recognition isn't available on this device right now."
            return
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let req = SFSpeechAudioBufferRecognitionRequest()
            req.shouldReportPartialResults = true
            if recognizer.supportsOnDeviceRecognition { req.requiresOnDeviceRecognition = true }
            request = req

            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                req.append(buffer)
            }
            engine.prepare()
            try engine.start()
            listening = true

            task = recognizer.recognitionTask(with: req) { [weak self] result, error in
                Task { @MainActor in
                    if let result { self?.transcript = result.bestTranscription.formattedString }
                    if error != nil { self?.stop() }
                }
            }
        } catch {
            errorMessage = "Couldn't start listening."
            stop()
        }
    }

    func stop() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        listening = false
    }
}

// MARK: - Voice blessing recorder — 15-second prayers for friends, shared via iMessage.

@MainActor
final class BlessingRecorder: ObservableObject {
    @Published var recording = false
    @Published var fileURL: URL?
    @Published var seconds: Double = 0
    private var recorder: AVAudioRecorder?
    private var timer: Timer?

    static let maxSeconds: Double = 20

    func start() {
        AVAudioApplication.requestRecordPermission { granted in
            Task { @MainActor in
                guard granted else { return }
                self.begin()
            }
        }
    }

    private func begin() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try? session.setActive(true)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("blessing-\(UUID().uuidString.prefix(6)).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        guard let r = try? AVAudioRecorder(url: url, settings: settings) else { return }
        recorder = r
        r.record()
        recording = true
        seconds = 0
        fileURL = nil
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.seconds += 0.1
                if self.seconds >= Self.maxSeconds { self.stop() }
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        recorder?.stop()
        if recording { fileURL = recorder?.url }
        recording = false
    }

    func discard() {
        stop()
        if let fileURL { try? FileManager.default.removeItem(at: fileURL) }
        fileURL = nil
        seconds = 0
    }
}

// MARK: - Calendar context — personalizes the morning around real life (on-device).

@MainActor
final class LifeContext: ObservableObject {
    @Published var granted = UserDefaults.standard.bool(forKey: "selah.calendarGranted")
    @Published var todaySummary: String?

    private let store = EKEventStore()

    func requestAccess() {
        store.requestFullAccessToEvents { [weak self] ok, _ in
            Task { @MainActor in
                self?.granted = ok
                UserDefaults.standard.set(ok, forKey: "selah.calendarGranted")
                if ok { self?.refresh() }
            }
        }
    }

    func refresh() {
        guard granted else { return }
        let cal = Calendar.current
        let start = Date()
        let end = cal.date(byAdding: .hour, value: 20, to: start)!
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = store.events(matching: predicate)
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }
        guard let next = events.first, let title = next.title, !title.isEmpty else {
            todaySummary = nil
            return
        }
        let time = next.startDate.formatted(date: .omitted, time: .shortened)
        todaySummary = "\(title) at \(time)"
    }
}
