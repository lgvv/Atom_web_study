//
//  ResultViewController.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/18.
//

import UIKit
import Vision
import SnapKit

protocol ResultViewControllerProtocol {
    func didTapImageView()
}

class ResultViewController: UIViewController, ResultViewControllerProtocol {
    var delegate: ResultViewControllerProtocol?
    
    // MARK: - Properties
    var image: UIImage? {
        didSet {
            guard let image else { return }
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
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .pretendardFont(size: 16, style: .regular)
        
        return $0
    }(UILabel())
    
    lazy var resultLabel: UILabel = {
        $0.textColor = .black
        $0.textAlignment = .center
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
        
        view.addSubview(resultLabel)
        resultLabel.snp.makeConstraints {
            $0.top.equalTo(view.snp.centerY).inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
