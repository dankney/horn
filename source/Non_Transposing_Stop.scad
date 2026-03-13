module pipe_bell() {
    //Pipe
    difference(){
        cylinder($fn=360, h=34, r1=4, r2=4, center=false);
        cylinder($fn=360, h=34, r1=3, r2=3, center=false);
    }
    //Bell
    translate([0,0,34]){
        difference(){
            cylinder($fn=360, h=20, r1=4, r2=16.5, center=false);
            cylinder($fn=360, h=20, r1=3, r2=15.5, center=false);
        }
    }
}
module torus_ext() {
    //Torus Top
    // Inner hole diameter = 17.5 mm, outer diameter = 125 mm
    // Major radius (R) = (125 + 17.5) / 4 = 35.625
    // Minor radius (r) = (125 - 17.5) / 4 = 26.875
    // Hollow torus shell = 3 mm
    // Half-height in Z (ellipse cross-section), hole size unchanged
    difference() {
        scale([1,1,0.5])
            rotate_extrude(convexity = 10, $fn = 180)
                translate([35.625, 0, 0])
                    circle(r = 26.875, $fn = 180);
        scale([1,1,0.5])
            rotate_extrude(convexity = 10, $fn = 180)
                translate([35.625, 0, 0])
                    circle(r = 25.375, $fn = 180);
    }
}
module base_section() {
    //Base section for bell insertion
    difference(){
        cylinder($fn=360, h=39, r1=27.25, r2= 34.25, center=false);
        cylinder($fn=360, h=39, r1=25.75, r2=33.25, center=false);
        }
}

module mute_body() {
    difference(){
        cylinder($fn=360, h=123.5, r1=34.25, r2=62.5, center=false);
        cylinder($fn=360, h=123.5, r1=32.75, r2= 61, center=false);
     }
}


base_section();

difference(){
    translate([0,0,162.5625])
        torus_ext();
     translate([0,0,39])
        cylinder($fn=360, h=123.5, r1=32.75, r2= 61, center=false);
}

translate([0,0,39]) 
    mute_body();


    
translate([0,0,122])
    pipe_bell();