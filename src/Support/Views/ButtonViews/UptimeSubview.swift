//
//  UptimeSubview.swift
//  Support
//
//  Created by Jordy Witteman on 17/03/2021.
//

import SwiftUI

struct UptimeSubview: View {
    
    // Get  computer info from functions in class
    @EnvironmentObject var computerinfo: ComputerInfo
    
    // Get preferences or default values
    @StateObject var preferences = Preferences()
    
    // Make UserDefaults easy to use
    let defaults = UserDefaults.standard
    
    // Dark Mode detection
    @Environment(\.colorScheme) var colorScheme
    
    // Boolean to show uptime alert when clicked
    @State var uptimeAlert: Bool = false
    
    // Set the custom color for all symbols depending on Light or Dark Mode.
    var customColor: String {
        if colorScheme == .light && defaults.string(forKey: "CustomColor") != nil {
            return preferences.customColor
        } else if colorScheme == .dark && defaults.string(forKey: "CustomColorDarkMode") != nil {
            return preferences.customColorDarkMode
        } else {
            return preferences.customColor
        }
    }
    
    // Enable hover effect and tap gesture when UptimeDaysLimit is configured
    var hoverEffectEnabled: Bool {
        if preferences.uptimeDaysLimit > 0 {
            return true
        } else {
            return false
        }
    }
    
    // Set different alert text when UptimeDaysLimit is set to 1
    var alertText: String {
        if preferences.uptimeDaysLimit > 1 {
           return NSLocalizedString("ADMIN_RECOMMENDS_RESTARTING_EVERY", comment: "") + " \(preferences.uptimeDaysLimit)" + NSLocalizedString(" days", comment: "")
        } else {
            return NSLocalizedString("ADMIN_RECOMMENDS_RESTARTING_EVERY", comment: "") + NSLocalizedString(" day", comment: "")
        }
    }
    
    var body: some View {
        
        if hoverEffectEnabled {
            InfoItem(title: NSLocalizedString("Last Reboot", comment: ""), subtitle: "\(computerinfo.uptimeRounded) \(computerinfo.uptimeText) " + NSLocalizedString("ago", comment: ""), image: "clock.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadge: computerinfo.uptimeLimitReached, hoverEffectEnable: true)
                .modify {
                    if #available(macOS 13, *) {
                        // Show Popover within NSPopover on macOS 13 or later because behaviour with standard alerts is changed when main popover is marked as transient, causing the NSPopover to lose focus and closes both the NSPopover and Alert
                        $0.popover(isPresented: $uptimeAlert, arrowEdge: .leading) {
                            PopoverAlertView(uptimeAlert: $uptimeAlert, title: NSLocalizedString("RESTART_REGULARLY", comment: ""), message: alertText)
                                .interactiveDismissDisabled(true)
                        }
                    } else {
                        $0.alert(isPresented: $uptimeAlert) {
                            Alert(title: Text(NSLocalizedString("RESTART_REGULARLY", comment: "")), message: Text(alertText), dismissButton: .default(Text("OK")))
                        }
                    }
                }
                .onTapGesture {
                    if hoverEffectEnabled {
                        self.uptimeAlert.toggle()
                    }
                }
        } else {
            InfoItem(title: NSLocalizedString("Last Reboot", comment: ""), subtitle: "\(computerinfo.uptimeRounded) \(computerinfo.uptimeText) " + NSLocalizedString("ago", comment: ""), image: "clock.fill", symbolColor: Color(NSColor(hex: "\(customColor)") ?? NSColor.controlAccentColor), notificationBadge: false, hoverEffectEnable: false)
        }
    }
}

struct UptimeSubview_Previews: PreviewProvider {
    static var previews: some View {
        UptimeSubview()
    }
}
