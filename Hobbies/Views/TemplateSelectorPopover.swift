//
//  TemplateSelectorPopover.swift
//  Hobbies
//
//  Created by David Idol on 7/6/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

fileprivate let templates: [Hobby.Template] = Hobby.Template.allCases

struct TemplateSelectorPopover : View {
    var selected: (_ template: Hobby.Template) -> Void
    
    var body: some View {
        List(templates.identified(by: \.self)) { template in
            TemplateItem(template: template)
                .tapAction({ self.selected(template) })
        }
    }
}


struct TemplateItem : View {
    var template: Hobby.Template
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(template.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 80, alignment: .center)
                .cornerRadius(5)
            
            Rectangle()
                .foregroundColor(.black)
                .frame(height: 40)
                .opacity(0.25)
                .blur(radius: 15)
            
            Text(template.rawValue.camelCaseToWords().uppercased())
                .font(.headline)
                .padding(.bottom)
        }
        .padding(.top)
        .padding(.bottom)
    }
}

