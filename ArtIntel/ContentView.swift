//
//  ContentView.swift
//
//
//  Created by Satvi Mahesh on 3/19/25.
//

import SwiftUI
import PhotosUI
public var selectedImage: UIImage? = nil

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showText = false
    @State private var selectedImage: UIImage? = nil
    @State private var aiResponse: String = ""
    @State private var isLoading = false

    var body: some View {
            VStack(spacing: 20) {
                Text("🎨 Art Intel")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 5)
                } else {
                    Text("What artwork would you like help on?")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                PhotosPicker("Choose an Artwork!", selection: $selectedItem, matching: .images)
                    .font(.headline)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .task(id: selectedItem) {
                        if let selectedItem {
                            do {
                                if let data = try await selectedItem.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                }
                            } catch {
                                print("Failed to load image: \(error.localizedDescription)")
                            }
                        }
                    }

                Button("Go!") {
                    Task {
                        await send()
                    }
                }
                .padding()
                .font(.headline)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .padding(.horizontal)
                .disabled(selectedImage == nil)

                if isLoading {
                    ProgressView("...")
                        .padding()
                }

                ScrollView {
                    Text(aiResponse)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                      //  .shadow(radius: 3)
                }

                Spacer()
            }
            .padding()
        }

        func send() async {
            guard let image = selectedImage else {
                aiResponse = "Please select an image first."
                return
            }

            isLoading = true
            do {
                let result = try await sendImageToClaude(
                    prompt: "Give kind, constructive art critique of this artwork. Mention strengths and areas for growth, as well as how to fix those areas.",
                    media: image
                )
                aiResponse = result
            } catch {
                aiResponse = "Error: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }


