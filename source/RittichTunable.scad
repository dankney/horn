// Rittich straight mute -- tunable variant.
//
// Tuning is accomplished by lengthening/shortening the acoustic tube inside the body.
// The original one-piece InnerTube is shortened by 20mm (140 -> 120mm) and given an
// internally-threaded "nut" (a trapezoidal-thread mount, same convention as DePolisMute)
// fused into its BASE. A separate, externally-threaded TuningTube screws up into that nut
// and telescopes downward, extending the column by up to 50mm.
//
// The body prints tip-down (apex on the bed) so the fixed tube hangs off the cone wall junction
// rather than floating; the collar is therefore bevelled into the tube wall, not stepped.
//
// The nut sits at the base (not the tip) so that as the TuningTube is unscrewed downward
// its threaded shank feeds into the open interior below the fixed tube -- a nut at the tip
// would jam the thread against the narrow bore. The threads themselves are the retention
// mechanism: the thread's lead angle (~1.5 deg) is far below the PLA-on-PLA friction angle
// (~17 deg), so the joint is strongly self-locking -- the TuningTube stays wherever it is set
// and moves only when turned. A collar below the thread stops it being wound up past the nut and
// trapped, and the thread is run long enough that it cannot reach the end of its travel -- so the
// tube can never drop free into the sealed mute. See TuningTube for why no collar above the
// thread is possible.
//
// The TuningTube is installed before the mute bottom is glued. Tuning after assembly is done
// through the top hole with a long driver engaging the notches in the TuningTube's drive stem.
//
// Inner Geometry
//  AdjustableTubeLength: 120mm fixed + 0..50mm telescoping extension (hard-stopped at both ends)
//  AdjustableTubeInternalDiameter: 38.1mm
//  OpenEndDiameter: 27.5mm
//  BaseDiameter: 127.5mm
//  TotalHeight: 244.2mm
//
// Dependencies
//  -- https://github.com/BelfrySCAD/BOSL2

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

CircleResolution = 360;
WallThickness = 1;

// --- Fixed inner tube (shortened by 20mm from the original 140mm) ---
TubeInnerRadius = 19.05;                          // 38.1mm bore (1.5")
TubeWall        = 1;
TubeTopZ        = 218.559;                         // top anchors to the cone wall (unchanged)
FixedTubeHeight = 120;                             // was 140 -- shortened by 20mm
FixedTubeBaseZ  = TubeTopZ - FixedTubeHeight;      // 98.559

// --- Telescoping tuning mechanism (BOSL2 trapezoidal thread) ---
ThreadPitch     = 3;
ThreadRootR     = TubeInnerRadius;                 // internal-thread root radius in the nut
ThreadClearance = 1.6;                             // diametral clearance, applied to the tuning tube only
                                                   // (1.0 printed too tight: only ~0.13mm per flank)
MaxExtension    = 50;                              // preview figure only -- the tube itself reaches
                                                   // the mute bottom at 92.1mm, see TuningTube
NutHeight       = 25;                              // internally-threaded collar at the tube base
NutOuterR       = 23;                              // shell around the internal thread
NutBevelAngle   = 35;                              // collar-to-wall taper, degrees from vertical

// --- Tuning tube (separate printed part) ---
TuneWall        = 2;
TuneStemLen     = 8;                               // plain drive stem above the thread
TuneDriveNotch  = 3;                               // notch width for a spanner/driver
TuneStopHeight  = 1.5;                             // up-stop collar under the thread -- kept thin,
                                                   // since it sets the shortest column (121.5mm)
TuneThreadLen   = 100;                             // full nut engagement to +2in (196.5mm column),
                                                   // still captive when resting on the mute bottom


module InnerGeometry(openEndDiameter = 27.5, baseDiameter = 127.5, totalHeight = 244.2) {
    cylinder ($fn = CircleResolution, h = totalHeight, r1 = baseDiameter / 2, r2 = openEndDiameter / 2);
}

module OuterGeometry(openEndDiameter = 27.5 + WallThickness * 2, baseDiameter = 127.5 + WallThickness * 2, totalHeight = 244.2) {
    cylinder ($fn = CircleResolution, h = totalHeight, r1 = baseDiameter / 2, r2 = openEndDiameter / 2);
}

// Shortened fixed inner tube with an internally-threaded nut fused into its base.
// The plain wall runs above the nut; the nut is a solid collar with the trapezoidal thread
// carved out (leaving crest material to thread against), so its bore is defined by the thread
// alone -- do NOT pre-drill it or there is nothing left to cut threads into.
module InnerTube(baseZ = FixedTubeBaseZ, height = FixedTubeHeight, innerRadius = TubeInnerRadius, wallThickness = TubeWall) {
    outerRadius = innerRadius + wallThickness;

    // The body prints tip-down, so model-z runs downward through the printer: the collar's
    // step out from the tube wall to NutOuterR would land as a flat, downward-facing annular
    // ledge -- an unsupported arch. Taper it instead, at NutBevelAngle from vertical.
    bevelHeight = (NutOuterR - outerRadius) / tan(NutBevelAngle);

    difference() {
        union() {
            // plain wall above the nut, blended down onto the collar by a conical bevel
            translate([0, 0, baseZ + NutHeight])
                difference() {
                    union() {
                        cylinder ($fn = CircleResolution, h = height - NutHeight, r = outerRadius);
                        cylinder ($fn = CircleResolution, h = bevelHeight, r1 = NutOuterR, r2 = outerRadius);
                    }
                    translate([0, 0, -0.1])
                        cylinder ($fn = CircleResolution, h = height - NutHeight + 0.2, r = innerRadius);
                }
            // threaded nut collar at the base (bored only by the thread cut below)
            translate([0, 0, baseZ])
                cylinder ($fn = CircleResolution, h = NutHeight, r = NutOuterR);
        }
        // internal trapezoidal thread -> defines the nut bore (root radius = ThreadRootR)
        translate([0, 0, baseZ - 0.01])
            trapezoidal_threaded_rod(d = 2 * ThreadRootR, l = NutHeight + 0.02,
                                     pitch = ThreadPitch, internal = true,
                                     anchor = BOTTOM, $fn = CircleResolution);
    }
}

module InnerTubeReinforcement(tubeBaseZ = FixedTubeBaseZ, tubeHeight = FixedTubeHeight, innerRadius = TubeInnerRadius, wallThickness = TubeWall, reinforcementHeight = 8, reinforcementDepth = 3, bevelHeight = 2, topBevelHeight = 1.5) {
    // Must match InnerTube's outer radius exactly, or the fillet floats clear of the tube and
    // gets clipped away entirely by the InnerGeometry intersection below.
    outerRadius = innerRadius + wallThickness;
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

// Separate, externally-threaded tuning tube.
//
// Retention: the trapezoidal thread (pitch 3 on a ~35.6mm pitch diameter) has a ~1.5 deg lead
// angle, well inside the ~17 deg PLA-on-PLA friction angle, so the tube is strongly self-locking.
// It holds any position against gravity and playing vibration and moves only when turned.
//
// Why there is no collar at the top. The tube installs from inside the open mute base, moving up:
// the drive stem enters the nut first, then the threaded shank screws in behind it. So everything
// above the thread has to pass clean through the nut, and the nut's narrowest point is its thread
// crest (nutCrestR). Any unthreaded feature above the thread wider than that jams against the nut
// before the thread can engage and the tube can never be fitted -- which rules out a hard
// down-stop on the tube entirely. The stem is deliberately kept under nutCrestR for this reason.
//
// Travel limits, given that:
//  -- UP (extension 0): a collar below the thread seats on the nut's underside. It never has to
//     pass through the nut, so it is safe. Without it the tube can be wound up clear of the nut,
//     where its thread is too wide to fall back through -- trapped inside a glued-shut mute.
//  -- DOWN: handled by thread length rather than a stop. The thread is longer than the tube can
//     physically travel: the bottom collar reaches the glued mute bottom at 92.1mm of extension
//     with 7.9mm of thread still inside the nut.
//     The thread cannot run out, so the tube cannot drop free into the sealed mute. Over-extending
//     past MaxExtension is possible but self-correcting -- it just bottoms out, and screws back.
module TuningTube() {
    extMajorD  = 2 * ThreadRootR - ThreadClearance;      // external thread major diameter
    nutCrestR  = ThreadRootR - ThreadPitch / 2;          // innermost radius of the nut thread
    stemOuterR = nutCrestR - 0.5;                        // clears the nut crest so it passes through
    bore       = stemOuterR - TuneWall;
    botStopR   = NutOuterR - 2;                          // seats flat on the nut's underside
    threadLen  = TuneThreadLen;
    threadZ    = TuneStopHeight;
    stemZ      = threadZ + threadLen;
    totalLen   = stemZ + TuneStemLen;

    difference() {
        union() {
            // up-stop -- seats on the nut underside at extension 0
            cylinder ($fn = CircleResolution, h = TuneStopHeight, r = botStopR);
            // external threaded shank
            translate([0, 0, threadZ])
                trapezoidal_threaded_rod(d = extMajorD, l = threadLen, pitch = ThreadPitch,
                                         anchor = BOTTOM, $fn = CircleResolution);
            // plain drive stem -- must stay under nutCrestR so it passes the nut on installation
            translate([0, 0, stemZ])
                cylinder ($fn = CircleResolution, h = TuneStemLen, r = stemOuterR);
        }
        // acoustic bore, all the way through
        translate([0, 0, -0.1])
            cylinder ($fn = CircleResolution, h = totalLen + 0.2, r = bore);
        // drive notches in the top rim
        for (a = [0, 90])
            rotate([0, 0, a])
                translate([0, 0, totalLen - 2])
                    cube([2 * stemOuterR + 2, TuneDriveNotch, 4], center = true);
    }
}

module MuteBody() {
    union() {
        difference() {
            OuterGeometry();
            InnerGeometry();
        }
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

// Preview: cross-sectioned body with the tuning tube screwed in. extension = 0 puts the tube
// base flush with the fixed tube base; extension = MaxExtension is fully lowered.
module TunableAssemblyCrossSection(extension = MaxExtension / 2) {
    MuteBodyCrossSection();
    intersection() {
        translate([0, 0, FixedTubeBaseZ - extension - TuneStopHeight])
            TuningTube();
        translate([0, -1000, -1])
            cube([1000, 2000, 1000]);
    }
}

// Render selector. "print" = body + tuning tube laid out for printing;
// "assembly" = cross-section of the body with the tuning tube installed (for inspection).
RenderMode = "print";

Extension = MaxExtension / 2;   // preview extension for RenderMode == "assembly"

if (RenderMode == "assembly") {
    TunableAssemblyCrossSection(Extension);
} else {
    MuteBody();
    // Tuning tube laid out for printing next to the body.
    translate([100, 0, 0])
        TuningTube();
}

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

if (RenderMode != "assembly")
    translate([250, 0, 0])
        MuteBottomWithHoles();
