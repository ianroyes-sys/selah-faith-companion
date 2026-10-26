import SwiftUI

// MARK: - The Privacy Promise — trust, made visible.
// People pour their most vulnerable prayers into Selah. This view says,
// in plain words, what happens to them: nothing leaves, nothing is sold.

struct PrivacyPromiseSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let promises: [(icon: String, title: String, body: String)] = [
        ("iphone.and.arrow.forward.inward",
         "Your journal never leaves this phone",
         "Journal entries, your prayer vault, reflections, and every conversation with the Companion are stored only on this device. There is no copy anywhere else — we couldn't read them if we wanted to."),
        ("cpu",
         "The AI runs on your device",
         "The Companion thinks on your phone with Apple Intelligence. What you tell it is never sent to a server, never used to train anything, never seen by anyone."),
        ("person.fill.questionmark",
         "No account. No email. No identity.",
         "Selah never asks who you are. If you join the community, you're a random anonymous ID — even we can't connect your prayers to your name."),
        ("hand.raised.fill",
         "Never sold. Never shared. Ever.",
         "No ads, no trackers, no analytics companies, no data brokers. Your walk with God is not a product, and it never will be."),
        ("trash",
         "You hold the delete button",
         "Remove anything you've shared with one tap. Delete the app and everything on this phone goes with it — permanently."),
    ]

    var body: some View {
        ZStack {
            DuskBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Capsule().fill(Palette.mocha).frame(width: 40, height: 5).padding(.top, 14)
                    Spacer().frame(height: 34)

                    ZStack {
                        Circle()
                            .fill(Palette.bronze.opacity(0.14))
                            .frame(width: 92, height: 92)
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 38, weight: .medium))
                            .foregroundStyle(Palette.bronze)
                    }
                    Spacer().frame(height: 22)
                    Text("THE PRIVACY PROMISE")
                        .font(.display(13))
                        .kerning(4)
                        .foregroundStyle(Palette.bronze)
                    Spacer().frame(height: 12)
                    Text("What you write here\nis between you and God")
                        .font(.display(30))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Palette.cream)
                    Spacer().frame(height: 30)

                    VStack(spacing: 14) {
                        ForEach(promises, id: \.title) { p in
                            HStack(alignment: .top, spacing: 16) {
                                Image(systemName: p.icon)
                                    .font(.system(size: 18))
                                    .foregroundStyle(Palette.bronze)
                                    .frame(width: 28)
                                    .padding(.top, 2)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(p.title)
                                        .font(.label(15, weight: .semibold))
                                        .foregroundStyle(Palette.cream)
                                    Text(p.body)
                                        .font(.label(13))
                                        .lineSpacing(3)
                                        .foregroundStyle(Palette.sand.opacity(0.85))
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(.white.opacity(0.06))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .strokeBorder(.white.opacity(0.09), lineWidth: 1)
                                    }
                            }
                        }
                    }

                    Spacer().frame(height: 26)
                    Link(destination: Legal.privacyURL) {
                        HStack(spacing: 6) {
                            Text("Read the full Privacy Policy")
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .font(.label(13, weight: .medium))
                        .foregroundStyle(Palette.sand.opacity(0.8))
                    }
                    Spacer().frame(height: 22)

                    Button {
                        Haptics.soft()
                        dismiss()
                    } label: {
                        Text("Amen")
                            .font(.label(16, weight: .semibold))
                            .foregroundStyle(Palette.espresso)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background { Capsule().fill(Palette.cream) }
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 26)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
    }
}

// MARK: - Inline trust badge — shown right where people write vulnerable things.

struct PrivacyBadge: View {
    let text: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "lock.fill")
                .font(.system(size: 10))
            Text(text)
                .font(.label(11, weight: .medium))
        }
        .foregroundStyle(Palette.taupe)
    }
}
