
// Antiflow visor modified by Cuban.Tech group, based on
//
// - parts borrowed from INSST-certified model , see https://github.com/cubanmakers/3DInHealth/tree/master/visor/cvm_fuenlabrada
// - modified to use the pin assembly mechanism crafted for Franklin's visor https://github.com/cubanmakers/3DInHealth/tree/master/visor/cubantech_franklin

// File system path to working copy of git respository
repo_path = "../../..";
// Part to render, one of "headmount" (default) , "visor", "pin_test"
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

// Internal constant values
function headup_pin_spacing() = 20;
function headup_hole_spacing() = 7;
function headup_hole_length() = 12;
function headup_hole_radius() = 1.5;
function headup_dim() = [50, 3, 15];

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
    resize(newsize=[14, 12, pin_height])
    rotate(-90, [1, 0, 0])  
    translate([6, 85, -10])
    intersection() {
        union() {
            translate([0, -90, 0]) cube([40, 10, 40], center=true);
        }
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
            cylinder(h=pin_height-3, r=5, center=false, $fn=100);
            cylinder(h=pin_height, r=3, center=false, $fn=100);
        }
    }
}

module cubantech_pin_head() {
        hull() {
            translate([-3.75, 0, 0])
            cube([7.5, 3, 3], center=true);
            translate([-2.75, 0, 3])
            cube([5.5, 2.5, 3], center=true);
            cylinder(h=3, r=5, center=false, $fn=100);
            cylinder(h=4.5, r=3, center=false, $fn=100);
        }
}

module cubantech_pin() {
    union() {
        // Convex pin head. Does not need support material for 3D print.
        translate([0, 0, pin_height - 4])
        cubantech_pin_head();
        // Cylindrical pin base
        cylinder(h=pin_height-3, r=5, center=false, $fn=100);
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

module custom_headmount() {
  if (hole_headup) {
      difference() {
          visor_fuenlabrada_headmount();
          translate([109.3 + headup_pin_spacing(), 33.4 + 1.5 * pin_height, 7.5])
          rotate([90, [1, 0, 0]])
          rotate(30, [0, 0, 1])
          headmount_hole();
          translate([109.3 + headup_pin_spacing(), 186 - 1.5 * pin_height, 7.5])
          rotate([-90, [1, 0, 0]])
          rotate(-30, [0, 0, 1])
          headmount_hole();
          translate([109.3 + headup_pin_spacing() + headup_hole_spacing(), 33.4 + 1.5 * pin_height, 7.5])
          rotate([90, [1, 0, 0]])
          rotate(30, [0, 0, 1])
          headmount_hole();
          translate([109.3 + headup_pin_spacing() + headup_hole_spacing(), 186 - 1.5 * pin_height, 7.5])
          rotate([-90, [1, 0, 0]])
          rotate(-30, [0, 0, 1])
          headmount_hole();
      }
  } else {
      visor_fuenlabrada_headmount();
  }
}

module cubantech_headmount() {
    union() {
        difference() {
            custom_headmount();
            union() {
                translate([109.3, 33.4, 7.5])
                rotate(90, [1, 0, 0])
                cylinder(h=10, r=5, center=false);
                translate([109.3, 196.6, 7.5])
                rotate(90, [1, 0, 0])
                cylinder(h=10, r=5, center=false);
            }
        }
        // Male pin left
        translate([109.3, 33.4, 7.5])
        rotate(90, [1, 0, 0])
        rotate(pin_pitch, [0, 0, 1])
        pin_male();
        // Male pin right
        translate([109.3, 186, 7.5])
        rotate(-90, [1, 0, 0])
        rotate(-pin_pitch, [0, 0, 1])
        pin_male();
    }
}

module cubantech_visor() {
    difference() {
        visor_fuenlabrada();
        translate([162.8, 28.7 + 1.5 * pin_height, 7.5])
        rotate(90, [1, 0, 0])
        pin_hole();
        translate([162.8, 191.2 + 1.5 * pin_height, 7.5])
        rotate(90, [1, 0, 0])
        pin_hole();
    }
}

module pin_test() {
    union() {
        intersection() {
            cubantech_headmount();
            union() {
                translate([109.3, 33.4, 7.5])
                cube([30, 30, 30], center=true);
                translate([109.3, 186, 7.5])
                cube([30, 30, 30], center=true);
            }
        }
        intersection() {
            cubantech_visor();
            union() {
                translate([162.8, 28.7, 7.5])
                cube([30, 30, 30], center=true);
                translate([162.8, 191.2, 7.5])
                cube([30, 30, 30], center=true);
            }
        }
    }
}

module cubantech_fuenlabrada() {
    echo("Building", part);
    if (part == "headmount") cubantech_headmount();
    else if (part == "visor") cubantech_visor();
    else if (part == "pin_test") pin_test();
}

module cubantech_fuenlabrada_main() {
    if (!(part == "headmount" || part == "visor" || part == "pin_test"))
        echo("Invalid param", "part", part);
    else if (!(pin == "nosupport" || pin == "franklin" || pin == "franklin_csg"))
        echo("Invalid param", "pin", pin);
    else
        cubantech_fuenlabrada();
}

cubantech_fuenlabrada_main();

