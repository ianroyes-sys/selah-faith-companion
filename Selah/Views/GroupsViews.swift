import SwiftUI

// MARK: - Pre-built small groups — themed circles anyone can join in one tap.
// No invite code, no waiting to be asked. You open the app already belonging somewhere.

struct GroupsRail: View {
    @ObservedObject var community: CommunityStore
    @State private var showAll = false

    private var unjoined: [PublicGroup] { community.groups.filter { !$0.joined } }

    var body: some View {
        if !unjoined.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Find your circle".uppercased())
                            .font(.label(10, weight: .semibold))
                            .kerning(1.2)
                            .foregroundStyle(Palette.mocha)
                        Text("Groups already waiting for you")
                            .font(.display(18))
                            .foregroundStyle(Palette.ink)
                    }
                    Spacer()
                    Button {
                        Haptics.tap(); showAll = true
                    } label: {
                        Text("See all")
                            .font(.label(12, weight: .semibold))
                            .foregroundStyle(Palette.bronze)
                    }
                    .buttonStyle(.plain)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(unjoined.prefix(6)) { group in
                            GroupCard(group: group, community: community)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAll) { FindCircleSheet(community: community) }
        }
    }
}

struct GroupCard: View {
    let group: PublicGroup
    @ObservedObject var community: CommunityStore
    @State private var joining = false
    @State private var joined = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                ArchShape()
                    .fill(LinearGradient(colors: [Palette.sand, Palette.taupe],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 128, height: 96)
                Image(systemName: group.symbol)
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(Palette.cream)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.label(13, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2, reservesSpace: true)
                Text(group.memberCount == 1 ? "1 member" : "\(group.memberCount) members")
                    .font(.label(10))
                    .foregroundStyle(Palette.taupe)
                Button {
                    join()
                } label: {
                    HStack(spacing: 5) {
                        if joining {
                            ProgressView().tint(Palette.onInk).scaleEffect(0.7)
                        } else {
                            Image(systemName: joined ? "checkmark" : "plus")
                                .font(.system(size: 10, weight: .bold))
                        }
                        Text(joined ? "Joined" : "Join")
                            .font(.label(12, weight: .semibold))
                    }
                    .foregroundStyle(Palette.onInk)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background { Capsule().fill(joined ? Palette.sage : Palette.ink) }
                }
                .buttonStyle(.plain)
                .disabled(joining || joined)
            }
            .padding(.top, 8)
        }
        .frame(width: 128)
    }

    private func join() {
        guard !joining else { return }
        Haptics.tap()
        joining = true
        Task {
            if (try? await community.joinGroup(group)) != nil {
                Haptics.success()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { joined = true }
            }
            joining = false
        }
    }
}

// MARK: - Full group browser

struct FindCircleSheet: View {
    @ObservedObject var community: CommunityStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SelahBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Capsule().fill(Palette.sand).frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity).padding(.top, 14)
                    Text("Find your circle")
                        .font(.display(30))
                        .foregroundStyle(Palette.ink)
                    Text("Real groups around what you're actually walking through. Join one and it becomes a circle of yours — shared prayers, blessings, daily check-ins.")
                        .font(.label(14))
                        .lineSpacing(4)
                        .foregroundStyle(Palette.mocha)

                    switch community.groupsState {
                    case .loading, .idle:
                        VStack(spacing: 12) {
                            ForEach(0..<4, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Palette.linen.opacity(0.6))
                                    .frame(height: 84)
                            }
                        }
                        .redacted(reason: .placeholder)
                    case .failed(let message):
                        ErrorCard(message: message) { Task { await community.browseGroups() } }
                    case .loaded:
                        ForEach(community.groups) { group in
                            GroupListRow(group: group, community: community)
                        }
                    }
                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 24)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(36)
        .task { await community.browseGroups() }
    }
}

struct GroupListRow: View {
    let group: PublicGroup
    @ObservedObject var community: CommunityStore
    @State private var joining = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Palette.blush).frame(width: 48, height: 48)
                Image(systemName: group.symbol)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Palette.ink)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(group.name)
                    .font(.label(15, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                Text(group.tagline)
                    .font(.label(12))
                    .foregroundStyle(Palette.mocha)
                    .lineLimit(2)
                Text(group.memberCount == 1 ? "1 member" : "\(group.memberCount) members")
                    .font(.label(11, weight: .medium))
                    .foregroundStyle(Palette.taupe)
            }
            Spacer()
            Button {
                join()
            } label: {
                Group {
                    if joining {
                        ProgressView().tint(Palette.onInk).scaleEffect(0.75)
                    } else if group.joined {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                    } else {
                        Text("Join")
                            .font(.label(13, weight: .semibold))
                    }
                }
                .foregroundStyle(group.joined ? Palette.cream : Palette.onInk)
                .frame(width: 62, height: 36)
                .background { Capsule().fill(group.joined ? Palette.sage : Palette.ink) }
            }
            .buttonStyle(.plain)
            .disabled(joining || group.joined)
        }
        .padding(16)
        .glassCard(corner: 26)
    }

    private func join() {
        guard !joining, !group.joined else { return }
        Haptics.tap()
        joining = true
        Task {
            if (try? await community.joinGroup(group)) != nil { Haptics.success() }
            joining = false
        }
    }
}
