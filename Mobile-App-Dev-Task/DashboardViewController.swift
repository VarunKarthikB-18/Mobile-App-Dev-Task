//
//  DashboardViewController.swift
//  Mobile-App-Dev-Task
//
//  Created by Varun on 01/01/26.
//

import UIKit

class DashboardViewController: UIViewController {

    // MARK: - UI Elements

    private let greetingLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Hello,"
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let doctorNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Doctor!"
        lbl.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = .systemOrange
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let greenCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let cardTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Stay Safe"
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let cardSubtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Protect Yourself & Others"
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .white
        lbl.alpha = 0.8
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private let viewAllDoctorsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("View All Doctors", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = .systemOrange
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let featureStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.title = ""

        setupLayout()
        setupFeatureButtons()
        setupActions()
        fetchDoctorDetails()
    }

    // MARK: - Layout Setup

    private func setupLayout() {
        view.addSubview(greetingLabel)
        view.addSubview(doctorNameLabel)
        view.addSubview(greenCardView)
        greenCardView.addSubview(cardTitleLabel)
        greenCardView.addSubview(cardSubtitleLabel)
        view.addSubview(searchBar)
        view.addSubview(viewAllDoctorsButton)
        view.addSubview(featureStackView)

        featureStackView.axis = .vertical
        featureStackView.spacing = 14
        featureStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            doctorNameLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            doctorNameLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),

            greenCardView.topAnchor.constraint(equalTo: doctorNameLabel.bottomAnchor, constant: 20),
            greenCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            greenCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            greenCardView.heightAnchor.constraint(equalToConstant: 110),

            cardTitleLabel.topAnchor.constraint(equalTo: greenCardView.topAnchor, constant: 18),
            cardTitleLabel.leadingAnchor.constraint(equalTo: greenCardView.leadingAnchor, constant: 18),

            cardSubtitleLabel.topAnchor.constraint(equalTo: cardTitleLabel.bottomAnchor, constant: 6),
            cardSubtitleLabel.leadingAnchor.constraint(equalTo: cardTitleLabel.leadingAnchor),

            searchBar.topAnchor.constraint(equalTo: greenCardView.bottomAnchor, constant: 18),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            viewAllDoctorsButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            viewAllDoctorsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            viewAllDoctorsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            viewAllDoctorsButton.heightAnchor.constraint(equalToConstant: 50),

            featureStackView.topAnchor.constraint(equalTo: viewAllDoctorsButton.bottomAnchor, constant: 20),
            featureStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            featureStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    private func setupActions() {
        viewAllDoctorsButton.addTarget(self, action: #selector(openDoctors), for: .touchUpInside)
    }

    @objc private func openDoctors() {
        let vc = DoctorListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Feature Buttons

    private func setupFeatureButtons() {
        let features = [
            "Scan", "Vaccine", "Booking",
            "Clinic", "Ambulance", "Nurse"
        ]

        var rowStack: UIStackView?

        for (index, name) in features.enumerated() {
            if index % 2 == 0 {
                rowStack = UIStackView()
                rowStack?.axis = .horizontal
                rowStack?.distribution = .fillEqually
                rowStack?.spacing = 12
                featureStackView.addArrangedSubview(rowStack!)
            }

            let btn = UIButton(type: .system)
            btn.setTitle(name, for: .normal)
            btn.backgroundColor = .white
            btn.layer.cornerRadius = 12
            btn.layer.shadowOpacity = 0.1
            btn.layer.shadowOffset = CGSize(width: 0, height: 2)
            btn.heightAnchor.constraint(equalToConstant: 80).isActive = true
            rowStack?.addArrangedSubview(btn)
        }
    }

    // MARK: - API GET Doctor Info

    private func fetchDoctorDetails() {
        guard let id = UserDefaults.standard.string(forKey: "doctorID") else {
            print("❌ No doctor ID found")
            return
        }

        let urlString = "http://199.192.26.248:8000/sap/opu/odata/sap/ZCDS_C_TEST_REGISTER_NEW_CDS/ZCDS_C_TEST_REGISTER_NEW(guid'\(id)')"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("X", forHTTPHeaderField: "X-Requested-With")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let d = json["d"] as? [String: Any],
               let name = d["Name"] as? String {
                DispatchQueue.main.async { self.doctorNameLabel.text = "Dr \(name)!" }
            }
        }.resume()
    }
}
