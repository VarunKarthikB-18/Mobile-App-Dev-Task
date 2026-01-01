//
//  BasicDetailsViewController.swift
//  Mobile-App-Dev-Task
//
//  Created by Varun on 01/01/26.
//


import UIKit

class BasicDetailsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!

    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var othersButton: UIButton!

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!   // 🔥 Restored

    // MARK: - Variables
    var selectedGender: String = "M"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.title = ""
    }

    // MARK: - UI Setup
    func setupUI() {
        styleGenderButtons()
        updateGenderButtons(selected: maleButton)
        setupProgressLabel()
    }

    func styleGenderButtons() {
        [maleButton, femaleButton, othersButton].forEach {
            $0?.layer.cornerRadius = 22
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = UIColor.systemOrange.cgColor
        }
    }

    func setupProgressLabel() {
        let fullText = "2/4"
        let attributed = NSMutableAttributedString(string: fullText)

        attributed.addAttributes([
            .font: UIFont.systemFont(ofSize: 12),
            .baselineOffset: 6,
            .foregroundColor: UIColor.gray
        ], range: NSRange(location: 1, length: 2))

        progressLabel.attributedText = attributed
    }

    func updateGenderButtons(selected: UIButton) {
        [maleButton, femaleButton, othersButton].forEach {
            let isActive = ($0 == selected)
            $0?.backgroundColor = isActive ? .systemOrange : .clear
            $0?.setTitleColor(isActive ? .white : .systemOrange, for: .normal)
        }
    }

    // MARK: - Gender Actions
    @IBAction func maleTapped(_ sender: UIButton) {
        selectedGender = "M"
        updateGenderButtons(selected: maleButton)
    }

    @IBAction func femaleTapped(_ sender: UIButton) {
        selectedGender = "F"
        updateGenderButtons(selected: femaleButton)
    }

    @IBAction func othersTapped(_ sender: UIButton) {
        selectedGender = "O"
        updateGenderButtons(selected: othersButton)
    }

    // MARK: - Next Button Action
    @IBAction func nextTapped(_ sender: UIButton) {

        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let year = yearTextField.text, !year.isEmpty else {
            showAlert(msg: "Please enter all details properly!")
            return
        }

        let payload: [String: Any] = [
            "Name": name,
            "NameUpper": name.uppercased(),
            "PhoneNo": "9876543210",
            "WhatsappNo": "9876543210",
            "CountryCode": "IN",
            "Email": email,
            "Gender": selectedGender,
            "Age": year,
            "AgeUnit": "Y"
        ]

        print("📤 Final Payload →", payload)
        sendRegisterAPI(data: payload)
    }

    // MARK: - API Call (POST)
    func sendRegisterAPI(data: [String: Any]) {
        guard let url = URL(string: "http://199.192.26.248:8000/sap/opu/odata/sap/ZCDS_C_TEST_REGISTER_NEW_CDS/ZCDS_C_TEST_REGISTER_NEW") else {
            print("❌ Invalid POST URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("X", forHTTPHeaderField: "X-Requested-With") // IMPORTANT for SAP

        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("❌ Error:", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            print("📦 Raw Response:", String(data: data, encoding: .utf8) ?? "nil")

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let outer = json["d"] as? [String: Any],
               let doctorID = outer["ID"] as? String {

                print("📌 Doctor GUID Saved:", doctorID)
                UserDefaults.standard.set(doctorID, forKey: "doctorID") // SAVE IT!!

                DispatchQueue.main.async {
                    self.navigateToDashboard()
                }
            } else {
                print("⚠️ Parsing Failed - No ID Found")
            }

        }.resume()
    }


    // MARK: - Navigate to Dashboard
    func navigateToDashboard() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Alerts
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
