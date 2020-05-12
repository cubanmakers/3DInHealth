
repo_path = "../../..";

module visor_franklin_headmount() {
    echo("Loading", str(repo_path, "/visor/cubantech_franklin/files/visera_agarre.stl"));
    import(str(repo_path, "/visor/cubantech_franklin/files/visera_agarre.stl"));
}

module franklin_mechanism_male() {
    rotate(-90, [1, 0, 0])  
    translate([6, 85, -10])
    intersection() {
        union() {
            translate([0, -90, 0]) cube([40, 10, 40], center=true);
        }
        visor_franklin_headmount();
    }
}

module visor_fuenlabrada_headmount() {
    echo("Loading", str(repo_path, "/visor/cvm_fuenlabrada/files/DIADEMA.stl"));
    import(str(repo_path, "/visor/cvm_fuenlabrada/files/DIADEMA.stl"));
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
        franklin_mechanism_male();
        // Repair right side after diff
        translate([109.3, 186.6, 7.5])
        rotate(90, [1, 0, 0])
        cylinder(h=0.4, r=5.2, center=false);
        // Male pin right
        translate([109.3, 186, 7.5])
        rotate(-90, [1, 0, 0])
        franklin_mechanism_male();
    }
}

cubantech_headmount();