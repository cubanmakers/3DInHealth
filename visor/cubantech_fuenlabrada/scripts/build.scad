
repo_path = ".";

module visor_franklin_headmount() {
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

module visor_fuenlabrada() {
    import(str(repo_path, "/visor/cvm_fuenlabrada/files/DIADEMA.stl"));
}

franklin_mechanism_male();
