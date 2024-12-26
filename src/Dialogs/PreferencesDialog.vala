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

public class Dialogs.PreferencesDialog : Granite.Dialog {

	//stacks
	private Gtk.Stack stack;
	private Gtk.StackSwitcher stackswitcher;

	//options - scales
	private Widgets.ValueRange pomodoro_scale;
	private Widgets.ValueRange short_break_scale;
	private Widgets.ValueRange long_break_scale;
	private Widgets.ValueRange long_break_delay_scale;

	//options - switches
	private Gtk.Switch reset_work_everyday;
	private Gtk.Switch pause_after_break;
	private Gtk.Switch auto_stop_enabled;
	private Gtk.Switch pomodoro_sound_enabled;
	private Gtk.Switch debug_switch;

	//options - button
	private Gtk.Button reset_timings;
	private Gtk.Button reset_work;

	//signals
	public signal void reset_work_clicked ();
	public signal void pomodoro_changed ();
	public signal void short_break_changed ();
	public signal void long_break_changed ();
	public signal void long_break_delay_changed ();

	Services.Preferences preferences { get; default = Services.Preferences.instance (); }
	Services.Settings settings { get; default = Services.Settings.instance (); }
	Services.SavedState saved { get; default = Services.SavedState.instance (); }

	public PreferencesDialog (Gtk.Window? parent) {
		Object (
			transient_for: parent,
			title: _("Preferences"),
			resizable: false,
			modal: true,
			deletable: false
		);
	}

	construct {
		stack = new Gtk.Stack ();
		stackswitcher = new Gtk.StackSwitcher ();

		stackswitcher.set_stack (stack);
		stackswitcher.set_halign (Gtk.Align.CENTER);

		bind_and_init_options ();
		create_ui ();
		update_timing_sensitivity ();
		update_work_sensitivity ();
		connect_signals ();
	}

	private void bind_and_init_options () {
		/* ** options - scales ** */
		//pomodoro_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 5, 60, 1);
		pomodoro_scale = new Widgets.ValueRange (5, 60, 1, _("minute"), _("minutes"));
		settings.schema.bind ("pomodoro-duration", pomodoro_scale, "current-value", SettingsBindFlags.DEFAULT);

		short_break_scale = new Widgets.ValueRange (1, 10, 1, _("minute"), _("minutes"));
		settings.schema.bind ("short-break-duration", short_break_scale, "current-value", SettingsBindFlags.DEFAULT);

		long_break_scale = new Widgets.ValueRange (10, 30, 1, _("minute"), _("minutes"));
		settings.schema.bind ("long-break-duration", long_break_scale, "current-value", SettingsBindFlags.DEFAULT);

		long_break_delay_scale = new Widgets.ValueRange (2, 8, 1, _("pomodoro"), _("pomodoros"));
		settings.schema.bind ("long-break-delay", long_break_delay_scale, "current-value", SettingsBindFlags.DEFAULT);

		/* ** options - switches ** */
		reset_work_everyday = new Gtk.Switch ();
		preferences.schema.bind ("reset-work-everyday", reset_work_everyday, "active", SettingsBindFlags.DEFAULT);

		pause_after_break = new Gtk.Switch ();
		preferences.schema.bind ("pause-after-break", pause_after_break, "active", SettingsBindFlags.DEFAULT);

		auto_stop_enabled = new Gtk.Switch ();
		preferences.schema.bind ("auto-stop", auto_stop_enabled, "active", SettingsBindFlags.DEFAULT);

		pomodoro_sound_enabled = new Gtk.Switch ();
		preferences.schema.bind ("pomodoro-sound-enabled", pomodoro_sound_enabled, "active", SettingsBindFlags.DEFAULT);

		if (preferences.debug_mode) {
			pomodoro_scale = new Widgets.ValueRange (1, 60, 1, _("minute"), _("minutes"));
			settings.schema.bind ("pomodoro-duration", pomodoro_scale, "current-value", SettingsBindFlags.DEFAULT);

			long_break_scale = new Widgets.ValueRange (2, 30, 1, _("minute"), _("minutes"));
			settings.schema.bind ("long-break-duration", long_break_scale, "current-value", SettingsBindFlags.DEFAULT);

			debug_switch = new Gtk.Switch ();
			preferences.schema.bind ("debug-mode", debug_switch, "active", SettingsBindFlags.DEFAULT);
		}

		/* ** options - buttons ** */
		reset_timings = new Gtk.Button.with_label (_("Default Settings"));
		reset_work = new Gtk.Button.with_label (_("Reset Work"));
	}

	private void create_ui () {

		stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
		//create timing tab

		stack.add_titled (get_timing_box (), "timing", _("Timing"));

		//create misc tab

		stack.add_titled (get_misc_box (), "misc", _("Preferences"));

		//creat future tabs here

		//close button
		var close_button = new Gtk.Button.with_label (_("Close"));
		close_button.clicked.connect (() => {
			destroy ();
		});

		//button box
		var button_box = new Gtk.Box (HORIZONTAL, 0) {
			hexpand = true,
			halign = END,
			margin_end = 12
		};
		button_box.append (close_button);

		//puts everything into a grid
		var main_grid = new Gtk.Grid ();
		main_grid.attach (stackswitcher, 0, 0, 1, 1);
		main_grid.attach (
			stack, 0, 1, 1, 1);
		main_grid.attach (button_box, 0, 2, 1, 1);

		//add the grid to the dialog
		get_content_area ().append (main_grid);
	}

	private Gtk.Widget get_timing_box () {
		//setup the grid for the timing Box
		var grid = make_grid ();
		var row = 0;

		//pomodoro Scale
		var label = new Gtk.Label (_("Pomodoro duration:"));
		add_option (grid, label, pomodoro_scale, ref row);

		//short break scale
		label = new Gtk.Label (_("Short break duration:"));
		add_option (grid, label, short_break_scale, ref row);

		//long break scale
		label = new Gtk.Label (_("Long break duration:"));
		add_option (grid, label, long_break_scale, ref row);

		//long break delay scale
		label = new Gtk.Label (_("Long break delay:"));
		add_option (grid, label, long_break_delay_scale, ref row);

		//reset buttons
		var reset_grid = new Gtk.Box (HORIZONTAL, 6);
		reset_grid.append (reset_timings);
		reset_grid.append (reset_work);
		label = new Gtk.Label (_("Reset:"));
		add_option (grid, label, reset_grid, ref row, 15);

		return grid;
	}

	private Gtk.Widget get_misc_box () {
		//setup the grid for the timing Box
		var grid = make_grid ();

		var row = 0;

		add_section (grid, new Granite.HeaderLabel (_("Behavior:")), ref row);

		var label = new Gtk.Label (_("Reset work everyday:"));
		add_option (grid, label, reset_work_everyday, ref row);

		label = new Gtk.Label (_("Start new pomodoro manually:"));
		add_option (grid, label, pause_after_break, ref row);

		label = new Gtk.Label (_("Auto stop:"));
		add_option (grid, label, auto_stop_enabled, ref row);

		add_section (grid, new Granite.HeaderLabel (_("Sound:")), ref row);

		label = new Gtk.Label (_("Pomodoro sound:"));
		add_option (grid, label, pomodoro_sound_enabled, ref row);

		if (preferences.debug_mode) {
			add_section (grid, new Granite.HeaderLabel (_("Extras:")), ref row);
			add_option (grid, new Granite.HeaderLabel (_("Debug mode")), debug_switch, ref row);
		}

		return grid;
	}

	private void reset_scales () {
		pomodoro_scale.current_value = Default.POMODORO_DURATION;
		short_break_scale.current_value = Default.SHORT_BREAK_DURATION;
		long_break_scale.current_value = Default.LONG_BREAK_DURATION;
		long_break_delay_scale.current_value = Default.LONG_BREAK_DELAY;
	}

	public void update_timing_sensitivity () {
		var sensitive = false;
		if (pomodoro_scale.current_value != Default.POMODORO_DURATION) {
			sensitive = true;
		} else if (short_break_scale.current_value != Default.SHORT_BREAK_DURATION) {
			sensitive = true;
		} else if (long_break_scale.current_value != Default.LONG_BREAK_DURATION) {
			sensitive = true;
		} else if (long_break_delay_scale.current_value != Default.LONG_BREAK_DELAY)  {
			sensitive = true;
		}

		reset_timings.sensitive = sensitive;
	}

	public void update_work_sensitivity () {
		var sensitive = false;
		if (saved.pomodoro_count != 0) {
			sensitive = true;
		} else if (saved.total_time != 0) {
			sensitive = true;
		} else if (saved.status != Status.START) {
			sensitive = true;
		}
		reset_work.sensitive = sensitive;
	}

	private void add_section (Gtk.Grid grid, Gtk.Widget name, ref int row) {
		grid.attach (name, 0, row, 1, 1);
		row++;
	}

	private void add_option (Gtk.Grid grid, Gtk.Widget label, Gtk.Widget switcher, ref int row, int margin_top = 0) {
		label.halign = END;

		if (switcher is Widgets.ValueRange) {
			label.margin_top = 12;
			label.halign = END;
		}

		grid.attach (label, 0, row, 1, 1);
		grid.attach_next_to (switcher, label, Gtk.PositionType.RIGHT, 3, 1);

		row++;
	}

	private Gtk.Grid make_grid () {
		var grid = new Gtk.Grid () {
			row_spacing = 6,
			column_spacing = 12,
			margin_start = 12,
			margin_end = 12,
			margin_top = 12,
			margin_bottom = 12
		};

		return grid;
	}

	private void connect_signals () {
		pomodoro_scale.changed.connect (() => {
			pomodoro_changed ();
		});

		short_break_scale.changed.connect (() => {
			short_break_changed ();
		});

		long_break_scale.changed.connect (() => {
			long_break_changed ();
		});

		long_break_delay_scale.changed.connect (() => {
			long_break_delay_changed ();
		});

		reset_timings.clicked.connect (reset_scales);

		reset_work.clicked.connect (() => {
			reset_work_clicked ();
		});

	}
}
