//
//  PieProgressView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/17.
//

import UIKit


class PieProgressView: UIView {
    
    /// progress가 업데이트될 때마다 채워지는 pie의 layer
    private var progressLayer = CAShapeLayer().then {
        $0.strokeEnd = 0
    }
    
    /// 원의 테두리를 나타내는 layer
    private var borderLayer = CAShapeLayer().then {
        $0.lineWidth = 3
        $0.strokeEnd = 1
    }
    
    /// progress가 업데이트될 때 진행되는 애니메이션의 길이
    var animationDuration = 0.2
    
    /// pie의 채워지는 부분과 테두리의 색
    var progressColor = UIColor(r: 250, g: 120, b: 123)
    
    /// pie의 비어있는 부분을 채우는 색
    var trackColor = UIColor(r: 240, g: 239, b: 240)
    
    /// progress 진행 값으로 0~1 사이의 값
    var progress: Double = 0 {
        didSet{
            let path: Double = {
                let value = progress - oldValue
                return value < 0 ? -value : value
            }()
            
            setProgress(duration: animationDuration * Double(path), to: progress)
        }
    }
    
    
    // MARK: - init
    init(frame: CGRect, progressColor: UIColor, trackColor: UIColor, progress: Double = 0) {
        super.init(frame: frame)
        
        self.progress = progress
        self.progressColor = progressColor
        self.backgroundColor = .clear
        layer.cornerRadius = frame.size.width / 2
        addPieProgressLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - helpers
    /// pie를 그리는 borderLayer, progressLayer를 추가해줍니다.
    private func addPieProgressLayers(){
        let borderLayerPath = UIBezierPath(arcCenter: center,
                                           radius: frame.width / 2 + 11,
                                           startAngle: CGFloat(-0.5 * .pi),
                                           endAngle: CGFloat(1.5 * .pi),
                                           clockwise: true)
        
        borderLayer.fillColor = trackColor.cgColor
        borderLayer.path = borderLayerPath.cgPath
        borderLayer.strokeColor = progressColor.cgColor
        layer.addSublayer(borderLayer)
        
        let progressLayerPath = UIBezierPath(arcCenter: center,
                                             radius: frame.width / 2,
                                             startAngle: CGFloat(-0.5 * .pi),
                                             endAngle: CGFloat(1.5 * .pi),
                                             clockwise: true)
        
        progressLayer.path = progressLayerPath.cgPath
        progressLayer.fillColor = trackColor.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = frame.width
        layer.addSublayer(progressLayer)
    }
    
    /// progress 값이 업데이트되면 실행되는 함수로 pie 애니메이션이 실행됩니다.
    private func setProgress(duration: TimeInterval, to newProgress: Double) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress
        
        progressLayer.strokeEnd = CGFloat(newProgress)
        progressLayer.add(animation, forKey: "animationProgress")
    }
}
