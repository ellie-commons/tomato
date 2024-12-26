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

public enum Status {
    START,
    POMODORO,
    SHORT_BREAK,
    LONG_BREAK
}

private int break_messages_index = 0;
private const string[] break_messages = { // vala-lint=naming-convention
    N_("Go have a coffee"),
    N_("Drink some water"),
    N_("Get up and dance!"),
    N_("Have a break, have a tomato"),
    N_("Get up! Stand up! Fight for your fingers!"),
    N_("Take a break, save a life"),
    N_("Woot! Break time, baby!"),
    N_("It's coffee time!"),
    N_("What about a beer?"),
    N_("Take a walk outside"),
    N_("Step away from the machine!")
};
