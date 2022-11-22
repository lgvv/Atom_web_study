//
//  ResultViewController.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/18.
//

import UIKit
import Vision
import SnapKit
import SwiftUI

protocol ResultViewControllerProtocol {
    func didTapImageView()
}

class ResultViewController: UIViewController, ResultViewControllerProtocol {
    var delegate: ResultViewControllerProtocol?
    
    // MARK: - Properties
    var image: UIImage? {
        // NOTE: - MVVM 리팩토링 고민. 할게 너무 많아요 근데 ㅠㅠ
        didSet {
            guard let image else { return }
            // NOTE: - 서버에서 결과가 내려오는데 시간이 오래걸림 (테스트 결과 적어도 5초 이상)
            if NetworkMonitor.shared.isConnected {
                APIManager.shared.uploadImage(for: image) { result in
                    switch result {
                    case .success(let banana):
                        self.answerLabel.text = banana.bananaClasses[banana.argmax]
                        var resultText: String = ""
                        banana.bananaClasses.forEach { key, value in
                            if let probability = banana.probability[key] {
                                resultText += String(format: "  (%.2f) %@\n", probability, value)
                            }
                        }
                        dump("☃️ \(resultText)")
                    case .failure(let error):
                        break
                    }
                }
            }
            
            self.updateClassifications(for: image)
            self.resultImageView.image = image
        }
    }
    private lazy var coreMLRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: BananaClassification().model)
            
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                guard let self else {
                    print("🚨 guard문에 걸렸네요.")
                    return
                }
                self.processClassifications(for: request, error: error)
            }
            
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("🚨 \(error.localizedDescription)")
        }
    }()
    
    // MARK: - function
    private func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("🚨 \(error?.localizedDescription)")
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                print("🚨 결과를 추출했지만 비어있어요.")
            } else {
                let classifications = classifications.prefix(4)
                dump("💕classifications \(classifications)")
                let descriptions = classifications.map { classification in
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                
                self.resultLabel.text = descriptions.joined(separator: "\n")
                self.answerLabel.text = classifications.prefix(1)
                    .map { classification in
                        return String(format: "%@", classification.identifier)
                    }.joined()
            }
        }
    }
    
    private func updateClassifications(for image: UIImage) {
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else {
            print("🚨 \(#function)")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            
            do {
                try handler.perform([self.coreMLRequest])
            } catch {
                print("🚨 \(error.localizedDescription)")
            }
        }
    }
    
    func didTapImageView() {
        print("didTapImageView")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configureUI()
    }
    
    // MARK: - UIComponents
    lazy var resultImageView: UIImageView = {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        return $0
    }(UIImageView())
    
    lazy var answerLabel: UILabel = {
        $0.textColor = .green
        $0.textAlignment = .center
        $0.font = .pretendardFont(size: 16, style: .regular)
        
        return $0
    }(UILabel())
    
    lazy var chartView: UIView = {
        let view = UIHostingController(
            rootView: ChartView(bananas: [])
        ).view ?? UIView()
        
        view.alpha = 0.0
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        return view
    }()
    
    lazy var resultLabel: UILabel = {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .pretendardFont(size: 22, style: .medium)
        
        return $0
    }(UILabel())
}

extension ResultViewController {
    func configureUI() {
        view.addSubview(resultImageView)
        resultImageView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview().inset(20)
            $0.height.equalTo(view.frame.width - 40)
        }
        
        resultImageView.addSubview(answerLabel)
        answerLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        view.addSubview(chartView)
        chartView.snp.makeConstraints {
            $0.top.equalTo(view.snp.centerY).inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension ResultViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        guard let type = sheetPresentationController.selectedDetentIdentifier else { return }
        
        switch type {
        case .medium: break
            UIView.animate(withDuration: 0.3) {
                self.chartView.alpha = 0.0
            }
        case .large: break
            UIView.animate(withDuration: 0.3) {
                self.chartView.alpha = 1.0
            }
        default: assert(true ,"지원하지 않는 옵션입니다")
        }
        
        print(type == .large ? "large" : "medium")
    }
}
