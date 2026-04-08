include <BOSL2/std.scad>
include <BOSL2/threading.scad>
    tubeRadius = 19;
    tubeHeight = 145;
    wallThickness = 2;





// Tube
module tuningTube(tubeRadius = tubeRadius, tubeLength = tubeHeight, wallThickness = wallThickness) {
    extDiameter = (tubeRadius * 2) + (2 * wallThickness);
    intRadius = tubeRadius - 2;

    
    difference() {

            union(){
                cylinder(h=5, r1=tubeRadius, r2=tubeRadius + 6);
                translate([0, 0, tubeLength - (tubeLength / 1.45)])
                    trapezoidal_threaded_rod(d=extDiameter, h=tubeLength/2, pitch=3);
                cylinder(h=tubeLength, d=extDiameter-3);
            }
            cylinder(h=tubeLength, r1=intRadius, r2=intRadius, center=false);
    }
}
    


tuningTube(tubeRadius, 155, wallThickness);

translate([0, 60, 0])
    tuningTube(tubeRadius, 155, wallThickness);


translate([60, 0, 0])
    tuningTube(tubeRadius, 155, wallThickness);

translate([60, 60, 0])
    tuningTube(tubeRadius, 155, wallThickness);
    
 translate([0, 120, 0])
    tuningTube(tubeRadius, 155, wallThickness);
    
     translate([120, 0, 0])
    tuningTube(tubeRadius, 155, wallThickness);