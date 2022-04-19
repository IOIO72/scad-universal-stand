/*

Universal Stand
Customizable stand for your devices and other stuff.

by IOIO72 aka Tamio Patrick Honma (https://honma.de)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.


Updates

2022-02-21: Add experimental feature Reduce Filament Consumption


Description

Whether you want to use a device in an angled position or present something in an optimal orientation, you can design a stand to suit your needs.

This model is customizable to generate STL files for your individual use case. Included in this package are some examples and inspirations for smartphones, tablets, notebooks, business cards, table name cards, print magazines, keyboards, etc.


Customization

Basic configuration:

1. Measure the `width` and `depth` of your device or object in millimeters and enter the values into the customizer.
2. Determine the height of the device at the front of the stand that will prevent the device or object from sliding off the stand. This can be the measured height of your device or object, if applicable. Enter the value of the `stopper height` into the customizer.
3. Enter the desired `angle` at which you want your device or object to be presented, which is the main purpose of the stand.

Foot configuration:

1. Define the `foot depth` to prevent the stand of sliding, especially concerning interactive devices. You should add a rubber tape on the bottom of the foot or a weight on top of it.
2. You are able to set the `foot orientation` behind, centered or in front of the stand leg.

Advanced configuration:

1. Define the `stand thickness` in relationship of the steadiness requirements and material consumption.
2. Define the `height` of the table plate for your device. The height is the thickness of the plate on which your device will be placed, if you will.
3. Set the number of fragments (`$fn`), especially to smooth or de-smooth the curve of the leg.

Reduce Filament Consumption (experimental) configuration:

1. Use these experimental parameters with caution. Be careful not to overstress your printer's ability to print overhangs. Also, find a good compromise between stand strength and filament reduction. You can also increase the `stand thickness` in the Advanced Configuration section.
2. The higher the `decrease percentage`, the larger the hole and the lower the steadiness of the stand.
3. To apply the filament consumption reduction to the table top of the stand, enable the `decrease table` option.
4. To apply the filament consumption reduction to the back plate (leg) of the stand, activate the `decrease back` option.

Tips:

* To test your configured stand, you could consider to cancel the print after some layers and test the angle and steadiness.
* If you use the stand for an interactive device, you should glue a rubber tape on the bottom of the foot to prevent the stand to slide away while using the device. To improve the adhesion, you may increase the depth of the foot in the foot options. Additionally you may add a weight on top of the foot.


Use OpenSCAD

As the Thingiverse customizer has some issues, it's better to use OpenSCAD instead.

1. **Download and install:** [OpenSCAD](http://openscad.org/) version 2021.01 or newer
2. **Download:** The *.scad file of this model.
3. **Start** OpenSCAD and **open** the *.scad file in it.
4. **Open the customizer** via the menu "Window/Customizer"

Now you can configure the model and use the `F5` key to render the preview of your changes.

Export your STL file:

If you're done with your model settings, you can export the STL file:

1. Render the mesh by pressing the `F6` key.
2. Wait until the rendering is finished. This might take some minutes.
3. Export the STL file by pressing the `F7` key.

Optionally save your configuration:

If you like to use your configuration as a template for further models, it's a good idea, to save your configuration:

1. Click the `+` symbol in the customizer, which you find beside the configuration selector drop-down in the second line of the customizer.
2. Give your configuration a name.

Use the drop-down menu to access your saved configurations.


Help others and post a Remix

Your configuration may be helpful for others. Consider to upload your STL file as a [remake of this model](https://www.thingiverse.com/thing:5245158/remix).
*/


/* [Basic] */

// Width of your device
width = 155;

// Depth of your device
depth = 63;

// Height of the bottom stopper ≈ device height
stopper_height = 12;

// Angle
angle = 35;


/* [Foot] */

// Depth of stand foot
foot_depth = 8;

// Foot orientation in relation to the leg of the stand
foot_orientation = "behind"; // ["behind", "centered", "infront":"in front"]


/* [Advanced] */

// Thickness of stand walls
stand_thickness = 1.8;

// Height of the table plate
height = 1.8;


// Number of fragments
$fn = 100; // [1:150]


/* [Reduce Filament Consumption (experimental)] */

// Percentage of decrease
decrease_percentage = 85; // [50:95]

// Decrease for table plate
decrease_table = false;

// Decrease for back plate
decrease_back = false;


function decrease(size, percent) = size * percent / 100;

module printable_rotation(width, height) {
  rotate([0, 90, 90])
  translate([-width, height, 0])
  children();
};

module stand(width, depth, height, thickness) {
  rotate_extrude(angle = angle) // extrudes to pribtable rotation
  translate([-height, 0, 0])
  rotate([0, 0, 90])
  translate([0, depth - thickness, 0])
  square([width, thickness]);
};

module stand_through_hole(through_hole, w, h) {
  if (through_hole) {
    rotate([180, 270, 90 - ((180 - angle) / 2)])
    translate([w, h, 0])
    rotate([180, 0, 0])
    scale([1, 1, 1000])
    children();
  } else {
    children();
  };
};

module reduce_filamant(reduce = false, through_hole = false, width, height, depth) {
  w = decrease(width, decrease_percentage);
  h = decrease(height, decrease_percentage);
  if (reduce) {
    difference() {
      children();
      stand_through_hole(through_hole, 0, height / 2)
      translate([width / 2, height / 2, -depth / 2])
      linear_extrude(depth * 2)
      resize([w, h])
      circle(r=w);
    };
  } else {
    children();
  };
};


/* Stand / Back Plate */
reduce_filamant(decrease_back, true, width, sin(angle) * depth, height)
stand(width, depth, height, stand_thickness);

/* Table Plate */
printable_rotation(width, height)
reduce_filamant(decrease_table, false, width, depth, height)
cube([width, depth, height]);

/* Stopper */
printable_rotation(width, height - stand_thickness)
cube([width, stand_thickness, stopper_height]);

/* Foot */
rotate([0, 0, angle])
translate([foot_orientation == "infront" ? foot_depth - stand_thickness : 0, 0, 0])
translate([foot_orientation == "centered" ? (foot_depth - stand_thickness) / 2 : 0, 0, 0])
printable_rotation(width, height + depth - stand_thickness)
cube([width, foot_depth, stand_thickness]);
