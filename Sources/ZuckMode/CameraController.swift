import AVFoundation
import CoreImage

class CameraController: NSObject {
    private var session: AVCaptureSession?
    private let detector: CIDetector?
    private var smileScore: Float = 0
    private let onUpdate: (Float) -> Void
    private let queue = DispatchQueue(label: "com.petar.ZuckMode.camera", qos: .userInitiated)

    init(onUpdate: @escaping (Float) -> Void) {
        self.onUpdate = onUpdate
        detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [
            CIDetectorAccuracy: CIDetectorAccuracyLow
        ])
        super.init()
    }

    func requestAccessAndStart() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted else { return }
            self?.queue.async { self?.setupAndStart() }
        }
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
        let isSmiling = features.first?.hasSmile ?? false

        // Rise fast (0.3/frame), fall slow (0.04/frame) — forgives brief non-smiles
        let target: Float = isSmiling ? 1.0 : 0.0
        let rate: Float = target > smileScore ? 0.3 : 0.04
        smileScore += (target - smileScore) * rate

        onUpdate(smileScore)
    }
}
