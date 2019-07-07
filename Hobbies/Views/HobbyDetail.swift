//
//  HobbyDetail.swift
//  Hobbies
//
//  Created by David Idol on 6/29/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

struct HobbyDetail : View {
    @Environment(\.editMode) private var editMode
    @EnvironmentObject private var hobbiesStore: HobbiesStore
    @ObjectBinding private var cache: BindableImageCache
    
    var hobby: Hobby
    @State var draftHobby: Hobby = Hobby(id: "", name: "", companyId: "")
    
    init(hobby: Hobby) {
        self.hobby = hobby
        cache = BindableImageCache(storagePath: hobby.gcsImagePath)
    }
    
    var body: some View {
        VStack {
            HobbyImageHeader(cache: cache, draftHobby: $draftHobby)
            
            if self.editMode?.value == .inactive {
                HobbyDetailBody(hobby: draftHobby)
                    .padding()
            } else {
                HobbyDetailEditor(hobby: $draftHobby)
//                    .onDisappear {
                        // TODO how to discard changes visually?
//                        self.draftHobby = self.hobby
//                    }
                    .padding(.top)
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

struct HobbyImageHeader : View {
    var cache: BindableImageCache
    private let placeholderImg: UIImage = UIImage(named: "spinner-third")!
    
    @Binding var draftHobby: Hobby
    
    var hobbyImage: Image {
        return draftHobby.templateImage != nil ?
            Image(draftHobby.templateImage!) :
            Image(uiImage: cache.imageData ?? placeholderImg)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            hobbyImage
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
            
            HobbyImageEditor(templateSelected: { template in self.draftHobby.template = template })
        }
        .listRowInsets(EdgeInsets())
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
