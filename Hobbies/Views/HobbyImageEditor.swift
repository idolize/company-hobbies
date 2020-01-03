//
//  HobbyImageEditor.swift
//  Hobbies
//
//  Created by David Idol on 7/7/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

struct HobbyImageEditor : View {
    @Environment(\.editMode) private var editMode
    @State private var isActionSheetVisible = false
    @State private var isPopoverVisible = false
    
    let templateSelected: (_ template: Hobby.Template) -> Void
    
    private var actionSheet: ActionSheet {
        let removeBtn = ActionSheet.Button.destructive(Text("Remove Current Photo")) {
            // TODO set template to nil and also delete image from GCS?
            self.isActionSheetVisible = false
        }
        let chooseFromTemplateBtn = ActionSheet.Button.default(Text("Choose from Template")) {
            self.isActionSheetVisible = false
            self.isPopoverVisible = true
        }
        let chooseFromLibBtn = ActionSheet.Button.default(Text("Choose from Library")) {
            self.isActionSheetVisible = false
        }
        let dismissBtn = ActionSheet.Button.cancel {
            self.isActionSheetVisible = false
        }
        let buttons = [removeBtn, chooseFromTemplateBtn, chooseFromLibBtn, dismissBtn]
        
        return ActionSheet(title: Text("Edit Photo"), buttons: buttons)
    }
    
    private var popover: TemplateSelectorPopover {
        return TemplateSelectorPopover(selected: { template in
            self.templateSelected(template)
            self.isPopoverVisible.toggle()
        })
    }
    
    var body: some View {
        VStack {
            Spacer()
            if self.editMode?.wrappedValue != .inactive {
                Button(action: {
                    self.isActionSheetVisible = true
                }) {
                    Image("edit")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(15)
                        .background(Color.black.opacity(0.35))
                        .mask(Circle())
                }
                .foregroundColor(.white)
            }
            Spacer()
        }
        .actionSheet(isPresented: $isActionSheetVisible, content: {
            self.actionSheet
        })
        .popover(isPresented: $isPopoverVisible, content: {
            self.popover
        })
    }
}

#if DEBUG
struct HobbyImageEditor_Previews : PreviewProvider {
    static var previews: some View {
        HobbyImageEditor(templateSelected: { template in })
    }
}
#endif
