// STATUS: BETA -- in active testing; dimensions and features are not finalized.
// This code and the rendered model are ©2025 by Don Ankney. They are licensed under Creative Commons Attribution 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by/4.0/

// This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt, and build upon the material in any medium or format, even for commercial purposes.

// Printed in TPU. The exterior carries a diamond knurl to add grip for pushing the
// mute into the bell.


H = 39;

// Interior bore, matched to the practice mute's outer cone just under the tip. The cork
// begins where the slant starts (small end sits at the tube-mount collar), so the straight
// pipe at the very top stays exposed. See the note by the bore cut below.
boreR1 = 24.75;   // small end (at the slant start, just under the tip collar)
boreR2 = 33.55;   // large end (39 mm down the cone)

// The practice mute's tip cone is far narrower than the Stop Mute Cork it is derived from.
// Rather than carry the Stop Mute Cork's wide exterior all the way down (which would leave a
// ~9 mm-thick blunt wall where the cork meets the narrow tip), the exterior hugs the bore
// thinly at the small end and flares out to the Stop Mute Cork's diameter only at the wide
// (bell) end. That gives the thinnest practical edge at the intersection while keeping the
// exterior within StopMuteCork + 0.5 mm at every height.
minWall = 1.2;              // wall at the small end (thin edge, just enough to back the knurl)
botR = boreR1 + minWall;    // small end (tip side)
topR = 38.25;               // large end (bell side) = Stop Mute Cork exterior

// Diamond knurl (grip texture)
// The knurl is scaled with the cone taper, so a ridge stands proud by knurlDepth at the
// small end and by knurlDepth*(topR/botR) at the wide end. Sizing the depth off the wide-end
// scale caps the outward growth at 0.5 mm on the radius there, where topR already equals the
// Stop Mute Cork; everywhere else the exterior sits comfortably inside StopMuteCork + 0.5 mm.
maxGrowth  = 0.5;                          // max radial growth at the ridge tips (at the wide end)
knurlTeeth = 44;                           // ridges around the circumference
knurlDepth = maxGrowth * botR / topR;      // 0.5 mm protrusion at the wide end
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

  // Interior: bored to match the practice mute's outer cone just under the tip so the
  // cork seats snugly over it. The mute tapers at ~0.2257 mm of radius per mm of height;
  // over this 39 mm span its outer radius runs 24.50 (upper, at the collar just under the
  // tip) to 33.30 (lower). Add 0.25 mm radial clearance for a snug slip fit.
    cylinder($fn = 360, h = H, r1 = boreR1, r2 = boreR2, center = false);

}
