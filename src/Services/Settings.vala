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

public class Services.Settings : GLib.Object {
    int _pomodoro_duration;
    public int pomodoro_duration {
        get {
            _pomodoro_duration = schema.get_int ("pomodoro-duration");
            return _pomodoro_duration;
        }

        set {
            schema.set_int ("pomodoro-duration", value);
        }
    }

    int _short_break_duration;
    public int short_break_duration {
        get {
            _short_break_duration = schema.get_int ("short-break-duration");
            return _short_break_duration;
        }

        set {
            schema.set_int ("short-break-duration", value);
        }
    }

    int _long_break_duration;
    public int long_break_duration {
        get {
            _long_break_duration = schema.get_int ("long-break-duration");
            return _long_break_duration;
        }

        set {
            schema.set_int ("long-break-duration", value);
        }
    }

    int _long_break_delay;
    public int long_break_delay {
        get {
            _long_break_delay = schema.get_int ("long-break-delay");
            return _long_break_delay;
        }

        set {
            schema.set_int ("long-break-delay", value);
        }
    }

    static GLib.Once<Services.Settings> _instance;
    public static unowned Services.Settings instance () {
        return _instance.once (() => {
            return new Services.Settings ();
        });
    }

    public GLib.Settings schema;

    construct {
        schema = new GLib.Settings ("io.github.ellie_commons.tomato.settings");
    }
}
