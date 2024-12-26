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

public class Services.Preferences : GLib.Object {
	bool _reset_work_everyday;
	public bool reset_work_everyday {
		get {
			_reset_work_everyday = schema.get_boolean ("reset-work-everyday");
			return _reset_work_everyday;
		}

		set {
			schema.set_boolean ("reset-work-everyday", value);
		}
	}

	bool _pause_after_break;
	public bool pause_after_break {
		get {
			_pause_after_break = schema.get_boolean ("pause-after-break");
			return _pause_after_break;
		}

		set {
			schema.set_boolean ("pause-after-break", value);
		}
	}

	bool _auto_stop;
	public bool auto_stop {
		get {
			_auto_stop = schema.get_boolean ("auto-stop");
			return _auto_stop;
		}

		set {
			schema.set_boolean ("auto-stop", value);
		}
	}

	bool _pomodoro_sound_enabled;
	public bool pomodoro_sound_enabled {
		get {
			_pomodoro_sound_enabled = schema.get_boolean ("pomodoro-sound-enabled");
			return _pomodoro_sound_enabled;
		}

		set {
			schema.set_boolean ("pomodoro-sound-enabled", value);
		}
	}

	bool _notifications_blocked;
	public bool notifications_blocked {
		get {
			_notifications_blocked = schema.get_boolean ("notifications-blocked");
			return _notifications_blocked;
		}

		set {
			schema.set_boolean ("notifications-blocked", value);
		}
	}

	bool _debug_mode;
	public bool debug_mode {
		get {
			_debug_mode = schema.get_boolean ("debug-mode");
			return _debug_mode;
		}

		set {
			schema.set_boolean ("debug-mode", value);
		}
	}

	static GLib.Once<Services.Preferences> _instance;
	public static unowned Services.Preferences instance () {
		return _instance.once (() => {
			return new Services.Preferences ();
		});
	}

	public GLib.Settings schema;

	construct {
		schema = new GLib.Settings ("io.github.ellie_commons.tomato.preferences");
	}
}
