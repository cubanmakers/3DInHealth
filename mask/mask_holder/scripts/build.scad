
// Mask holder width
width = 8;

// Border width
border_width = 1;

// Mask holder size
size = 60;

// Strip width
strip_width = 10;

// Inner diameter
support_diameter = 30;

// Number of strip holders in part
holder_count = 2;

// Holder spacing
holder_spacing = 4;

module border(width) {
    difference() {
        translate([0,0]) {
            children();
        }
        offset(-width) {
            translate([0,0]) {
                children();
            }
        }
    }
}

module extrude_with_border(border_width, length, bevel_height) {
    union() {
        linear_extrude(length + bevel_height)
            border(border_width)
            children();
        linear_extrude(length)
            children();
    }
}

module holder() {
    border(0.5 * strip_width)
        union() {
            square([2 * strip_width, 1.5 * strip_width], center=true);
            translate([-strip_width, 0])
            circle(r=0.75 * strip_width);
            translate([strip_width, 0])
            circle(r=0.75 * strip_width);
        }
}

module place_holders(distance) {
    translate([0, distance])
        children(0);
    translate([0, -distance])
        rotate([0,0,180])
        children(0);
    translate([distance, 0])
        rotate([0,0,-90])
        children(0);
    translate([-distance, 0])
        rotate([0,0,-270])
        children(0);
}

module part_holders(count, distance, spacing) {
    place_holders(distance) {
        union() {
            children(0);
            if (holder_count > 1) {
                for (i=[0:holder_count-2]) {
                    translate([0, 0.75 * strip_width + 0.5 * holder_spacing + i * (1.5 * strip_width + holder_spacing)])
                        union() {
                            children(1);
                            translate([0, 0.5 * holder_spacing + 0.75 * strip_width])
                                children(0);
                        }
                }
            }
        }
    }
}

module mask_holder() {
    union() {
        extrude_with_border(border_width, width, border_width)
            difference() {
                union() {
                    square([2 * size, strip_width], center=true);
                    square([strip_width, 2 * size], center=true);
                    circle(r=0.6 * support_diameter + strip_width);
                }
                circle(r=0.5 * support_diameter);
            }
        linear_extrude(width + border_width)
            part_holders(holder_count, size + 0.75 * strip_width, holder_spacing) {
                holder();
                square([strip_width, holder_spacing], center=true);
            }
    }
}

mask_holder();

//            part_holders(holder_count, size + 0.75 * strip_width, holder_spacing) {
//                holder();
//                square([strip_width, holder_spacing], center=true);
//            }

