// This code and the rendered model are ©2025 by Don Ankney. They are licensed under Creative Commons Attribution 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by/4.0/
// This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt, and build upon the material in any medium or format, even for commercial purposes.

// --- Dimensions (edit here to change the whole model) ---
shell_outer_r1  = 27.25;  // shell outer radius at bottom
shell_outer_r2  = 34.25;  // shell outer radius at top
shell_inner_r1  = 25.75;  // shell inner radius at bottom (= stop base outer r1)
shell_inner_r2  = 33.25;  // shell inner radius at top   (= stop base outer r2)
fit_clearance   = 0.10;   // radial clearance: shell over stop base
tube_clearance  = 0.20;   // radial clearance: tube inside stop base opening
tube_slip       = 0.20;   // extra radial slip so tube slides in freely
tube_inner_r    = 25.75;  // reference inner radius for tube sizing
tube_thickness  = 2.25;   // tube wall thickness
ring_outer_r    = shell_outer_r1;    // outer edge of shell bottom
ring_inner_r    = tube_inner_r - tube_clearance - tube_slip - tube_thickness; // tube bore
// ---------------------------------------------------------

module outside_shell(outer_r1, outer_r2, inner_r1, inner_r2, fit_clearance) {
    translate([0,0,2]){
        difference() {
            cylinder($fn=360, h=39, r1=outer_r1 + fit_clearance, r2=outer_r2 + fit_clearance, center=false); 
            cylinder($fn=360, h=39, r1=inner_r1 + fit_clearance, r2=inner_r2 + fit_clearance, center=false);
        }
    }
}

module base_ring(outer_r, inner_r) {
    difference() {
        cylinder($fn=360, h=2, r=outer_r);
        cylinder($fn=360, h=140, r=inner_r);
    }
}

module tube(inner_r, tube_clearance, tube_slip, tube_thickness) {
    tube_r = inner_r - tube_clearance - tube_slip;
    difference(){
        cylinder($fn=360, h=140, r=tube_r);
        cylinder($fn=360, h=140, r=tube_r - tube_thickness);
    }
}

outside_shell(
    outer_r1      = shell_outer_r1,
    outer_r2      = shell_outer_r2,
    inner_r1      = shell_inner_r1,
    inner_r2      = shell_inner_r2,
    fit_clearance = fit_clearance
);

base_ring(
    outer_r = ring_outer_r,
    inner_r = ring_inner_r
);

tube(
    inner_r        = tube_inner_r,
    tube_clearance = tube_clearance,
    tube_slip      = tube_slip,
    tube_thickness = tube_thickness
);

