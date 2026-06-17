import AVFoundation
import CoreImage

class CameraController: NSObject {
    private var session: AVCaptureSession?
    private let detector: CIDetector?
    private let onUpdate: (Float) -> Void
    private let queue = DispatchQueue(label: "com.petar.ZuckMode.camera", qos: .userInitiated)

    // Asymmetric EMA: rises fast on detections, falls slowly on misses
    private var ema: Float = 1.0  // start bright
    private let riseAlpha: Float = 0.20   // fast response when smile detected
    private let fallAlpha: Float = 0.05   // slow decay when not detected — tolerates gaps
    private let detectionNorm: Float = 0.50  // ~50% detection rate → full brightness

    init(onUpdate: @escaping (Float) -> Void) {
        self.onUpdate = onUpdate
        detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [
            CIDetectorAccuracy: CIDetectorAccuracyHigh
        ])
        super.init()
    }

    func start() {
        queue.async { self.setupAndStart() }
    }

    func stop() {
        session?.stopRunning()
    }

    private func setupAndStart() {
        let s = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              s.canAddInput(input) else { return }

        s.addInput(input)
        if s.canSetSessionPreset(.low) { s.sessionPreset = .low }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)

        guard s.canAddOutput(output) else { return }
        s.addOutput(output)

        session = s
        s.startRunning()
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let image = CIImage(cvPixelBuffer: pixelBuffer)
        let features = detector?.features(in: image, options: [CIDetectorSmile: true]) as? [CIFaceFeature] ?? []

        let detected: Float = (features.first?.hasSmile ?? false) ? 1.0 : 0.0
        let alpha = detected > ema ? riseAlpha : fallAlpha
        ema += (detected - ema) * alpha
        onUpdate(min(1.0, ema / detectionNorm))
    }
}
