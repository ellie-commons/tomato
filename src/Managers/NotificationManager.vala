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

public class Managers.NotificationManager {
	private SoundManager sound;
	private Services.SavedState saved;
	private Services.Preferences preferences;

	public NotificationManager () {
		sound = new SoundManager ();
		saved = Services.SavedState.instance ();
		preferences = Services.Preferences.instance ();
	}

	public void show_status () {
		string title, body;
		if (saved.status == Status.POMODORO) {
			title = _("Pomodoro Time");
			body = _("Get back to work!");
		} else if (saved.status == Status.SHORT_BREAK) {
			title = _("Short Break");
			body = _(break_messages[break_messages_index]);
		} else {
			title = _("Long Break!");
			body = _(break_messages[break_messages_index]);
		}
		if (preferences.pomodoro_sound_enabled) {
			sound.play ();
		}

		show (title, body);
	}

	public void show (string title, string body) {
		var notification = new GLib.Notification (title);
		notification.set_body (body);
		notification.set_icon (new ThemedIcon ("io.github.ellie_commons.tomato"));
		GLib.Application.get_default ().send_notification ("com.github.tomatoers.tomato", notification);
	}
}
