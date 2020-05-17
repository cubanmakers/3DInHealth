
// Antiflow visor modified by Cuban.Tech group, based on
//
// - parts borrowed from INSST-certified model , see https://github.com/cubanmakers/3DInHealth/tree/master/visor/cvm_fuenlabrada
// - modified to use the pin assembly mechanism crafted for Franklin's visor https://github.com/cubanmakers/3DInHealth/tree/master/visor/cubantech_franklin

// File system path to working copy of git respository
repo_path = "../../..";
// Part to render, one of "headmount" (default) , "visor"
part = "headmount";
// Spacing to use between moving parts
spacing = 0.4;
// Pin geometry one of "franklin", "nosupport" (default)
pin = "nosupport";
// Head mount pin height
pin_height = 11.5;
// Pin rotation angle
pin_pitch = -155;

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
    rotate(pin_pitch, [0, 0, 1])
    linear_extrude(height=3 * pin_height)
    offset(delta=spacing, chamfer=true)
    projection(cut = false)
    pin_male();
}

module pin_male() {
    if (pin == "franklin")
        franklin_mechanism_pin();
    else if (pin == "nosupport")
        cubantech_pin();
    else
        echo("Invalid pin type", pin);
}

module cubantech_headmount() {
    union() {
        difference() {
            visor_fuenlabrada_headmount();
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
        pin_male();
        // Male pin right
        translate([109.3, 186, 7.5])
        rotate(-90, [1, 0, 0])
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

module cubantech_fuenlabrada() {
    echo("Building", part);
    if (part == "headmount") cubantech_headmount();
    else if (part == "visor") cubantech_visor();
}

module cubantech_fuenlabrada_main() {
    if (!(part == "headmount" || part == "visor"))
        echo("Invalid param", "part", part);
    else if (!(pin == "nosupport" || pin == "franklin"))
        echo("Invalid param", "pin", pin);
    else
        cubantech_fuenlabrada();

}

cubantech_fuenlabrada_main();
