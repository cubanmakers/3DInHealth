
repo_path = "../../..";
part = "headmount";
spacing = 0.1;

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
    rotate(-90, [1, 0, 0])  
    translate([6, 85, -10])
    intersection() {
        union() {
            translate([0, -90, 0]) cube([40, 10, 40], center=true);
        }
        visor_franklin_headmount();
    }
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
    visor_fuenlabrada();
}

module cubantech_fuenlabrada() {
    echo("Building", part);
    if (part == "headmount") cubantech_headmount();
    else if (part == "visor") cubantech_visor();
}

cubantech_fuenlabrada();
