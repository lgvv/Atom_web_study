//
//  ViewController.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/18.
//

import UIKit
import AVFoundation
import Photos
import RxSwift
import RxCocoa
import SnapKit

class CameraViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    // MARK: - Properties
    var captureSession = AVCaptureSession()
    var deviceInput : AVCaptureDeviceInput!
    var photoOutput: AVCapturePhotoOutput!
    var sessionQueue = DispatchQueue(label: "sessionQueue", qos: .userInitiated)
    var previewLayer: AVCaptureVideoPreviewLayer! // 디스커션 읽어보기

    // MARK: - Binding
    private func bind() {
        captureButton.rx.tap
            .bind { _ in self.didTakePhoto() }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.bind()
    }
    
    // MARK: - function
    private func configureSession() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        sessionQueue.async { [weak self] in
            guard let self else { return }
            
            self.captureSession.sessionPreset = .photo
            self.configureDeviceInput()
        }
    }
    
    // 디바이스 인풋에 대해서 설정합니다.
    private func configureDeviceInput() {
        // builtInWideAngleCamera를 획득
        captureSession.beginConfiguration()
        
        // ☃️ TODO: - 근데 듀얼 카메라가 없는 디바이스면 어떻게 할까?
        guard let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else {
            captureSession.commitConfiguration()
            
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            photoOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                self.deviceInput = input
            } else {
                captureSession.commitConfiguration()
                
                return
            }
        } catch {
            captureSession.commitConfiguration()
            print("🚨 \(error.localizedDescription)")
        }
    }
    
    func setUpLivePreview() {
        // 캡처 비디오를 표시할 레이어
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewViewLayer.layer.addSublayer(previewLayer)
        
        // startRunning이 blocking call이므로 GCD 사용
        DispatchQueue.global(qos: .userInitiated).async {
            // 세션 시작
            self.captureSession.startRunning()
            
            // UI 변경을 위해 main queue 접근
            DispatchQueue.main.async {
                self.previewLayer.frame = self.previewViewLayer.bounds
            }
        }
    }

    func didTakePhoto() {
        // 호출될 때 마다 다른 세팅을 주어야 하기 때문에 메서드 안에서 생성
        let settings = AVCapturePhotoSettings(
format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        // 아래에 AVCapturePhotoCaptureDelegate를 채택
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 세션 정지
        self.captureSession.stopRunning()
    }
    
    // MARK: - UIComponents
    var previewViewLayer = UIView()
    var captureButton: UIButton = {
        $0.setTitle("버튼", for: .normal)
        
        return $0
    }(UIButton())
}

extension CameraViewController {
    private func configureUI() {
        view.addSubview(previewViewLayer)
        previewViewLayer.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(captureButton)
        captureButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(100)
            $0.leading.trailing.equalToSuperview()
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        print(image)
    }
}
