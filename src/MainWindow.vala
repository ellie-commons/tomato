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

public class MainWindow : Gtk.ApplicationWindow {
    private const string COLOR_PRIMARY = """
        @define-color colorPrimary %s;
    """;

    private Gtk.Label countdown_label;
    private Gtk.Label total_time_label;

    private Gtk.Button start_button;
    private Gtk.Button resume_button;
    private Gtk.Button pause_button;
    private Gtk.Button stop_button;
    private Gtk.Button skip_button;

    private Gtk.Stack resume_pause_stack;
    private Gtk.Stack buttons_stack;

    private Gtk.Button appmenu;

    private int stop_countdown = 14;
    private bool paused = true;
    private bool stopped = true;

    private const uint TIME = 1000;
    private uint work_timeout_id = 0;
    private uint stop_timeout_id = 0;

    private Managers.WorkManager work;
    private Managers.NotificationManager notification;
    private Managers.LauncherManager launcher;

    private Services.SavedState saved { get; default = Services.SavedState.instance (); }
    private Services.Preferences preferences { get; default = Services.Preferences.instance (); }

    private Dialogs.PreferencesDialog pref_dialog;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            default_height: 250,
            default_width: 300,
            resizable: false,
            icon_name: "io.github.ellie_commons.tomato",
            title: "Tomato"
        );
    }

    static construct {
        weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
        default_theme.add_resource_path ("io/github/ellie_commons/tomato/");
    }

    construct {
        var headerbar = new Adw.HeaderBar () {
            decoration_layout = "close:"
        };

        appmenu = new Gtk.Button.from_icon_name ("open-menu-symbolic") {
            tooltip_text = _("Preferences")
        };
        appmenu.add_css_class (Granite.STYLE_CLASS_FLAT);
        appmenu.add_css_class ("menu");

        headerbar.pack_end (appmenu);

        countdown_label = new Gtk.Label (null);
        countdown_label.add_css_class ("countdown");

        total_time_label = new Gtk.Label (null) {
            margin_top = 12
        };
        total_time_label.add_css_class ("total-time");

        start_button = new Gtk.Button.with_label (_("Start")) {
            width_request = 125,
            halign = CENTER
        };
        start_button.add_css_class ("pomodoro-button");

        resume_button = new Gtk.Button.with_label (_("Resume"));
        resume_button.add_css_class ("pomodoro-button");

        pause_button = new Gtk.Button.with_label (_("Pause"));
        pause_button.add_css_class ("pomodoro-button");

        resume_pause_stack = new Gtk.Stack () {
            transition_type = CROSSFADE
        };

        resume_pause_stack.add_child (resume_button);
        resume_pause_stack.add_child (pause_button);

        stop_button = new Gtk.Button.with_label (_("Stop"));
        stop_button.add_css_class ("pomodoro-button");

        var action_buttons_box = new Gtk.Box (HORIZONTAL, 6) {
            homogeneous = true
        };
        action_buttons_box.append (resume_pause_stack);
        action_buttons_box.append (stop_button);

        skip_button = new Gtk.Button.with_label (_("Skip")) {
            width_request = 125,
            halign = CENTER
        };
        skip_button.add_css_class ("pomodoro-button");

        buttons_stack = new Gtk.Stack () {
            vexpand = true,
            valign = END,
            transition_type = CROSSFADE
        };
        buttons_stack.add_named (start_button, "start");
        buttons_stack.add_named (skip_button, "break");
        buttons_stack.add_named (action_buttons_box, "pomodoro");

        var container = new Gtk.Box (VERTICAL, 0) {
            vexpand = true,
            margin_top = 24,
            margin_end = 24,
            margin_bottom = 24,
            margin_start = 24
        };
        container.append (countdown_label);
        container.append (total_time_label);
        container.append (buttons_stack);

        var toolbar_view = new Adw.ToolbarView () {
            content = new Gtk.WindowHandle () {
                child = container
            }
        };
        toolbar_view.add_top_bar (headerbar);

        var null_title = new Gtk.Grid () {
            visible = false
        };
        set_titlebar (null_title);

        child = toolbar_view;
        add_css_class ("main-window");

        // Instantiating tomato managers
        work = new Managers.WorkManager ();
        notification = new Managers.NotificationManager ();
        launcher = new Managers.LauncherManager (work);

        update_progress ();
        next_status ();

        start_button.clicked.connect (on_start_clicked);
        pause_button.clicked.connect (on_pause_clicked);
        resume_button.clicked.connect (on_resume_clicked);
        stop_button.clicked.connect (on_stop_clicked);
        skip_button.clicked.connect (on_skip_clicked);

        var gesture_focus = new Gtk.EventControllerFocus ();
        ((Gtk.Widget) this).add_controller (gesture_focus);
        gesture_focus.enter.connect (() => {
            launcher.hide_progress ();
        });

        gesture_focus.leave.connect (() => {
            if (!paused) {
                launcher.show_progress ();
            }
        });

        appmenu.clicked.connect (() => {
            pref_dialog = new Dialogs.PreferencesDialog (this);
            pref_dialog.show ();

            connect_pref_signals ();
        });
    }

    private void update_style (string view) {
        string color_primary;

        switch (view) {
            case "start":
                color_primary = "#8ea5af";
                break;
            case "pomodoro":
                color_primary = "#df4b4b";
                break;
            case "break":
                color_primary = "#05B560";
                break;
            default:
                color_primary = "#8ea5af";
                break;
        }

        var provider = new Gtk.CssProvider ();

        try {
            var colored_css = COLOR_PRIMARY.printf (color_primary);
            provider.load_from_string (colored_css);
            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (), provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        } catch (GLib.Error e) {
            critical (e.message);
        }
    }

    private void on_start_clicked () {
        work.start ();
        next_status ();
        update_progress ();
        play ();
    }

    private void on_resume_clicked () {
        if (preferences.auto_stop && stop_timeout_id != 0 && !stopped) {
            finish_auto_stop ();
        }

        play ();
    }

    private void on_pause_clicked () {
        pause ();
        update_progress ();
        /* Show a notification when the app is paused for a long period */
        if (preferences.auto_stop && saved.status == Status.POMODORO) {
            message ("Auto stop countdown started");
            stop_timeout_id = Timeout.add (TIME, start_auto_stop);
        } else {
            stop_timeout_id = 0;
        }
    }

    private void on_stop_clicked () {
        stop ();
        work.stop ();
        work.reset_countdown ();
        next_status ();

        if (preferences.auto_stop && stop_timeout_id != 0 && stopped) {
            finish_auto_stop ();
        }
    }

    private void on_skip_clicked () {
        on_stop_clicked ();
    }

    private void play () {
        set_pause (false);

        if (work_timeout_id != 0) {
            Source.remove (work_timeout_id);
        }

        work_timeout_id = Timeout.add (TIME, update_time);
    }

    private void pause () {
        set_pause (true);
        launcher.hide_progress ();

        if (work_timeout_id != 0) {
            Source.remove (work_timeout_id);
            work_timeout_id = 0;
        }
    }

    private void stop () {
        stopped = true;
        pause ();
    }

    private void set_pause (bool topause = true) {
        paused = topause;
        if (!paused) {
            stopped = paused;
        }

        window_set_pause (topause);
    }

    private bool update_time () {
        var rand = new Rand ();
        if (!paused) {
            work.tick ();
            if (work.time_is_over ()) {
                break_messages_index = rand.int_range (0, break_messages.length);
                notification.show_status ();
                next_status ();
                if (preferences.pause_after_break && saved.status == Status.POMODORO) {
                    on_stop_clicked ();
                    return false;
                }
            }

            update_progress ();
        }

        return !paused;
    }

    public void next_status () {
        if (saved.status == Status.START) {
            buttons_stack.visible_child_name = "start";
            update_style ("start");
            title = "Pomodoro %d".printf (saved.pomodoro_count + 1);
            appmenu.sensitive = true;
        } else if (saved.status == Status.SHORT_BREAK) {
            buttons_stack.visible_child_name = "break";
            update_style ("break");
            title = _("Short Break");
            appmenu.sensitive = true;
        } else if (saved.status == Status.LONG_BREAK) {
            buttons_stack.visible_child_name = "break";
            update_style ("break");
            title = _("Long Break");
            appmenu.sensitive = true;
        } else {
            buttons_stack.visible_child_name = "pomodoro";
            update_style ("pomodoro");
            title = "Pomodoro %d".printf (saved.pomodoro_count + 1);
            appmenu.sensitive = false;
        }

        update_progress ();
    }

    public void update_progress () {
        update_countdown ();
        update_total_time ();
        launcher.update_progress ();
    }

    public void update_countdown () {
        countdown_label.label = work.formatted_countdown ();
    }

    public void update_total_time () {
        if ((saved.status == Status.START || saved.status == Status.SHORT_BREAK || saved.status == Status.LONG_BREAK || paused) && saved.total_time != 0) {
            total_time_label.label = work.formatted_total_time () + _(" of work");
        } else {
            total_time_label.label = "";
        }
    }

    private void window_set_pause (bool topause = true) {
        paused = topause;
        if (!paused) {
            stopped = paused;
        }

        if (topause) {
            resume_pause_stack.visible_child = resume_button;
            resume_button.grab_focus ();
        } else {
            resume_pause_stack.visible_child = pause_button;
            pause_button.grab_focus ();
        }
    }

    private bool start_auto_stop () {
        if (paused && !stopped) {
            update_stop (_("Stopping in ") + "%d".printf (stop_countdown));
            stop_countdown -= 1;
            if (stop_countdown == -1) {
                on_stop_clicked ();
                stop_countdown = 14;
                notification.show (_("Pomodoro was interrupted"), _("Tomato was paused for a long time. You might have lost focus. Try a new pomodoro!"));
            }
        }

        return paused;
    }

    private void finish_auto_stop () {
        Source.remove (stop_timeout_id);
        stop_timeout_id = 0;
        stop_countdown = 14;
        update_stop (_("Stop"));
        message ("Finished auto stop");
    }

    public void update_stop (string text) {
        stop_button.label = text;
    }

    private void connect_pref_signals () {
        /* Watch for change in settings*/
        pref_dialog.pomodoro_changed.connect (() => {
            if (saved.status == Status.START) {
                work.reset_countdown ();
                update_progress ();
            }
            pref_dialog.update_timing_sensitivity ();
            message ("Pomodoro scale changed");
        });

        pref_dialog.short_break_changed.connect (() => {
            pref_dialog.update_timing_sensitivity ();
            message ("Short break scale changed");
        });

        pref_dialog.long_break_changed.connect (() => {
            pref_dialog.update_timing_sensitivity ();
            message ("Long break scale changed");
        });

        pref_dialog.long_break_delay_changed.connect (() => {
            pref_dialog.update_timing_sensitivity ();
        });

        //watch for change in preferences
        preferences.schema.changed.connect (() => {
            pref_dialog.update_timing_sensitivity ();
            pref_dialog.update_work_sensitivity ();
        });

        //watch for reset action
        pref_dialog.reset_work_clicked.connect (() => {
            work.reset ();
            on_stop_clicked ();
            pref_dialog.update_work_sensitivity ();
        });
    }
}
