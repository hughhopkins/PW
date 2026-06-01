//
//  ViewController.swift
//  PW
//
//  Created by hugh on 04/03/2016.
//  Copyright © 2016 hugh. All rights reserved.
//

import Cocoa
import CommonCrypto

class ViewController: NSViewController {

    @IBOutlet weak var pwOutput: NSTextField!
    @IBOutlet weak var serviceInput: NSTextField!
    @IBOutlet weak var passwordInput: NSTextField!

    private var versionSegment: NSSegmentedControl!
    private var emojiLabel: NSTextField!
    private var gradientView: NSView?
    private var autoCopyCheckbox: NSButton!
    private var copy15Button: NSButton!
    private var copyFullButton: NSButton!

    private var lastCopiedResult: String = ""
    private var copy15Override: Bool = false

    var currentVersion: PWVersion {
        get { return PWVersion(rawValue: UserDefaults.standard.integer(forKey: "pwVersion")) ?? .v1 }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "pwVersion") }
    }

    var autoCopyEnabled: Bool {
        get {
            // Default to true for backwards compat with original behavior
            if UserDefaults.standard.object(forKey: "autoCopy") == nil { return true }
            return UserDefaults.standard.bool(forKey: "autoCopy")
        }
        set { UserDefaults.standard.set(newValue, forKey: "autoCopy") }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordInput.delegate = self
        serviceInput.delegate = self

        // Disable text services to prevent ViewBridge errors
        for field in [serviceInput!, passwordInput!] {
            if #available(macOS 10.12.2, *) {
                field.isAutomaticTextCompletionEnabled = false
            }
            if #available(macOS 11.0, *) {
                field.contentType = NSTextContentType(rawValue: "")
            }
        }

        setupVersionSegment()
        setupEmojiLabel()
        setupGradientView()
        setupCopy15Button()
        setupCopyFullButton()
        setupAutoCopyCheckbox()
        applyVersionAppearance()

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.autoUpdate()
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        // Disable window restoration early to prevent className=(null) error
        view.window?.isRestorable = false
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(serviceInput)
    }

    // MARK: - UI Setup

    private func setupVersionSegment() {
        let seg = NSSegmentedControl()
        seg.segmentCount = 2
        seg.setLabel("V1", forSegment: 0)
        seg.setLabel("V2", forSegment: 1)
        seg.selectedSegment = currentVersion.rawValue
        seg.target = self
        seg.action = #selector(versionChanged)
        seg.sizeToFit()
        seg.frame.origin = NSPoint(x: 12, y: 236)

        // Shortcut hints in smaller grey text beside the switcher
        let hint = NSTextField(labelWithString: "⌘1 / ⌘2")
        hint.font = NSFont.systemFont(ofSize: 10)
        hint.textColor = NSColor.white.withAlphaComponent(0.4)
        hint.isBezeled = false
        hint.drawsBackground = false
        hint.isEditable = false
        hint.isSelectable = false
        hint.sizeToFit()
        hint.frame.origin = NSPoint(x: seg.frame.maxX + 6, y: 240)
        hint.autoresizingMask = [.minYMargin]
        view.addSubview(hint)
        seg.autoresizingMask = [.minYMargin]
        view.addSubview(seg)
        versionSegment = seg

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, event.modifierFlags.contains(.command) else { return event }
            let chars = event.charactersIgnoringModifiers ?? ""
            if chars == "1" {
                self.versionSegment.selectedSegment = 0
                self.versionChanged()
                return nil
            } else if chars == "2" {
                self.versionSegment.selectedSegment = 1
                self.versionChanged()
                return nil
            } else if chars == "C" && event.modifierFlags.contains(.shift) {
                // Cmd+Shift+C = copy 15
                self.copy15()
                return nil
            }
            return event
        }
    }

    private func setupEmojiLabel() {
        let label = NSTextField(labelWithString: "")
        label.font = NSFont.systemFont(ofSize: 20)
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .right
        label.textColor = .white
        label.frame = NSRect(x: 370, y: 234, width: 100, height: 28)
        label.autoresizingMask = [.minYMargin, .minXMargin]
        view.addSubview(label)
        emojiLabel = label
    }

    private func setupGradientView() {
        let gv = NSView(frame: view.bounds)
        gv.wantsLayer = true
        gv.autoresizingMask = [.width, .height]

        let gradient = CAGradientLayer()
        gradient.frame = gv.bounds
        gradient.colors = [
            NSColor(red: 0.06, green: 0.07, blue: 0.18, alpha: 1.0).cgColor,
            NSColor(red: 0.12, green: 0.10, blue: 0.30, alpha: 1.0).cgColor,
            NSColor(red: 0.35, green: 0.15, blue: 0.30, alpha: 1.0).cgColor,
            NSColor(red: 0.65, green: 0.25, blue: 0.15, alpha: 1.0).cgColor,
        ]
        gradient.locations = [0.0, 0.35, 0.7, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        gv.layer = gradient

        view.addSubview(gv, positioned: .above, relativeTo: view.subviews.first)
        gradientView = gv
    }

    private func setupCopy15Button() {
        let btn = NSButton(title: "Copy 15  ⇧⌘C", target: self, action: #selector(copy15Clicked))
        btn.bezelStyle = .rounded
        btn.frame = NSRect(x: 310, y: 8, width: 150, height: 24)
        btn.autoresizingMask = [.minYMargin]
        view.addSubview(btn)
        copy15Button = btn
    }

    private func setupCopyFullButton() {
        let btn = NSButton(title: "Copy Full PW", target: self, action: #selector(copyFullClicked))
        btn.bezelStyle = .rounded
        btn.frame = NSRect(x: 148, y: 8, width: 148, height: 24)
        btn.autoresizingMask = [.minYMargin]
        view.addSubview(btn)
        copyFullButton = btn
        updateCopyFullButtonVisibility()
    }

    private func updateCopyFullButtonVisibility() {
        copyFullButton.isHidden = autoCopyEnabled && !copy15Override
    }

    private func setupAutoCopyCheckbox() {
        let cb = NSButton(checkboxWithTitle: "Auto-copy", target: self, action: #selector(autoCopyToggled))
        cb.state = autoCopyEnabled ? .on : .off
        cb.frame = NSRect(x: 18, y: 8, width: 120, height: 20)
        cb.autoresizingMask = [.minYMargin]
        // Style for visibility on colored backgrounds
        if let cell = cb.cell as? NSButtonCell {
            cell.attributedTitle = NSAttributedString(
                string: "Auto-copy",
                attributes: [.foregroundColor: NSColor.white.withAlphaComponent(0.8),
                             .font: NSFont.systemFont(ofSize: 11)]
            )
        }
        view.addSubview(cb)
        autoCopyCheckbox = cb
    }

    // MARK: - Actions

    @objc private func versionChanged() {
        currentVersion = PWVersion(rawValue: versionSegment.selectedSegment) ?? .v1
        applyVersionAppearance()
        autoUpdate()
    }

    @objc private func autoCopyToggled() {
        autoCopyEnabled = autoCopyCheckbox.state == .on
        updateCopyFullButtonVisibility()
    }

    @objc private func copyFullClicked() {
        let output = pwOutput.stringValue
        guard !output.isEmpty else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(output, forType: .string)
        lastCopiedResult = output
        copy15Override = false
        updateCopyFullButtonVisibility()

        copyFullButton.highlight(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.copyFullButton.highlight(false)
        }
    }

    @objc private func copy15Clicked() {
        copy15()
    }

    private func copy15() {
        let output = pwOutput.stringValue
        guard !output.isEmpty else { return }
        let short = String(output.prefix(15))
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(short, forType: .string)

        copy15Override = true
        updateCopyFullButtonVisibility()

        // Flash the button to show the shortcut worked
        copy15Button.highlight(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.copy15Button.highlight(false)
        }
    }

    private func copyFullToClipboard(_ text: String) {
        guard autoCopyEnabled else { return }
        guard NSApp.isActive else { return }
        guard !text.isEmpty else { return }
        // Only copy if the result changed (avoid clearing clipboard repeatedly)
        guard text != lastCopiedResult else { return }
        lastCopiedResult = text
        copy15Override = false
        updateCopyFullButtonVisibility()

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    // MARK: - Appearance

    private func applyVersionAppearance() {
        if currentVersion == .v1 {
            gradientView?.isHidden = true
            emojiLabel.stringValue = ""
        } else {
            gradientView?.isHidden = false
        }
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        if let gv = gradientView, let gradient = gv.layer as? CAGradientLayer {
            gradient.frame = gv.bounds
        }
    }

    // MARK: - Password Generation

    func autoUpdate() {
        let srv = serviceInput.stringValue
        let pass = passwordInput.stringValue

        if srv.isEmpty && pass.isEmpty {
            pwOutput.stringValue = ""
            emojiLabel.stringValue = ""
            lastCopiedResult = ""
            return
        }

        let result = PWHasher.hash(service: srv, password: pass, version: currentVersion)
        pwOutput.stringValue = result

        if currentVersion == .v2 {
            emojiLabel.stringValue = PWHasher.emojiCue(service: srv, password: pass)
        } else {
            emojiLabel.stringValue = ""
        }

        copyFullToClipboard(result)
    }
}

// MARK: - Text Field Delegate

extension ViewController: NSTextFieldDelegate {

    override func controlTextDidEndEditing(_ obj: Notification) {
        // When a field loses focus (e.g. Tab pressed), reset lastCopiedResult
        // so autoUpdate re-copies the password to the clipboard
        lastCopiedResult = ""
    }
}
