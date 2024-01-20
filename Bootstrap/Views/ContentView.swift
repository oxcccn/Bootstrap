//
//  ContentView.swift
//  BootstrapUI
//
//  Created by haxi0 on 21.12.2023.
//

import SwiftUI
import FluidGradient

@objc class SwiftUIViewWrapper: NSObject {
    @objc static func createSwiftUIView() -> UIViewController {
        let viewController = UIHostingController(rootView: ContentView())
        return viewController
    }
}

struct ContentView: View {
    @State var LogItems: [String.SubSequence] = {
        return [""]
    }()
    
    @State private var showOptions = false
    @State private var showCredits = false
    @State private var showAppView = false
    @State private var strapButtonDisabled = false
    @State private var newVersionAvailable = false
    @State private var newVersionReleaseURL:String = ""
    @State private var tweakEnable: Bool = !isSystemBootstrapped() || FileManager.default.fileExists(atPath: jbroot("/var/mobile/.tweakenabled"))
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    var body: some View {
        ZStack {
            FluidGradient(blobs: [.red,Color.purple],
                          highlights: [Color.purple, .yellow],
                          speed: 0.5,
                          blur: 0.95)
            .background(.quaternary)
            .ignoresSafeArea()
            
            VStack {
                HStack(spacing: 15) {
                    Image("Bootstrap")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(18)
                        .contextMenu {
                            Button(action: {
                                // 在确认后运行 respringAction()
                                respringAction()
                            }) {
                                Text("Respring")
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    VStack(alignment: .leading, content: {
                        Text("Bootstrap")
                            .bold()
                            .font(Font.system(size: 35))
                        Text("Version \(appVersion!)")
                            .font(Font.system(size: 20))
                            .opacity(0.5)
                    })
                }
                .padding(20)
                
                if newVersionAvailable {
                    Button {
                        UIApplication.shared.open(URL(string: newVersionReleaseURL)!)
                    } label: {
                        Label(
                            title: { Text("New Version Available") },
                            icon: { Image(systemName: "arrow.down.app.fill") }
                        )
                    }
                    .frame(height:20)
                    .padding(.top, -20)
                    .padding(10)
                }
                
                VStack(spacing: screenHeight * 0.02) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        bootstrapAction()
                    } label: {
                        if isSystemBootstrapped() {
                            if checkBootstrapVersion() {
                                Label(
                                    title: { Text("Bootstrapped").bold() },
                                    icon: { Image(systemName: "chair.fill") }
                                )
                                .frame(maxWidth: .infinity)
                                .padding(25)
                                .onAppear() {
                                    strapButtonDisabled = true
                                }
                            } else {
                                Label(
                                    title: { Text("Update").bold() },
                                    icon: { Image(systemName: "chair") }
                                )
                                .frame(maxWidth: .infinity)
                                .padding(25)
                            }
                        } else if isBootstrapInstalled() {
                            Label(
                                title: { Text("Bootstrap").bold() },
                                icon: { Image(systemName: "chair") }
                            )
                            .frame(maxWidth: .infinity)
                            .padding(25)
                        } else if ProcessInfo.processInfo.operatingSystemVersion.majorVersion>=15 {
                            Label(
                                title: { Text("Install").bold() },
                                icon: { Image(systemName: "chair") }
                            )
                            .frame(maxWidth: .infinity)
                            .padding(25)
                        } else {
                            Label(
                                title: { Text("Unsupported").bold() },
                                icon: { Image(systemName: "chair") }
                            )
                            .frame(maxWidth: .infinity)
                            .padding(25)
                            .onAppear() {
                                strapButtonDisabled = true
                            }
                        }
                    }
                    .frame(width: screenWidth*0.9)
                    .background {
                        Color(UIColor.systemBackground)
                            .cornerRadius(20)
                            .opacity(0.5)
                    }
                    .disabled(strapButtonDisabled)
                    
                    HStack {
                        
                        Button {
                            showAppView.toggle()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Label(
                                title: {
                                    Text("App List")
                                        .font(Font.system(size: 17).weight(.bold))
                                },
                                icon: { Image(systemName: "checklist") }
                            )
                            .frame(width: screenWidth*0.44, height: 65)
                        }
                        .background {
                            Color(UIColor.systemBackground)
                                .cornerRadius(20)
                                .opacity(0.5)
                        }
                        .disabled(!isSystemBootstrapped())
                        
                        Button {
                            withAnimation {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                showOptions.toggle()
                            }
                        } label: {
                            Label(
                                title: {
                                    Text("Settings")
                                        .font(Font.system(size: 17).weight(.bold))
                                },
                                icon: { Image(systemName: "gear") }
                            )
                            .frame(width: screenWidth*0.44, height: 65)
                        }
                        .background {
                            Color(UIColor.systemBackground)
                                .cornerRadius(20)
                                .opacity(0.5)
                        }
                        
                    }
                    
                    VStack(spacing: screenHeight * 0.02) {
                        ScrollView {
                            ScrollViewReader { scroll in
                                VStack(alignment: .leading) {
                                    ForEach(0..<LogItems.count, id: \.self) { LogItem in
                                        Text("\(String(LogItems[LogItem]))")
                                            .textSelection(.enabled)
                                            .font(.custom("Menlo", size: 15))
                                            .foregroundColor(.white)
                                    }
                                }
                                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LogMsgNotification"))) { obj in
                                    DispatchQueue.global(qos: .utility).async {
                                        LogItems.append((obj.object as! NSString) as String.SubSequence)
                                        scroll.scrollTo(LogItems.count - 1)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                    .frame(width: screenWidth*0.8)
                    .padding(20)
                    .background {
                        Color(.black)
                            .cornerRadius(20)
                            .opacity(0.5)
                    }
                    
                    Text("UI remade by ClaraCora. ")
                        .font(Font.system(size: 13))
                        .opacity(0.1)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button {
                withAnimation {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showCredits.toggle()
                }
            } label: {
                Label(
                    title: { Text("Credits").opacity(0.2) },
                    icon: { Image(systemName: "person").opacity(0.2) }
                )
                .foregroundColor(Color.gray) // 设置按钮标题的颜色为灰色
            }
            .frame(height:30, alignment: .bottom)
            .padding(10)
            
        }
        .overlay {
            if showCredits {
                CreditsView(showCredits: $showCredits)
            }
            
            if showOptions {
                OptionsView(showOptions: $showOptions, tweakEnable: $tweakEnable)
            }
        }
        .onAppear {
            initFromSwiftUI()
            Task {
                do {
                    try await checkForUpdates()
                } catch {

                }
            }
        }
        .sheet(isPresented: $showAppView) {
            AppViewControllerWrapper()
        }
    }
    
    func checkForUpdates() async throws {
        if let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let owner = "roothide"
            let repo = "Bootstrap"
            
            // Get the releases
            let releasesURL = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/releases")!
            let releasesRequest = URLRequest(url: releasesURL)
            let (releasesData, _) = try await URLSession.shared.data(for: releasesRequest)
            guard let releasesJSON = try JSONSerialization.jsonObject(with: releasesData, options: []) as? [[String: Any]] else {
                return
            }
            
            if let latestTag = releasesJSON.first?["tag_name"] as? String, latestTag != currentAppVersion {
                newVersionAvailable = true
                newVersionReleaseURL = "https://github.com/\(owner)/\(repo)/releases/tag/\(latestTag)"
            }
        }
    }
}
