
// Antiflow visor modified by Cuban.Tech group, based on
//
// - parts borrowed from INSST-certified model , see https://github.com/cubanmakers/3DInHealth/tree/master/visor/cvm_fuenlabrada
// - modified to use the pin assembly mechanism crafted for Franklin's visor https://github.com/cubanmakers/3DInHealth/tree/master/visor/cubantech_franklin

//--------------------
// Model parameters
//--------------------

// File system path to working copy of git respository
repo_path = "../../..";
// Part to render, one of "headmount" (default) , "visor", "pin_test", "assembled"
part = "headmount";
// Spacing to use between moving parts
spacing = 0.6;
// Pin geometry one of "franklin", "nosupport", "franklin_csg" (default)
pin = "franklin_csg";
// Head mount pin height
pin_height = 13.5;
// Pin rotation angle
pin_pitch = 90;
// Hole rotation angle relative to pin
hole_angle = -295;
// Insert holes to tighten visor atop the head near coronal suture
hole_headup = false;
// Shorten headmount sides , like popular Hancoh visor
small = false;
// Geomerty detail quality factor
fn = 100;


// Internal constant values for Frankin's visor geometry
function franklin_pin_dim() = [14, 12, pin_height];
function franklin_pin_pos() = [6, 85, -10];

// Internal constant values for INSST-certified visor geometry
function cvm_visor_height() = 15;
function cvm_headmount_thickness() = 1.2;
function cvm_pos_pin_left() = [109.3, 33.4, cvm_visor_height() / 2];
function cvm_pos_pin_right() = [109.3, 186, cvm_visor_height() / 2];
function cvm_pos_hole_left() = [162.8, 28.7, cvm_visor_height() / 2];
function cvm_pos_hole_right() = [162.8, 191.2, cvm_visor_height() / 2];

// Internal constant values for holes to tighten visor atop the head
function headup_pin_spacing() = 23;
function headup_hole_spacing() = 7;
function headup_hole_length() = 12;
function headup_hole_radius() = 1.5;
function headup_dim() = [50, 3, 15];

// Internal constants for building small visor
function pos_small_tip_left() = cvm_pos_pin_left() + [headup_pin_spacing() - 0.5 * headup_hole_length(), 0, -cvm_visor_height() / 2];
function pos_small_tip_right() = cvm_pos_pin_right() + [headup_pin_spacing() - 0.5 * headup_hole_length(), 0, -cvm_visor_height() / 2];
function small_tip_length() = 23;
function small_tip_align_angle() = 2.5;

module import_model(subpath="") {
    echo("Loading", str(repo_path, subpath));
    import(str(repo_path, subpath));
}

module visor_franklin_headmount() {
    import_model("/visor/cubantech_franklin/files/visera_agarre.stl");
}

module visor_fuenlabrada_headmount() {
    import_model("/visor/cvm_fuenlabrada/files/DIADEMA.stl");
}

module visor_fuenlabrada() {
    import_model("/visor/cvm_fuenlabrada/files/PORTAPANTALLA.stl");
}

module part_headup_sandra() {
    import_model("/visor/cubantech_sandra/files/pieza_agarre_cabeza.stl");
}

module cubantech_headup() {
    resize(headup_dim())
    part_headup_sandra();
}

module franklin_mechanism_pin() {
    resize(newsize=franklin_pin_dim())
    rotate(-90, [1, 0, 0])  
    translate(franklin_pin_pos())
    intersection() {
        translate([0, -90, 0])
        cube([40, 10, 40], center=true);
        visor_franklin_headmount();
    }
}

module franklin_csg_pin() {
    union() {
        hull() {
            translate([-3.75, 0, pin_height - 4.5])
            cube([7.5, 3, 3], center=true);
            translate([-2.75, 0, pin_height - 1.5])
            cube([5.5, 2.5, 3], center=true);
        }
        hull() {
            cylinder(h=pin_height-3, r=5, center=false, $fn=fn);
            cylinder(h=pin_height, r=3, center=false, $fn=fn);
        }
    }
}

module cubantech_pin_head() {
        hull() {
            translate([-3.75, 0, 0])
            cube([7.5, 3, 3], center=true);
            translate([-2.75, 0, 3])
            cube([5.5, 2.5, 3], center=true);
            cylinder(h=3, r=5, center=false, $fn=fn);
            cylinder(h=4.5, r=3, center=false, $fn=fn);
        }
}

module cubantech_pin() {
    union() {
        // Convex pin head. Does not need support material for 3D print.
        translate([0, 0, pin_height - 4])
        cubantech_pin_head();
        // Cylindrical pin base
        cylinder(h=pin_height-3, r=5, center=false, $fn=fn);
    }
}

module pin_hole() {
    if (spacing < 0.6) {
        echo("WARNING", "Tolerance tests revealed ", spacing, "mm is not enough for pin to fit into hole");
    }
    rotate(pin_pitch + hole_angle, [0, 0, 1])
    linear_extrude(height=3 * pin_height)
    offset(delta=spacing, chamfer=true)
    projection(cut = false)
    pin_male();
}

module headmount_hole() {
    circle_x = (headup_hole_length() - 2 * headup_hole_radius()) / 2;
    linear_extrude(height=3 * pin_height)
    union() {
        translate([circle_x, 0, 0], $fn=40)
        circle(r=headup_hole_radius());
        translate([-circle_x, 0, 0], $fn=40)
        circle(r=headup_hole_radius());
        square([2 * circle_x, 2 * headup_hole_radius()], center=true);
    }
}


module pin_male() {
    if (pin_height < 13.5) {
        echo("WARNING", "Pin height of ". pin_height, " mm might not fit in visor hole");
    }
    if (pin == "franklin")
        franklin_mechanism_pin();
    else if (pin == "nosupport")
        cubantech_pin();
    else if (pin == "franklin_csg")
        franklin_csg_pin();
    else
        echo("Invalid pin type", pin);
}

module headmount_small_tip_left() {
    translate(-pos_small_tip_left())
    intersection() {
        translate(pos_small_tip_left() - [3, 0, 0])
        cube([small_tip_length(), 2 * cvm_headmount_thickness() + 3, cvm_visor_height()]);
        visor_fuenlabrada_headmount();
    }
}

module headmount_small_patch_left() {
    hull() {
        headmount_small_tip_left();
        translate([2,-cvm_headmount_thickness(),0])
        resize([headup_pin_spacing() - 2,0,0])
        headmount_small_tip_left();
        // TODO: small_tip_length() ?
        translate([small_tip_length() - 3, 2.59, cvm_visor_height() / 2])
        rotate(small_tip_align_angle(), [0,0,1])
        rotate(90, [1,0,0])
        cylinder(h=2.33, r=cvm_visor_height() / 2, center=true, $fn=fn);
    }
}

module headmount_small_tip_right() {
    translate(-pos_small_tip_right())
    intersection() {
        visor_fuenlabrada_headmount();
        translate(pos_small_tip_right() - [3, 3, 0])
        cube([small_tip_length(), 2 * cvm_headmount_thickness() + 3, cvm_visor_height()]);
    }
}

module headmount_small_patch_right() {
    hull() {
        headmount_small_tip_right();
        translate([2,cvm_headmount_thickness(),0])
        resize([headup_pin_spacing() - 2,0,0])
        headmount_small_tip_right();
        // TODO: small_tip_length() ?
        translate([small_tip_length() - 3, -1.0, cvm_visor_height() / 2])
        rotate(-small_tip_align_angle(), [0,0,1])
        rotate(90, [1,0,0])
        cylinder(h=2.33, r=cvm_visor_height() / 2, center=true, $fn=fn);
    }
}

module headmount_for_size() {
    if (small) {
        union() {
            difference() {
                visor_fuenlabrada_headmount();
                translate([109.3 + headup_pin_spacing() + 2 * headup_hole_spacing(), 33.4, 0])
                cube([70, 25, 15], centered=true);
                translate([109.3 + headup_pin_spacing() + 2 * headup_hole_spacing(), 186 - 25, 0])
                cube([70, 25, 15], centered=true);
            }
            translate(pos_small_tip_left())
            headmount_small_patch_left();
            translate(pos_small_tip_right())
            headmount_small_patch_right();
        }
    }
    else {
        visor_fuenlabrada_headmount();
    }
}

module custom_headmount() {
  if (hole_headup || small) {
      difference() {
          headmount_for_size();
          translate(cvm_pos_pin_left() + [headup_pin_spacing(), 1.5 * pin_height, 0])
          rotate([90, [1, 0, 0]])
          rotate(30, [0, 0, 1])
          headmount_hole();
          translate(cvm_pos_pin_right() + [headup_pin_spacing(), - 1.5 * pin_height, 0])
          rotate([-90, [1, 0, 0]])
          rotate(-30, [0, 0, 1])
          headmount_hole();
          translate(cvm_pos_pin_left() + [headup_pin_spacing() + headup_hole_spacing(), 1.5 * pin_height, 0])
          rotate([90, [1, 0, 0]])
          rotate(30, [0, 0, 1])
          headmount_hole();
          translate(cvm_pos_pin_right() + [headup_pin_spacing() + headup_hole_spacing(), -1.5 * pin_height, 0])
          rotate([-90, [1, 0, 0]])
          rotate(-30, [0, 0, 1])
          headmount_hole();
      }
  } else {
    headmount_for_size();
  }
}

module cubantech_headmount() {
    union() {
        difference() {
            custom_headmount();
            union() {
                translate(cvm_pos_pin_left())
                rotate(90, [1, 0, 0])
                cylinder(h=10, r=5, center=false);
                translate(cvm_pos_pin_right() + [0, 16.6, 0])
                rotate(90, [1, 0, 0])
                cylinder(h=10, r=5, center=false);
            }
        }
        // Male pin left
        translate(cvm_pos_pin_left())
        rotate(90, [1, 0, 0])
        rotate(pin_pitch, [0, 0, 1])
        pin_male();
        // Male pin right
        translate(cvm_pos_pin_right())
        rotate(-90, [1, 0, 0])
        rotate(-pin_pitch, [0, 0, 1])
        pin_male();
    }
}

module cubantech_visor() {
    hole_offset = [0, 1.5 * pin_height, 0];
    difference() {
        visor_fuenlabrada();
        translate(cvm_pos_hole_left() + hole_offset)
        rotate(90, [1, 0, 0])
        pin_hole();
        translate(cvm_pos_hole_right() + hole_offset)
        rotate(90, [1, 0, 0])
        pin_hole();
    }
}

module pin_test() {
    union() {
        intersection() {
            cubantech_headmount();
            union() {
                translate(cvm_pos_pin_left())
                cube([30, 30, 30], center=true);
                translate(cvm_pos_pin_right())
                cube([30, 30, 30], center=true);
            }
        }
        intersection() {
            cubantech_visor();
            union() {
                translate(cvm_pos_hole_left())
                cube([30, 30, 30], center=true);
                translate(cvm_pos_hole_right())
                cube([30, 30, 30], center=true);
            }
        }
    }
}

module cubantech_visor_assembled() {
    color("red")
    translate([cvm_pos_hole_left()[0] - cvm_pos_pin_left()[0], 0, 0])
    cubantech_headmount();
    color("blue")
    cubantech_visor();
}

module cubantech_fuenlabrada() {
    echo("Building", part);
    if (part == "headmount") cubantech_headmount();
    else if (part == "visor") cubantech_visor();
    else if (part == "pin_test") pin_test();
    else if (part == "assembled") cubantech_visor_assembled();
}

module cubantech_fuenlabrada_main() {
    if (!(part == "headmount" || part == "visor" || part == "pin_test" || part == "assembled"))
        echo("Invalid param", "part", part);
    else if (!(pin == "nosupport" || pin == "franklin" || pin == "franklin_csg"))
        echo("Invalid param", "pin", pin);
    else
        cubantech_fuenlabrada();
}

cubantech_fuenlabrada_main();
