/* Copyright 2015 LuizAugustoMorais
* Copyright 2024 elementary Commons
*
* This file is part of Tomato.
*
* Tomato is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Tomato is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* This project was originally created by LuizAugustoMorais
* and is now maintained by elementary Commons.
*
* You should have received a copy of the GNU General Public License along
* with Tomato. If not, see http://www.gnu.org/licenses/.
*/

public class Widgets.ValueRange : Adw.Bin {
    public signal void changed ();

    //scale object
    private Gtk.Scale scale;

    //current value getter and setter methods
    public int current_value {
        get {
            return (int) scale.get_value ();
        }

        set {
            scale.set_value (value);
        }
    }

    //constructor
    public ValueRange (double min, double max, double step, string? display = null, string? plural = null) {
        //init scale and add it to this
        scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, min, max, step) {
            hexpand = true,
            draw_value = true
        };

        child = scale;

        //set optional display string
        if (display != null) {
            scale.set_format_value_func ((scale, val) => {
                if (val == 1) {
                    return "%.0f %s".printf (val, display);
                }
                if (plural != null) {
                    return "%.0f %s".printf (val, plural);
                }
                return "%.0f".printf (val);
            });
        }

        //connect signals so that the scale updates its value on move
        scale.value_changed.connect (() => {
            current_value = current_value;
            changed ();
        });
    }
}