// Rittich_Deco -- the Rittich mute with the reusable Art Deco exterior relief applied.
// The body geometry is identical to Rittich.scad; the exterior texture comes from
// Deco_Overlay.scad and is purely additive, so the acoustic interior is unchanged.

use <Deco_Overlay.scad>

// Inner Geometry
//  AdjustableTubeLength: 100mm
//  AdjustableTubeInternalDiameter: 38.1mm
//  OpenEndDiameter: 27.5mm
//  BaseDiameter: 127.5mm
//  TotalHeight: 244.2mm

CircleResolution = 360;
WallThickness = 1;


module InnerGeometry(openEndDiameter = 27.5, baseDiameter = 127.5, totalHeight = 244.2) {
    cylinder ($fn = CircleResolution, h = totalHeight, r1 = baseDiameter / 2, r2 = openEndDiameter / 2);
}

module OuterGeometry(openEndDiameter = 27.5 + WallThickness * 2, baseDiameter = 127.5 + WallThickness * 2, totalHeight = 244.2) {
    cylinder ($fn = CircleResolution, h = totalHeight, r1 = baseDiameter / 2, r2 = openEndDiameter / 2);
}

module InnerTube(height = 140, innerRadius = 18, wallThickness = 1) {
    outerRadius = innerRadius + wallThickness * 2;

    difference() {
        cylinder (h = height, r = outerRadius);
        translate([0, 0, -0.1])
            cylinder (h = height + 0.2, r = innerRadius);
    }
}

module InnerTubeReinforcement(tubeBaseZ = 78.559, tubeHeight = 140, innerRadius = 18, wallThickness = 1, reinforcementHeight = 8, reinforcementDepth = 3, bevelHeight = 2, topBevelHeight = 1.5) {
    outerRadius = innerRadius + wallThickness * 2;
    tubeTop = tubeBaseZ + tubeHeight;
    reinforcementStart = tubeTop - reinforcementHeight;
    bevelStart = reinforcementStart - bevelHeight;
    topBevelStart = tubeTop - topBevelHeight;
    straightSectionStart = reinforcementStart;
    straightSectionHeight = topBevelStart - straightSectionStart;

    intersection() {
        InnerGeometry();
        union() {
            translate([0, 0, straightSectionStart])
                difference() {
                    cylinder(h = straightSectionHeight, r = outerRadius + reinforcementDepth);
                    cylinder(h = straightSectionHeight, r = outerRadius);
                }
            translate([0, 0, bevelStart])
                difference() {
                    cylinder(h = bevelHeight, r1 = outerRadius, r2 = outerRadius + reinforcementDepth);
                    cylinder(h = bevelHeight, r = outerRadius);
                }
            translate([0, 0, topBevelStart])
                difference() {
                    cylinder(h = topBevelHeight, r1 = outerRadius + reinforcementDepth, r2 = outerRadius);
                    cylinder(h = topBevelHeight, r = outerRadius);
                }
        }
    }
}

module MuteBody() {
    union() {
        difference() {
            OuterGeometry();
            InnerGeometry();
        }
        translate([0, 0, 78.559])
            InnerTube();
        InnerTubeReinforcement();
    }
}

module MuteBodyCrossSection() {
    intersection() {
        MuteBody();
        translate([0, -1000, -1])
            cube([1000, 2000, 1000]);
    }
}

// The mute body with the reusable Art Deco relief fused onto its exterior. The relief hugs
// the OuterGeometry cone (outer radius baseDiameter/2 at the base tapering to openEndDiameter/2
// at the top) and only adds material, so InnerGeometry (the acoustic bore) is untouched.
module MuteBodyArtDeco() {
    union() {
        MuteBody();
        ArtDecoRelief(baseR     = (127.5 + WallThickness * 2) / 2,
                      topR      = ( 27.5 + WallThickness * 2) / 2,
                      coneH     = 244.2,
                      circleRes = CircleResolution);
    }
}

//MuteBodyCrossSection();
//MuteBottom();
MuteBodyArtDeco();

module MuteBottom() {
    difference(){
        cylinder($fn = CircleResolution, h = 5, r = 63.75);
        MuteBody();
    }
}


module MuteBottomWithHoles() {
    difference() {
        MuteBottom();
        translate ([45, 0, 0])
            cylinder (h = 5, r1 = 2.5, r2 = 3);
        translate ([-45, 0, 0])
            cylinder (h = 5, r1 = 2.5, r2 = 3);
    }

}

module MuteBottomConcave() {
    difference() {
        rotate_extrude($fn = CircleResolution)
            polygon([[0, 0], [63.75, 0], [63.75, 10], [0, 5]]);
        MuteBody();
    }
}

translate([150,0,0])
    MuteBottomWithHoles();
