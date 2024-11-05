//
//  ContentView.swift
//  RoPaSci
//
//  Created by Bibin Jacob Pulickal on 16/9/2024.
//

import SwiftUI
import Lottie

enum Choice: Int, Identifiable, CaseIterable {
    case scissor
    case rock
    case paper

    var id: Int { rawValue }

    var winningChoice: Choice {
        switch self {
        case .scissor:
            return .rock
        case .rock:
            return .paper
        case .paper:
            return .scissor
        }
    }

    var progressTime: AnimationProgressTime {
        switch self {
        case .rock:
            return 0.2
        case .paper:
            return 0.86
        case .scissor:
            return 0.54
        }
    }
}

private enum Constants {
    static let animationFileName = "ropasci"
}

struct SelectionButton: View {
    var choice: Choice
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            LottieView(animation: .named(Constants.animationFileName))
                .currentProgress(choice.progressTime)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black)
                        .shadow(radius: isSelected ? 0 : 8)
                }
        }
        .frame(height: 100)
    }
}

@Observable class ViewModel {
    var score = 0
    var opponentScore = 0
    var highScore = 0
    var selectedChoice: Choice?
    var opponentsChoice: Choice?
    var showResult = false
    private let highScoreKey = "highScore"

    init() {
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }

    func showResult(_ choice: Choice) {
        selectedChoice = choice
        opponentsChoice = Choice.allCases.randomElement()
        withAnimation {
            showResult.toggle()
        }
    }

    func reset() {
        score = 0
        opponentScore = 0
        if score > highScore {
            UserDefaults.standard.setValue(score, forKey: highScoreKey)
        }
        nextRound()
    }

    func nextRound() {
        selectedChoice = nil
        showResult.toggle()
    }
}

struct ScoreCardView: View {

    var viewModel: ViewModel

    var body: some View {
        VStack {
            Text("Rock Paper Scissors")
                .font(.amarante(size: 32))
                .foregroundStyle(Color.white)
            Text("Highscore:\(viewModel.highScore)")
                .font(.amarante(size: 16))
                .foregroundStyle(Color.yellow)
            HStack {
                Text("You:\(viewModel.score)")
                    .font(.amarante(size: 24))
                    .foregroundStyle(Color.green)
                Spacer()
                Text("Opponent:\(viewModel.opponentScore)")
                    .font(.amarante(size: 24))
                    .foregroundStyle(Color.red)
            }
            .padding(.horizontal)
        }
    }
}

struct ContentView: View {

    private var viewModel = ViewModel()

    var body: some View {
        VStack {
            if viewModel.showResult {
                ResultView(viewModel: viewModel)
                    .transition(.move(edge: .trailing))
            } else {
                SelectionView(viewModel: viewModel)
                    .transition(.move(edge: .trailing))
            }
        }
        .background {
            Color(white: 0.1)
                .ignoresSafeArea()
        }
    }
}

struct SelectionView: View {
    let viewModel: ViewModel

    var body: some View {
        VStack {
            ScoreCardView(viewModel: viewModel)
            Spacer()
            if let choice = viewModel.selectedChoice {
                LottieView(animation: .named(Constants.animationFileName))
                    .currentProgress(choice.progressTime)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LottieView(animation: .named(Constants.animationFileName))
                    .looping()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Spacer()
            HStack {
                ForEach(Choice.allCases) { choice in
                    SelectionButton(choice: choice, isSelected: choice == viewModel.selectedChoice) {
                        viewModel.showResult(choice)
                    }
                }
            }
            .padding()
        }
        .background {
            Color(white: 0.1)
                .ignoresSafeArea()
        }
    }
}

struct ResultView: View {
    let viewModel: ViewModel

    var body: some View {
        VStack {
            if viewModel.showResult {
                ScoreCardView(viewModel: viewModel)
                if let opponentsChoice = viewModel.opponentsChoice {
                    LottieView(animation: .named(Constants.animationFileName))
                        .currentProgress(opponentsChoice.progressTime)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.move(edge: .top))
                }
                if viewModel.selectedChoice == viewModel.opponentsChoice {
                    Text("Draw!")
                        .font(.amarante(size: 24))
                        .foregroundStyle(Color.yellow)
                } else if viewModel.opponentsChoice?.winningChoice == viewModel.selectedChoice {
                    Text("You Win!")
                        .font(.amarante(size: 24))
                        .foregroundStyle(Color.green)
                        .onAppear {
                            viewModel.score += 1
                        }
                } else {
                    Text("You Lost!")
                        .font(.amarante(size: 24))
                        .foregroundStyle(Color.red)
                        .onAppear {
                            viewModel.opponentScore += 1
                        }
                }
                if let choice = viewModel.selectedChoice {
                    LottieView(animation: .named(Constants.animationFileName))
                        .currentProgress(choice.progressTime)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.move(edge: .bottom))
                }
                HStack {
                    ActionButton(iconName: "arrow.counterclockwise") {
                        viewModel.reset()
                    }
                    Spacer()
                    ActionButton(iconName: "chevron.forward") {
                        viewModel.nextRound()
                    }
                }
                .padding([.horizontal, .bottom])
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color(white: 0.1)
                .ignoresSafeArea()
        }
    }
}

struct ActionButton: View {
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .foregroundStyle(Color.white)
                .frame(width: 64, height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black)
                )
        }
    }
}

#Preview {
    ContentView()
}

extension Font {
    static func amarante(weight: Font.Weight = .regular, size: CGFloat) -> Font {
        Font.custom("Amarante-Regular", size: size)
    }
}
