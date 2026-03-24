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
        cylinder (h = height, r = innerRadius);
    }
}

module MuteBody() {
    union (){
        difference() {
            OuterGeometry();
            InnerGeometry();
        }
    }
        translate([0, 0, 78.559])
        InnerTube();
}   

module MuteBodyCrossSection() {
    intersection() {
        MuteBody();
        translate([0, -1000, -1])
            cube([1000, 2000, 1000]);
    }
}
MuteBodyCrossSection();
MuteBottom();
//MuteBody();

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

//translate([150,0,0])
//    MuteBottomConcave();