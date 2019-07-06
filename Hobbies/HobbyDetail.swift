//
//  HobbyDetail.swift
//  Hobbies
//
//  Created by David Idol on 6/29/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

struct HobbyDetail : View {
    @Environment(\.editMode) var editMode
    @EnvironmentObject var hobbiesStore: HobbiesStore
    
    @ObjectBinding var cache: BindableImageCache
    var placeholderImg: UIImage = UIImage(named: "spinner-third")!
    
    
    var hobby: Hobby
    @State var draftHobby: Hobby = Hobby(id: "", name: "", companyId: "")
    
    init(hobby: Hobby) {
        self.hobby = hobby
        cache = BindableImageCache(storagePath: "images/\(hobby.companyId)/hobbies/\(hobby.id).jpg")
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Image(uiImage: cache.imageData ?? placeholderImg)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: nil, height: 275, alignment: .topLeading)
                    .clipped()
                
                Rectangle()
                    .foregroundColor(.black)
                    .frame(height: 80)
                    .opacity(0.25)
                    .blur(radius: 15)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("\(draftHobby.name) @ Snap, Inc.")
                            .color(.white)
                            .font(.largeTitle)
                    }
                    .padding(.leading)
                    .padding(.bottom)
                    
                    Spacer()
                }
            }
            .listRowInsets(EdgeInsets())
            
            if self.editMode?.value == .inactive {
                HobbyDetailBody(hobby: draftHobby)
                    .padding()
            } else {
                HobbyDetailEditor(hobby: $draftHobby)
                    .onDisappear {
                        self.draftHobby = self.hobby
                    }
                    .padding()
            }
            
            HStack {
                Spacer()
                ActionButton(hobby: draftHobby)
                Spacer()
            }
            .padding(.top, 50)
            
            Spacer()
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarItems(trailing: EditButton())
        .onAppear(perform: { self.draftHobby = self.hobby })
    }
}

struct HobbyDetailBody : View {
    var hobby: Hobby
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading) {
            Text(hobby.description)
                .font(Font.system(size: 22).italic())
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .padding(.bottom)
            
            HStack {
                Text("Contact:")
                Text("idol@snapchat.com")
                    .color(.blue)
            }
            Divider()
            HStack {
                Text("Slack:")
                Text(hobby.external["slack"] ?? "none")
                    .color(.blue)
            }
            Divider()
            Text("Members: userA, userB, userC, userD, userE, userF").lineLimit(nil).lineSpacing(9.0)
        }
    }
}

struct ActionButton : View {
    @Environment(\.editMode) var editMode
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var hobbiesStore: HobbiesStore
    var hobby: Hobby
    
    var isMemberOfHobby: Bool {
        return userDataStore.userData?.isMemberOfHobby(hobbyId: hobby.id) ?? false
    }
    
    var isEditing: Bool {
        return editMode?.value != .inactive
    }
    
    var body: some View {
        Button(action: performAction) {
            Text(isEditing ? "Save" : isMemberOfHobby ? "Leave" : "Join Up!")
                .transition(AnyTransition.opacity)
        }
        .frame(width: 210, height: 50)
        .foregroundColor(.white)
        .font(.headline)
        .background(!isEditing && isMemberOfHobby ? Color.gray : Color.blue)
        .cornerRadius(10)
    }
    
    func performAction() {
        if isEditing {
            hobbiesStore.updateHobby(hobby: hobby)
            self.editMode?.animation().value = .inactive
        } else if isMemberOfHobby {
            userDataStore.leaveHobby(hobby: hobby)
        } else {
            userDataStore.joinHobby(hobby: hobby)
        }
    }
}

//#if DEBUG
//struct HobbyDetail_Previews : PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            HobbyDetail()
//        }
//    }
//}
//#endif
