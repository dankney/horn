// Deco_Overlay.scad
// Reusable Art Deco relief overlay for conical surfaces.
//
// Purely ADDITIVE: the relief reaches at most `weld` mm back into the wall and otherwise
// stands proud of the outer surface, so it never disturbs a thin-walled interior bore.
// Union it onto a cone whose OUTER surface runs from radius `baseR` (at z = 0) up to `topR`
// (at z = coneH).
//
// Motif: a sunburst of vertical flutes converging on the narrow top, a stepped ziggurat
// plinth and a matching capital, beaded borders, and a mid-height racing-stripe band.
//
// Usage:
//   use <Deco_Overlay.scad>
//   union() {
//       MyConeBody();
//       ArtDecoRelief(baseR = 64.75, topR = 14.75, coneH = 244.2, circleRes = 360);
//   }

module ArtDecoRelief(baseR, topR, coneH,
                     circleRes   = 360,
                     rayCount    = 30,    // number of bold sunburst flutes
                     rayCoverage = 0.55,  // fraction of each angular pitch that is raised rib
                     rayDepth    = 2.6,   // how far the flutes stand off the surface (mm)
                     rayBottom   = 24,    // flutes start above the plinth
                     rayTop      = 210,   // flutes stop below the capital
                     weld        = 0.4) { // how far the relief reaches back into the wall

    // A cone parallel to the outer surface, its radius offset by dr everywhere.
    module DecoConeOffset(dr) {
        cylinder($fn = circleRes, h = coneH, r1 = baseR + dr, r2 = topR + dr);
    }

    // A thin shell hugging the outer surface: from `weld` inside the wall out to +depth.
    module DecoShell(depth) {
        difference() {
            DecoConeOffset(depth);
            DecoConeOffset(-weld);
        }
    }

    // Outer radius of the bare cone surface at height z.
    function DecoBaseR(z) = baseR + (topR - baseR) * z / coneH;

    // Clip solid for the z-band [z0, z0 + bandH]. Same as a plain z-band cube, but the
    // UNDERSIDE is cut back to a <=45-degree chamfer instead of a flat horizontal ledge,
    // so a raised feature of radial `depth` prints with no downward-facing overhang.
    // (The cone itself narrows going up, so tops and sides are already self-supporting;
    // only the bottoms of the protrusions needed fixing.) This only removes outer
    // material -- the inner mating surface at -weld is never touched.
    module DecoBandClip(z0, bandH, depth) {
        ch  = min(depth, bandH);  // vertical rise of the bottom ramp (>= its radial run)
        pad = 1;                  // ramp cone overshoots the band top so the chamfer closes
                                  // on a clean edge, not a boolean-coincident plane (a
                                  // coincident plane leaves a flat downward ledge = overhang)
        difference() {
            translate([-300, -300, z0]) cube([600, 600, bandH]);
            // Remove the outer-bottom corner: everything in the bottom `ch` slab that lies
            // outside a cone whose radial offset grows 1:1 with height (0 at z0, ch at z0+ch).
            difference() {
                translate([-300, -300, z0 - 0.01]) cube([600, 600, ch + 0.01]);
                translate([0, 0, z0])
                    cylinder($fn = circleRes,
                             h  = ch + pad,
                             r1 = DecoBaseR(z0),
                             r2 = DecoBaseR(z0 + ch + pad) + (ch + pad));
            }
        }
    }

    // A pie-slice wedge of angle a (centred on +x), used as an angular mask.
    module DecoWedge(a, R, h) {
        linear_extrude(h)
            polygon(concat([[0, 0]],
                           [for (t = [-a/2 : a/8 : a/2 + 0.001]) [R * cos(t), R * sin(t)]]));
    }

    // Sunburst flutes: the outer shell clipped to a z-band and to a ring of angular wedges.
    module DecoRays(n, coverage, depth, z0, z1) {
        R = baseR + depth + 5;
        intersection() {
            DecoShell(depth);
            DecoBandClip(z0, z1 - z0, depth);
            union() {
                for (i = [0 : n - 1])
                    rotate([0, 0, i * 360 / n])
                        DecoWedge(360 / n * coverage, R, coneH);
            }
        }
    }

    // A raised ring collar of the given radial depth over a z-band.
    module DecoCollar(z0, bandH, depth) {
        intersection() {
            DecoShell(depth);
            DecoBandClip(z0, bandH, depth);
        }
    }

    // Three thin parallel rings -- the classic Art Deco "racing stripe" band.
    module DecoTripleBand(zc, depth) {
        DecoCollar(zc - 3, 1.6, depth);
        DecoCollar(zc,     1.6, depth);
        DecoCollar(zc + 3, 1.6, depth);
    }

    // A ring of short raised studs -- Art Deco beaded / dotted border.
    module DecoBeadRing(zc, count, depth) {
        DecoRays(count, 0.45, depth, zc, zc + 3.5);
    }

    // Stepped ziggurat plinth: collars of decreasing depth stacked into a setback.
    module DecoStepBase(z0) {
        DecoCollar(z0,      6, 3.6);
        DecoCollar(z0 + 6,  5, 2.7);
        DecoCollar(z0 + 11, 4, 1.8);
    }

    // Stepped "capital" just above the flutes -- mirrors the plinth.
    module DecoStepCap(zTop) {
        DecoCollar(zTop + 1,  5, 1.6);
        DecoCollar(zTop + 6,  5, 2.4);
        DecoCollar(zTop + 11, 4, 3.0);
    }

    // Assembly.
    // The flutes are extruded `join` mm past their nominal band so they physically overlap
    // the plinth top and the capital bottom. Together with the full-ring plinth, capital and
    // racing stripe (which tie every flute together), this makes the whole relief a single
    // connected solid -- so it stays rigid and printable even when produced on its own and
    // glued onto the mute, instead of the plinth/capital rings floating free.
    join = 3;
    DecoRays(rayCount, rayCoverage, rayDepth, rayBottom - join, rayTop + join);
    DecoStepBase(8);
    DecoStepCap(rayTop);
    DecoBeadRing(rayBottom - 4, 60, 1.8);          // beaded border straddling the plinth top
    DecoBeadRing(rayTop + 0.5, 48, 1.8);           // beaded border straddling the capital base
                                                   // (must overlap a full ring so every bead
                                                   //  is anchored -- studs over the bare gaps
                                                   //  between flutes would print as free floaters)
    DecoTripleBand((rayBottom + rayTop) / 2, 2.0); // racing stripe at mid-height
}


// ---------------------------------------------------------------------------------------
// Demo (ignored when this file is used/included elsewhere via `use`/`include`).
// ---------------------------------------------------------------------------------------
%cylinder($fn = 120, h = 244.2, r1 = 64.75, r2 = 14.75);   // ghost cone for reference
ArtDecoRelief(baseR = 64.75, topR = 14.75, coneH = 244.2);
