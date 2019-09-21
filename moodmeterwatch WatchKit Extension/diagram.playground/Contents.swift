//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
		label.text = "Hello World!"
		label.textColor = .black
		let frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        
        view.addSubview(label)
		let diag = getDiagram(frame:frame)
		//self.view.frame = frame
        self.view = UIImageView(image: diag!)
    }
	
	func getDiagram(frame: CGRect) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(frame.size, false, 1);
		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(CGColor.init(srgbRed: 1, green: 0, blue: 1, alpha: 1))
		context?.fill(frame)
		
		let axisColor: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		axisColor.setStroke()
		let xAxis = UIBezierPath()
		xAxis.move(to: CGPoint(x:0, y:frame.height-2))
		xAxis.addLine(to: CGPoint(x:frame.width, y:frame.height-2))
		xAxis.lineWidth = 1;
		xAxis.stroke()
		
		let tickHeight = frame.height/5.0
		for i in 1...5 {
			let tick = UIBezierPath()
			xAxis.move(to: CGPoint(x:0, y: CGFloat(i)*tickHeight))
			xAxis.addLine(to: CGPoint(x:10, y:CGFloat(i)*tickHeight))
			tick.stroke()
		}
		let yAxis = UIBezierPath()
		yAxis.move(to: CGPoint(x:1, y:0))
		yAxis.addLine(to: CGPoint(x:1, y:frame.height-2))
		yAxis.lineWidth = 1;
		yAxis.stroke()
		
		let strokeColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
		strokeColor.setStroke()
		let path = UIBezierPath()
		path.move(to: CGPoint(x:0,y:0))
		path.addLine(to: CGPoint(x:30,y:30))
		path.addLine(to: CGPoint(x:20,y:70))
		path.lineWidth = 2;
		path.stroke()
		
		let image2 = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return image2
	}
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
