
// Part to render
part = "valve"; // [valve:Valve consolidated parts,tube:Inner tube,lock:Rotary lock,void:Mechanical tolerance test]
plug_d_min = 3;
plug_d_max = 4.4;
plug_h = 3.5;
hole_d = 2.2;
connector_d = 6.3;
// Lock tube wrapper height
lock_h1 = 4.8;
// Size of rotary lock hinge
lock_h2 = 2.5;
// Lock height
lock_h = 10.3;
lock_d = 10.5;
lock_w = 1;
lock_hole_w = 0.9;
clearance = 0.15;

/* HHidden */
gap = 0.5 * (plug_d_max - plug_d_min);

module tcone(r, w, h, n) {
    for (i = [0:n-1]) {
        translate([0, 0, i*h])
            cylinder(r1=r, r2=r-w, h=h);
    }
}

module inner_connector_head() {
    h1 = lock_h - lock_h1 - 4 * gap;
    // Border with plastic washer
    cylinder(r=0.5 * connector_d, 2 * gap);
    translate([0,0,2 * gap])
    cylinder(r=0.5 * connector_d - 2 * gap, 2 * gap);
    translate([0,0,4 * gap])
    cylinder(r=0.5 * connector_d, h1);

    // Part assembly limit
    translate([0,0,4 * gap + h1])
    cylinder(r=0.5 * lock_d - lock_w - clearance, gap);

    // Hidden tube continuation
    translate([0,0,4 * gap + h1 + gap])
    cylinder(r=0.5 * plug_d_max, lock_h1 - 2 * gap);

    // Part assembly limit
    translate([0,0,4 * gap + h1 + gap + lock_h1 - 2 * gap])
    cylinder(r=0.5 * connector_d, gap);
}

module inner_connector() {
    h1 = lock_h - lock_h1 - 4 * gap;
    difference() {
        union() {
            tcone(0.5 *plug_d_max, gap, plug_h, 4);
            translate([0,0,-lock_h])
            inner_connector_head();
        }
        translate([0,0,-lock_h1 - 8 * gap - h1 - 0.1])
        cylinder(r=0.5 * hole_d, h=lock_h1 + 8 * gap + h1 + 4 * plug_h + 0.2);
    }
}

module connector_lock() {
    lock_hdiff = lock_h - lock_h1 + 0.01;
    lock_ddiff = lock_d + 0.01;
    lock_hole_height = lock_h - lock_h1 - lock_h2;
    lock_hole_angle = asin(lock_hole_w / lock_d);
    lock_groove_height = 0.2 * lock_h1;
    difference() {
        // Lock boundary
        cylinder(r=0.5 * lock_d, h=lock_h);
        // Lock quarters at the top
        translate([0,0,-0.01]) {
            cylinder(r=0.5 * lock_d - lock_w, h=lock_hdiff);
            cube([lock_ddiff, lock_ddiff, lock_hdiff]);
            translate([-lock_ddiff, -lock_ddiff, 0])
            cube([lock_ddiff, lock_ddiff, lock_hdiff]);
        }
        // Lock holes
        translate([0,0,lock_h2 + 0.5 * lock_hole_height])
        rotate([0,0,lock_hole_angle])
            cube([lock_hole_w, lock_d + 0.02, lock_hole_height], center=true);
        // External groove
        translate([0,0,lock_hdiff + lock_groove_height])
        difference() {
            cylinder(r=0.5 * lock_d + 0.01, h=lock_groove_height);
            cylinder(r=0.5 * lock_d - 0.2, h=lock_groove_height);
        }
        translate([0,0,lock_hdiff + 3 * lock_groove_height])
        difference() {
            cylinder(r=0.5 * lock_d + 0.01, h=lock_groove_height);
            cylinder(r=0.5 * lock_d - 0.2, h=lock_groove_height);
        }
        // Space for inner connector limit
        translate([0,0,lock_h - lock_h1 - 0.01])
            cylinder(r1=0.5 * lock_d - lock_w - 0.5 * clearance, r2=0.5 * lock_d - lock_w - clearance, h=gap + clearance + 0.01);
        // Hole for inner connector to go through
        cylinder(r=0.5 * plug_d_max + clearance, h=lock_h + 0.01);
        // Space for inner connector limit
        translate([0,0,lock_h - gap - clearance])
            cylinder(r1=0.5 * connector_d + 2 * clearance, r2=0.5 * connector_d + clearance, h=gap + clearance + 0.01);
    }
}

module lock_hinge() {
    
}

$fn = 100;


module main() {
    if (part=="valve") {
        union() {
            translate([0,0,lock_h])
                inner_connector();
            connector_lock();
        }
    } else if (part == "tube") {
        translate([0,0,lock_h])
            inner_connector();
        %connector_lock();
    } else if (part == "lock") {
        %translate([0,0,lock_h])
            inner_connector();
        connector_lock();
    } else if (part == "void") {
        intersection() {
            inner_connector();
            translate([0,0,-lock_h])
                connector_lock();
        }
    }
}

main();