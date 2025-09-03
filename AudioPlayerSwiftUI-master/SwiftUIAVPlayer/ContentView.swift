
import AVFoundation
import SwiftUI

/// A view that just has a play/pause button and a slider
/// to scrub through the audio.
struct ContentView: View {
    /// The player, which wraps an AVPlayer
    @ObservedObject var player: PlayerFrameWork
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    switch self.player.timeControlStatus {
                    case .paused:
                        self.player.play()
                    case .waitingToPlayAtSpecifiedRate:
                        self.player.pause()
                    case .playing:
                        self.player.pause()
                    @unknown default:
                        fatalError()
                    }
                }) {
                    Image(systemName: self.player.timeControlStatus == .paused ? "play" : "pause")
                        .imageScale(.large)
                        .frame(width: 64, height: 64)
                }
                
                HStack {
                    Text("Observed time")
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                    Text(Date().durationFormatter.string(from: self.player.observedTime) ?? "")
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
                
                HStack {
                    Text("Display time")
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                    Text(Date().durationFormatter.string(from: self.player.displayTime) ?? "")
                }
                
                /// This is a bit of a hack, but it takes a moment for the AVPlayerItem to load
                /// the duration, so we need to avoid adding the slider until the range
                /// (0...self.player.duration) is not empty.
                if self.player.itemDuration > 0 {
                    Slider(value: self.$player.displayTime, in: (0...self.player.itemDuration), onEditingChanged: {
                        (scrubStarted) in
                        if scrubStarted {
                            self.player.scrubState = .scrubStarted
                        } else {
                            self.player.scrubState = .scrubEnded(self.player.displayTime)
                        }
                    })
                } else {
                    Text("Slider will appear here when the player is ready")
                        .font(.footnote)
                }
                NavigationLink(
                    destination: Text("Destination"),
                    label: {
                        Text("Navigate")
                    })
            }
        }
    }
    
    /// Return a formatter for durations.

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(player: PlayerFrameWork(avPlayer: AVPlayer()))
    }
}

extension Date {
    var durationFormatter: DateComponentsFormatter {
        
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.allowedUnits = [.minute, .second]
        durationFormatter.unitsStyle = .positional
        durationFormatter.zeroFormattingBehavior = .pad
        
        return durationFormatter
    }
}
