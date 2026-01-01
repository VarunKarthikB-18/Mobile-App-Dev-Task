//
//  DoctorListViewController.swift
//  Mobile-App-Dev-Task
//
//  Created by Varun on 01/01/26.
//

import UIKit

struct DoctorModel {
    let id: String
    let name: String
    let email: String
    let gender: String
}

class DoctorListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var myDoctor: DoctorModel?
    private var allDoctors: [DoctorModel] = []

    private let tableView = UITableView()

    private let myCardView = UIView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let genderLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Doctors List"

        setupProfileCardUI()
        setupTableView()
        fetchAllDoctors()
    }

    // MARK: - UI Setup

    private func setupProfileCardUI() {
        myCardView.backgroundColor = .secondarySystemBackground
        myCardView.layer.cornerRadius = 14
        myCardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myCardView)

        [nameLabel, emailLabel, genderLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            myCardView.addSubview($0)
        }

        nameLabel.font = .boldSystemFont(ofSize: 24)
        emailLabel.font = .systemFont(ofSize: 16)
        genderLabel.font = .systemFont(ofSize: 16)

        NSLayoutConstraint.activate([
            myCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            myCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            myCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),

            nameLabel.topAnchor.constraint(equalTo: myCardView.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: myCardView.leadingAnchor, constant: 14),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            genderLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 6),
            genderLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            genderLabel.bottomAnchor.constraint(equalTo: myCardView.bottomAnchor, constant: -14)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: myCardView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - API

    private func fetchAllDoctors() {
        guard let url = URL(string:
            "http://199.192.26.248:8000/sap/opu/odata/sap/ZCDS_C_TEST_REGISTER_NEW_CDS/ZCDS_C_TEST_REGISTER_NEW"
        ) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("X", forHTTPHeaderField: "X-Requested-With")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let d = json["d"] as? [String: Any],
               let results = d["results"] as? [[String: Any]] {

                let myID = UserDefaults.standard.string(forKey: "doctorID") ?? ""

                self.allDoctors = results.compactMap { dict in
                    guard let id = dict["ID"] as? String,
                          let name = dict["Name"] as? String,
                          let mail = dict["Email"] as? String,
                          let gender = dict["Gender"] as? String else { return nil }
                    return DoctorModel(id: id, name: name, email: mail, gender: gender)
                }

                self.myDoctor = self.allDoctors.first(where: { $0.id == myID })
                self.allDoctors = self.allDoctors.filter { $0.id != myID }

                DispatchQueue.main.async {
                    self.updateMyCard()
                    self.tableView.reloadData()
                }
            }
        }.resume()
    }

    private func updateMyCard() {
        guard let doc = myDoctor else { return }
        nameLabel.text = "Dr \(doc.name)"
        emailLabel.text = "📧 \(doc.email)"
        genderLabel.text = "⚥ \(doc.gender)"
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allDoctors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let doc = allDoctors[indexPath.row]
        cell.textLabel?.text = "Dr \(doc.name) (\(doc.gender))\n\(doc.email)"
        cell.textLabel?.numberOfLines = 2
        return cell
    }
}
