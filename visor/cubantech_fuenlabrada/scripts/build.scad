
// File system path to working copy of git respository
repo_path = "../../..";
// Part to render, one of "headmount" , "visor"
part = "headmount";
// Spacing to use between moving parts
spacing = 0.1;
// Head mount pin height
pin_height = 10;
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
    resize(newsize=[0, 0, pin_height])
    rotate(-90, [1, 0, 0])  
    translate([6, 85, -10])
    intersection() {
        union() {
            translate([0, -90, 0]) cube([40, 10, 40], center=true);
        }
        visor_franklin_headmount();
    }
}

module franklin_mechanism_hole() {
    rotate(pin_pitch, [0, 0, 1])
    linear_extrude(height=3 * pin_height)
    offset(delta=spacing, chamfer=true)
    projection(cut = false)
    franklin_mechanism_pin();
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
        // Repair left side after diff
        translate([109.3, 33.5, 7.5])
        rotate(90, [1, 0, 0])
        cylinder(h=0.4, r=5, center=false);
        // Male pin left
        translate([109.3, 33.4, 7.5])
        rotate(90, [1, 0, 0])
        franklin_mechanism_pin();
        // Repair right side after diff
        translate([109.3, 186.6, 7.5])
        rotate(90, [1, 0, 0])
        cylinder(h=0.4, r=5.2, center=false);
        // Male pin right
        translate([109.3, 186, 7.5])
        rotate(-90, [1, 0, 0])
        franklin_mechanism_pin();
    }
}

module cubantech_visor() {
    difference() {
        visor_fuenlabrada();
        translate([162.8, 28.7 + 1.5 * pin_height, 7.5])
        rotate(90, [1, 0, 0])
        franklin_mechanism_hole();
        translate([162.8, 191.2 + 1.5 * pin_height, 7.5])
        rotate(90, [1, 0, 0])
        franklin_mechanism_hole();
    }
}

module cubantech_fuenlabrada() {
    echo("Building", part);
    if (part == "headmount") cubantech_headmount();
    else if (part == "visor") cubantech_visor();
}

cubantech_fuenlabrada();
