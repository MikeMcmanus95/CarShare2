//
//  ViewController.swift
//  getting-started-ios-sdk
//
//  Created by Smartcar on 11/19/18.
//  Copyright © 2018 Smartcar. All rights reserved.
//
import Alamofire
import UIKit
import SmartcarAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var webViewBG: UIWebView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var vehicleText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let htmlPath = Bundle.main.path(forResource: "WebViewContent", ofType: "html")
        let htmlURL = URL(fileURLWithPath: htmlPath!)
        let html = try? Data(contentsOf: htmlURL)
        
        self.webViewBG.load(html!, mimeType: "text/html", textEncodingName: "UTF-8", baseURL: htmlURL.deletingLastPathComponent())
        // Do any additional setup after loading the view, typically from a nib.
        
        // TODO: Authorization Step 1: Initialize the Smartcar object
        appDelegate.smartcar = SmartcarAuth(
            clientId: Constants.clientId,
            redirectUri: "sc\(Constants.clientId)://exchange",
            development: true,
            completion: completion
        )
        
        // display a button
        let button = UIButton(frame: CGRect(x: 55, y: 300, width: 250, height: 50))
        button.addTarget(self, action: #selector(self.connectPressed(_:)), for: .touchUpInside)
        button.setTitle("Unlock Vehicle", for: .normal)
        button.backgroundColor = .darkGray
        button.alpha = 0.9
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(button)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectPressed(_ sender: UIButton) {
        let smartcar = appDelegate.smartcar!
        smartcar.launchAuthFlow(viewController: self)
        
    }
    
    func completion(err: Error?, code: String?, state: String?) -> Any {
        // TODO: Authorization Step 3b: Receive an authorization code
        print("----CODE----")
        print(code!);
        print("----CODE----")
        
        // TODO: Request Step 1: Obtain an access token
        
        Alamofire.request("\(Constants.appServer)/exchange?code=\(code!)", method: .get)
            .responseJSON {_ in}
        
        // TODO: Request Step 2: Get vehicle information
        Alamofire.request("\(Constants.appServer)/vehicle", method: .get).responseJSON { response in
            
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                
                let make = JSON.object(forKey: "make")!  as! String
                let model = JSON.object(forKey: "model")!  as! String
                let year = String(JSON.object(forKey: "year")!  as! Int)
                
                let vehicle = "\(year) \(make) \(model)"
                self.vehicleText = vehicle
                
                self.performSegue(withIdentifier: "displayVehicleInfo", sender: self)
                //print(response.result.value!)
            }
        }
        
        return ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? InfoViewController {
            destinationVC.text = self.vehicleText
        }
    }
    
}
