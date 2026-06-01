//
//  ViewController.swift
//  pw26
//
//  Created by Hugh Hopkins on 04/02/2017.
//  Copyright © 2020 io.pwapp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // V1 bad-security site lists (only used in V1 mode)
    let sitesThatPraticeBadSecruity = ["apple", "lloyds", "bank", "nike", "tesco", "easyjet", "glassdoor", "spearfishingstore", "europcar", "tsb", "hsbc", "rbs", "barclays", "expedia", "three", "nexmo", "wechat", "line", "natwest"]
    let sitesThatPraticeBetterSecruity = ["zendesk"]

    // UI copy buttons (from storyboard)
    @IBOutlet weak var buttonCopyNormal: UIButton!
    @IBOutlet weak var buttonCopy15CharYes: UIButton!
    @IBOutlet weak var buttonCopySpecialChar: UIButton!
    @IBOutlet weak var buttonWebsiteLink: UIButton!

    // Version switcher (programmatic)
    private let versionSegment = UISegmentedControl(items: ["V1", "V2"])
    private let emojiLabel = UILabel()

    // Persisted version preference
    var currentVersion: PWVersion {
        get { PWVersion(rawValue: UserDefaults.standard.integer(forKey: "pwVersion")) ?? .v1 }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "pwVersion") }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showHide()
        showHideLink()

        // little touches
        serviceInput.autocorrectionType = UITextAutocorrectionType.no
        serviceInput.autocapitalizationType = UITextAutocapitalizationType.none
        serviceInput.spellCheckingType = UITextSpellCheckingType.no
        passwordInput.autocorrectionType = UITextAutocorrectionType.no
        passwordInput.autocapitalizationType = UITextAutocapitalizationType.none
        passwordInput.spellCheckingType = UITextSpellCheckingType.no
        passwordInput.isSecureTextEntry = true

        buttonCopyNormal.layer.cornerRadius = 5
        buttonCopy15CharYes.layer.cornerRadius = 5
        buttonCopySpecialChar.layer.cornerRadius = 5
        buttonWebsiteLink.layer.cornerRadius = 5

        serviceInput.layer.cornerRadius = 5
        serviceInput.clipsToBounds = true
        passwordInput.layer.cornerRadius = 5
        passwordInput.clipsToBounds = true

        setupVersionSegment()
        setupEmojiLabel()
        applyVersionAppearance(animated: false)
    }

    // MARK: - Version Switcher Setup

    private func setupVersionSegment() {
        versionSegment.selectedSegmentIndex = currentVersion.rawValue
        versionSegment.addTarget(self, action: #selector(versionChanged), for: .valueChanged)
        versionSegment.translatesAutoresizingMaskIntoConstraints = false
        versionSegment.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        versionSegment.tintColor = .white
        if #available(iOS 13.0, *) {
            versionSegment.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.4)
            versionSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
            versionSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        }
        view.addSubview(versionSegment)

        NSLayoutConstraint.activate([
            versionSegment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            versionSegment.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            versionSegment.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func setupEmojiLabel() {
        emojiLabel.font = UIFont.systemFont(ofSize: 24)
        emojiLabel.textAlignment = .right
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emojiLabel)

        NSLayoutConstraint.activate([
            emojiLabel.centerYAnchor.constraint(equalTo: versionSegment.centerYAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    @objc private func versionChanged() {
        currentVersion = PWVersion(rawValue: versionSegment.selectedSegmentIndex) ?? .v1
        applyVersionAppearance(animated: true)
        update()
    }

    private var gradientLayer: CAGradientLayer?

    private func applyVersionAppearance(animated: Bool) {
        let v1Color = UIColor(red: 0.45, green: 0.20, blue: 0.65, alpha: 1.0) // purple

        if currentVersion == .v1 {
            // V1: flat purple, remove gradient
            if animated {
                UIView.animate(withDuration: 0.3) {
                    self.gradientLayer?.opacity = 0
                    self.view.backgroundColor = v1Color
                }
            } else {
                gradientLayer?.opacity = 0
                view.backgroundColor = v1Color
            }
        } else {
            // V2: sunset gradient - midnight blue top, warm amber glow bottom
            view.backgroundColor = .black
            if gradientLayer == nil {
                let gl = CAGradientLayer()
                gl.frame = view.bounds
                view.layer.insertSublayer(gl, at: 0)
                gradientLayer = gl
            }
            gradientLayer?.frame = view.bounds
            gradientLayer?.colors = [
                UIColor(red: 0.06, green: 0.07, blue: 0.18, alpha: 1.0).cgColor, // deep midnight
                UIColor(red: 0.12, green: 0.10, blue: 0.30, alpha: 1.0).cgColor, // dark indigo
                UIColor(red: 0.35, green: 0.15, blue: 0.30, alpha: 1.0).cgColor, // dusky purple
                UIColor(red: 0.65, green: 0.25, blue: 0.15, alpha: 1.0).cgColor, // warm amber
            ]
            gradientLayer?.locations = [0.0, 0.35, 0.7, 1.0]

            if animated {
                let fade = CABasicAnimation(keyPath: "opacity")
                fade.fromValue = 0
                fade.toValue = 1
                fade.duration = 0.3
                gradientLayer?.add(fade, forKey: "fadeIn")
            }
            gradientLayer?.opacity = 1
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // UI
    @IBOutlet weak var serviceInput: UITextField!
    @IBAction func serviceInputEdit(_ sender: Any) {
        update()
    }

    @IBOutlet weak var passwordInput: UITextField!
    @IBAction func passwordInputEdit(_ sender: Any) {
        update()
    }

    @IBOutlet weak var pwOutput: UILabel!

    // PW code
    var pwNew: String = ""
    var shorterPW: String = ""
    var shorterPWCopy: String = ""
    var specialCharPW: String = ""
    var specialCharPWCopy: String = ""

    // to do clean all of this up
    // to do play around with text colour change
    var shortershortPW: String = ""
    var restOfThePW: String = ""
    var normalPWToBeCopiedToClipboard = ""

    func update() {
        showHide()
        showHideLink()

        let srv: String = serviceInput.text!
        let pass: String = passwordInput.text!

        if srv.isEmpty && pass.isEmpty {
            emojiLabel.text = ""
            return
        }

        let result = PWHasher.hash(service: srv, password: pass, version: currentVersion)
        normalPWToBeCopiedToClipboard = result

        if currentVersion == .v1 {
            pwNew = result
            pwTextFormatting()
            emojiLabel.text = ""
        } else {
            pwOutput.text = result
            emojiLabel.text = PWHasher.emojiCue(service: srv, password: pass)
        }
    }

    func pwTextFormatting () {
        normalPWToBeCopiedToClipboard = pwNew

        shortershortPW = String(pwNew.prefix(15))
        restOfThePW = String(pwNew.suffix(25))
        if sitesThatPraticeBadSecruity.contains(serviceInput.text!.lowercased()) {
            pwOutput.text = "\(shortershortPW)" + "  " + "\(restOfThePW)"
        } else if sitesThatPraticeBetterSecruity.contains(serviceInput.text!.lowercased()) {
            pwOutput.text = "\(pwNew)" + " (*)"
        } else {
            pwOutput.text = pwNew
        }
    }

    func pwRefresh() {
        pwNew = ""
    }

    // buttons
    @IBAction func copyNormal(_ sender: Any) {
        UIPasteboard.general.string = normalPWToBeCopiedToClipboard
        animateCopy(button: buttonCopyNormal, originalTitle: "  Copy PW  ")
    }

    @IBAction func copy15CharYes(_ sender: Any) {
        shorterPW = pwOutput.text!
        shorterPWCopy = String(shorterPW.prefix(15))
        UIPasteboard.general.string = shorterPWCopy
        animateCopy(button: buttonCopy15CharYes, originalTitle: "  Copy 15 Character PW  ")
    }

    @IBAction func copySpecialChar(_ sender: Any) {
        specialCharPW = pwOutput.text!
        specialCharPWCopy = "\(specialCharPW)" + "*"
        animateCopy(button: buttonCopySpecialChar, originalTitle: "  Copy PW with Special * Character  ")
    }

    private func animateCopy(button: UIButton, originalTitle: String) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        button.setTitle("  Copied ✓  ", for: .normal)
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            button.setTitle(originalTitle, for: .normal)
        }
    }

    @IBAction func websiteLink(_ sender: Any) {
        if let url = URL(string: "https://pwapp.io/?utm_source=iOS&utm_medium=link&utm_content=footer&utm_campaign=iOS") {
            UIApplication.shared.open(url)
        }
    }

    // Show / hide different UI elements
    func showHide () {
        if serviceInput.text! == "" && passwordInput.text! == "" {
            // When the text field is blank
            pwOutput.isHidden = true
            buttonCopyNormal.isHidden = true
            buttonCopy15CharYes.isHidden = true
            buttonCopySpecialChar.isHidden = true
        } else if currentVersion == .v2 {
            // V2: show output, copy and copy 15 only (special char is baked in)
            pwOutput.isHidden = false
            buttonCopyNormal.isHidden = false
            buttonCopy15CharYes.isHidden = false
            buttonCopySpecialChar.isHidden = true
        } else if sitesThatPraticeBadSecruity.contains(serviceInput.text!.lowercased()) {
            // V1: when it should show the 15 character option
            buttonCopyNormal.isHidden = false
            buttonCopy15CharYes.isHidden = false
        } else if sitesThatPraticeBetterSecruity.contains(serviceInput.text!.lowercased()) {
            // V1: when it should be a special character
            buttonCopyNormal.isHidden = false
            buttonCopySpecialChar.isHidden = false
        } else {
            // V1: normal
            pwOutput.isHidden = false
            buttonCopyNormal.isHidden = false
            buttonCopy15CharYes.isHidden = false
            buttonCopySpecialChar.isHidden = true
        }
    }

    // todo hide buttonWebsiteLink on iPhone 5 SE
    func showHideLink () {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            buttonWebsiteLink.isHidden = true
        } else {
            buttonWebsiteLink.isHidden = false
        }
    }

// end
}
