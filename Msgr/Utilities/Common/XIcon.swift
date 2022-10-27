//
//  XIcon.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 21/3/22.
//

import SwiftUI

struct XIcon: View {
    
    enum Icon: String, CaseIterable {

        case tuningfork, waveform_path_ecg, chart_line_uptrend_xyaxis, chart_bar_xaxis, chart_pie_fill, paintpalette_fill, chart_xyaxis_line, flowchart, box_truck_fill, box_truck, train_side_front_car, tram_fill_tunnel, tram, bus_doubledecker_fill, bus_fill, iphone, person_crop_circle, waveform_and_magnifyingglass, bolt_horizontal_fill, magnifyingglass, menucard, creditcard, creditcard_fill, circle_grid_2x2_fill, wifi, shoeprints_fill, arrow_triangle_branch, globe_central_south_asia_fill, person, laptopcomputer_and_iphone, arrow_up_and_down_and_sparkles, circlebadge_fill, applelogo, candybarphone, distribute_vertical_top, calendar, pin, pin_fill, plus, plus_circle_fill

        var systemName: String { self.rawValue.replacingOccurrences(of: "_", with: ".") }
    }
    
    private let icon: Icon
    
    init(_ icon: Icon) {
        self.icon = icon
    }
    
    var body: some View {
        Image(systemName: icon.systemName)
    }
}
