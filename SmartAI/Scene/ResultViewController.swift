//
//  ResultViewController.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/18.
//

import UIKit
import CoreML

import SnapKit
import Vision

class ResultViewController: UIViewController {
    // MARK: - Properties
    var image: UIImage?
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
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("🚨 \(error?.localizedDescription)")
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
        
            if classifications.isEmpty {
                print("🚨 결과를 추출했지만 비어있어요.")
            } else {
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    
                   return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                
                print("🍕 \(descriptions.joined(separator: "\n"))")
            }
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        configureUI()
    }
    
    // MARK: - UIComponents
    lazy var resultLabel: UILabel = {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .pretendardFont(size: 22, style: .medium)
        
        return $0
    }(UILabel())
}

extension ResultViewController {
    func configureUI() {
        view.addSubview(resultLabel)
        resultLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(50)
        }
    }
}
