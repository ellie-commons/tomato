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

public class Managers.LauncherManager : GLib.Object {
    public Managers.WorkManager work { get; construct; }

    private Services.SavedState saved;
    private Services.Settings settings;

    public LauncherManager (Managers.WorkManager work) {
        Object (work: work);
    }

    construct {
        saved = Services.SavedState.instance ();
        settings = Services.Settings.instance ();

        update_progress ();
    }

    public void update_progress () {
        double duration;
        if (saved.status == Status.SHORT_BREAK) {
            duration = settings.short_break_duration * 60.0;
        } else if (saved.status == Status.LONG_BREAK) {
            duration = settings.long_break_duration * 60.0;
        } else {
            duration = settings.pomodoro_duration * 60.0;
        }

        Granite.Services.Application.set_progress.begin (1 - work.raw_countdown () / duration, (obj, res) => {
            try {
                Granite.Services.Application.set_progress.end (res);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        });
    }

    public void show_progress () {
        Granite.Services.Application.set_progress_visible.begin (true, (obj, res) => {
            try {
                Granite.Services.Application.set_progress_visible.end (res);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        });
    }

    public void hide_progress () {
        Granite.Services.Application.set_progress_visible.begin (false, (obj, res) => {
            try {
                Granite.Services.Application.set_progress_visible.end (res);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        });
    }
}
