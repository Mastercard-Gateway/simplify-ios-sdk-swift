/*
 Copyright (c) 2017 Mastercard
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

enum tokenResult {
    case success
    case failure
}

class ResultViewController: UIViewController {
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    var status : tokenResult = .success
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    func setup() {
//        navBar.tintColor = UIColor(named: "SimplifyOrange")
        switch status {
            case .success:
                barButton.title = "Done"
                labelTitle.text = "Cheers!"
                labelDescription.text = "Thanks for your order.  While you wait, check out our famous \"Nickel Scones.\""
                imageView.image = UIImage(named: "coffeeCupFullBG")
            case .failure:
                barButton.title = "Try Again"
                labelTitle.text = "Uh oh."
                labelDescription.text = "Something went wrong with your order. If you really want to spend a bunch of money, go ahead and try that again."
                imageView.image = UIImage(named: "coffeeCupEmptyFullBG")
            }
    }
    

}
