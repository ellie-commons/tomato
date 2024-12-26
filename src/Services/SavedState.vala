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

public class Services.SavedState : GLib.Object {
	string _date;
	public string date {
		get {
			_date = schema.get_string ("date");
			return _date;
		}

		set {
			schema.set_string ("date", value);
		}
	}

	Status _status;
	public Status status {
		get {
			_status = (Status) schema.get_enum ("status");
			return _status;
		}

		set {
			schema.set_enum ("status", value);
		}
	}

	int _countdown;
	public int countdown {
		get {
			_countdown = schema.get_int ("countdown");
			return _countdown;
		}

		set {
			schema.set_int ("countdown", value);
		}
	}

	int _total_time;
	public int total_time {
		get {
			_total_time = schema.get_int ("total-time");
			return _total_time;
		}

		set {
			schema.set_int ("total-time", value);
		}
	}

	int _pomodoro_count;
	public int pomodoro_count {
		get {
			_pomodoro_count = schema.get_int ("pomodoro-count");
			return _pomodoro_count;
		}

		set {
			schema.set_int ("pomodoro-count", value);
		}
	}

	public bool is_date_today () {
		var dt = new DateTime.now_local ();
		return date == dt.format ("%Y-%m-%d");
	}

	public void update_date () {
		date = (new DateTime.now_local ()).format ("%Y-%m-%d");
	}

	static GLib.Once<Services.SavedState> _instance;
	public static unowned Services.SavedState instance () {
		return _instance.once (() => {
			return new Services.SavedState ();
		});
	}

	public GLib.Settings schema;

	construct {
		schema = new GLib.Settings ("io.github.ellie_commons.tomato.saved");
	}
}
