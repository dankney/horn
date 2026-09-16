// This code and the rendered model are ©2025 by Don Ankney. They are licensed under Creative Commons Attribution 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by/4.0/

// This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt, and build upon the material in any medium or format, even for commercial purposes.

// Printed in TPU. The exterior carries the same diamond knurl as the Practice Mute cork to
// add grip for pushing the mute into the bell. The interior bore parallels the Stop Mute
// Rev 7 base exterior with a uniform 0.3 mm radial clearance so the cork grips snugly the
// full length, and the knurl grows the exterior by at most 1 mm in diameter (0.5 mm on the
// radius) at any height.


H = 39;

// Interior bore -- re-tapered to match the Stop Mute Rev 7 base exterior (r 27.25 -> 34.25
// over the 39 mm height, slope 7/39) with a uniform 0.3 mm radial clearance. The old bore
// (28.75 -> 34.25) tapered too shallow: it touched only at the top rim and left up to 3 mm
// of diametral slop at the bottom. Subtracted last so the knurl never touches it.
boreR1 = 27.55;   // small end (bottom): Rev 7 base 27.25 + 0.3 clearance
boreR2 = 34.55;   // large end (top):    Rev 7 base 34.25 + 0.3 clearance

// Smooth exterior cone -- UNCHANGED from the original Stop Mute Cork. The knurl roots ride on
// this surface, so this is the exterior everywhere except where a ridge stands proud.
botR = 33.75;     // small end (bottom)
topR = 38.25;     // large end (top)

// Diamond knurl (grip texture), ported from PracticeMuteCork.
// The knurl is scaled with the cone taper, so a ridge stands proud by knurlDepth at the small
// end and by knurlDepth*(topR/botR) at the wide end. Sizing the depth off the wide-end scale
// caps the radial growth at maxGrowth there (the widest ridges); everywhere else the exterior
// sits inside that bound. maxGrowth = 0.5 mm on the radius = 1 mm on the diameter.
maxGrowth  = 0.48;                         // max radial growth at the ridge tips (at the wide end);
                                           // 0.96 mm on the diameter, leaving margin under the 1 mm cap
knurlTeeth = 44;                           // ridges around the circumference
knurlDepth = maxGrowth * botR / topR;      // scaled so growth is exactly maxGrowth at the wide end
knurlTwist = 55;                           // helix angle, in degrees over the full height, per direction


// A ring of teeth: alternating root (rootR) and tip (tipR) vertices.
module toothed2D(rootR, tipR, teeth) {
    pts = [ for (i = [0:teeth-1]) each [
        [rootR * cos(i * 360 / teeth),         rootR * sin(i * 360 / teeth)],
        [tipR  * cos((i + 0.5) * 360 / teeth), tipR  * sin((i + 0.5) * 360 / teeth)]
    ]];
    polygon(pts);
}

// Two opposite-hand helical toothed extrudes, scaled to follow the cone taper, cross
// to form the diamond pattern. Valleys sit on the original cone surface; ridges stand
// knurlDepth proud, so the bored fit is unaffected and only the grip surface changes.
module knurl() {
    s = topR / botR;   // top scale keeps the tooth roots on the cone surface
    union() {
        linear_extrude(height = H, twist =  knurlTwist, scale = s, slices = 120)
            toothed2D(botR, botR + knurlDepth, knurlTeeth);
        linear_extrude(height = H, twist = -knurlTwist, scale = s, slices = 120)
            toothed2D(botR, botR + knurlDepth, knurlTeeth);
    }
}


difference() {

  union() {
    // Smooth exterior cone provides the base surface; the knurl adds grip ridges.
    cylinder($fn = 360, h = H, r1 = botR, r2 = topR, center = false);
    knurl();
  }

  // Interior bore -- unchanged.
  cylinder($fn = 360, h = H, r1 = boreR1, r2 = boreR2, center = false);

}
