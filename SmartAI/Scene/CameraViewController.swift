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
import Lottie

// TODO: - ReactorKit 적용 + RxDelegateProxy로 전부 다 묶기
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
        
        self.rx.viewDidLoad
            .withUnretained(self)
            .bind { owner, _ in
                owner.configurePreviewLayer()
                owner.configureUI()
            }.disposed(by: disposeBag)
        
        self.rx.viewWillDisappear
            .withUnretained(self)
            .bind { owner, _ in owner.captureSession.stopRunning() }
            .disposed(by: disposeBag)
        
        captureButton.rx.tap
            .bind { _ in
                self.didTakePhoto()
            }
            .disposed(by: disposeBag)
    }

    // MARK: - function
    private func configurePreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewViewLayer.layer.addSublayer(previewLayer)
        
        // NOTE: - startRunning은 blocking call이라서 main block 되지 않도록 queue로 처리
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.captureSession.startRunning()
            
            // UI 변경을 위해 main queue 접근
            DispatchQueue.main.async {
                self.previewLayer.frame = self.previewViewLayer.bounds
            }
            
            self.configureCaptureSession()
        }
    }
    
    // captureSession에 대해서 설정합니다.
    private func configureCaptureSession() {
        captureSession.sessionPreset = .photo
        captureSession.beginConfiguration()
        
        // ☃️ TODO: - 근데 듀얼 카메라가 없는 디바이스면 어떻게 할까?
        guard let device = AVCaptureDevice.default(for: .video) else {
            captureSession.commitConfiguration()
            return
        }
        
        do {
            // NOTE: - Input
            let input = try AVCaptureDeviceInput(device: device)
            photoOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                self.deviceInput = input
            } else {
                captureSession.commitConfiguration()
                return
            }
            
            // NOTE: - Output
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            } else {
                captureSession.commitConfiguration()
                return
            }
            
        } catch {
            captureSession.commitConfiguration()
            print("🚨 \(error.localizedDescription)")
        }
        captureSession.commitConfiguration()
    }
    
    func didTakePhoto() {
        // 호출될 때 마다 다른 세팅을 주어야 하기 때문에 메서드 안에서 생성
        let settings = AVCapturePhotoSettings(
format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        // 아래에 AVCapturePhotoCaptureDelegate를 채택
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - initialize
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIComponents
    var previewViewLayer = UIView()
    lazy var captureButton: UIButton = {
        let text = "🤖 분석 시작하기 🤖"
        
        //내가 적용하고싶은 폰트 사이즈
        let fontSize = UIFont.pretendardFont(size: 22, style: .semiBold)
        //label에 있는 Text를 NSMutableAttributedString으로 만들어준다.
        let attributedStr = NSMutableAttributedString(string: text)
        attributedStr.addAttribute(.font, value: fontSize, range: (text as NSString).range(of: text))
        
        $0.setAttributedTitle(attributedStr, for: .normal)
        $0.setTitleColor(.green, for: .normal)
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
            $0.centerX.equalToSuperview()
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        
        if let image = UIImage(data: imageData) {
            print(image)
            self.showResultViewController(image: image)
        }
    }
}
