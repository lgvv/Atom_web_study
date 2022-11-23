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
import RxSwift
import RxCocoa

protocol ResultViewControllerProtocol {
    func didTapMoreInfoButton(bananaData: [ChartInfo])
}

class ResultViewController: UIViewController, ResultViewControllerProtocol {
    var disposeBag = DisposeBag()
    var delegate: ResultViewControllerProtocol?
    
    // MARK: - Properties
    /** 로컬 바나나 정보 */ var localBananaInfo: ChartInfo?
    /** 서버 바나나 정보 */ var serverBananaInfo: ChartInfo?
    var bananaData: [ChartInfo] = []

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
                        var infos: [BananaChartInfo] = []
                        
                        banana.bananaClasses.forEach { key, value in
                            if let probability = banana.probability[key] {
                                let string = String(format: "%.2f %@\n", probability, value)
                                let items = string.split(separator: " ").map { String($0) }
                                
                                let info = BananaChartInfo(name: items[0], probability: items[1])
                                infos.append(info)
                            }
                        }
                        
                        self.bananaData.append(.init(type: "CNN", bananas: infos))
                        
                    case .failure(let error):
                        print("🚨 \(error.localizedDescription)")
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
    
    // MARK: - Binding
    func bind() {
        disposeBag.insert {
            moreInfoButton.rx.tap
                .withUnretained(self)
                .bind { this, _ in
                    this.didTapMoreInfoButton(bananaData: this.bananaData)
                }
        }
    }
    
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
                    return String(format: "%.2f %@", classification.confidence, classification.identifier)
                }
                dump(" ❄️: \(descriptions)")
                
                let infos = descriptions.map { description in
                    let items = description.split(separator: " ").map { String($0) }
                    return BananaChartInfo(name: items[0], probability: items[1])
                }
                
                self.bananaData.append(.init(type: "CoreML", bananas: infos))
                
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
    
    func didTapMoreInfoButton(bananaData: [ChartInfo]) {
        print("didTapImageView")
        
        // BUGFIX: - 🚨 코디네이터 delegate가 전달이 안됩니다.
//        self.delegate?.didTapMoreInfoButton(bananaData: bananaData)
        let chartView = ChartView(bananaData: bananaData)
        let vc = UIHostingController(rootView: chartView)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configureUI()
        bind()
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
    
    lazy var resultLabel: UILabel = {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .pretendardFont(size: 30, style: .medium)
        
        return $0
    }(UILabel())
    
    lazy var moreInfoButton: UIButton = {
        let mainText = "더 자세한 결과 확인하기 👉"
        let subText = "📡 서버 통신이 원활한 경우에만 확인하실 수 있습니다."
        let text = """
        \(mainText)
        
        \(subText)
        """
        
        let mainFont = UIFont.pretendardFont(size: 20, style: .bold)
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.font,
                                      value: mainFont,
                                      range: (text as NSString).range(of: mainText))
        
        let subFont = UIFont.pretendardFont(size: 12, style: .regular)
        attributedString.addAttribute(.font,
                                      value: subFont,
                                      range: (text as NSString).range(of: subText))
        
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.numberOfLines = 0
        $0.titleLabel?.text = text
        $0.setTitleColor(.black, for: .normal)
        $0.setAttributedTitle(attributedString, for: .normal)
        
        $0.layer.backgroundColor = UIColor.green.cgColor
        $0.layer.borderWidth = 4
        $0.layer.cornerRadius = 12
        $0.alpha = 0.0
        return $0
    }(UIButton())
}

extension ResultViewController {
    func configureUI() {
        view.addSubview(moreInfoButton)
        moreInfoButton.snp.makeConstraints {
            $0.top.equalTo(view.snp.centerY).inset(40)
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(resultImageView)
        resultImageView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview().inset(20)
            $0.height.equalTo(view.frame.width - 40)
        }
        
        resultImageView.addSubview(answerLabel)
        answerLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

extension ResultViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        guard let type = sheetPresentationController.selectedDetentIdentifier else { return }
        
        switch type {
        case .medium:
            UIView.animate(withDuration: 0.3) {
                self.moreInfoButton.alpha = 0.0
            }
        case .large:
            UIView.animate(withDuration: 0.3) {
                self.moreInfoButton.alpha = 1.0
            }
        default: assert(true ,"지원하지 않는 옵션입니다")
        }
        
        print(type == .large ? "large" : "medium")
    }
}
